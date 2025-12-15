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
      // Toggle visibility of all bar instances
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

      height: 30

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

          // Calculate available space and pass it as chopLength
          chopLength: {
            var space = Math.floor(bar.width - (rightBlocks.implicitWidth + leftBlocks.implicitWidth))
            return Math.max(10, Math.floor(space * 0.08));
          }

          // The complex 'text' and 'color' bindings are now handled internally 
          // or have been simplified to work across compositors.
          color: {
            // This logic is also made more generic
            const currentWs = CompositorService.getCurrentWorkspace();
            return (currentWs && currentWs.output === modelData.name) ? "#FFFFFF" : "#CCCCCC";
          }
        }

        // Without this filler item, the active window block will be centered
        // despite setting left alignment
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
          // Blocks.Date {}
          Blocks.Time {}
          Blocks.Logout {}
        }
      }
    }
  }
}

