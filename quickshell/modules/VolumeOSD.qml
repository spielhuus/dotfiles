import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import qs.config

Scope {
  id: root

  property var sink: Pipewire.defaultAudioSink
  Connections {
    target: sink ? sink.audio : null
    function onVolumeChanged() {
      root.present()
    }
    function onMutedChanged() {
      root.present()
    }
  }

  property bool showOsd: false
  property bool initialized: false

  Timer {
    interval: 1000; running: true; repeat: false
    onTriggered: root.initialized = true
  }

  Timer {
    id: hideTimer
    interval: 2000
    onTriggered: root.showOsd = false
  }

  function present() {
    if (!initialized) return
    showOsd = true
    hideTimer.restart()
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: window
      property var modelData
      screen: modelData
      anchors.bottom: true
      margins.bottom: 100
      implicitWidth: 300
      implicitHeight: 80
      visible: bg.opacity > 0
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "volume-osd"
      exclusionMode: ExclusionMode.Ignore

      Rectangle {
        id: bg
        anchors.fill: parent
        radius: 30
        color: Config.theme.osdBgColor
        border.width: 1
        border.color: Config.theme.osdBorderColor

        // Animate Opacity here
        opacity: root.showOsd ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        RowLayout {
          anchors.fill: parent
          anchors.margins: 20
          spacing: 15

          // Icon
          Text {
            text: {
              if (!root.sink || !root.sink.audio) return "\uf026"
              const vol = root.sink.audio.volume
              const muted = root.sink.audio.muted

              if (muted) return ""
              if (vol >= 0.66) return "󰕾"
              if (vol >= 0.33) return "󰖀"
              if (vol > 0) return "󰕿"
              return ""
            }
            color: Config.theme.iconColor
            font.family: Config.theme.fontSymbol
            font.pixelSize: 24
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
          }

          // Progress Bar
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            color: Config.theme.osdBgColor 
            radius: 3
            clip: true
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
              height: parent.height
              width: parent.width * (root.sink?.audio?.volume ?? 0)

              color: (root.sink?.audio?.muted) ? "#555555" : Config.theme.iconColor
              radius: 3

              Behavior on width { NumberAnimation { duration: 50 } }
            }
          }

          Text {
            text: Math.round((root.sink?.audio?.volume ?? 0) * 100) + "%"
            color: "white"
            font.family: Config.theme.fontFamily
            font.pixelSize: 16
            font.bold: true
            Layout.preferredWidth: 45
            horizontalAlignment: Text.AlignRight
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
          }
        }
      }
    }
  }
}
