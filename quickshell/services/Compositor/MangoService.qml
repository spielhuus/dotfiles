import QtQml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services.Keyboard

Item {
    id: root

    // ===== PUBLIC INTERFACE =====
    property ListModel workspaces: ListModel {}
    property var windows: []
    property int focusedWindowIndex: -1
    property bool initialized: false
    
    // ===== MANGOSERVICE PROPERTIES =====
    property string selectedMonitor: ""
    property string currentLayoutSymbol: ""
    
    // ===== TRACKING HELPER =====
    property var toplevelList: ToplevelManager.toplevels.values
    
    // ===== PROCESSES =====
    property QtObject _tagStream
    property QtObject _monStream
    property QtObject _kbStream
    property QtObject _restartTimer
    property QtObject _initialTagsQuery
    property QtObject _initialMonitorsQuery
    property QtObject _scaleQuery

    Component.onCompleted: initialize()

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
        root.focusedWindowIndex = newFocusedIndex;
        root.activeWindowChanged();
        root.windowListChanged();
    }

    // ===== INITIALIZATION =====
    function initialize() {
        if (initialized)
            return;

        console.log("[MangoService] Initializing MangoWM processes...");
        scaleQuery.running = true;
        initialTagsQuery.running = true;
        initialMonitorsQuery.running = true;
        tagStream.running = true;
        monStream.running = true;
        kbStream.running = true;
        initialized = true;
    }

    // ===== Public Functions =====
    function queryDisplayScales() {
        scaleQuery.running = true;
    }

    function switchToWorkspace(ws) {
        console.log("[MangoService] Dispatching workspace switch to:", ws.idx);
        Quickshell.execDetached(["mmsg", "dispatch", "view," + ws.idx.toString()]);
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
        Quickshell.execDetached(["mmsg", "dispatch", "quit"]);
    }

   function toggleKeyboardLayout() {
        const current = KeyboardLayoutService.currentLayout.toLowerCase();
        const nextLayout = (current === "us" || current.startsWith("en")) ? "ch" : "us";
        Quickshell.execDetached(["mmsg", "dispatch", "setoption,xkb_rules_layout," + nextLayout]);
        
        if (typeof KeyboardLayoutService.setCurrentLayout === 'function') {
            KeyboardLayoutService.setCurrentLayout(nextLayout);
        } else {
            KeyboardLayoutService.currentLayout = nextLayout;
        }
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

    Instantiator {
        model: root.toplevelList
        delegate: Connections {
            function onTitleChanged() { root.updateWindows(); }
            function onAppIdChanged() { root.updateWindows(); }
            function onActivatedChanged() { root.updateWindows(); }
            target: modelData 
        }
    }

    // ===== INTERNAL STATE & PROCESSES =====
    QtObject {
        id: internal

        property var tagStates: ({})
        property var activeTags: ({})
        property var outputIndices: ({})
        property int outputCounter: 0
        
        // JSON stream parsing buffers (defends against multiline stream chunks)
        property string tagBuffer: ""
        property int tagBrackets: 0
        property string monBuffer: ""
        property int monBrackets: 0
        property string kbBuffer: ""
        property int kbBrackets: 0

        function processStreamLine(line, type) {
            let bufferProp = type + "Buffer";
            let bracketsProp = type + "Brackets";
            
            internal[bufferProp] += line + "\n";
            
            for (let i = 0; i < line.length; i++) {
                if (line[i] === '{' || line[i] === '[') internal[bracketsProp]++;
                else if (line[i] === '}' || line[i] === ']') internal[bracketsProp]--;
            }
            
            if (internal[bracketsProp] === 0 && internal[bufferProp].trim().length > 0) {
                if (type === "tag") processTagData(internal[bufferProp]);
                else if (type === "mon") processMonData(internal[bufferProp]);
                else if (type === "kb") processKbData(internal[bufferProp]);
                
                internal[bufferProp] = "";
            }
        }

        // ===== PROCESS JSON DATA =====
        function processTagData(jsonStr) {
            try {
                let data = JSON.parse(jsonStr);
                const newTagStates = {};
                const newActiveTags = {};
                
                // Get the monitor array (fallback if not wrapped in "all_tags")
                let monitorsList = data.all_tags || data.tags || [];
                if (!Array.isArray(monitorsList)) {
                    monitorsList = [monitorsList];
                }

                // Loop through each monitor output
                for (let i = 0; i < monitorsList.length; i++) {
                    let monItem = monitorsList[i];
                    if (!monItem || typeof monItem !== 'object') continue;

                    // Match screen name: "eDP-1"
                    let outputName = monItem.monitor || monItem.name || monItem.output || root.selectedMonitor || "Unknown";
                    if (outputName === "selmon") continue;

                    // Fetch tags array
                    let tags = monItem.tags || [];
                    if (!Array.isArray(tags)) continue;

                    if (!newTagStates[outputName]) newTagStates[outputName] = [];
                    
                    // Loop through the workspaces (tags) for this screen
                    for (let j = 0; j < tags.length; j++) {
                        let tag = tags[j];
                        
                        // Extract indexes and layouts safely using Mango WM naming
                        let tagId = tag.index !== undefined ? tag.index : tag.id !== undefined ? tag.id : (j + 1);
                        let clients = tag.client_count !== undefined ? tag.client_count : tag.clients !== undefined ? tag.clients : 0;
                        
                        let isActive = tag.is_active !== undefined ? tag.is_active : tag.active !== undefined ? tag.active : false;
                        let isUrgent = tag.is_urgent !== undefined ? tag.is_urgent : tag.urgent !== undefined ? tag.urgent : false;
                        let isOccupied = clients > 0;

                        if (isActive) newActiveTags[outputName] = tagId;
                        
                        newTagStates[outputName].push({
                            "id": tagId,
                            "clients": clients,
                            "isActive": isActive,
                            "isUrgent": isUrgent,
                            "isOccupied": isOccupied
                        });
                    }
                }
                
                if (Object.keys(newTagStates).length > 0) {
                    for (const k in newTagStates) internal.tagStates[k] = newTagStates[k];
                    for (const k in newActiveTags) internal.activeTags[k] = newActiveTags[k];
                    internal.rebuildWorkspaces();
                    root.updateWindows();
                }
            } catch (e) {
                console.error("[MangoService] Failed to parse tag JSON:", e, "Payload:", jsonStr);
            }
          }
          function processMonData(jsonStr) {
            try {
                let data = JSON.parse(jsonStr);
                let monitors = Array.isArray(data) ? data : (data.monitors || Object.values(data));
                for (let i = 0; i < monitors.length; i++) {
                    let m = monitors[i];
                    if (!m || typeof m !== 'object') continue;
                    let mName = m.name || m.output || Object.keys(data)[i] || "Unknown";
                    if (m.focused || m.is_selected || m.selmon || m.active) {
                        root.selectedMonitor = mName;
                    }
                }

                // Self-Correction Migration Logic: 
                // Migrate temporary placeholder keys ("Unknown" or "all_tags") to the resolved monitor name
                if (root.selectedMonitor && root.selectedMonitor !== "Unknown") {
                    const placeholders = ["Unknown", "all_tags"];
                    for (const key of placeholders) {
                        if (internal.tagStates[key]) {
                            internal.tagStates[root.selectedMonitor] = internal.tagStates[key];
                            delete internal.tagStates[key];
                        }
                        if (internal.activeTags[key]) {
                            internal.activeTags[root.selectedMonitor] = internal.activeTags[key];
                            delete internal.activeTags[key];
                        }
                    }
                }

                internal.rebuildWorkspaces(); 
                root.updateWindows();
            } catch (e) {
                console.error("[MangoService] Failed to parse mon JSON:", e, "Payload:", jsonStr);
            }
          }

        function processKbData(jsonStr) {
            try {
                let data = JSON.parse(jsonStr);
                let layout = "";
                if (typeof data === 'string') {
                    layout = data;
                } else if (typeof data === 'object') {
                    layout = data.layout || data.keyboardlayout || data.value || data.name || "";
                }
                if (layout) KeyboardLayoutService.setCurrentLayout(layout);
            } catch(e) {
                let text = jsonStr.trim();
                // strip string quotes for basic responses
                if (text.startsWith('"') && text.endsWith('"')) {
                    text = text.slice(1, -1);
                }
                if (text) KeyboardLayoutService.setCurrentLayout(text);
            }
        }

      function rebuildWorkspaces() {
          console.log("[MangoService] rebuildWorkspaces() invoked. Selected Monitor:", root.selectedMonitor);
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

              if (tag.clients === 0 && !tag.isActive)
                  continue;

              const isMonSelected = (outputName === root.selectedMonitor);
              const isFocused = tag.isActive && (tag.focused === 1 || isMonSelected);
              
              const wsItem = {
                "uid": outputIdx * 100 + tag.id,
                "idx": tag.id,
                "name": tag.id.toString(),
                "output": outputName,
                "isActive": tag.isActive,
                "isFocused": isFocused,
                "isUrgent": tag.isUrgent,
                "isOccupied": tag.clients > 0
              };
              workspaceList.push(wsItem);
            }
          }
          workspaceList.sort((a, b) => a.uid - b.uid);
          root.workspaces.clear();
          for (let k = 0; k < workspaceList.length; k++) {
            root.workspaces.append(workspaceList[k]);
          }
          console.log("[MangoService] rebuildWorkspaces() complete. Output models count:", root.workspaces.count);
          root.workspaceChanged();
        }}

    _tagStream: Process {
        id: tagStream
        running: false
        command: ["mmsg", "watch", "all-tags"]
        onExited: (code) => { 
            console.log("[MangoService] tagStream closed. Exit code:", code);
            if (code !== 0) restartTimer.start(); 
        }
        stdout: SplitParser {
            onRead: (line) => { internal.processStreamLine(line, "tag"); }
        }
    }

    _monStream: Process {
        id: monStream
        running: false
        command: ["mmsg", "watch", "all-monitors"]
        onExited: (code) => { 
            console.log("[MangoService] monStream closed. Exit code:", code);
            if (code !== 0) restartTimer.start(); 
        }
        stdout: SplitParser {
            onRead: (line) => { internal.processStreamLine(line, "mon"); }
        }
    }

    _kbStream: Process {
        id: kbStream
        running: false
        command: ["mmsg", "watch", "keyboardlayout"]
        onExited: (code) => { 
            console.log("[MangoService] kbStream closed. Exit code:", code);
            if (code !== 0) restartTimer.start(); 
        }
        stdout: SplitParser {
            onRead: (line) => { internal.processStreamLine(line, "kb"); }
        }
    }

    _restartTimer: Timer {
        id: restartTimer
        interval: 2000
        onTriggered: {
            if (root.initialized) {
                if (!tagStream.running) tagStream.running = true;
                if (!monStream.running) monStream.running = true;
                if (!kbStream.running) kbStream.running = true;
            }
        }
    }

    _initialTagsQuery: Process {
        id: initialTagsQuery
        command: ["mmsg", "get", "all-tags"]
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("[MangoService] initialTagsQuery text retrieved length:", text.length);
                if (text.trim().length > 0) {
                    internal.processTagData(text);
                }
            }
        }
    }

    _initialMonitorsQuery: Process {
        id: initialMonitorsQuery
        command: ["mmsg", "get", "all-monitors"]
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("[MangoService] initialMonitorsQuery text retrieved length:", text.length);
                if (text.trim().length > 0) {
                    internal.processMonData(text);
                }
            }
        }
    }

    _scaleQuery: Process {
        id: scaleQuery
        command: ["mmsg", "get", "all-monitors"]
        stdout: StdioCollector {}
    }
}
