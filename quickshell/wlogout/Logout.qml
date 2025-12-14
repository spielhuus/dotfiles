import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Window

PanelWindow {
    id: logoutWindow
    screen: modelData

    anchors {
        top: true; bottom: true
        left: true; right: true
    }

    // --- Layer & Focus Configuration ---
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore 
    WlrLayershell.exclusiveZone: -1
    color: "transparent"

    // --- Command Processing ---
    Process {
        id: sysCmd
        onRunningChanged: {
            if (!running && exitCode === 0) logoutWindow.visible = false
        }
    }

    function executeCommand(commandString) {
        if (commandString === "") {
            logoutWindow.visible = false
            return
        }
        console.log("Executing:", commandString)
        sysCmd.command = commandString.split(" ")
        sysCmd.running = true
    }

    // --- Main UI Container ---
    Rectangle {
        id: mainUI
        anchors.fill: parent
        color: "#CC000000"
        
        // 1. Give this container focus so it catches keys
        focus: true 

        // 2. Manual Keyboard Logic (Robust & Simple)
        // We manipulate the grid.currentIndex directly.
        Keys.onLeftPressed:  grid.moveCurrentIndexLeft()
        Keys.onRightPressed: grid.moveCurrentIndexRight()
        Keys.onUpPressed:    grid.moveCurrentIndexUp()
        Keys.onDownPressed:  grid.moveCurrentIndexDown()
        Keys.onEscapePressed: logoutWindow.visible = false
        
        // Execute the command of the CURRENTLY selected item
        Keys.onReturnPressed: executeCommand(grid.model.get(grid.currentIndex).cmd)
        Keys.onEnterPressed:  executeCommand(grid.model.get(grid.currentIndex).cmd)

        // Ensure focus is grabbed whenever window opens
        onVisibleChanged: {
            if (visible) mainUI.forceActiveFocus()
        }

        // Close on background click
        MouseArea {
            anchors.fill: parent
            onClicked: logoutWindow.visible = false
        }

        GridView {
            id: grid
            anchors.centerIn: parent
            width: 600
            height: 300
            cellWidth: 200
            cellHeight: 150
            
            // Disable default GridView highlighting to avoid conflicts
            highlightFollowsCurrentItem: false
            
            // Helper properties for manual navigation
            property int columns: Math.floor(width / cellWidth)

            function moveCurrentIndexRight() {
                if (currentIndex < count - 1) currentIndex++
            }
            function moveCurrentIndexLeft() {
                if (currentIndex > 0) currentIndex--
            }
            function moveCurrentIndexDown() {
                if (currentIndex + columns < count) currentIndex += columns
            }
            function moveCurrentIndexUp() {
                if (currentIndex - columns >= 0) currentIndex -= columns
            }

            model: ListModel {
                ListElement { name: "Lock";     cmd: "loginctl lock-session";         color: "#8E44AD" }
                ListElement { name: "Logout";   cmd: "loginctl terminate-user $USER"; color: "#2980B9" }
                ListElement { name: "Suspend";  cmd: "systemctl suspend";             color: "#F1C40F" }
                ListElement { name: "Reboot";   cmd: "systemctl reboot";              color: "#E67E22" }
                ListElement { name: "Shutdown"; cmd: "systemctl poweroff";            color: "#C0392B" }
                ListElement { name: "Cancel";   cmd: "";                              color: "#7F8C8D" }
            }

            delegate: Item {
                width: grid.cellWidth
                height: grid.cellHeight

                Rectangle {
                    width: 180
                    height: 130
                    anchors.centerIn: parent
                    radius: 10
                    
                    // 3. Highlight Logic
                    // This checks the GridView's currentIndex (controlled by Keys OR Mouse)
                    property bool isSelected: grid.currentIndex === index
                    
                    color: isSelected ? Qt.lighter(model.color, 1.2) : model.color
                    
                    border.width: isSelected ? 4 : 0
                    border.color: "white"

                    scale: isSelected ? 1.05 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: model.name
                        color: "white"
                        font.bold: true
                        font.pixelSize: 20
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        // 4. Mouse Logic:
                        // Just update the index. The visual bind above handles the rest.
                        onEntered: grid.currentIndex = index
                        onClicked: executeCommand(model.cmd)
                    }
                }
            }
        }
    }
  }


// PanelWindow {
//   id: logoutWindow
//   screen: modelData
//
//   anchors {
//     top: true
//     bottom: true
//     left: true
//     right: true
//   }
//
//     exclusionMode: ExclusionMode.Ignore
//
//     WlrLayershell.exclusiveZone: -1
//   WlrLayershell.layer: WlrLayer.Overlay
//
//   color: "transparent"
//
//   WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
//
//   Rectangle {
//     anchors.fill: parent
//     color: "#CC000000"
//
//     // 4. The Close Button
//     Rectangle {
//       width: 150
//       height: 50
//       radius: 8
//       color: "#FF5555"
//       anchors.centerIn: parent
//
//       Text {
//         anchors.centerIn: parent
//         text: "Close Overlay"
//         color: "white"
//         font.bold: true
//       }
//
//       MouseArea {
//         anchors.fill: parent
//         cursorShape: Qt.PointingHandCursor
//
//         // Logic to close the window
//         onClicked: {
//           console.log("Closing overlay...")
//           onClicked: logoutWindow.visible = false
//         }
//       }
//     }
//   }
// }


// PopupWindow {
//
//   id: logoutWindow
//     anchor.window: toplevel
//     anchor.rect.x: parentWindow.width / 2 - width / 2
//     anchor.rect.y: parentWindow.height
//     width: 500
//     height: 500
//     visible: true
//     // width: 400
//     // height: 600
//     // title: "Process Component Diagnostic Tool"
//     // color: "#ffffffff"   
//     // property ShellScreen screen: ShellRoot.primaryScreen
//     // anchors {
//     // top: true
//     // left: true
//     // bottom: true
//     // right: true
//   }
//     // x: screen.geometry.x
//     // y: screen.geometry.y
//     // width: screen.geometry.width
//     // height: screen.geometry.height
//     // property string responseBuffer: ""
//     // property string errorBuffer: ""
//
//     Column {
//         anchors.fill: parent
//         anchors.margins: 10
//         spacing: 10
//
//         Row {
//             spacing: 10
//             Button { text: "1. Test Echo"; onClicked: testEcho() }
//             Button { text: "2. Test Curl"; onClicked: testCurl() }
//         }
//
//         Flickable {
//             width: parent.width
//             height: parent.height - 50 // Adjust height to fit buttons
//             contentHeight: chatLog.implicitHeight
//             flickableDirection: Flickable.VerticalFlick
//             ScrollBar.vertical: ScrollBar {}
//
//             Column {
//                 id: chatLog
//                 width: parent.width
//                 spacing: 10
//                 Text { text: "Click a button to begin the test."; font.bold: true }
//             }
//         }
//     }
//
//     Process { id: llamaProcess }
//
//     Connections {
//         target: llamaProcess
//
//         function onReadyReadStandardOutput() {
//             responseBuffer += llamaProcess.readAllStandardOutput();
//         }
//         function onReadyReadStandardError() {
//             errorBuffer += llamaProcess.readAllStandardError();
//         }
//
//         function onFinished(exitCode, exitStatus) {
//             addMessage("RESULT", "Process finished with exit code: " + exitCode);
//             if (responseBuffer.trim() !== "") {
//                 addMessage("STDOUT", responseBuffer);
//             }
//             if (errorBuffer.trim() !== "") {
//                 addMessage("STDERR", errorBuffer);
//             }
//             llamaProcess.running = false;
//         }
//     }
//
//     function addMessage(sender, message) {
//         var newText = Qt.createQmlObject(
//             'import QtQuick 2.15; Text { text: "' + sender + ': ' + String(message).replace(/"/g, '\\"') + '"; wrapMode: Text.WordWrap; width: ' + (chatLog.width - 5) + '}',
//             chatLog);
//     }
//
//     function startProcess(commandArray) {
//         if (llamaProcess.running) {
//             addMessage("STATUS", "A process is already running.");
//             return;
//         }
//         responseBuffer = "";
//         errorBuffer = "";
//         llamaProcess.command = commandArray;
//         addMessage("STARTED", commandArray.join(" "));
//         llamaProcess.running = true;
//     }
//
//     function testEcho() {
//         startProcess(["echo", "Hello from Quickshell"]);
//     }
//
//     function testCurl() {
//       var xhr = new XMLHttpRequest();
//       xhr.onreadystatechange = function() {
//         if (xhr.readyState === XMLHttpRequest.DONE) {
//           if (xhr.status === 200) {
//             console.log(">: " + xhr.responseText);
//             var jsObject = JSON.parse(xhr.responseText);
//             for(let c of jsObject["choices"]) {
//
//               console.log(">: " + c["message"]["role"] + ": " + c["message"]["content"]);
//             }
//
//           } else {
//             console.log("Error: " + xhr.status + " " + xhr.statusText);
//           }
//         }
//       }
//
//       xhr.open("POST", "http://localhost:8080/v1/chat/completions");
//       xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
//       var data = {messages: [{
//         role: "user",
//         content: "hi"
//       }]};
//       xhr.send(JSON.stringify(data));
//     }
// }
