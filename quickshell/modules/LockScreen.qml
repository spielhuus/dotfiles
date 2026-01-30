import "../"
import "../services"
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import extensions.build

WlSessionLock {
    id: sessionLock

    property string username: "User"

    // --- Lock State ---
    locked: Idle.locked
    Component.onCompleted: {
        var envUser = Quickshell.env("USER");
        if (envUser)
            sessionLock.username = envUser;

    }
    onLockedChanged: {
        if (!locked && Idle.locked)
            Idle.unlock();

    }

    // --- User Info ---
    Process {
        id: userProcess

        running: sessionLock.username === "User"
        command: ["whoami"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "")
                    sessionLock.username = text.trim();

            }
        }

    }

    // --- Surface Loader ---
    Loader {
        active: sessionLock.locked
        sourceComponent: lockSurfaceComponent
    }

    Component {
        id: lockSurfaceComponent

        WlSessionLockSurface {
            id: lockSurface

            property int inactivityTimeout: 30000
            property bool isScreenOff: false
            property bool mouseThrottle: false
            property var collectedPaths: []
            property string currentWallpaper: ""
            property string wallpaperSearchPath: {
                var url = Qt.resolvedUrl("../assets/wallpaper").toString();
                if (url.indexOf("file://") === 0)
                    return url.substring(7);
                else if (url.indexOf("file:") === 0)
                    return url.substring(5);
                return url;
            }

            // --- Power Logic ---
            function setDpms(on) {
                WaylandPower.setDpms(on);
                lockSurface.isScreenOff = !on;
            }

            function resetActivity() {
                if (lockSurface.isScreenOff)
                    lockSurface.setDpms(true);

                inactivityTimer.restart();
            }

            Component.onCompleted: {
                console.log("[LockScreen] Surface Loaded.");
                inactivityTimer.restart();
                passwordInput.forceActiveFocus();
            }
            Component.onDestruction: {
                WaylandPower.setDpms(true);
            }

            Process {
                // Push to the internal buffer, not the bound property

                id: scanProcess

                // Internal buffer to store paths without triggering QML updates
                property var _buffer: []

                running: true
                command: ["find", "-L", lockSurface.wallpaperSearchPath, "-maxdepth", "1", "-type", "f"]
                onExited: {
                    // Bulk assignment: Update the UI property only once!
                    lockSurface.collectedPaths = scanProcess._buffer;
                    console.log("[LockScreen] Scanned: " + lockSurface.wallpaperSearchPath);
                    if (lockSurface.collectedPaths.length > 0) {
                        var randomIndex = Math.floor(Math.random() * lockSurface.collectedPaths.length);
                        lockSurface.currentWallpaper = "file://" + lockSurface.collectedPaths[randomIndex];
                        console.log("[LockScreen] Selected: " + lockSurface.currentWallpaper);
                    } else {
                        console.log("[LockScreen] No images found. Screen will be black.");
                    }
                    // Clear buffer to free memory
                    scanProcess._buffer = [];
                }

                stdout: SplitParser {
                    onRead: (data) => {
                        var file = data.trim();
                        if (file.match(/\.(jpg|jpeg|png|webp|bmp|svg)$/i))
                            scanProcess._buffer.push(file);

                    }
                }

                stderr: StdioCollector {
                    onTextChanged: console.log("[LockScreen] Wallpaper Scan Error: " + text)
                }

            }

            Timer {
                id: inactivityTimer

                interval: lockSurface.inactivityTimeout
                repeat: false
                onTriggered: lockSurface.setDpms(false)
            }

            Timer {
                id: throttleTimer

                interval: 1000
                repeat: false
                onTriggered: lockSurface.mouseThrottle = false
            }

            QtObject {
                id: authState

                property bool error: false
                property bool processing: false
            }

            // --- Visuals ---
            Rectangle {
                anchors.fill: parent
                color: "black"

                Image {
                    id: bgImage

                    anchors.fill: parent
                    source: lockSurface.currentWallpaper
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: false // Hidden, used by MultiEffect
                    asynchronous: true
                    onStatusChanged: {
                        if (status === Image.Ready)
                            console.log("[LockScreen] Image Loaded Successfully.");
                        else if (status === Image.Error)
                            console.log("[LockScreen] Failed to load image source.");
                    }
                }

                MultiEffect {
                    anchors.fill: parent
                    source: bgImage
                    visible: bgImage.status === Image.Ready
                    blurEnabled: true
                    blurMax: 20
                    blur: 1
                    saturation: 0
                }

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.5
                }

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
                    onTriggered: {
                        var now = new Date();
                        // Only update the QML property if the minute has actually changed
                        if (now.getMinutes() !== clock.time.getMinutes() || now.getHours() !== clock.time.getHours())
                            clock.time = now;

                    }
                }

            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 15

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(clock.time, "h:mm") + (clock.time.getHours() >= 12 ? "PM" : "AM")
                    color: "white"
                    font.pixelSize: 80
                    font.family: "JetBrainsMono Nerd Font"
                    font.weight: Font.ExtraBold
                    font.letterSpacing: 2
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    text: "Hi there, " + sessionLock.username
                    color: "white"
                    font.pixelSize: 18
                    font.family: "JetBrainsMono Nerd Font"
                    font.weight: Font.Medium
                    opacity: 0.9
                }

                TextField {
                    id: passwordInput

                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 220
                    Layout.preferredHeight: 40
                    placeholderText: "Input Password..."
                    placeholderTextColor: "#99ffffff"
                    color: "white"
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                    font.italic: true
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
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
                            Idle.unlock();
                        } else {
                            passwordInput.text = "";
                            authState.error = true;
                            shakeAnimation.start();
                            lockSurface.resetActivity();
                        }
                        authState.processing = false;
                    }

                    SequentialAnimation {
                        id: shakeAnimation

                        NumberAnimation {
                            target: passwordInput
                            property: "Layout.leftMargin"
                            from: 0
                            to: 10
                            duration: 50
                        }

                        NumberAnimation {
                            target: passwordInput
                            property: "Layout.leftMargin"
                            from: 10
                            to: -10
                            duration: 50
                        }

                        NumberAnimation {
                            target: passwordInput
                            property: "Layout.leftMargin"
                            from: -10
                            to: 0
                            duration: 50
                        }

                    }

                    background: Rectangle {
                        color: "#50000000"
                        radius: height / 2
                        border.width: 1
                        border.color: authState.error ? "#cc8822" : "transparent"
                    }

                }

            }

        }

    }

}
