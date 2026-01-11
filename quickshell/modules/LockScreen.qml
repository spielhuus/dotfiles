import "../"
import "../services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import extensions.build

WlSessionLock {
    id: sessionLock

    property string username: "User"

    locked: Idle.locked
    Component.onCompleted: {
        var envUser = Quickshell.env("USER");
        if (envUser)
            sessionLock.username = envUser;

    }
    onLockedChanged: {
        if (!locked && Idle.locked) {
            console.log("[LockScreen] Session unlocked externally. Resetting Idle.");
            Idle.unlock();
        }
    }

    Process {
        id: userProcess

        running: sessionLock.username === "User"
        command: ["whoami"]

        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim();
                if (output !== "")
                    sessionLock.username = output;

            }
        }

    }

    WlSessionLockSurface {
        id: lockSurface

        // --- Logic & State ---
        property int inactivityTimeout: 30000
        property bool isScreenOff: false
        property bool mouseThrottle: false

        function setDpms(on) {
            WaylandPower.setDpms(on);
            lockSurface.isScreenOff = !on;
        }

        function resetActivity() {
            if (lockSurface.isScreenOff) {
                console.log("[LockScreen] Activity detected. Waking screen.");
                lockSurface.setDpms(true);
            }
            inactivityTimer.restart();
        }

        // --- Start Timer when Surface Appears ---
        Component.onCompleted: {
            console.log("[LockScreen] Surface created. Starting inactivity timer.");
            inactivityTimer.restart();
            // Ensure input focus
            passwordInput.forceActiveFocus();
        }
        // --- Cleanup when Surface Destroys (Unlocks) ---
        Component.onDestruction: {
            console.log("[LockScreen] Surface destroying. Ensuring screen is ON.");
            lockSurface.setDpms(true);
        }

        // --- Inactivity Timer ---
        Timer {
            id: inactivityTimer

            interval: lockSurface.inactivityTimeout
            repeat: false
            running: false
            onTriggered: {
                console.log("[LockScreen] Inactivity timeout reached. Turning screen OFF.");
                lockSurface.setDpms(false);
            }
        }

        Timer {
            id: throttleTimer

            interval: 1000
            repeat: false
            onTriggered: lockSurface.mouseThrottle = false
        }

        // --- Visuals ---
        Rectangle {
            anchors.fill: parent
            color: "black"

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    passwordInput.forceActiveFocus();
                    lockSurface.resetActivity();
                }
                onPositionChanged: {
                    if (!lockSurface.mouseThrottle) {
                        lockSurface.resetActivity();
                        lockSurface.mouseThrottle = true;
                        throttleTimer.restart();
                    }
                }
                onWheel: lockSurface.resetActivity()
            }

        }

        Item {
            id: clock

            property var time: new Date()

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.time = new Date()
            }

        }

        ColumnLayout {
            id: mainLayout

            anchors.centerIn: parent
            spacing: 20

            Text {
                text: Qt.formatDateTime(clock.time, "hh:mm")
                color: "white"
                font.pixelSize: 100
                font.weight: Font.Light
                font.family: {
                    if (typeof Theme !== "undefined" && Theme.get && Theme.get.bar && Theme.get.bar.fontFamily)
                        return Theme.get.bar.fontFamily;

                    if (typeof Theme !== "undefined" && Theme.defaultBar)
                        return Theme.defaultBar.fontFamily;

                    return "Sans Serif";
                }
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: Qt.formatDateTime(clock.time, "dd MMM dddd")
                color: "#999999"
                font.pixelSize: 24
                font.bold: true
                font.capitalization: Font.AllUppercase
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Hi " + sessionLock.username + " :)"
                color: "#cccccc"
                font.pixelSize: 18
                font.italic: true
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 30
            }

            TextField {
                id: passwordInput

                Layout.preferredWidth: 220
                Layout.preferredHeight: 45
                Layout.alignment: Qt.AlignHCenter
                placeholderText: "Use Me ;)"
                placeholderTextColor: "#ccffffff"
                color: "white"
                font.pixelSize: 14
                font.italic: true
                echoMode: TextInput.Password
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                focus: true
                Keys.onPressed: (event) => {
                    lockSurface.resetActivity();
                    event.accepted = false;
                }
                onTextEdited: lockSurface.resetActivity()
                Component.onCompleted: forceActiveFocus()
                onAccepted: {
                    authState.processing = true;
                    if (PamAuth.checkPassword(passwordInput.text)) {
                        passwordInput.text = "";
                        authState.error = false;
                        // Unlock via global service.
                        // This changes sessionLock.locked -> destroys Surface -> triggers onDestruction -> ensures DPMS on.
                        Idle.unlock();
                    } else {
                        passwordInput.text = "";
                        authState.error = true;
                        shakeAnimation.start();
                        lockSurface.resetActivity();
                    }
                    authState.processing = false;
                }

                background: Rectangle {
                    color: "#20ffffff"
                    radius: height / 2
                    border.width: 1
                    border.color: authState.error ? "#ff5555" : "transparent"
                }

            }

        }

        QtObject {
            id: authState

            property bool error: false
            property bool processing: false
        }

        SequentialAnimation {
            id: shakeAnimation

            NumberAnimation {
                target: mainLayout
                property: "anchors.horizontalCenterOffset"
                from: 0
                to: 10
                duration: 50
            }

            NumberAnimation {
                target: mainLayout
                property: "anchors.horizontalCenterOffset"
                from: 10
                to: -10
                duration: 50
            }

            NumberAnimation {
                target: mainLayout
                property: "anchors.horizontalCenterOffset"
                from: -10
                to: 0
                duration: 50
            }

        }

    }

}
