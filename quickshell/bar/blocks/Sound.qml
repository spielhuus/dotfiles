import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import Quickshell.Io
import qs.config
import "../"

BarBlock {
    id: root
    property var sink: null

    // ─── pbpctrl Configuration & State ───────────────────
    property string pbpctrlPath: "pbpctrl"
    
    property var batteryCmd: [pbpctrlPath, "show", "battery"]
    property var ancQueryCmd: [pbpctrlPath, "get", "anc"] // Uses 'get' instead of 'show'
    
    function getSetAncCmd(mode) {
        return [pbpctrlPath, "set", "anc", mode];
      }

    property string pixelBudsAncMode: "off"
    property int pixelBudsBatteryLeft: -1
    property int pixelBudsBatteryRight: -1
    property int pixelBudsBatteryCase: -1

    // Reactive container for connected Pixel Buds
    property var activeBuds: null

    function updateActiveBuds() {
        if (typeof Bluetooth === "undefined" || !Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.devices) {
            root.activeBuds = null;
            return;
        }

        const devs = Bluetooth.defaultAdapter.devices.values;
        if (!devs) {
            root.activeBuds = null;
            return;
        }

        for (let i = 0; i < devs.length; i++) {
            const dev = devs[i];
            if (dev && dev.connected) {
                let name = (dev.name || dev.deviceName || dev.alias || "").toLowerCase();
                if (name.includes("pixel buds")) {
                    if (root.activeBuds !== dev) {
                        console.log("[PixelBuds] Connected: " + (dev.name || dev.alias || "Pixel Buds"));
                        root.activeBuds = dev;
                    }
                    return;
                }
            }
        }

        if (root.activeBuds !== null) {
            console.log("[PixelBuds] Disconnected.");
            root.activeBuds = null;
        }
    }

    onActiveBudsChanged: {
        if (activeBuds !== null) {
            queryPixelBudsState();
        }
    }

    function queryPixelBudsState() {
        // Prevent launching queries if either query is already active or if a write action is running
        if (root.activeBuds !== null && !pbpctrlBatteryQuery.running && !pbpctrlAncQuery.running && !pbpctrlSetAnc.running) {
            pbpctrlBatteryQuery.running = true;
        }
    }

    function setPixelBudsAnc(mode) {
        // Terminate any active background query processes to clear the BlueZ channel for the write command
        if (pbpctrlBatteryQuery.running) pbpctrlBatteryQuery.running = false;
        if (pbpctrlAncQuery.running) pbpctrlAncQuery.running = false;

        pbpctrlSetAnc.command = root.getSetAncCmd(mode);
        pbpctrlSetAnc.running = true;
        root.pixelBudsAncMode = mode; // Optimistic UI update
    }

    // ─── Event-Driven Bluetooth Triggers ─────────────────
    
    // Monitors dynamic connection state changes on all paired devices
    Instantiator {
        model: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.devices : null
        delegate: Connections {
            target: modelData
            ignoreUnknownSignals: true
            function onConnectedChanged() {
                root.updateActiveBuds();
            }
        }
    }

    // Listens for adapter changes
    Connections {
        target: Bluetooth
        ignoreUnknownSignals: true
        function onDefaultAdapterChanged() {
            root.updateActiveBuds();
        }
    }

    // Listens for pairing/unpairing list modifications
    Connections {
        target: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter : null
        ignoreUnknownSignals: true
        function onDevicesChanged() {
            root.updateActiveBuds();
        }
    }

    // ─── Process Utilities ───────────────────────────────

    // Process to query detailed battery percentages (L / R / Case)
    Process {
        id: pbpctrlBatteryQuery
        command: root.batteryCmd
        running: false
        
        // When the battery query completes, trigger the ANC query to avoid parallel BlueZ registration conflicts
        onExited: {
            pbpctrlAncQuery.running = true;
        }

        stdout: StdioCollector {
            onStreamFinished: {
                let textLower = text.toLowerCase();
                let matchL = textLower.match(/left\s*(?:bud)?:\s*(\d+)/i);
                let matchR = textLower.match(/right\s*(?:bud)?:\s*(\d+)/i);
                let matchC = textLower.match(/case:\s*(\d+)/i);
                
                root.pixelBudsBatteryLeft = matchL ? parseInt(matchL[1]) : -1;
                root.pixelBudsBatteryRight = matchR ? parseInt(matchR[1]) : -1;
                root.pixelBudsBatteryCase = matchC ? parseInt(matchC[1]) : -1;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.error("[PixelBuds] Battery query error:\n" + text.trim());
                }
            }
        }
    }

    // Process to query active noise control mode
    Process {
        id: pbpctrlAncQuery
        command: root.ancQueryCmd
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let textLower = text.toLowerCase().trim();
                if (textLower.includes("active") || (textLower.includes("noise") && textLower.includes("cancel"))) {
                    root.pixelBudsAncMode = "active";
                } else if (textLower.includes("transparency")) {
                    root.pixelBudsAncMode = "transparency";
                } else if (textLower.includes("off")) {
                    root.pixelBudsAncMode = "off";
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.error("[PixelBuds] ANC query error:\n" + text.trim());
                }
            }
        }
    }

    // Process to apply the selected ANC state
    Process {
        id: pbpctrlSetAnc
        running: false
        
        // Once the change is written, trigger a refresh to synchronize the final state on the UI
        onExited: {
            root.queryPixelBudsState();
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.error("[PixelBuds] Set ANC error:\n" + text.trim());
                }
            }
        }
    }
    // Poll battery & settings gently only when the menu window is open
    Timer {
        id: pixelBudsPollTimer
        interval: 15000 // Checked every 15 seconds
        running: menuWindow.visible && root.activeBuds !== null
        repeat: true
        onTriggered: {
            root.queryPixelBudsState();
        }
    }

    function updateSink() {
        const currentSink = Pipewire.defaultAudioSink;
        if (currentSink !== sink) {
            sink = currentSink;
        }
    }

    Component.onCompleted: {
        updateSink();
        updateActiveBuds();
    }

    // Hook into Pipewire default audio route changes (syncs on connection)
    Connections {
        target: Pipewire
        ignoreUnknownSignals: true
        function onDefaultAudioSinkChanged() {
            root.updateSink();
            root.updateActiveBuds();
        }
    }

    PwObjectTracker { 
        objects: root.sink ? [root.sink] : []
    }

    readonly property real volume: {
        if (sink && sink.audio && typeof sink.audio.volume === "number" && !isNaN(sink.audio.volume)) {
            return sink.audio.volume;
        }
        return 0;
    }
    readonly property bool muted: {
        if (sink && sink.audio && typeof sink.audio.muted === "boolean") {
            return sink.audio.muted;
        }
        return false;
    }

    content: BarText { 
        symbolText: root.muted 
            ? "󰖁" 
            : `󰕾 ${Math.round(root.volume * 100)}%`
        color: root.muted ? Config.theme.inactive : Config.theme.normal
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: toggleMenu()
        onWheel: function(event) {
            if (sink?.audio) {
                sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + (event.angleDelta.y / 120) * 0.05))
            }
        }
    }

    Process {
        id: pavucontrol
        command: ["pavucontrol"]
        running: false
    }

    PopupWindow {
        id: menuWindow
        visible: false
        color: "transparent"
        grabFocus: true

        anchor.window: root.QsWindow?.window ?? null
        anchor.rect.x: root.QsWindow?.window ? (root.mapToGlobal(root.width / 2, 0).x - width / 2) : 0
        anchor.rect.y: root.QsWindow?.window ? root.mapToGlobal(0, root.height).y : 0

        implicitWidth: popupContent.implicitWidth
        implicitHeight: popupContent.implicitHeight

        onVisibleChanged: {
            if (visible) {
                root.updateActiveBuds();
                root.queryPixelBudsState();
            }
        }

        Pane {
            id: popupContent
            implicitWidth: 340
            
            topPadding: 16
            bottomPadding: 16
            leftPadding: 20  
            rightPadding: 20 

            Connections {
                target: popupContent.QsWindow ? popupContent.QsWindow.window : null
                ignoreUnknownSignals: true
                
                function onActiveChanged() {
                    if (target && !target.active && menuWindow.visible) {
                        menuWindow.visible = false;
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

                // --- Volume Header ---
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Volume"
                        font.bold: true
                        color: Config.theme.text
                        font.family: Config.theme.fontFamily
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: root.muted ? "Muted" : `${Math.round(root.volume * 100)}%`
                        color: Config.theme.subtext
                        font.family: Config.theme.fontFamily
                        font.pixelSize: 12
                    }
                }

                // --- Volume Slider ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: root.muted ? "󰖁" : "󰕾"
                        font.family: Config.theme.fontSymbol
                        font.pixelSize: 18
                        color: root.muted ? Config.theme.inactive : Config.theme.iconColor
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        from: 0
                        to: 1
                        value: root.volume
                        
                        onMoved: {
                            if (sink?.audio) {
                                sink.audio.volume = value
                            }
                        }

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: volumeSlider.availableWidth
                            height: 6
                            radius: 3
                            color: Config.theme.border

                            Rectangle {
                                width: volumeSlider.visualPosition * parent.width
                                height: parent.height
                                color: root.muted ? Config.theme.inactive : Config.theme.iconColor
                                radius: 3
                            }
                        }

                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: 16
                            height: 16
                            radius: 8
                            color: volumeSlider.pressed ? Config.theme.iconPressedColor : "#ffffff"
                            border.color: Config.theme.border
                            border.width: 1
                        }
                    }
                }

                // ─── Pixel Buds Advanced Panel (pbpctrl) ───────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: root.activeBuds !== null

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Config.theme.border
                    }

                    // Pixel Buds Identifier & Individual Batteries
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Label {
                            text: root.activeBuds ? (root.activeBuds.name || root.activeBuds.deviceName || root.activeBuds.alias || "Pixel Buds") : "Pixel Buds"
                            font.bold: true
                            color: Config.theme.text
                            font.family: Config.theme.fontFamily
                            font.pixelSize: 13
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Detailed Battery Readout (L / R / Case) from pbpctrl
                        RowLayout {
                            spacing: 8
                            visible: root.pixelBudsBatteryLeft !== -1
                            
                            Label {
                                text: `L: ${root.pixelBudsBatteryLeft}%`
                                font.pixelSize: 11
                                color: Config.theme.subtext
                                font.family: Config.theme.fontFamily
                            }
                            Label {
                                text: `R: ${root.pixelBudsBatteryRight}%`
                                font.pixelSize: 11
                                color: Config.theme.subtext
                                font.family: Config.theme.fontFamily
                            }
                            Label {
                                text: `C: ${root.pixelBudsBatteryCase}%`
                                font.pixelSize: 11
                                color: Config.theme.subtext
                                font.family: Config.theme.fontFamily
                            }
                        }

                        // Fallback Single Battery Readout from Bluez
                        Label {
                            visible: root.pixelBudsBatteryLeft === -1 && (root.activeBuds?.batteryAvailable ?? false)
                            text: ` ${Math.round((root.activeBuds?.battery ?? 0) * 100)}%`
                            color: Config.theme.subtext
                            font.family: Config.theme.fontFamily
                            font.pixelSize: 12
                        }
                    }

                    // Noise Cancellation Option Selectors
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [
                                { name: "ANC", value: "active", icon: "󱫯" }, // Value mapped to "active"
                                { name: "Transparency", value: "transparency", icon: "󱫰" },
                                { name: "Off", value: "off", icon: "󰋌" }
                            ]
                            delegate: Button {
                                id: ancBtn
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                flat: true

                                background: Rectangle {
                                    color: root.pixelBudsAncMode === modelData.value
                                        ? Config.theme.iconColor
                                        : (ancBtn.hovered ? Config.theme.chatBgHover : "transparent")
                                    radius: 6
                                    border.color: root.pixelBudsAncMode === modelData.value ? "transparent" : Config.theme.border
                                    border.width: 1

                                    Behavior on color {
                                        ColorAnimation { duration: 100 }
                                    }
                                }

                                contentItem: RowLayout {
                                    spacing: 6
                                    anchors.centerIn: parent
                                    Text {
                                        text: modelData.icon
                                        font.family: Config.theme.fontSymbol
                                        font.pixelSize: 14
                                        color: root.pixelBudsAncMode === modelData.value ? "#1e1e1e" : Config.theme.text
                                    }
                                    Label {
                                        text: modelData.name
                                        font.family: Config.theme.fontFamily
                                        font.pixelSize: 11
                                        font.bold: root.pixelBudsAncMode === modelData.value
                                        color: root.pixelBudsAncMode === modelData.value ? "#1e1e1e" : Config.theme.text
                                    }
                                }

                                onClicked: root.setPixelBudsAnc(modelData.value)
                            }
                        }
                    }
                }

                // --- Separator Line ---
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Config.theme.border
                }

                // --- Standard Mixer Actions List ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: [
                            { 
                                text: root.muted ? "Unmute" : "Mute", 
                                icon: root.muted ? "󰖁" : "󰝟", 
                                action: () => sink?.audio && (sink.audio.muted = !sink.audio.muted) 
                            },
                            { 
                                text: "Audio Mixer (Pavucontrol)", 
                                icon: "󰓃", 
                                action: () => { pavucontrol.running = true; menuWindow.visible = false } 
                            }
                        ]

                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38

                            Rectangle {
                                anchors.fill: parent
                                color: itemMouseArea.containsMouse ? Config.theme.chatBgHover : "transparent"
                                radius: 6

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }

                            MouseArea {
                                id: itemMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    modelData.action()
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 12

                                Text {
                                    text: modelData.icon
                                    font.family: Config.theme.fontSymbol
                                    font.pixelSize: 16
                                    color: Config.theme.subtext
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Label {
                                    text: modelData.text
                                    color: Config.theme.text
                                    font.family: Config.theme.fontFamily
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function toggleMenu() {
        menuWindow.visible = !menuWindow.visible
    }
}
