import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland

PanelWindow {
    id: window

    implicitWidth: 350
    implicitHeight: Screen.height
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 10
        right: 10
    }

    ListModel {
        id: notificationModel
    }

    NotificationServer {
        id: server

        onNotification: (notif) => {
            notificationModel.insert(0, {
                "id": notif.id,
                "summary": notif.summary,
                "body": notif.body,
                "urgency": notif.urgency,
                "icon": notif.icon || ""
            });
        }
    }

    ColumnLayout {
        id: listContainer

        width: parent.width
        spacing: 10

        Repeater {
            model: notificationModel
            Layout.fillWidth: true

            delegate: NotificationToast {
                summary: notificationModel.get(index).summary
                body: notificationModel.get(index).body
                iconName: notificationModel.get(index).icon
                urgency: notificationModel.get(index).urgency
                index: index
                onRequestClose: {
                    notificationModel.remove(index);
                }
            }

        }

    }

    mask: Region {
        item: listContainer
    }

}
