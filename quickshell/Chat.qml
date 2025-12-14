import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: chatWindow
    width: 400
    height: 600
    title: "Process Component Diagnostic Tool"

    property string responseBuffer: ""
    property string errorBuffer: ""

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Row {
            spacing: 10
            Button { text: "1. Test Echo"; onClicked: testEcho() }
            Button { text: "2. Test Curl"; onClicked: testCurl() }
        }

        Flickable {
            width: parent.width
            height: parent.height - 50 // Adjust height to fit buttons
            contentHeight: chatLog.implicitHeight
            flickableDirection: Flickable.VerticalFlick
            ScrollBar.vertical: ScrollBar {}

            Column {
                id: chatLog
                width: parent.width
                spacing: 10
                Text { text: "Click a button to begin the test."; font.bold: true }
            }
        }
    }

    Process { id: llamaProcess }

    Connections {
        target: llamaProcess

        function onReadyReadStandardOutput() {
            responseBuffer += llamaProcess.readAllStandardOutput();
        }
        function onReadyReadStandardError() {
            errorBuffer += llamaProcess.readAllStandardError();
        }

        function onFinished(exitCode, exitStatus) {
            addMessage("RESULT", "Process finished with exit code: " + exitCode);
            if (responseBuffer.trim() !== "") {
                addMessage("STDOUT", responseBuffer);
            }
            if (errorBuffer.trim() !== "") {
                addMessage("STDERR", errorBuffer);
            }
            llamaProcess.running = false;
        }
    }

    function addMessage(sender, message) {
        var newText = Qt.createQmlObject(
            'import QtQuick 2.15; Text { text: "' + sender + ': ' + String(message).replace(/"/g, '\\"') + '"; wrapMode: Text.WordWrap; width: ' + (chatLog.width - 5) + '}',
            chatLog);
    }

    function startProcess(commandArray) {
        if (llamaProcess.running) {
            addMessage("STATUS", "A process is already running.");
            return;
        }
        responseBuffer = "";
        errorBuffer = "";
        llamaProcess.command = commandArray;
        addMessage("STARTED", commandArray.join(" "));
        llamaProcess.running = true;
    }

    function testEcho() {
        startProcess(["echo", "Hello from Quickshell"]);
    }

    function testCurl() {
      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
          if (xhr.status === 200) {
            console.log(">: " + xhr.responseText);
            var jsObject = JSON.parse(xhr.responseText);
            for(let c of jsObject["choices"]) {

              console.log(">: " + c["message"]["role"] + ": " + c["message"]["content"]);
            }

          } else {
            console.log("Error: " + xhr.status + " " + xhr.statusText);
          }
        }
      }

      xhr.open("POST", "http://localhost:8080/v1/chat/completions");
      xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
      var data = {messages: [{
        role: "user",
        content: "hi"
      }]};
      xhr.send(JSON.stringify(data));
    }
}
