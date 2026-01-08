import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../"

BarBlock {
    id: root
    Layout.preferredWidth: 30
    
    content: BarText {
        text: "󰣇"
        pointSize: 20
        anchors.centerIn: parent
    }

    color: "transparent"

    // Use Quickshell's native model
    property var appModel: DesktopEntries.applications.values

    PopupWindow {
        id: menuWindow
        width: 300
        height: 400
        visible: false
        color: "transparent" // Let content handle color

        anchor {
            window: root.QsWindow?.window
            edges: Edges.Bottom
            gravity: Edges.Top
        }

        // Close when clicking outside
        MouseArea {
            anchors.fill: parent
            onClicked: menuWindow.visible = false
            z: -1
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.get.barBgColor
            border.color: Theme.get.buttonBorderColor
            border.width: 1
            radius: 4
            clip: true

            ListView {
                id: appListView
                anchors.fill: parent
                anchors.margins: 5
                clip: true
                spacing: 2
                
                // Filter out non-gui apps if needed, or simply use the whole list
                model: root.appModel

                delegate: ItemDelegate {
                    width: parent.width
                    height: 35
                    
                    background: Rectangle {
                        color: parent.hovered ? Theme.get.buttonBackgroundColor : "transparent"
                        radius: 4
                    }

                    contentItem: RowLayout {
                        spacing: 10
                        Image {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            text: modelData.name
                            color: "white"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    onClicked: {
                        modelData.execute() // Native Quickshell execution
                        menuWindow.visible = false
                    }
                }
            }
        }
    }

    onClicked: menuWindow.visible = !menuWindow.visible
}
