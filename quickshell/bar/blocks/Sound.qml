import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import qs.config
import "../"

BarBlock {
    id: root
    property var sink: Pipewire.defaultAudioSink

    // Defensive readouts to handle transitional or null/NaN values safely
    readonly property real volume: {
        if (sink && sink.audio && typeof sink.audio.volume === "number" && !isNaN(sink.audio.volume)) {
            return sink.audio.volume;
        }
        return 0;
    }
    readonly property bool muted: {
        if (sink && sink.audio && typeof sink.audio.muted === "boolean") {
            return sink.audio.muted;
        }
        return false;
    }

    PwObjectTracker { 
        objects: [Pipewire.defaultAudioSink]
        onObjectsChanged: {
            sink = Pipewire.defaultAudioSink
        }
    }

    content: BarText { 
      symbolText: root.muted 
        ? "󰖁" 
        : `󰕾 ${Math.round(root.volume * 100)}%`
      color: root.muted ? Config.theme.inactive : Config.theme.normal
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: toggleMenu()
        onWheel: function(event) {
            if (sink?.audio) {
                sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + (event.angleDelta.y / 120) * 0.05))
            }
        }
    }

    Process {
        id: pavucontrol
        command: ["pavucontrol"]
        running: false
    }

    PopupWindow {
        id: menuWindow
        visible: false
        color: "transparent"
        grabFocus: true

        anchor.window: root.QsWindow?.window ?? null
        anchor.rect.x: root.QsWindow?.window ? (root.mapToGlobal(root.width / 2, 0).x - width / 2) : 0
        anchor.rect.y: root.QsWindow?.window ? root.mapToGlobal(0, root.height).y : 0

        implicitWidth: popupContent.implicitWidth
        implicitHeight: popupContent.implicitHeight

        Pane {
            id: popupContent
            implicitWidth: 320
            
            topPadding: 16
            bottomPadding: 16
            leftPadding: 20  
            rightPadding: 20 

            Connections {
                target: popupContent.QsWindow ? popupContent.QsWindow.window : null
                
                function onActiveChanged() {
                    if (target && !target.active && menuWindow.visible) {
                        menuWindow.visible = false;
                    }
                }
            }

            background: Rectangle {
                color: Config.theme.bg
                radius: 10
                border.color: Config.theme.border
                border.width: 1
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Volume"
                        font.bold: true
                        color: Config.theme.text
                        font.family: Config.theme.fontFamily
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: root.muted ? "Muted" : `${Math.round(root.volume * 100)}%`
                        color: Config.theme.subtext
                        font.family: Config.theme.fontFamily
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: root.muted ? "󰖁" : "󰕾"
                        font.family: Config.theme.fontSymbol
                        font.pixelSize: 18
                        color: root.muted ? Config.theme.inactive : Config.theme.iconColor
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        from: 0
                        to: 1
                        value: root.volume
                        
                        onMoved: {
                            if (sink?.audio) {
                                sink.audio.volume = value
                            }
                        }

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: volumeSlider.availableWidth
                            height: 6
                            radius: 3
                            color: Config.theme.border

                            Rectangle {
                                width: volumeSlider.visualPosition * parent.width
                                height: parent.height
                                color: root.muted ? Config.theme.inactive : Config.theme.iconColor
                                radius: 3
                            }
                        }

                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: 16
                            height: 16
                            radius: 8
                            color: volumeSlider.pressed ? Config.theme.iconPressedColor : "#ffffff"
                            border.color: Config.theme.border
                            border.width: 1
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Config.theme.border
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: [
                            { 
                                text: root.muted ? "Unmute" : "Mute", 
                                icon: root.muted ? "󰖁" : "󰝟", 
                                action: () => sink?.audio && (sink.audio.muted = !sink.audio.muted) 
                            },
                            { 
                                text: "Audio Mixer (Pavucontrol)", 
                                icon: "󰓃", 
                                action: () => { pavucontrol.running = true; menuWindow.visible = false } 
                            }
                        ]

                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38

                            Rectangle {
                                anchors.fill: parent
                                color: itemMouseArea.containsMouse ? Config.theme.chatBgHover : "transparent"
                                radius: 6

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }

                            MouseArea {
                                id: itemMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    modelData.action()
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 12

                                Text {
                                    text: modelData.icon
                                    font.family: Config.theme.fontSymbol
                                    font.pixelSize: 16
                                    color: Config.theme.subtext
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Label {
                                    text: modelData.text
                                    color: Config.theme.text
                                    font.family: Config.theme.fontFamily
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function toggleMenu() {
        menuWindow.visible = !menuWindow.visible
    }
}
