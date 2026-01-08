import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: root

        property var modelData
        property int intervalMinutes: 15
        property var wallpapers: []
        property var collectedPaths: []
        property int currentIndex: 0
        property string wallpaperPath: {
            var url = Qt.resolvedUrl("../assets/wallpaper").toString();
            if (url.indexOf("file://") === 0)
                return url.substring(7);
            else if (url.indexOf("file:") === 0)
                return url.substring(5);
            return url;
        }

        screen: modelData
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.exclusiveZone: -1
        color: "black"
        Component.onCompleted: {
            scanProcess.running = true;
        }

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Process {
            id: scanProcess

            command: ["find", "-L", root.wallpaperPath, "-maxdepth", "1", "-type", "f"]
            onExited: {
                if (root.collectedPaths.length > 0) {
                    root.wallpapers = root.collectedPaths.slice();
                    root.currentIndex = Math.floor(Math.random() * root.wallpapers.length);
                } else {
                    console.log("[Wallpaper] WARNING: No images found.");
                }
            }

            stdout: SplitParser {
                onRead: (data) => {
                    var file = data.trim();
                    // Basic check for image extensions
                    if (file.match(/\.(jpg|jpeg|png|webp|bmp|svg)$/i)) {
                        // Store in temporary array
                        var temp = root.collectedPaths;
                        temp.push(file);
                        root.collectedPaths = temp;
                    }
                }
            }

        }

        Timer {
            interval: root.intervalMinutes * 60 * 1000
            running: root.wallpapers.length > 1
            repeat: true
            onTriggered: {
                root.currentIndex = (root.currentIndex + 1) % root.wallpapers.length;
            }
        }

        Item {
            anchors.fill: parent

            Image {
                id: bgImage

                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: {
                    if (root.wallpapers.length === 0)
                        return "";

                    var rawPath = root.wallpapers[root.currentIndex];
                    if (!rawPath)
                        return "";

                    return "file://" + rawPath;
                }
                onStatusChanged: {
                    if (status === Image.Ready)
                        opacity = 1;
                    else if (status === Image.Error)
                        console.log(`[Wallpaper] ERROR: Could not load image. Is the format supported?`);
                }
                opacity: 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 1000
                    }

                }

            }

        }

    }

}
