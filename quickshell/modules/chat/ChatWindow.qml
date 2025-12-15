import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import extensions.build

FloatingWindow {
  id: window
  width: 1200
  height: 800
  title: "Qt Chat"

  AiPlugin {
    id: aiPlugin
  }

  property string homeDir: Quickshell.env("HOME")
  property string chatDirectory: homeDir + "/.config/lungan"
  property string historyDirectory: homeDir + "/.local/share/nvim/lungan"

  property string currentFilePath: ""
  property var currentSettings: ({})

  Component.onCompleted: {
    try {
      window.x = (Screen.width - window.width) / 2
      window.y = (Screen.height - window.height) / 2
    } catch (e) {
      console.log("Warning: Could not center window via QML")
    }

    console.log("ChatWindow: Initializing...")
    refreshFileList()
    refreshHistoryList()
  }

  // -------------------------------------------------------------------------
  // FILE PROCESSES
  // -------------------------------------------------------------------------

  Process {
    id: listChatFiles
    command: ["ls", "-1", "--color=never", chatDirectory]

    stdout: SplitParser {
      onRead: data => {
        if (data.trim() !== "") fileSelectorModel.append({ text: data.trim() })
      }
    }

    stderr: SplitParser {
      onRead: data => console.log("LS Error (Chat): " + data)
    }

    onExited: exitCode => {
      if (exitCode === 0 && fileSelectorModel.count > 0) {
        fileSelector.currentIndex = 0
        var firstFile = fileSelectorModel.get(0).text
        console.log("Auto-loading first file: " + firstFile)
        loadContentFromPath(chatDirectory + "/" + firstFile)
      } else if (exitCode !== 0) {
        console.log("CRITICAL: Could not list chat files. Does the folder exist?")
      }
    }
  }

  // History Files Lister
  Process {
    id: listHistoryFiles
    command: ["ls", "-1", "--color=never", historyDirectory]

    stdout: SplitParser {
      onRead: data => {
        if (data.trim() !== "") historyListModel.append({ text: data.trim() })
      }
    }

    stderr: SplitParser {
      onRead: data => console.log("LS Error (History): " + data)
    }
  }

  // Active File Reader
  FileView {
    id: activeFileReader
    path: window.currentFilePath
    onPathChanged: reload()
    onLoaded: {
      if (window.currentFilePath !== "") {
        parseChatContent(text())
      }
    }

    onLoadFailed: {
      console.log("Failed to load chat file: " + window.currentFilePath)
    }
  }
  ListModel { id: fileSelectorModel }
  ListModel { id: historyListModel }
  ListModel { id: chatModel }

  // -------------------------------------------------------------------------
  // LOGIC
  // -------------------------------------------------------------------------

  function refreshFileList() {
    console.log("Refreshing Chat List...")
    fileSelectorModel.clear()
    listChatFiles.running = true
  }

  function refreshHistoryList() {
    historyListModel.clear()
    listHistoryFiles.running = true
  }

  function loadContentFromPath(fullPath) {
    console.log("Loading path: " + fullPath);
    currentFilePath = fullPath;
  }

  function parseChatContent(fileContent) {
    chatModel.clear();
    currentSettings = {};

    if (!fileContent) {
      console.log("Chat file is empty or undefined.");
      return;
    }

    // Call C++ Plugin
    var result = aiPlugin.parseChat(fileContent);

    if (result && result.yaml) {
      currentSettings = result.yaml;
    }

    var systemPrompt = (result.yaml && result.yaml.system_prompt) ? result.yaml.system_prompt : "You are a helpful assistant.";
    var messagesPayload = [{ role: "system", content: systemPrompt }];

    for (var i = 0; i < result.messages.count; i++) {
      var item = result.messages.get(i);
      messagesPayload.push({ role: item.role, content: item.content });
      chatModel.append({ role: item.role, content: item.content });
    }

    var data = {
      model: (result.yaml && result.yaml.provider) ? result.yaml.provider.model : "default",
      messages: messagesPayload,
      streaming: (result.yaml && result.yaml.streaming) ? true : false
    };

    if (result.yaml && result.yaml.options) {
      var keys = Object.keys(result.yaml.options);
      for(var k = 0; k < keys.length; k++) {
        var key = keys[k];
        if (key === "provider") continue; // 'continue', not 'next'
        console.log("process key: " + key)
        data[key] = result.yaml.options[key];
      }
    }

    // console.log("LLM Request (Preview): " + JSON.stringify(data));
    Qt.callLater(function() { 
      if (chatListView) chatListView.positionViewAtEnd(); 
    });
  }

  function sendMessage() {
    var text = messageInput.text.trim();
    if (text === "") return;

    chatModel.append({ role: "user", content: text });

    var newEntry = "\n\n<== user\n" + text + "\n==>\n";
    var appendCmd = ["/usr/bin/bash", "-c", "printf '%s' \"$0\" >> \"$1\"", newEntry, currentFilePath];
    Quickshell.execDetached(appendCmd) 

    messageInput.text = "";
    Qt.callLater(function() { chatListView.positionViewAtEnd(); });

    var systemPrompt = currentSettings.system_prompt || "You are a helpful assistant.";
    var messagesPayload = [{ role: "system", content: systemPrompt }];

    for (var i = 0; i < chatModel.count; i++) {
      var item = chatModel.get(i);
      messagesPayload.push({ role: item.role, content: item.content });
    }

    var data = {
      model: currentSettings.provider ? currentSettings.provider.model : "default",
      messages: messagesPayload,
      streaming: currentSettings.streaming ? true : false
    };

    if (currentSettings.options) {
      var keys = Object.keys(currentSettings.options);
      for(var k = 0; k < keys.length; k++) {
        data[keys[k]] = currentSettings.options[keys[k]];
      }
    }

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          try {
            var jsObject = JSON.parse(xhr.responseText);
            if (jsObject["choices"]) {
              for(var c of jsObject["choices"]) {
                var botContent = c["message"]["content"];
                chatModel.append({ role: "assistant", content: botContent });
                var botEntry = "\n\n<== assistant\n" + botContent + "\n==>\n";
                var botAppendCmd = ["/usr/bin/bash", "-c", "printf '%s' \"$0\" >> \"$1\"", botEntry, currentFilePath];
                Quickshell.execDetached(botAppendCmd);
              }
            }
            Qt.callLater(function() { chatListView.positionViewAtEnd(); });
          } catch (e) { console.log("JSON Parse Error: " + e.message); }
        } else {
          console.log("LLM Error: " + xhr.status + " " + xhr.responseText);
        }
      }
    }

    xhr.open("POST", "http://localhost:8080/v1/chat/completions");
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    console.log("chat request: " + JSON.stringify(data));
    xhr.send(JSON.stringify(data));
  }

  // -------------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------------

  RowLayout {
    anchors.fill: parent
    spacing: 0

    // Side Navigation Bar
    Rectangle {
      id: sideNavBar
      Layout.preferredWidth: 260
      Layout.fillHeight: true
      color: "#171717"

      ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10
        anchors.topMargin: 20

        Button {
          text: "New chat"
          icon.source: "root:/icons/send.svg" 
          Layout.fillWidth: true
          background: Rectangle {
            color: parent.hovered ? "#333" : "transparent"
            border.color: "#444"
            radius: 4
          }
        }

        Label {
          text: "History"
          font.pixelSize: 12
          color: "#888"
          topPadding: 10
        }

        ListView {
          id: historyListView
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          model: historyListModel 

          delegate: ItemDelegate {
            width: parent.width
            background: Rectangle { 
              color: parent.hovered ? "#333" : "transparent" 
              radius: 4
            }
            contentItem: Text {
              text: model.text 
              color: "#ccc"
              font.pixelSize: 14
              elide: Text.ElideRight
              verticalAlignment: Text.AlignVCenter
              leftPadding: 10
            }
            onClicked: loadContentFromPath(historyDirectory + "/" + model.text)
          }
        }
      }
    }

    // Main Chat Area
    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      color: "#212121"

      ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 50
          color: "transparent"

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 15

            Label {
              text: "Active Chat:"
              font.bold: true
              font.pixelSize: 15
              color: "#E0E0E0"
            }

            ComboBox {
              id: fileSelector
              Layout.preferredWidth: 250
              Layout.preferredHeight: 32
              flat: true
              model: fileSelectorModel
              textRole: "text"

              background: Rectangle {
                color: parent.hovered ? "#333" : "transparent"
                radius: 4
                border.color: "#444"
                border.width: 1
              }
              contentItem: Text {
                text: parent.displayText
                color: "#ccc"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
                leftPadding: 10
                elide: Text.ElideRight
              }

              onActivated: (index) => {
                loadContentFromPath(chatDirectory + "/" + currentValue);
              }
            }
            Item { Layout.fillWidth: true }
            Button {
              text: "📝"
              flat: true
              Layout.preferredWidth: 40
              background: Rectangle { color: parent.hovered ? "#333" : "transparent"; radius: 4 }
            }
          }
          Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#333" }
        }

        ListView {
          id: chatListView
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          model: chatModel
          spacing: 15
          topMargin: 20; bottomMargin: 20; leftMargin: 20; rightMargin: 20

          delegate: Column {
            width: chatListView.width - 40
            spacing: 5
            anchors.right: role === "user" ? parent.right : undefined
            anchors.left: role !== "user" ? parent.left : undefined

            Label {
              text: role
              color: "#888888"
              font.pixelSize: 11
              anchors.right: role === "user" ? parent.right : undefined
              anchors.left: role !== "user" ? parent.left : undefined
            }
            Rectangle {
              width: Math.min(msgTxt.implicitWidth + 24, parent.parent.width * 0.8)
              height: msgTxt.implicitHeight + 24
              radius: 12
              color: role === "user" ? "#3E3E3E" : "transparent"

              anchors.right: role === "user" ? parent.right : undefined
              anchors.left: role !== "user" ? parent.left : undefined

              Text {
                id: msgTxt
                text: content
                color: "#E0E0E0"
                font.pixelSize: 16
                textFormat: Text.MarkdownText
                wrapMode: Text.Wrap
                width: Math.min(implicitWidth, parent.parent.parent.width * 0.8 - 24)
                anchors.centerIn: parent
              }
            }
          }
        }

        // Input Field
        Rectangle {
          Layout.preferredHeight: 80
          Layout.fillWidth: true
          color: "transparent" 

          RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            TextField {
              id: messageInput
              Layout.fillWidth: true
              Layout.preferredHeight: 50
              placeholderText: "Message..."
              color: "white"
              font.pixelSize: 15
              leftPadding: 15
              background: Rectangle {
                radius: 25
                color: "#2F2F2F"
                border.color: parent.activeFocus ? "#555" : "#333"
                border.width: 1
              }
              onAccepted: sendMessage()
            }

            Button {
              icon.source: "root:/icons/send.svg"
              Layout.preferredHeight: 40
              Layout.preferredWidth: 40
              flat: true
              background: Rectangle { radius: 20; color: parent.hovered ? "#444" : "#2F2F2F" }
              onClicked: sendMessage()
            }
          }
        }
      }
    }
  }
}
