import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import extensions.build
import "../services"
import "../"

WlSessionLock {
    id: sessionLock
    
    // Bind to the Idle service
    // Note: Use 'locked', not 'active' for WlSessionLock
    locked: Idle.locked

    // If the lock is destroyed externally (e.g. by the compositor), sync state
    onLockedChanged: {
        if (!locked && Idle.locked) {
            Idle.unlock();
        }
    }

    // This component is automatically instantiated for EVERY screen
    WlSessionLockSurface {
        id: lockSurface
        
        // Background
        Rectangle {
            anchors.fill: parent
            color: "black"

            // Optional: Wallpaper background
            Image {
                anchors.fill: parent
                source: Config.theme.background_color === "#000000" ? "" : "file:///path/to/lock_wallpaper.jpg"
                fillMode: Image.PreserveAspectCrop
                opacity: 0.3
                visible: source != ""
            }
        }

        // Login Box
        Rectangle {
            anchors.centerIn: parent
            width: 300
            height: 350
            color: Theme.get.osdBgColor || "#cc222222"
            radius: 10
            border.color: authState.error ? "red" : (Theme.get.osdBorderColor || "#444")
            border.width: 1

            // State for visual feedback
            QtObject {
                id: authState
                property bool error: false
                property bool processing: false
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width - 40

                // Lock Icon
                Text {
                    text: ""
                    font.family: Theme.get.bar.fontSymbol
                    font.pixelSize: 48
                    color: "white"
                    Layout.alignment: Qt.AlignHCenter
                }

                // Clock
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 0
                    Text {
                        text: Qt.formatDateTime(new Date(), "HH:mm")
                        color: "white"
                        font.pixelSize: 42
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                        color: "#aaa"
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // Password Input
                TextField {
                    id: passwordInput
                    Layout.fillWidth: true
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    color: "white"
                    font.pixelSize: 16
                    horizontalAlignment: TextInput.AlignHCenter
                    
                    background: Rectangle {
                        color: "#333"
                        radius: 5
                        border.width: 1
                        border.color: parent.activeFocus ? Theme.get.iconColor : "transparent"
                    }

                    // Ensure focus is grabbed when lock appears
                    focus: true
                    
                    Connections {
                        target: sessionLock
                        function onLockedChanged() {
                            if (sessionLock.locked) {
                                passwordInput.text = ""
                                passwordInput.forceActiveFocus()
                                authState.error = false
                            }
                        }
                    }

                    onAccepted: checkPassword()

                    function checkPassword() {
                        authState.processing = true;
                        
                        // Use the C++ PamAuth extension
                        if (PamAuth.checkPassword(passwordInput.text)) {
                            passwordInput.text = "";
                            authState.error = false;
                            Idle.unlock(); // This will set sessionLock.locked = false
                        } else {
                            passwordInput.text = "";
                            authState.error = true;
                            shakeAnimation.start();
                        }
                        authState.processing = false;
                    }
                }

                Text {
                    text: authState.error ? "Incorrect Password" : ""
                    color: "#ff5555"
                    visible: authState.error
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 12
                }
            }

            // Shake Animation for wrong password
            SequentialAnimation {
                id: shakeAnimation
                loops: 2
                NumberAnimation { target: passwordInput; property: "Layout.leftMargin"; from: 0; to: 10; duration: 50 }
                NumberAnimation { target: passwordInput; property: "Layout.leftMargin"; from: 10; to: -10; duration: 50 }
                NumberAnimation { target: passwordInput; property: "Layout.leftMargin"; from: -10; to: 0; duration: 50 }
            }
        }
    }
}
