import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.services.Compositor
import "blocks" as Blocks
import "root:/"

Scope {
  IpcHandler {
    target: "bar"

    function toggleVis(): void {
      for (let i = 0; i < Quickshell.screens.length; i++) {
        barInstances[i].visible = !barInstances[i].visible;
      }
    }
  }

  property var barInstances: []

  Variants {
    model: Quickshell.screens
  
    PanelWindow {
      id: bar
      WlrLayershell.layer: WlrLayer.Top 
      property var modelData
      screen: modelData

      Component.onCompleted: {
        barInstances.push(bar);
      }

      color: "transparent"

      Rectangle {
        id: highlight
        anchors.fill: parent
        color: Theme.get.barBgColor
      }

      implicitHeight: 30
      visible: true

      anchors {
        top: Theme.get.onTop
        bottom: !Theme.get.onTop
        left: true
        right: true
      }
    
      RowLayout {
        id: allBlocks
        spacing: 0
        anchors.fill: parent
  
        // Left side
        RowLayout {
          id: leftBlocks
          spacing: 10
          Layout.alignment: Qt.AlignLeft
          Layout.fillWidth: true

          //Blocks.Icon {}
          Blocks.Workspaces {}
        }

        Blocks.ActiveWorkspace {
          id: activeWorkspace
          Layout.leftMargin: 10
          anchors.centerIn: undefined

          // Calculate max available width preventing overlap
          property real maxWidth: Math.max(0, parent.width - leftBlocks.implicitWidth - rightBlocks.implicitWidth - 200)
          Layout.preferredWidth: maxWidth
          width: Math.min(implicitWidth, maxWidth)
          elide: Text.ElideRight
          color: {
            const currentWs = CompositorService.getCurrentWorkspace();
            return (currentWs && currentWs.output === modelData.name) ? "#FFFFFF" : "#CCCCCC";
          }
        }

        Item {
          Layout.fillWidth: true
        }
  
        // Right side
        RowLayout {
          id: rightBlocks
          spacing: 0
          Layout.alignment: Qt.AlignRight
          Layout.fillWidth: true

          Blocks.SystemTray {}
          Blocks.CpuLoad {}
          Blocks.Memory {}
          Blocks.Sound {}
          Blocks.Battery {}
          Blocks.Temperature {}
          Blocks.KeyboardLayout {} 
          Blocks.Time {}
        }
      }
    }
  }
}

