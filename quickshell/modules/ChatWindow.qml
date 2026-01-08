import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import extensions.build
import qs.config

FloatingWindow {
    id: window

    property string chatDirectory: Config.chat.chatDirectory
    property string historyDirectory: Config.chat.historyDirectory
    property string currentFilePath: ""
    property var currentSettings: ({
    })

    function refreshFileList() {
        fileSelectorModel.clear();
        listChatFiles.running = true;
    }

    function refreshHistoryList() {
        historyListModel.clear();
        listHistoryFiles.running = true;
    }

    function deleteHistoryFile(fileName) {
        deleteHistoryProcess.command = ["rm", historyDirectory + "/" + fileName];
        deleteHistoryProcess.running = true;
    }

    function loadTemplate(fileName) {
        currentFilePath = "";
        readTemplateProcess.command = ["cat", chatDirectory + "/" + fileName];
        readTemplateProcess.running = true;
    }

    function loadHistory(fileName) {
        currentFilePath = historyDirectory + "/" + fileName;
    }

    function createNewChat() {
        currentFilePath = "";
        chatModel.clear();
        currentSettings = {
        };
    }

    function saveChatHistory() {
        if (currentFilePath === "")
            return ;

        var messagesList = [];
        for (var i = 0; i < chatModel.count; i++) {
            var item = chatModel.get(i);
            // Skip empty assistant messages (streaming placeholders)
            if (item.role === "assistant" && item.content === "")
                continue;

            messagesList.push({
                "role": item.role,
                "content": item.content
            });
        }
        aiPlugin.createChatFile(currentFilePath, currentSettings, messagesList);
    }

    function parseChatContent(fileContent) {
        chatModel.clear();
        currentSettings = {
        };
        if (!fileContent)
            return ;

        var result = aiPlugin.parseChat(fileContent);
        if (result && result.yaml)
            currentSettings = result.yaml;

        var messagesList = result.messages || [];
        for (var i = 0; i < messagesList.length; i++) {
            var item = messagesList[i];
            chatModel.append({
                "role": item.role,
                "content": item.content
            });
        }
        Qt.callLater(function() {
            if (chatListView)
                chatListView.positionViewAtEnd();

        });
    }

    function sendMessage() {
        var text = messageInput.text.trim();
        if (text === "")
            return ;

        // Update UI
        chatModel.append({
            "role": "user",
            "content": text
        });
        messageInput.text = "";
        chatModel.append({
            "role": "assistant",
            "content": ""
        });
        Qt.callLater(function() {
            chatListView.positionViewAtEnd();
        });
        if (currentFilePath === "") {
            var timestamp = Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss");
            var safeName = (currentSettings.name || "chat").replace(/[^a-z0-9\-_]/gi, '_');
            var filename = safeName + "_" + timestamp + ".md";
            currentFilePath = historyDirectory + "/" + filename;
            var messagesList = [];
            for (var i = 0; i < chatModel.count - 1; i++) {
                var item = chatModel.get(i);
                messagesList.push({
                    "role": item.role,
                    "content": item.content
                });
            }
            // Call C++ to create file with YAML header
            if (aiPlugin.createChatFile(currentFilePath, currentSettings, messagesList))
                historyRefreshTimer.start();
            else
                console.log("Error creating chat file.");
        } else {
            aiPlugin.appendMessage(currentFilePath, "user", text);
        }
        // Prepare conversation list for C++ (exclude the empty placeholder at end)
        var conversation = [];
        for (var i = 0; i < chatModel.count - 1; i++) {
            var item = chatModel.get(i);
            conversation.push({
                "role": item.role,
                "content": item.content
            });
        }
        // Ensure settings has streaming enabled
        var settings = currentSettings || {
        };
        settings["stream"] = true;
        // Generate JSON string using C++ plugin
        var jsonBody = aiPlugin.createChatPayload(settings, conversation);
        var endpoint = settings["endpoint"] || Config.chat.defaultEndpoint;
        var apiKey = settings["api_key"] || "";
        console.log("LLM Streaming Request to: " + endpoint + ", content: " + jsonBody);
        // Trigger C++ Network Request
        aiPlugin.sendChatRequest(endpoint, jsonBody, apiKey);
    }

    // Triggered from the context menu to re-send a specific historical message
    function sendMessageFromIndex(idx) {
        var text = chatModel.get(idx).content;
        // Add assistant placeholder
        chatModel.append({
            "role": "assistant",
            "content": ""
        });
        chatListView.positionViewAtEnd();
        var conversation = [];
        // Only send up to the current message
        for (var i = 0; i <= idx; i++) {
            var item = chatModel.get(i);
            conversation.push({
                "role": item.role,
                "content": item.content
            });
        }
        var settings = currentSettings || {
        };
        settings["stream"] = true;
        var jsonBody = aiPlugin.createChatPayload(settings, conversation);
        var endpoint = settings["endpoint"] || Config.chat.defaultEndpoint;
        var apiKey = settings["api_key"] || "";
        console.log("LLM request: " + jsonBody);
        aiPlugin.sendChatRequest(endpoint, jsonBody, apiKey);
    }

    implicitWidth: Config.theme.chatWidth
    implicitHeight: Config.theme.chatHeight
    title: "LLM Chat"
    Component.onCompleted: {
        try {
            window.x = (Screen.width - window.width) / 2;
            window.y = (Screen.height - window.height) / 2;
        } catch (e) {
            console.log("Warning: Could not center window via QML");
        }
        refreshFileList();
        refreshHistoryList();
    }

    AiPlugin {
        id: aiPlugin

        // --- Streaming Handlers ---
        onStreamReceived: (content) => {
            if (!content || content.length === 0)
                return ;

            console.log("LLM reponse: " + JSON.stringify(content));
            // Find the last message (Assistant's placeholder)
            if (chatModel.count > 0) {
                var lastIndex = chatModel.count - 1;
                var lastItem = chatModel.get(lastIndex);
                // Only append to assistant messages
                if (lastItem.role === "assistant") {
                    var newContent = lastItem.content + content;
                    chatModel.setProperty(lastIndex, "content", newContent);
                    // Auto-scroll
                    chatListView.positionViewAtEnd();
                }
            }
        }
        onStreamFinished: {
            console.log("Stream finished.");
            // Save the full response to file
            if (chatModel.count > 0) {
                var lastItem = chatModel.get(chatModel.count - 1);
                if (lastItem.role === "assistant" && currentFilePath !== "")
                    aiPlugin.appendMessage(currentFilePath, "assistant", lastItem.content);

            }
        }
        onStreamError: (error) => {
            console.log("Stream Error: " + error);
            chatModel.append({
                "role": "assistant",
                "content": "⚠️ Error: " + error
            });
        }
    }

    Process {
        id: listChatFiles

        command: ["ls", "-1", "--color=never", chatDirectory]
        onExited: (exitCode) => {
            if (exitCode === 0 && fileSelectorModel.count > 0) {
                fileSelector.currentIndex = 0;
                var firstFile = fileSelectorModel.get(0).text;
                console.log("Auto-loading first template: " + firstFile);
                loadTemplate(firstFile);
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim() !== "")
                    fileSelectorModel.append({
                    "text": data.trim()
                });

            }
        }

        stderr: SplitParser {
            onRead: (data) => {
                return console.log("LS Error (Chat): " + data);
            }
        }

    }

    Process {
        id: listHistoryFiles

        command: ["ls", "-1", "--color=never", historyDirectory]

        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim() !== "")
                    historyListModel.append({
                    "text": data.trim()
                });

            }
        }

    }

    Process {
        id: deleteHistoryProcess

        onExited: (exitCode) => {
            if (exitCode === 0)
                refreshHistoryList();

        }
    }

    Process {
        id: readTemplateProcess

        stdout: StdioCollector {
            onStreamFinished: {
                parseChatContent(text);
                currentFilePath = "";
            }
        }

    }

    Timer {
        id: historyRefreshTimer

        interval: 500
        repeat: false
        onTriggered: refreshHistoryList()
    }

    FileView {
        id: activeFileReader

        path: window.currentFilePath
        onPathChanged: reload()
        onLoaded: {
            if (window.currentFilePath !== "")
                parseChatContent(text());

        }
    }

    ListModel {
        id: fileSelectorModel
    }

    ListModel {
        id: historyListModel
    }

    ListModel {
        id: chatModel
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Side Navigation Bar
        Rectangle {
            id: sideNavBar

            Layout.preferredWidth: Config.theme.chatSidebarWidth
            Layout.fillHeight: true
            color: Config.theme.chatBgSidebar

            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                anchors.margins: 10
                anchors.topMargin: 20

                Button {
                    text: "New chat"
                    icon.source: "root:/icons/send.svg"
                    Layout.fillWidth: true
                    onClicked: createNewChat()

                    background: Rectangle {
                        color: parent.hovered ? Config.theme.chatBgHover : "transparent"
                        border.color: Config.theme.chatBorderMedium
                        radius: 4
                    }

                }

                Label {
                    text: "History"
                    font.pixelSize: Config.theme.chatFsSmall
                    color: Config.theme.chatTextDim
                    topPadding: 10
                }

                ListView {
                    id: historyListView

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: historyListModel

                    delegate: ItemDelegate {
                        id: historyDelegate

                        width: ListView.view ? ListView.view.width : Config.theme.chatSidebarWidth
                        hoverEnabled: true
                        onClicked: loadHistory(model.text)

                        background: Rectangle {
                            color: historyDelegate.hovered ? Config.theme.chatBgHover : "transparent"
                            radius: 4
                        }

                        contentItem: RowLayout {
                            spacing: 0

                            Text {
                                text: model.text
                                color: Config.theme.chatTextSecondary
                                font.pixelSize: Config.theme.chatFsMedium
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                                Layout.fillWidth: true
                            }

                            Button {
                                visible: historyDelegate.hovered
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                Layout.rightMargin: 5
                                flat: true
                                onClicked: deleteHistoryFile(model.text)

                                background: Rectangle {
                                    color: parent.hovered ? Config.theme.chatBorderMedium : "transparent"
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: "×"
                                    color: parent.parent.hovered ? Config.theme.chatDangerColor : Config.theme.chatTextDim
                                    font.pixelSize: Config.theme.chatFsMedium
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                            }

                        }

                    }

                }

            }

        }

        // Main Chat Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Config.theme.chatBgMain

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Config.theme.chatHeaderHeight
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 15

                        Label {
                            text: "Template:"
                            font.bold: true
                            font.pixelSize: Config.theme.chatFsStandard
                            color: Config.theme.chatTextPrimary
                        }

                        ComboBox {
                            id: fileSelector

                            Layout.preferredWidth: 250
                            Layout.preferredHeight: 32
                            flat: true
                            model: fileSelectorModel
                            textRole: "text"
                            onActivated: (index) => {
                                var fileName = fileSelectorModel.get(index).text;
                                loadTemplate(fileName);
                            }

                            background: Rectangle {
                                color: parent.hovered ? Config.theme.chatBgHover : "transparent"
                                radius: 4
                                border.color: Config.theme.chatBorderMedium
                                border.width: 1
                            }

                            contentItem: Text {
                                text: parent.displayText
                                color: Config.theme.chatTextSecondary
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: Config.theme.chatFsMedium
                                leftPadding: 10
                                elide: Text.ElideRight
                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            text: currentFilePath === "" ? "(New Chat)" : currentFilePath.split('/').pop()
                            color: Config.theme.chatTextDark
                            font.italic: true
                            font.pixelSize: Config.theme.chatFsSmall
                        }

                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: Config.theme.chatBorderDark
                    }

                }

                ListView {
                    id: chatListView

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: chatModel
                    spacing: 15
                    topMargin: 20
                    bottomMargin: 20
                    leftMargin: 20
                    rightMargin: 20

                    delegate: Column {
                        id: chatDelegate

                        readonly property real viewWidth: ListView.view ? ListView.view.width : 500
                        property bool isEditing: false // State for the edit feature

                        // Helper to save edits
                        function saveEdit() {
                            chatModel.setProperty(index, "content", editField.text);
                            chatDelegate.isEditing = false;
                            window.saveChatHistory();
                        }

                        width: viewWidth - 40
                        spacing: 5
                        anchors.right: (parent && role === "user") ? parent.right : undefined
                        anchors.left: (parent && role !== "user") ? parent.left : undefined

                        Label {
                            text: role
                            color: Config.theme.chatTextDim
                            font.pixelSize: Config.theme.chatRoleSize
                            anchors.right: (parent && role === "user") ? parent.right : undefined
                            anchors.left: (parent && role !== "user") ? parent.left : undefined
                        }

                        Rectangle {
                            id: bubble

                            // Hover Tracking Property
                            property bool hovered: false

                            width: isEditing ? chatDelegate.viewWidth * 0.8 : Math.min(msgTxt.implicitWidth + 24, chatDelegate.viewWidth * 0.8)
                            height: isEditing ? editField.implicitHeight + 24 : msgTxt.implicitHeight + 24
                            radius: Config.theme.chatBubbleRadius
                            color: role === "user" ? Config.theme.chatBubbleUser : Config.theme.chatBubbleAi
                            border.color: isEditing ? Theme.get.iconColor : "transparent"
                            border.width: isEditing ? 1 : 0
                            anchors.right: (parent && role === "user") ? parent.right : undefined
                            anchors.left: (parent && role !== "user") ? parent.left : undefined

                            // Text Display
                            Text {
                                id: msgTxt

                                visible: !chatDelegate.isEditing
                                text: content
                                color: Config.theme.chatTextPrimary
                                font.pixelSize: Config.theme.chatFsText
                                textFormat: Text.MarkdownText
                                wrapMode: Text.Wrap
                                width: Math.min(implicitWidth, chatDelegate.viewWidth * 0.8 - 24)
                                anchors.centerIn: parent
                            }

                            // Edit Field (Visible only when editing)
                            TextArea {
                                id: editField

                                visible: chatDelegate.isEditing
                                text: content
                                width: parent.width - 20
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: Config.theme.chatFsLarge
                                wrapMode: Text.Wrap
                                background: null
                                focus: chatDelegate.isEditing
                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Return && event.modifiers & Qt.ControlModifier) {
                                        saveEdit();
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        chatDelegate.isEditing = false;
                                        event.accepted = true;
                                    }
                                }
                            }

                            // Hover Tracking MouseArea
                            // Defined after content to sit on top (Z-order) and capture hover correctly
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                                enabled: !chatDelegate.isEditing
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                            }

                            // Action Overlay
                            Rectangle {
                                visible: parent.hovered || actionRow.hovered
                                opacity: visible ? 1 : 0
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: Config.theme.chatOverlayMargin
                                height: Config.theme.chatOverlayHeight
                                width: actionRow.width + Config.theme.chatOverlayPadding
                                radius: Config.theme.chatOverlayRadius
                                color: Config.theme.chatBgOverlay
                                border.color: Config.theme.chatBorderMedium
                                border.width: 1

                                Row {
                                    id: actionRow

                                    property bool hovered: false

                                    anchors.centerIn: parent
                                    spacing: 8

                                    IconBtn {
                                        text: ""
                                        tooltip: "Copy"
                                        onClicked: Quickshell.clipboard.text = content
                                    }

                                    IconBtn {
                                        visible: role === "user"
                                        text: ""
                                        tooltip: "Edit"
                                        onClicked: {
                                            chatDelegate.isEditing = true;
                                            editField.forceActiveFocus();
                                        }
                                    }

                                    IconBtn {
                                        visible: role === "user"
                                        text: ""
                                        tooltip: "Regenerate"
                                        onClicked: {
                                            while (chatModel.count > index + 1)chatModel.remove(index + 1)
                                            sendMessageFromIndex(index);
                                        }
                                    }

                                    IconBtn {
                                        text: ""
                                        tooltip: "Delete"
                                        hoverColor: Config.theme.chatDangerHover
                                        onClicked: {
                                            chatModel.remove(index);
                                            window.saveChatHistory();
                                        }
                                    }

                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }

                                }

                            }

                        }

                    }

                }

                // Input Field
                Rectangle {
                    Layout.preferredHeight: Config.theme.chatInputAreaHeight
                    Layout.fillWidth: true
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        TextField {
                            id: messageInput

                            Layout.fillWidth: true
                            Layout.preferredHeight: Config.theme.chatInputHeight
                            placeholderText: "Message..."
                            color: "white"
                            font.pixelSize: Config.theme.chatFsStandard
                            leftPadding: 15
                            onAccepted: sendMessage()

                            background: Rectangle {
                                radius: Config.theme.chatInputRadius
                                color: Config.theme.chatBgInput
                                border.color: parent.activeFocus ? Config.theme.chatBorderLight : Config.theme.chatBorderDark
                                border.width: 1
                            }

                        }

                        Button {
                            icon.source: "root:/icons/send.svg"
                            Layout.preferredHeight: Config.theme.chatSendBtnSize
                            Layout.preferredWidth: Config.theme.chatSendBtnSize
                            flat: true
                            onClicked: sendMessage()

                            background: Rectangle {
                                radius: Config.theme.chatSendBtnRadius
                                color: parent.hovered ? Config.theme.chatBorderMedium : Config.theme.chatBgInput
                            }

                        }

                    }

                }

            }

        }

    }

    component IconBtn: Text {
        property string tooltip
        property color hoverColor: Config.theme.iconColor

        signal clicked()

        font.family: Config.theme.fontSymbol
        font.pixelSize: Config.theme.chatFsMedium
        color: ma.containsMouse ? hoverColor : "#AAA"

        MouseArea {
            id: ma

            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.parent.hovered = true
            onExited: parent.parent.hovered = false
            onClicked: parent.clicked()
            ToolTip.visible: containsMouse
            ToolTip.text: parent.tooltip
            ToolTip.delay: 400
        }

    }

}
