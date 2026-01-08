import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects 
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Variants {
  id: root

  property bool visible: false
  property color backgroundColor: "#e60c0c0c"
  property color buttonColor: "#1e1e1e"
  property color buttonHoverColor: "#3700b3" // Highlight color

  default property list<LogoutButton> buttons

  model: Quickshell.screens

  PanelWindow {
    id: w
    property var modelData
    screen: modelData

    property int currentIndex: 0
    property int gridColumns: 3

    visible: root.visible

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"

    anchors { top: true; bottom: true; left: true; right: true }

    onVisibleChanged: {
      if (visible) {
        w.currentIndex = 0
        inputHandler.forceActiveFocus()
      }
    }

    contentItem {
      id: inputHandler
      focus: true
      Keys.onPressed: event => {
        // --- Navigation Logic ---
        if (event.key == Qt.Key_Left) {
          w.currentIndex = Math.max(0, w.currentIndex - 1)
        } 
        else if (event.key == Qt.Key_Right) {
          w.currentIndex = Math.min(root.buttons.length - 1, w.currentIndex + 1)
        } 
        else if (event.key == Qt.Key_Up) {
          if (w.currentIndex - w.gridColumns >= 0) 
          w.currentIndex -= w.gridColumns
        } 
        else if (event.key == Qt.Key_Down) {
          if (w.currentIndex + w.gridColumns < root.buttons.length) 
          w.currentIndex += w.gridColumns
        }

        // --- Action Logic ---
        else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
          root.buttons[w.currentIndex].exec()
          root.visible = false
        }
        else if (event.key == Qt.Key_Escape) {
          root.visible = false
        } 

        // --- Hotkey Logic (Existing) ---
        else {
          for (let i = 0; i < buttons.length; i++) {
            let button = buttons[i];
            if (event.key == button.keybind) {
              button.exec();
              root.visible = false
              event.accepted = true;
              return;
            }
          }
        }
      }
    }

    Rectangle {
      color: root.backgroundColor
      anchors.fill: parent

      MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false

        GridLayout {
          anchors.centerIn: parent
          width: parent.width * 0.5 //0.75
          height: parent.height * 0.5 //0.75

          // Use the property so logic matches layout
          columns: w.gridColumns 

          Repeater {
            model: root.buttons
            delegate: Rectangle {
              required property LogoutButton modelData;
              required property int index; // Access the index provided by Repeater

              Layout.fillWidth: true
              Layout.fillHeight: true
              property bool isSelected: w.currentIndex === index

              // MODIFIED: Background always transparent
              color: "transparent"

              // MODIFIED: No border
              border.width: 0

              MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true

                // Sync mouse hover with keyboard selection
                onEntered: w.currentIndex = index

                onClicked: {
                  modelData.exec()
                  root.visible = false
                }
              }

              // Group Icon and Text to scale them together
              Item {
                id: contentContainer
                anchors.centerIn: parent
                width: parent.width
                height: parent.height

                // Scale increases when selected/hovered to provide visual feedback
                scale: (parent.isSelected || ma.containsMouse) ? 1.25 : 1.0
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                // Icon + White Overlay
                Item {
                    id: iconContainer
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -20 // Shift up slightly to make room for text
                    width: parent.width * 0.25
                    height: parent.width * 0.25

                    Image {
                    id: icon
                    anchors.fill: parent
                    source: `../../assets/icons/${modelData.icon}.svg`
                    fillMode: Image.PreserveAspectFit
                    visible: false 
                    smooth: true
                    }
                    ColorOverlay {
                    anchors.fill: icon
                    source: icon
                    color: "white"
                    }
                }

                Text {
                    anchors {
                    top: iconContainer.bottom 
                    topMargin: 20
                    horizontalCenter: parent.horizontalCenter
                    }
                    text: modelData.text
                    font.pointSize: 20
                    color: "white"
                }
              }
            }
          }
        }
      }
    }
  }
}
