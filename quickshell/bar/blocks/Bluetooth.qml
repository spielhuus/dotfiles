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
  property bool isPowered: {
    if (adapter && typeof adapter.enabled === "boolean") {
        return adapter.enabled;
    }
    return false;
  }
  property int connectedCount: {
    if (adapter && adapter.devices && typeof adapter.devices.length === "number") {
        return adapter.devices.length;
    }
    return 0;
  }

  content: BarText {
    symbolText: {
      if (!isPowered) return "󰂯"
      if (adapter && adapter.discovering) return "󰂰"
      if (connectedCount === 0) return "󰂲"
      return "󰂱"
    }
    color: isPowered
    ? (adapter && adapter.discovering ? Config.theme.iconColor : (connectedCount > 0 ? Config.theme.ok : Config.theme.normal))
    : Config.theme.inactive
  }

  onClicked: () => { devicePopup.visible = !devicePopup.visible }

  // ─── Popup Window ──────────────────────────────────────
  PopupWindow {
    id: devicePopup
    visible: false
    color: "transparent"
    grabFocus: true

    // Synchronize anchor and positioning settings exactly with the volume menu
    anchor {
      window: root.QsWindow?.window ?? null
      rect.x: root.QsWindow?.window ? (root.mapToGlobal(root.width / 2, 0).x - width / 2) : 0
      rect.y: root.QsWindow?.window ? root.mapToGlobal(0, root.height).y : 0
      edges: Edges.Bottom
      gravity: Edges.Bottom
    }

    implicitWidth: popupContent.implicitWidth
    implicitHeight: popupContent.implicitHeight

    // Auto-hide scanning when popup closed
    onVisibleChanged: if (!visible && adapter && adapter.discovering) adapter.discovering = false

    Pane {
      id: popupContent
      implicitWidth: 440
      
      topPadding: 16
      bottomPadding: 16
      leftPadding: 20  
      rightPadding: 20 

      // Explicitly set base font configurations for the container
      font.family: Config.theme.fontFamily
      font.pixelSize: 13

      // --- Hoisted Connection State & Timers ---
      // This prevents the timers from being destroyed when the ListView refreshes
      property string connectingDeviceId: ""
      property string failedDeviceId: ""

      Timer {
        id: sharedConnectionTimer
        interval: 15000 
        repeat: false
        onTriggered: {
          popupContent.failedDeviceId = popupContent.connectingDeviceId;
          popupContent.connectingDeviceId = "";
          sharedFailureTimer.restart();
        }
      }

      Timer {
        id: sharedFailureTimer
        interval: 5000 
        repeat: false
        onTriggered: popupContent.failedDeviceId = ""
      }

      Timer {
        id: sharedDelayTimer
        interval: 500 
        repeat: false
        onTriggered: {
          if (!adapter || !adapter.devices) return;
          let found = false;
          // Find the device again in case the list was recreated
          for (let i = 0; i < adapter.devices.length; i++) {
            let d = adapter.devices[i];
            let dId = d.address || d.name || d.deviceName || "Unknown";
            if (dId === popupContent.connectingDeviceId) {
              d.connected = true;
              sharedConnectionTimer.start();
              found = true;
              break;
            }
          }
          // Failsafe if device vanished
          if (!found) {
            popupContent.failedDeviceId = popupContent.connectingDeviceId;
            popupContent.connectingDeviceId = "";
            sharedFailureTimer.restart();
          }
        }
      }
      // ------------------------------------------

      // Capture focus loss of the native window object
      Connections {
        target: popupContent.QsWindow ? popupContent.QsWindow.window : null
        ignoreUnknownSignals: true
        
        function onActiveChanged() {
          if (target && !target.active && devicePopup.visible) {
            devicePopup.visible = false;
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

        // Header
        RowLayout {
          Label {
            text: "Bluetooth"
            font.family: Config.theme.fontFamily
            font.pixelSize: 14
            font.bold: true
            color: Config.theme.text
          }
          Item { Layout.fillWidth: true }
          
          // Power toggle
          Text {
            text: isPowered ? "󰂱" : "󰂯"
            font.family: Config.theme.fontSymbol
            font.pixelSize: 16
            color: Config.theme.text
            
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (adapter) adapter.enabled = !adapter.enabled
            }
          }
        }

        // Scan button (changed to Item to support stacked overlays)
        Item {
          id: scanButtonRow
          visible: isPowered
          Layout.fillWidth: true
          Layout.preferredHeight: 38

          Rectangle {
            anchors.fill: parent
            color: (scanMouseArea.containsMouse && !adapter?.discovering) ? Config.theme.chatBgHover : "transparent"
            radius: 6

            Behavior on color {
              ColorAnimation { duration: 100 }
            }
          }

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 12

            Text {
              id: scanButtonIcon
              text: adapter?.discovering ? "" : "󰂰"
              font.family: Config.theme.fontSymbol
              font.pixelSize: 16
              color: adapter?.discovering ? Config.theme.subtext : Config.theme.text
              transformOrigin: Item.Center

              NumberAnimation {
                target: scanButtonIcon
                property: "rotation"
                from: 0
                to: 360
                duration: 1200
                running: adapter?.discovering === true
                loops: Animation.Infinite
                onRunningChanged: {
                  if (!running) {
                    scanButtonIcon.rotation = 0;
                  }
                }
              }
            }

            Label {
              text: adapter?.discovering ? "Scanning for devices..." : "Scan for devices"
              font.family: Config.theme.fontFamily
              font.pixelSize: 13
              color: adapter?.discovering ? Config.theme.subtext : Config.theme.text
              Layout.fillWidth: true
            }
          }

          MouseArea {
            id: scanMouseArea
            anchors.fill: parent
            hoverEnabled: !adapter?.discovering
            enabled: !adapter?.discovering
            cursorShape: adapter?.discovering ? Qt.ArrowCursor : Qt.PointingHandCursor
            onClicked: if (adapter) adapter.discovering = true
          }
        }

        // Connected devices list header
        Label {
          text: "Connected Devices"
          font.family: Config.theme.fontFamily
          font.pixelSize: 12
          font.bold: true
          color: Config.theme.text
          visible: connectedCount > 0
        }

        // Device list
        ListView {
          id: deviceListView
          model: adapter?.devices ?? []
          
          // Displayed count logic prevents the ListView from collapsing to 0 height
          // when the model briefly empties out during the backend reload
          property int displayedCount: count > 0 ? count : (popupContent.connectingDeviceId !== "" ? 1 : 0)
          
          visible: displayedCount > 0
          Layout.fillWidth: true
          Layout.preferredHeight: Math.min(displayedCount * 50, 200)
          clip: true

          delegate: Item {
            id: delegateItem
            width: deviceListView.width
            height: 50

            // Expose device reliably
            readonly property var device: modelData
            readonly property string devId: device ? (device.address || device.name || device.deviceName || "Unknown") : "Unknown"
            
            // Check global UI state instead of keeping it in the delegate
            readonly property bool isConnecting: popupContent.connectingDeviceId === devId
            readonly property bool showFailed: popupContent.failedDeviceId === devId

            Connections {
              target: delegateItem.device
              ignoreUnknownSignals: true
              
              function onConnectedChanged() {
                if (delegateItem.isConnecting && delegateItem.device && delegateItem.device.connected) {
                  popupContent.connectingDeviceId = "";
                  sharedConnectionTimer.stop();
                }
              }
            }

            // Hover indicator background
            Rectangle {
              anchors.fill: parent
              color: itemMouseArea.containsMouse ? Config.theme.chatBgHover : "transparent"
              radius: 6
              
              Behavior on color {
                ColorAnimation { duration: 100 }
              }
            }

            // Entire row mouse interaction area
            MouseArea {
              id: itemMouseArea
              anchors.fill: parent
              hoverEnabled: !delegateItem.isConnecting
              enabled: !delegateItem.isConnecting 
              cursorShape: delegateItem.isConnecting ? Qt.ArrowCursor : Qt.PointingHandCursor
              onClicked: {
                if (!delegateItem.device) return;

                if (delegateItem.device.connected) {
                  delegateItem.device.connected = false;
                } else {
                  popupContent.connectingDeviceId = delegateItem.devId;
                  popupContent.failedDeviceId = "";
                  
                  // Check if scanning is active and stop it first
                  if (adapter && adapter.discovering) {
                    adapter.discovering = false;
                    sharedDelayTimer.restart();
                  } else {
                    delegateItem.device.connected = true;
                    sharedConnectionTimer.start();
                  }
                }
              }
            }

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 10
              anchors.rightMargin: 10
              spacing: 12

              // Device icon
              Image {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                source: Quickshell.iconPath(delegateItem.device?.icon || "bluetooth")
                fillMode: Image.PreserveAspectFit
                opacity: delegateItem.isConnecting ? 0.5 : 1.0
              }

              // Device info
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                  text: delegateItem.device ? (delegateItem.device.name || delegateItem.device.deviceName || "Unknown") : "Unknown"
                  font.family: Config.theme.fontFamily
                  font.pixelSize: 13
                  color: Config.theme.text
                  font.weight: delegateItem.device?.connected ? Font.Bold : Font.Normal
                  elide: Text.ElideRight
                  Layout.fillWidth: true
                }
                
                // Status subtext
                Label {
                  Layout.fillWidth: true
                  font.family: Config.theme.fontFamily
                  font.pixelSize: 10
                  
                  text: {
                    if (delegateItem.isConnecting) return "Connecting...";
                    if (delegateItem.showFailed) return "Connection failed";
                    if (delegateItem.device?.batteryAvailable) return " " + Math.round(delegateItem.device.battery * 100) + "%";
                    return "";
                  }
                  
                  color: {
                    if (delegateItem.showFailed) return "#ff5555";
                    if (delegateItem.isConnecting) return "#4a9eff";
                    return Config.theme.subtext;
                  }
                  
                  visible: delegateItem.isConnecting || delegateItem.showFailed || (delegateItem.device && delegateItem.device.batteryAvailable)
                }
              }

              // Connect/disconnect status icon
              Text {
                id: statusIcon
                text: delegateItem.isConnecting ? "" : (delegateItem.device?.connected ? "󰌾" : "󰂲")
                font.family: Config.theme.fontSymbol
                font.pixelSize: 18
                color: {
                  if (delegateItem.isConnecting) return "#4a9eff";
                  if (delegateItem.device?.connected) return Config.theme.ok;
                  return Config.theme.text;
                }
                Layout.alignment: Qt.AlignVCenter
                transformOrigin: Item.Center

                // Spinner rotation animation
                NumberAnimation {
                  target: statusIcon
                  property: "rotation"
                  from: 0
                  to: 360
                  duration: 1200
                  running: delegateItem.isConnecting
                  loops: Animation.Infinite
                  
                  onRunningChanged: {
                    if (!running) {
                      statusIcon.rotation = 0;
                    }
                  }
                }
              }
            }
          }
        }

        // Empty state
        Label {
          // Keep it hidden if we're actively attempting to connect
          visible: isPowered && deviceListView.count === 0 && !(adapter?.discovering) && popupContent.connectingDeviceId === ""
          text: "No devices connected"
          font.family: Config.theme.fontFamily
          font.pixelSize: 13
          color: Config.theme.subtext
          
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignHCenter
        }
      }
    }
  }
}
