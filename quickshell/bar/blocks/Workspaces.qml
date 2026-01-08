import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services.Compositor

RowLayout {
  Rectangle {
    id: workspaceBar
    Layout.preferredWidth: row.width + 10
    Layout.preferredHeight: 30
    color: "transparent"

    Row {
      id: row
      anchors.centerIn: parent
      spacing: 5

      Repeater {
        id: wsRepeater
        model: CompositorService.workspaces

        Rectangle {
          id: wsDelegate
          required property int index
          required property bool isFocused
          required property int idx 

          property bool focused: wsDelegate.isFocused
          property int workspaceId: wsDelegate.idx
          width: 25
          height: 30
          radius: 4

          color: mouseArea.containsMouse ? Config.theme.barHover : "transparent"

          Behavior on color {
            ColorAnimation { duration: 150 }
          }

          Text {
            anchors.centerIn: parent
            visible: true 
            text: workspaceId.toString()
            color: Config.theme.bar_text_color
            font.pixelSize: Config.theme.bar_font_size
            font.bold: focused
            font.family: Config.theme.fontFamily
          }

          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: CompositorService.switchToWorkspace(CompositorService.workspaces.get(index))
          }
        }
      }
    }
  }
}
