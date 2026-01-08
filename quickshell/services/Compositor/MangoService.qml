import QtQml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services.Keyboard

Item {
    id: root

    // ===== PUBLIC INTERFACE =====
    property ListModel workspaces

    workspaces: ListModel {
    }

    property var windows: []
    property int focusedWindowIndex: -1
    property bool initialized: false
    // ===== MANGOSERVICE PROPERTIES =====
    property string selectedMonitor: ""
    property string currentLayoutSymbol: ""
    // ===== TRACKING HELPER =====
    // Helper property to expose toplevels list for Instantiator
    property var toplevelList: ToplevelManager.toplevels.values
    // ===== PROCESSES =====
    property QtObject _eventStream

    _eventStream: Process {
        id: eventStream

        running: false
        command: ["mmsg", "-w"]
        onExited: (code) => {
            if (code !== 0)
                restartTimer.start();

        }

        stdout: SplitParser {
            onRead: (line) => {
                internal.streamBuffer += line + "\n";
                if (line.match(internal.patterns.tagBinary) || line.match(internal.patterns.kbLayout)) {
                    internal.processTagData(internal.streamBuffer);
                    internal.streamBuffer = "";
                }
            }
        }

    }

    property QtObject _restartTimer

    _restartTimer: Timer {
        id: restartTimer

        interval: 2000
        onTriggered: {
            if (root.initialized)
                eventStream.running = true;

        }
    }

    property QtObject _initialQuery

    _initialQuery: Process {
        id: initialQuery

        property string buffer: ""

        command: ["mmsg", "-g", "-t"]
        onExited: (code) => {
            if (code === 0) {
                internal.processTagData(initialQuery.buffer);
                initialQuery.buffer = "";
            } else {
                console.error("MangoService: Initial query failed (code " + code + ")");
            }
        }

        stdout: SplitParser {
            onRead: (line) => {
                return initialQuery.buffer += line + "\n";
            }
        }

    }

    property QtObject _scaleQuery

    _scaleQuery: Process {
        id: scaleQuery

        property string buffer: ""

        command: ["mmsg", "-g", "-A"]
        onExited: (code) => {
            if (code === 0)
                // internal.processScales(scaleQuery.buffer);
                scaleQuery.buffer = "";

        }

        stdout: SplitParser {
            onRead: (line) => {
                return scaleQuery.buffer += line + "\n";
            }
        }

    }

    signal workspaceChanged()
    signal activeWindowChanged()
    signal windowListChanged()
    signal displayScalesChanged()

    function updateWindows() {
        const newWindows = [];
        const toplevels = root.toplevelList || [];
        const activeToplevel = ToplevelManager.activeToplevel;
        let newFocusedIndex = -1;
        for (let i = 0; i < toplevels.length; i++) {
            const toplevel = toplevels[i];
            if (!toplevel)
                continue;

            // Use individual property instead of global activeToplevel comparison
            const isFocused = toplevel.activated;
            const windowData = {
                "id": toplevel.address || `mango-win-${i}`,
                "title": toplevel.title || "",
                "appId": toplevel.appId || "",
                "workspaceId": -1,
                "isFocused": isFocused,
                "output": "",
                "handle": toplevel
            };
            newWindows.push(windowData);
            if (isFocused)
                newFocusedIndex = i;

        }
        root.windows = newWindows;
        // Always update focused index
        root.focusedWindowIndex = newFocusedIndex;
        // CRITICAL: Emit signals to force UI updates even if array length didn't change
        root.activeWindowChanged();
        root.windowListChanged();
    }

    // ===== INITIALIZATION =====
    function initialize() {
        if (initialized)
            return ;

        console.log("MangoService: Initializing...");
        scaleQuery.running = true;
        initialQuery.running = true;
        eventStream.running = true;
        Quickshell.execDetached(["mmsg", "-g", "-o"]);
        initialized = true;
    }

    // ===== Public Functions =====
    function queryDisplayScales() {
        scaleQuery.running = true;
    }

    function switchToWorkspace(ws) {
        Quickshell.execDetached(["mmsg", "-s", "-t", ws.idx.toString()]);
    }

    function focusWindow(w) {
        if (w.handle && typeof w.handle.activate === 'function')
            w.handle.activate();

    }

    function closeWindow(w) {
        if (w.handle && typeof w.handle.close === 'function')
            w.handle.close();

    }

    function logout() {
        Quickshell.execDetached(["mmsg", "-s", "-q"]);
    }

    Connections {
        function onValuesChanged() {
            root.toplevelList = ToplevelManager.toplevels.values;
            root.updateWindows();
        }

        target: ToplevelManager.toplevels
    }

    Connections {
        function onActiveToplevelChanged() {
            root.updateWindows();
        }

        target: ToplevelManager
    }

    // Instantiator ensures we connect to every window's signals regardless of lifecycle
    Instantiator {
        model: root.toplevelList

        delegate: Connections {
            function onTitleChanged() {
                root.updateWindows();
            }

            function onAppIdChanged() {
                root.updateWindows();
            }

            function onActivatedChanged() {
                root.updateWindows();
            }

            target: modelData // The Toplevel object
        }

    }

    // ===== INTERNAL STATE & PROCESSES =====
    QtObject {
        id: internal

        property var tagStates: ({
        })
        property var activeTags: ({
        })
        property var outputIndices: ({
        })
        property int outputCounter: 0
        property string streamBuffer: ""
        // ===== REGEX PATTERNS =====
        readonly property var
        patterns: QtObject {
            readonly property var tagDetail: /^(\S+)\s+tag\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/
            readonly property var tagBinary: /^(\S+)\s+tags\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)/
            readonly property var kbLayout: /^(\S+)\s+kb_layout\s+(.*)$/
            readonly property var selmon: /^(\S+)\s+selmon\s+1/
        }

        // ===== PROCESS TAG DATA =====
        function processTagData(output) {
            const lines = output.trim().split('\n');
            const newTagStates = {
            };
            const newActiveTags = {
            };
            const detailedOutputTags = {
            };
            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();
                if (!line)
                    continue;

                const detailMatch = line.match(patterns.tagDetail);
                if (detailMatch) {
                    const outputName = detailMatch[1];
                    const tagId = parseInt(detailMatch[2]);
                    const state = parseInt(detailMatch[3]);
                    const clients = parseInt(detailMatch[4]);
                    const focused = parseInt(detailMatch[5]);
                    if (!newTagStates[outputName])
                        newTagStates[outputName] = [];

                    detailedOutputTags[`${outputName}-${tagId}`] = true;
                    const isActive = (state & 1) !== 0;
                    const isUrgent = (state & 2) !== 0;
                    if (isActive)
                        newActiveTags[outputName] = tagId;

                    newTagStates[outputName].push({
                        "id": tagId,
                        "state": state,
                        "clients": clients,
                        "focused": focused,
                        "isActive": isActive,
                        "isUrgent": isUrgent
                    });
                    continue;
                }
                const binaryMatch = line.match(patterns.tagBinary);
                if (binaryMatch) {
                    const outputName = binaryMatch[1];
                    const occStr = binaryMatch[2];
                    const selStr = binaryMatch[3];
                    const urgStr = binaryMatch[4];
                    if (!newTagStates[outputName])
                        newTagStates[outputName] = [];

                    const isBinaryString = occStr.length > 5;
                    if (isBinaryString) {
                        const len = occStr.length;
                        for (let j = 0; j < len; j++) {
                            const tagId = j + 1;
                            if (detailedOutputTags[`${outputName}-${tagId}`])
                                continue;

                            const charIdx = len - 1 - j;
                            const isActive = selStr[charIdx] !== '0';
                            const isUrgent = urgStr[charIdx] !== '0';
                            const isOccupied = occStr[charIdx] !== '0';
                            if (isActive)
                                newActiveTags[outputName] = tagId;

                            newTagStates[outputName].push(createTagObj(tagId, isActive, isUrgent, isOccupied));
                        }
                    } else {
                        const occMask = parseInt(occStr);
                        const selMask = parseInt(selStr);
                        const urgMask = parseInt(urgStr);
                        for (let j = 0; j < 32; j++) {
                            const tagId = j + 1;
                            if (detailedOutputTags[`${outputName}-${tagId}`])
                                continue;

                            const bit = (1 << j);
                            const isActive = (selMask & bit) !== 0;
                            const isUrgent = (urgMask & bit) !== 0;
                            const isOccupied = (occMask & bit) !== 0;
                            if (!isActive && !isOccupied && !isUrgent && tagId > 9)
                                continue;

                            if (isActive)
                                newActiveTags[outputName] = tagId;

                            newTagStates[outputName].push(createTagObj(tagId, isActive, isUrgent, isOccupied));
                        }
                    }
                    continue;
                }
                const selmonMatch = line.match(patterns.selmon);
                if (selmonMatch) {
                    root.selectedMonitor = selmonMatch[1];
                    continue;
                }
                const kbMatch = line.match(patterns.kbLayout);
                if (kbMatch) {
                    KeyboardLayoutService.setCurrentLayout(kbMatch[2]);
                    continue;
                }
            }
            if (Object.keys(newTagStates).length > 0) {
                for (const k in newTagStates) internal.tagStates[k] = newTagStates[k]
                for (const k in newActiveTags) internal.activeTags[k] = newActiveTags[k]
                internal.rebuildWorkspaces();
                // Also update windows to refresh focus state based on monitor selection if needed
                root.updateWindows();
            }
        }

        function createTagObj(id, active, urgent, occupied) {
            return {
                "id": id,
                "state": (active ? 1 : 0) | (urgent ? 2 : 0),
                "clients": occupied ? 1 : 0,
                "focused": 0,
                "isActive": active,
                "isUrgent": urgent
            };
        }

        function rebuildWorkspaces() {
            const workspaceList = [];
            for (const outputName in internal.tagStates) {
                if (internal.outputIndices[outputName] === undefined)
                    internal.outputIndices[outputName] = internal.outputCounter++;

            }
            for (const outputName in internal.tagStates) {
                const tags = internal.tagStates[outputName];
                const outputIdx = internal.outputIndices[outputName];
                for (let i = 0; i < tags.length; i++) {
                    const tag = tags[i];
                    //skip empty tags
                    if (tag.clients === 0 && !tag.isActive)
                        continue;

                    const isMonSelected = (outputName === root.selectedMonitor);
                    const isFocused = tag.isActive && (tag.focused === 1 || isMonSelected);
                    workspaceList.push({
                        "id": outputIdx * 100 + tag.id,
                        "idx": tag.id,
                        "name": tag.id.toString(),
                        "output": outputName,
                        "isActive": tag.isActive,
                        "isFocused": isFocused,
                        "isUrgent": tag.isUrgent,
                        "isOccupied": tag.clients > 0
                    });
                }
            }
            workspaceList.sort((a, b) => {
                return a.id - b.id;
            });
            root.workspaces.clear();
            for (let k = 0; k < workspaceList.length; k++) root.workspaces.append(workspaceList[k])
            root.workspaceChanged();
        }

    }

}
