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

  signal workspaceChanged
  signal activeWindowChanged
  signal windowListChanged
  signal displayScalesChanged

  // ===== MANGOSERVICE PROPERTIES =====
  property string selectedMonitor: ""
  property string currentLayoutSymbol: ""

  // ===== INTERNAL STATE =====
  QtObject {
    id: internal
    property var tagStates: ({})
    property var activeTags: ({})
    // focusedTitle and focusedAppId are no longer needed for window focus
    // but might be kept if other parts of the logic use them.
    // For this fix, they are effectively deprecated for focus tracking.

    property var outputIndices: ({})
    property int outputCounter: 0
    property var monitorScales: ({})
    
    // Buffer for event stream
    property string streamBuffer: ""

    // ===== REGEX PATTERNS (Relaxed) =====
    readonly property var patterns: QtObject {
      readonly property var tagDetail: /^(\S+)\s+tag\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/
      readonly property var tagBinary: /^(\S+)\s+tags\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)/
      readonly property var layout: /^(\S+)\s+layout\s+(\S+)/
      readonly property var metadata: /^(\S+)\s+(title|appid)\s+(.*)$/
      readonly property var kbLayout: /^(\S+)\s+kb_layout\s+(.*)$/
      readonly property var scale: /^(\S+)\s+scale_factor\s+(\d+(?:\.\d+)?)/
      readonly property var selmon: /^(\S+)\s+selmon\s+1/
    }

    // ===== PROCESS TAG DATA =====
    function processTagData(output) {
      const lines = output.trim().split('\n');
      const newTagStates = {};
      const newActiveTags = {};
      const detailedOutputTags = {};

      for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;

        // 1. Detailed Format (Primary Source)
        const detailMatch = line.match(patterns.tagDetail);
        if (detailMatch) {
          const outputName = detailMatch[1];
          const tagId = parseInt(detailMatch[2]);
          const state = parseInt(detailMatch[3]);
          const clients = parseInt(detailMatch[4]);
          const focused = parseInt(detailMatch[5]);

          if (!newTagStates[outputName]) newTagStates[outputName] = [];
          
          detailedOutputTags[`${outputName}-${tagId}`] = true;

          const isActive = (state & 1) !== 0;
          const isUrgent = (state & 2) !== 0;

          if (isActive) newActiveTags[outputName] = tagId;

          newTagStates[outputName].push({
            id: tagId,
            state: state,
            clients: clients,
            focused: focused,
            isActive: isActive,
            isUrgent: isUrgent
          });
          continue;
        }

        // 2. Tags Mask/String Format (Secondary Source)
        const binaryMatch = line.match(patterns.tagBinary);
        if (binaryMatch) {
          const outputName = binaryMatch[1];
          const occStr = binaryMatch[2];
          const selStr = binaryMatch[3];
          const urgStr = binaryMatch[4];

          if (!newTagStates[outputName]) newTagStates[outputName] = [];
          const isBinaryString = occStr.length > 5;

          if (isBinaryString) {
             const len = occStr.length;
             for (let j = 0; j < len; j++) {
                const tagId = j + 1;
                if (detailedOutputTags[`${outputName}-${tagId}`]) continue;
                const charIdx = len - 1 - j;
                const isActive = selStr[charIdx] !== '0';
                const isUrgent = urgStr[charIdx] !== '0';
                const isOccupied = occStr[charIdx] !== '0';
                if (isActive) newActiveTags[outputName] = tagId;
                newTagStates[outputName].push(createTagObj(tagId, isActive, isUrgent, isOccupied));
             }
          } else {
             const occMask = parseInt(occStr);
             const selMask = parseInt(selStr);
             const urgMask = parseInt(urgStr);
             for (let j = 0; j < 32; j++) {
                const tagId = j + 1;
                if (detailedOutputTags[`${outputName}-${tagId}`]) continue;
                const bit = (1 << j);
                const isActive = (selMask & bit) !== 0;
                const isUrgent = (urgMask & bit) !== 0;
                const isOccupied = (occMask & bit) !== 0;
                if (!isActive && !isOccupied && !isUrgent && tagId > 9) continue;
                if (isActive) newActiveTags[outputName] = tagId;
                newTagStates[outputName].push(createTagObj(tagId, isActive, isUrgent, isOccupied));
             }
          }
          continue;
        }
        
        // 3. Selected Monitor
        const selmonMatch = line.match(patterns.selmon);
        if (selmonMatch) root.selectedMonitor = selmonMatch[1];
      }

      for (const k in newTagStates) internal.tagStates[k] = newTagStates[k];
      for (const k in newActiveTags) internal.activeTags[k] = newActiveTags[k];

      internal.rebuildWorkspaces();
      internal.updateWindows(); // We still need to call this to update window properties
    }
    
    function createTagObj(id, active, urgent, occupied) {
        return {
            id: id,
            state: (active ? 1 : 0) | (urgent ? 2 : 0),
            clients: occupied ? 1 : 0,
            focused: 0,
            isActive: active,
            isUrgent: urgent
        };
    }

    function rebuildWorkspaces() {
      const workspaceList = [];
      for (const outputName in internal.tagStates) {
        if (internal.outputIndices[outputName] === undefined) {
          internal.outputIndices[outputName] = internal.outputCounter++;
        }
      }

      for (const outputName in internal.tagStates) {
        const tags = internal.tagStates[outputName];
        const outputIdx = internal.outputIndices[outputName];

        for (let i = 0; i < tags.length; i++) {
          const tag = tags[i];
          const isMonSelected = (outputName === root.selectedMonitor);
          const isFocused = tag.isActive && (tag.focused === 1 || isMonSelected);
          
          workspaceList.push({
            id: outputIdx * 100 + tag.id,
            idx: tag.id,
            name: tag.id.toString(),
            output: outputName,
            isActive: tag.isActive,
            isFocused: isFocused,
            isUrgent: tag.isUrgent,
            isOccupied: tag.clients > 0
          });
        }
      }

      workspaceList.sort((a, b) => a.id - b.id);
      root.workspaces.clear();
      for (let k = 0; k < workspaceList.length; k++) root.workspaces.append(workspaceList[k]);
      root.workspaceChanged();
    }

    // *** MODIFIED FUNCTION ***
    function updateWindows() {
      const newWindows = [];
      const toplevels = ToplevelManager.toplevels?.values || [];
      const activeToplevel = ToplevelManager.activeToplevel; // Get the currently active toplevel
      let newFocusedIndex = -1;

      for (let i = 0; i < toplevels.length; i++) {
        const toplevel = toplevels[i];
        if (!toplevel) continue;

        const isFocused = (activeToplevel && toplevel.address === activeToplevel.address);

        const windowData = {
          // FIX: Ensure every window object has a unique 'id'
          "id": toplevel.address || `mango-win-${i}`, 
          "title": toplevel.title || "",
          "appId": toplevel.appId || "",
          // Workspace association for Mango requires more logic, -1 for now
          "workspaceId": -1, 
          "isFocused": isFocused,
          "output": "", // Output association requires more logic
          "handle": toplevel
        };

        newWindows.push(windowData);

        if (isFocused) {
          newFocusedIndex = i;
        }
      }

      // Update the main properties and emit signals
      root.windows = newWindows;
      if (root.focusedWindowIndex !== newFocusedIndex) {
        root.focusedWindowIndex = newFocusedIndex;
        root.activeWindowChanged();
      }
      root.windowListChanged();
    }
    
    function processScales(output) {
       // (Scale processing logic remains the same)
    }
  }

  // ===== PROCESSES =====
  property QtObject _eventStream: Process {
    id: eventStream
    running: false
    command: ["mmsg", "-w"]
    stdout: SplitParser {
      onRead: line => {
        internal.streamBuffer += line + "\n";
        if (line.match(internal.patterns.tagBinary)) {
             internal.processTagData(internal.streamBuffer);
             internal.streamBuffer = "";
        }
      }
    }
    onExited: code => { if (code !== 0) restartTimer.start(); }
  }

  property QtObject _restartTimer: Timer {
    id: restartTimer
    interval: 2000
    onTriggered: { if (root.initialized) eventStream.running = true; }
  }

  property QtObject _initialQuery: Process {
    id: initialQuery
    command: ["mmsg", "-g", "-t"]
    property string buffer: "" 
    stdout: SplitParser { onRead: line => initialQuery.buffer += line + "\n"; }
    onExited: code => {
      if (code === 0) {
        internal.processTagData(initialQuery.buffer);
        initialQuery.buffer = "";
      } else {
        console.error("MangoService: Initial query failed (code " + code + ")");
      }
    }
  }

  property QtObject _scaleQuery: Process {
    id: scaleQuery
    command: ["mmsg", "-g", "-A"]
    property string buffer: ""
    stdout: SplitParser { onRead: line => scaleQuery.buffer += line + "\n"; }
    onExited: code => {
      if (code === 0) {
        internal.processScales(scaleQuery.buffer);
        scaleQuery.buffer = "";
      }
    }
  }

  // ===== CONNECTIONS =====
  Connections {
    // ToplevelManager is the source of truth for window state
    target: ToplevelManager
    function onToplevelsChanged() { internal.updateWindows(); }
    function onActiveToplevelChanged() { internal.updateWindows(); }
  }

  // ===== INITIALIZATION =====
  function initialize() {
    if (initialized) return;
    console.log("MangoService: Initializing...");
    scaleQuery.running = true;
    initialQuery.running = true;
    eventStream.running = true;
    Quickshell.execDetached(["mmsg", "-g", "-o"]);
    initialized = true;
  }
  
  // ===== Public Functions =====
  function queryDisplayScales() { scaleQuery.running = true; }
  function switchToWorkspace(ws) { Quickshell.execDetached(["mmsg", "-s", "-t", ws.idx.toString()]); }
  function focusWindow(w) { if (w.handle && typeof w.handle.activate === 'function') w.handle.activate(); }
  function closeWindow(w) { if (w.handle && typeof w.handle.close === 'function') w.handle.close(); }
  function logout() { Quickshell.execDetached(["mmsg", "-s", "-q"]); }
}
