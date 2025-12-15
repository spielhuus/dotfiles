import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import qs.services.Compositor
import "root:/" 

RowLayout {
    Rectangle {
        id: workspaceBar
        Layout.preferredWidth: row.width + 30
        Layout.preferredHeight: 23
        radius: 7
        color: Theme.get.barBgColor

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 15

            Repeater {
                id: wsRepeater
                model: CompositorService.workspaces

                Item {
                  id: wsDelegate
                    required property int index
                    required property bool isFocused
                    required property int idx 

                    property bool focused: wsDelegate.isFocused
                    property int workspaceId: wsDelegate.idx
                    width: 20
                    height: 20

                    Text {
                        anchors.centerIn: parent
                        visible: true 
                        text: workspaceId.toString()
                        color: "white"
                        font.pixelSize: 18
                        font.bold: focused
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                     onClicked: CompositorService.switchToWorkspace(CompositorService.workspaces.get(index))}
                }
            }
        }
    }
}
