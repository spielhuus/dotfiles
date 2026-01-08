import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: root

    property var filteredApps: []

    function loadApps() {
        const apps = DesktopEntries.applications.values;
        const query = (searchInput.text || "").toLowerCase();
        let result = [];
        if (apps.length === 0)
            return ;

        for (let i = 0; i < apps.length; i++) {
            const app = apps[i];
            if (query === "") {
                result.push(app);
                continue;
            }
            const matchName = app.name && app.name.toLowerCase().includes(query);
            const matchGeneric = app.genericName && app.genericName.toLowerCase().includes(query);
            const matchExec = app.execString && app.execString.toLowerCase().includes(query);
            if (matchName || matchGeneric || matchExec)
                result.push(app);

        }
        filteredApps = result;
        if (filteredApps.length > 0)
            grid.currentIndex = 0;
        else
            grid.currentIndex = -1;
    }

    function launchApp(appObject) {
        if (appObject) {
            appObject.execute();
            root.visible = false;
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"
    visible: false
    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            searchInput.forceActiveFocus();
            loadApps();
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Shortcut {
        enabled: root.visible
        sequence: "Escape"
        onActivated: root.visible = false
    }

    IpcHandler {
        function toggle() {
            root.visible = !root.visible;
        }

        target: "AppLauncher"
    }

    Connections {
        function onValuesChanged() {
            if (root.visible)
                loadApps();

        }

        target: DesktopEntries.applications
    }

    Rectangle {
        anchors.fill: parent
        color: Config.theme.barBgColor

        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false
        }

    }

    Rectangle {
        width: 800
        height: 600
        anchors.centerIn: parent
        color: Config.theme.buttonBgColor
        border.color: Config.theme.buttonBorderColor
        border.width: 1
        radius: 10
        clip: true

        // Prevent clicks inside container from closing
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Search Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Config.theme.buttonBgColor
                radius: 8
                border.color: searchInput.activeFocus ? Config.theme.iconColor : Config.theme.buttonBorderColor
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Text {
                        text: ""
                        color: "#888"
                        font.family: Config.theme.fontSymbol
                        font.pixelSize: 18
                    }

                    TextInput {
                        id: searchInput

                        Layout.fillWidth: true
                        color: "white"
                        font.pixelSize: 16
                        selectByMouse: true
                        focus: true
                        onTextChanged: loadApps()
                        Keys.onPressed: (event) => {
                            if (filteredApps.length === 0)
                                return ;

                            let columns = Math.floor(grid.width / grid.cellWidth);
                            if (columns < 1)
                                columns = 1;

                            let idx = grid.currentIndex;
                            let count = filteredApps.length;
                            if (event.key === Qt.Key_Down) {
                                if (idx === -1) {
                                    grid.currentIndex = 0;
                                } else {
                                    let next = idx + columns;
                                    // Prevent jumping to a non-existent item
                                    if (next < count)
                                        grid.currentIndex = next;

                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up) {
                                if (idx === -1) {
                                    grid.currentIndex = 0;
                                } else {
                                    let prev = idx - columns;
                                    if (prev >= 0)
                                        grid.currentIndex = prev;

                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Right) {
                                if (idx === -1)
                                    grid.currentIndex = 0;
                                else if (idx < count - 1)
                                    grid.currentIndex = idx + 1;
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Left) {
                                if (idx === -1)
                                    grid.currentIndex = 0;
                                else if (idx > 0)
                                    grid.currentIndex = idx - 1;
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (idx >= 0 && idx < count)
                                    launchApp(filteredApps[idx]);

                                event.accepted = true;
                            }
                        }
                    }

                }

            }

            // App Grid
            GridView {
                id: grid

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: 120
                cellHeight: 130
                model: filteredApps
                focus: false
                highlightFollowsCurrentItem: true

                // Selection Highlight
                highlight: Rectangle {
                    color: "#33ffffff"
                    radius: 8
                    visible: grid.currentItem !== null
                }

                // Access data via `modelData` since we are using a JS array
                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        id: itemBg

                        anchors.fill: parent
                        anchors.margins: 5
                        color: "transparent"
                        // Scale effect on selection
                        scale: GridView.isCurrentItem ? 1.05 : 1

                        // Interaction
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            // Sync mouse hover to keyboard selection
                            onEntered: grid.currentIndex = index
                            onClicked: launchApp(modelData)
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            width: parent.width - 10

                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: "white"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                            }

                        }

                    }

                }

                ScrollBar.vertical: ScrollBar {
                    active: true
                    width: 10

                    background: Rectangle {
                        color: "transparent"
                    }

                    contentItem: Rectangle {
                        color: Config.theme.buttonBorderColor
                        radius: 5
                    }

                }

            }

        }

    }

}
