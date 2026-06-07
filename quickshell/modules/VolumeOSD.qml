import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import qs.config

Scope {
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

        opacity: root.showOsd ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        RowLayout {
          anchors.fill: parent
          anchors.margins: 20
          spacing: 15

          // Icon
          Text {
            text: {
              if (root.muted) return ""
              const vol = root.volume

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
              width: parent.width * root.volume

              color: root.muted ? "#555555" : Config.theme.iconColor
              radius: 3

              Behavior on width { NumberAnimation { duration: 50 } }
            }
          }

          Text {
            text: Math.round(root.volume * 100) + "%"
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
