import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

Scope {
  id: root

  Loader {
    id: sidebarLoader
    active: true

    sourceComponent: PanelWindow {
      id: sidebarRoot

      anchors.left: true
      anchors.top: true
      anchors.bottom: true

      implicitWidth: 250
      color: "#282A36" // A dark background color

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        // 1. Title Label
        // Label {
        //   text: "My Sidebar"
        //   font.pixelSize: 20
        //   font.bold: true
        //   color: "#F8F8F2" // Light text color
        //   Layout.alignment: Qt.AlignHCenter // Center the label
        // }

        Clock {
          id: clock
          Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#44475A"
        }

        SidebarButton {
          text: "Home"
          // In a real app, you would add an onClicked handler
          // onClicked: { ... }
        }

        SidebarButton {
          text: "Settings"
        }

        SidebarButton {
          text: "About"
        }

        // Spacer to push content to the top
        Item {
          Layout.fillHeight: true
        }

      }
    }
  }

  // --- Reusable Button Component ---
  component SidebarButton: Rectangle {
    required property string text
    implicitWidth: 120
    implicitHeight: 40
    Layout.alignment: Qt.AlignHCenter
    color: "#44475A" // Button color
    radius: 5

    Text {
      anchors.centerIn: parent
      text: parent.text
      color: "#F8F8F2"
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: parent.color = "#6272A4"
      onExited: parent.color = "#44475A"
    }
  }

  component Clock: Text {
    // Update the time every second
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
    }

    Component.onCompleted: {
        text = Qt.formatDateTime(new Date(), "hh:mm:ss")
    }

    color: "#8BE9FD" // Cyan color for the clock
    font.pixelSize: 18
    font.family: "monospace"
  }

  IpcHandler {
    target: "sidebarLeft"

    function toggle(): void {
      console.log("toggle called inside sidebar")
      GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen
    }

    function close(): void {
      GlobalStates.sidebarLeftOpen = false
    }

    function open(): void {
      GlobalStates.sidebarLeftOpen = true
    }
  }
}
