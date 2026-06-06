import "../"
import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts 
import Quickshell
import Quickshell.Bluetooth
import qs.config

BarBlock {
  id: root
  visible: Bluetooth.defaultAdapter !== undefined

  readonly property var adapter: Bluetooth.defaultAdapter
  property bool isPowered: adapter ? adapter.enabled : false
  property int connectedCount: adapter ? adapter.devices.length : 0

  content: BarText {
    symbolText: {
      if (!isPowered) return "󰂯"
      if (connectedCount === 0) return "󰂲"
      return "󰂱"
    }
    color: isPowered
    ? (connectedCount > 0 ? Config.theme.ok : Config.theme.normal)
    : Config.theme.inactive
  }

  onClicked: devicePopup.visible = !devicePopup.visible

  // ─── Popup Window ──────────────────────────────────────
  PopupWindow {
    id: devicePopup
    anchor.window: root.window
    anchor.rect.x: root.mapToGlobal(root.width/2, 0).x - width/2
    anchor.rect.y: root.mapToGlobal(0, root.height).y
    // grabFocus: true
    visible: false

    // Auto-hide when clicking outside + stop scanning
    onVisibleChanged: if (!visible && adapter && adapter.discovering) adapter.discovering = false

    // ✅ Direct child - NO "content:" assignment
    Container {
      padding: 12
      width: 320
      background: Rectangle {
        color: Config.theme.bg
        radius: 8
        border.color: Config.theme.border
      }

      ColumnLayout {
        spacing: 8
        width: parent.width

        // Header
        RowLayout {
          Label {
            text: "Bluetooth"
            font.bold: true
            color: Config.theme.text
          }
          Item { Layout.fillWidth: true }
          // Power toggle
          Text {
            text: isPowered ? "󰂱" : "󰂯"
            font.pixelSize: 16
            color: Config.theme.text
          MouseArea {
        anchors.fill: parent
        // hoverEnabled: true              // ← REQUIRED for cursor changes to work
        // cursorShape: Qt.PointingHandCursor  // ← MOVE here
        onClicked: if (adapter) adapter.enabled = !adapter.enabled
    }}
        }

        // Scan button (only when powered)
        Text {
          visible: isPowered
          text: adapter?.discovering ? "Scanning..." : "Scan for devices"
          color: adapter?.discovering ? Config.theme.subtext : Config.theme.text
          // cursorShape: adapter?.discovering ? Qt.ArrowCursor : Qt.PointingHandCursor
            MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        // cursorShape: adapter?.discovering ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !adapter?.discovering
        onClicked: if (adapter) adapter.discovering = true
    }}

        // Connected devices list header
        Label {
          text: "Connected Devices"
          font.bold: true
          color: Config.theme.text
          visible: connectedCount > 0
        }

        // Device list
        ListView {
          model: adapter?.devices ?? []
          visible: count > 0
          Layout.fillWidth: true
          implicitHeight: Math.min(count * 50, 200)
          clip: true

          delegate: Item {
            width: parent.width
            height: 50

            RowLayout {
              anchors.fill: parent
              spacing: 10

              // Device icon
              Image {
                source: Quickshell.iconPath(modelData.icon || "bluetooth")
                width: 24; height: 24
                fillMode: Image.PreserveAspectFit
              }

              // Device info
              Column {
                Layout.fillWidth: true
                Label {
                  text: modelData.name || modelData.deviceName || "Unknown"
                  color: Config.theme.text
                  font.weight: modelData.connected ? Font.Bold : Font.Normal
                }
                Label {
                  visible: modelData.batteryAvailable
                  text: " " + Math.round(modelData.battery * 100) + "%"
                  color: Config.theme.subtext
                  font.pointSize: 10
                }
              }

              // Connect/disconnect toggle
              Text {
                text: modelData.connected ? "󰌾" : "󰂲"
                font.pixelSize: 16
                color: Config.theme.text
                  MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        // cursorShape: Qt.PointingHandCursor
        onClicked: modelData.connected = !modelData.connected
    }}
            }
          }
        }

        // Empty state
        Label {
          visible: isPowered && connectedCount === 0 && !(adapter?.discovering)
          text: "No devices connected"
          color: Config.theme.subtext
          horizontalAlignment: Text.AlignHCenter
          Layout.fillWidth: true
        }
      }
    }
  }
}
