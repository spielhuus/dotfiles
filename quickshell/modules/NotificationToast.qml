import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.config
import qs.utils

Rectangle {
    id: root

    required property string summary
    required property string body
    required property string iconName
    required property int urgency
    required property int index
    property int timeout: urgency === NotificationUrgency.Critical ? 0 : 5000

    signal requestClose()

    implicitWidth: 350
    implicitHeight: contentLayout.implicitHeight + 20
    color: Config.theme.barBgColor
    radius: 10
    border.width: 1
    border.color: Config.theme.osdBorderColor
    clip: true
    Component.onCompleted: showAnim.start()

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onClicked: (mouse) => {
            hideAnim.start();
        }
    }

    Timer {
        id: dismissTimer

        interval: root.timeout
        running: root.timeout > 0 && !mouseArea.containsMouse
        onTriggered: hideAnim.start()
    }

    // --- Layout ---
    RowLayout {
        id: contentLayout

        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        Image {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            source: {
                if (root.iconName && root.iconName !== "") {
                    if (root.iconName.indexOf("/") === 0)
                        return "file://" + root.iconName;

                    if (root.iconName.indexOf("file:") === 0)
                        return root.iconName;

                    return Quickshell.iconPath(root.iconName, "dialog-information");
                }
                return Quickshell.iconPath(Icons.getNotifIcon(root.summary, root.urgency), "dialog-information");
            }
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.summary
                font.bold: true
                font.pixelSize: Config.theme.fontSize
                color: Config.theme.bar_text_color
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.body
                font.pixelSize: Config.theme.fontSize
                color: Config.theme.bar_text_color
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 3
                Layout.fillWidth: true
                visible: text !== ""
            }

        }

    }

    NumberAnimation {
        id: showAnim

        target: root
        property: "opacity"
        from: 0
        to: 1
        duration: 250
        easing.type: Easing.OutQuad
    }

    SequentialAnimation {
        id: hideAnim

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0
            duration: 250
            easing.type: Easing.InQuad
        }

        ScriptAction {
            script: root.requestClose()
        }

    }

}
