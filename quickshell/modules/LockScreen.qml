import "../"
import "../services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import extensions.build
import qs.config

WlSessionLock {
    id: sessionLock

    // 1. Bind to the Idle service
    locked: Idle.locked
    // 2. Sync state: If the compositor unlocks us forcefully, tell Idle service
    onLockedChanged: {
        if (!locked && Idle.locked)
            Idle.unlock();

    }

    WlSessionLockSurface {
        id: lockSurface

        // --- LOGIC: Screensaver vs Login Mode ---
        property bool showLogin: false

        // Reset state when lock appears
        Component.onCompleted: {
            showLogin = false;
        }

        // Background (Wallpaper)
        Rectangle {
            anchors.fill: parent
            color: "black"

            Image {
                anchors.fill: parent
                source: Config.theme.background_color === "#000000" ? "" : "file://" + Config.chat.homeDir + "/Pictures/wallpaper.jpg" // Adjust path
                fillMode: Image.PreserveAspectCrop
                opacity: 0.5
            }

        }

        // --- SCREENSAVER CONTENT (Visible when NOT logging in) ---
        Item {
            // Simple "Bouncing" animation or fade effect could go here

            anchors.fill: parent
            visible: !lockSurface.showLogin

            // Example: A moving clock or large text
            ColumnLayout {
                anchors.centerIn: parent

                Text {
                    text: Qt.formatDateTime(new Date(), "HH:mm")
                    color: "white"
                    font.pixelSize: 100
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                    color: "#ddd"
                    font.pixelSize: 32
                    Layout.alignment: Qt.AlignHCenter
                }

            }

        }

        // --- INTERACTION HANDLER ---
        // Detects activity to switch from Screensaver -> Login
        MouseArea {
            // Optional: Uncomment if you want mouse movement to show login immediately
            // lockSurface.showLogin = true

            anchors.fill: parent
            hoverEnabled: true
            onClicked: lockSurface.showLogin = true
            onPositionChanged: {
            }
        }

        // Detect Keyboard activity to switch to Login
        Item {
            focus: true
            anchors.fill: parent
            Keys.onPressed: (event) => {
                if (!lockSurface.showLogin) {
                    lockSurface.showLogin = true;
                    event.accepted = true;
                }
            }
        }

        // --- LOGIN BOX (Visible only after interaction) ---
        Rectangle {
            id: loginBox

            anchors.centerIn: parent
            width: 300
            height: 350
            // Visibility logic
            visible: lockSurface.showLogin
            opacity: visible ? 1 : 0
            color: Theme.get.osdBgColor || "#cc222222"
            radius: 10
            border.color: authState.error ? "red" : (Theme.get.osdBorderColor || "#444")
            border.width: 1

            QtObject {
                id: authState

                property bool error: false
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width - 40

                Text {
                    text: ""
                    font.family: Theme.get.bar.fontSymbol
                    font.pixelSize: 48
                    color: "white"
                    Layout.alignment: Qt.AlignHCenter
                }

                // Small clock inside login box
                Text {
                    text: Qt.formatDateTime(new Date(), "HH:mm")
                    color: "white"
                    font.pixelSize: 24
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: passwordInput

                    function checkPassword() {
                        // Your PamAuth logic
                        if (PamAuth.checkPassword(passwordInput.text)) {
                            passwordInput.text = "";
                            authState.error = false;
                            Idle.unlock();
                            // Reset state for next time
                            lockSurface.showLogin = false;
                        } else {
                            passwordInput.text = "";
                            authState.error = true;
                            shakeAnimation.start();
                        }
                    }

                    Layout.fillWidth: true
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    color: "white"
                    font.pixelSize: 16
                    horizontalAlignment: TextInput.AlignHCenter
                    // Focus Management
                    focus: lockSurface.showLogin
                    onAccepted: checkPassword()

                    background: Rectangle {
                        color: "#333"
                        radius: 5
                        border.width: 1
                        border.color: parent.activeFocus ? Theme.get.iconColor : "transparent"
                    }

                }

                Text {
                    text: authState.error ? "Incorrect Password" : ""
                    color: "#ff5555"
                    visible: authState.error
                    Layout.alignment: Qt.AlignHCenter
                }

            }

            SequentialAnimation {
                // ... (Keep existing shake animation) ...

                id: shakeAnimation
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }

            }

        }

    }

}
