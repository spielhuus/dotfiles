pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Compositor detection
  property bool isHyprland: false
  property bool isNiri: false
  property bool isSway: false
  property bool isMango: false
  property bool isLabwc: false

  // Generic workspace and window data
  property ListModel workspaces: ListModel {}
  property ListModel windows: ListModel {}
  property int focusedWindowIndex: -1

  // Display scale data
  property var displayScales: ({})
  property bool displayScalesLoaded: false

  // Generic events
  signal workspaceChanged
  signal activeWindowChanged
  signal windowListChanged

  // Backend service loader
  property var backend: null

  Component.onCompleted: {
    // Load display scales from ShellState
    Qt.callLater(() => {
                   if (typeof ShellState !== 'undefined' && ShellState.isLoaded) {
                     loadDisplayScalesFromState();
                   }
                 });

    detectCompositor();
  }

  Connections {
    target: typeof ShellState !== 'undefined' ? ShellState : null
    function onIsLoadedChanged() {
      if (ShellState.isLoaded) {
        loadDisplayScalesFromState();
      }
    }
  }

  function detectCompositor() {
    const hyprlandSignature = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
    const niriSocket = Quickshell.env("NIRI_SOCKET");
    const swaySock = Quickshell.env("SWAYSOCK");
    const currentDesktop = Quickshell.env("XDG_CURRENT_DESKTOP");
    const labwcPid = Quickshell.env("LABWC_PID");

    // Check for MangoWC using XDG_CURRENT_DESKTOP environment variable
    // MangoWC sets XDG_CURRENT_DESKTOP=mango
    console.log("isMango: " + currentDesktop.toLowerCase().includes("mango"))
    if (currentDesktop && currentDesktop.toLowerCase().includes("mango")) {
      isHyprland = false;
      isNiri = false;
      isSway = false;
      isMango = true;
      isLabwc = false;
      backendLoader.sourceComponent = mangoComponent;
    } else if (labwcPid && labwcPid.length > 0) {
      isHyprland = false;
      isNiri = false;
      isSway = false;
      isMango = false;
      isLabwc = true;
      backendLoader.sourceComponent = labwcComponent;
      console.log("CompositorService", "Detected LabWC with PID: " + labwcPid);
    } else if (niriSocket && niriSocket.length > 0) {
      isHyprland = false;
      isNiri = true;
      isSway = false;
      isMango = false;
      isLabwc = false;
      backendLoader.sourceComponent = niriComponent;
    } else if (hyprlandSignature && hyprlandSignature.length > 0) {
      isHyprland = true;
      isNiri = false;
      isSway = false;
      isMango = false;
      isLabwc = false;
      backendLoader.sourceComponent = hyprlandComponent;
    } else if (swaySock && swaySock.length > 0) {
      isHyprland = false;
      isNiri = false;
      isSway = true;
      isMango = false;
      isLabwc = false;
      backendLoader.sourceComponent = swayComponent;
    } else {
      // Always fallback to Niri
      isHyprland = false;
      isNiri = true;
      isSway = false;
      isMango = false;
      isLabwc = false;
      backendLoader.sourceComponent = niriComponent;
    }
  }

  Loader {
    id: backendLoader
    onLoaded: {
      if (item) {
        root.backend = item;
        setupBackendConnections();
        backend.initialize();
      }
    }
  }

  // Load display scales from ShellState
  function loadDisplayScalesFromState() {
    try {
      const cached = ShellState.getDisplay();
      if (cached && Object.keys(cached).length > 0) {
        displayScales = cached;
        displayScalesLoaded = true;
        console.log("CompositorService", "Loaded display scales from ShellState");
      } else {
        // Migration is now handled in Settings.qml
        displayScalesLoaded = true;
      }
    } catch (error) {
      console.error("CompositorService", "Failed to load display scales:", error);
      displayScalesLoaded = true;
    }
  }

  // Hyprland backend component
  Component {
    id: hyprlandComponent
    HyprlandService {
      id: hyprlandBackend
    }
  }

  // Niri backend component
  Component {
    id: niriComponent
    NiriService {
      id: niriBackend
    }
  }

  // Sway backend component
  Component {
    id: swayComponent
    SwayService {
      id: swayBackend
    }
  }

  // Mango backend component
  Component {
    id: mangoComponent
    MangoService {
      id: mangoBackend
    }
  }

  // Labwc backend component
  Component {
    id: labwcComponent
    LabwcService {
      id: labwcBackend
    }
  }

  function setupBackendConnections() {
    if (!backend)
      return;

    // Connect backend signals to facade signals
    backend.workspaceChanged.connect(() => {
                                       // Sync workspaces when they change
                                       syncWorkspaces();
                                       // Forward the signal
                                       workspaceChanged();
                                     });

    backend.activeWindowChanged.connect(() => {
                                          // Only sync focus state, not entire window list
                                          syncFocusedWindow();
                                          // Forward the signal
                                          activeWindowChanged();
                                        });

    backend.windowListChanged.connect(() => {
                                        // Sync windows when they change
                                        syncWindows();
                                        // Forward the signal
                                        windowListChanged();
                                      });

    // Property bindings - use automatic property change signal
    backend.focusedWindowIndexChanged.connect(() => {
                                                focusedWindowIndex = backend.focusedWindowIndex;
                                              });

    // Initial sync
    syncWorkspaces();
    syncWindows();
    focusedWindowIndex = backend.focusedWindowIndex;
  }

  function syncWorkspaces() {
    workspaces.clear();
    const ws = backend.workspaces;
    for (var i = 0; i < ws.count; i++) {
      workspaces.append(ws.get(i));
    }
    // Emit signal to notify listeners that workspace list has been updated
    workspacesChanged();
  }

  function syncWindows() {
    windows.clear();
    const ws = backend.windows;
    for (var i = 0; i < ws.length; i++) {
      windows.append(ws[i]);
    }
    // Emit signal to notify listeners that window list has been updated
    windowListChanged();
  }

  // Sync only the focused window state, not the entire window list
  function syncFocusedWindow() {
    const newIndex = backend.focusedWindowIndex;

    // Update isFocused flags by syncing from backend
    for (var i = 0; i < windows.count && i < backend.windows.length; i++) {
      const backendFocused = backend.windows[i].isFocused;
      if (windows.get(i).isFocused !== backendFocused) {
        windows.setProperty(i, "isFocused", backendFocused);
      }
    }

    focusedWindowIndex = newIndex;
  }

  // Update display scales from backend
  function updateDisplayScales() {
    if (!backend || !backend.queryDisplayScales) {
      console.error("CompositorService", "Backend does not support display scale queries");
      return;
    }

    backend.queryDisplayScales();
  }

  // Called by backend when display scales are ready
  function onDisplayScalesUpdated(scales) {
    displayScales = scales;
    saveDisplayScalesToCache();
    displayScalesChanged();
    console.log("CompositorService", "Display scales updated");
  }

  // Save display scales to cache
  function saveDisplayScalesToCache() {
    try {
      ShellState.setDisplay(displayScales);
      console.log("CompositorService", "Saved display scales to ShellState");
    } catch (error) {
      console.error("CompositorService", "Failed to save display scales:", error);
    }
  }

  // Public function to get scale for a specific display
  function getDisplayScale(displayName) {
    if (!displayName || !displayScales[displayName]) {
      return 1.0;
    }
    return displayScales[displayName].scale || 1.0;
  }

  // Public function to get all display info for a specific display
  function getDisplayInfo(displayName) {
    if (!displayName || !displayScales[displayName]) {
      return null;
    }
    return displayScales[displayName];
  }

  // Get focused window
  function getFocusedWindow() {
    if (focusedWindowIndex >= 0 && focusedWindowIndex < windows.count) {
      return windows.get(focusedWindowIndex);
    }
    return null;
  }

  // Get focused window title
  function getFocusedWindowTitle() {
    if (focusedWindowIndex >= 0 && focusedWindowIndex < windows.count) {
      var title = windows.get(focusedWindowIndex).title;
      if (title !== undefined) {
        title = title.replace(/(\r\n|\n|\r)/g, "");
      }
      return title || "";
    }
    return "";
  }

  // Get clean app name from appId
  // Extracts the last segment from reverse domain notation (e.g., "org.kde.dolphin" -> "Dolphin")
  // Falls back to title if appId is empty
  function getCleanAppName(appId, fallbackTitle) {
    var name = (appId || "").split(".").pop() || fallbackTitle || "Unknown";
    return name.charAt(0).toUpperCase() + name.slice(1);
  }

  function getWindowsForWorkspace(workspaceId) {
    var windowsInWs = [];
    for (var i = 0; i < windows.count; i++) {
      var window = windows.get(i);
      if (window.workspaceId === workspaceId) {
        windowsInWs.push(window);
      }
    }
    return windowsInWs;
  }

  // Generic workspace switching
  function switchToWorkspace(workspace) {
    if (backend && backend.switchToWorkspace) {
      backend.switchToWorkspace(workspace);
    } else {
      console.error("Compositor", "No backend available for workspace switching");
    }
  }

  // Get current workspace
  function getCurrentWorkspace() {
    for (var i = 0; i < workspaces.count; i++) {
      const ws = workspaces.get(i);
      if (ws.isFocused) {
        return ws;
      }
    }
    return null;
  }

  // Get active workspaces
  function getActiveWorkspaces() {
    const activeWorkspaces = [];
    for (var i = 0; i < workspaces.count; i++) {
      const ws = workspaces.get(i);
      if (ws.isActive) {
        activeWorkspaces.push(ws);
      }
    }
    return activeWorkspaces;
  }

  // Set focused window
  function focusWindow(window) {
    if (backend && backend.focusWindow) {
      backend.focusWindow(window);
    } else {
      console.error("Compositor", "No backend available for window focus");
    }
  }

  // Close window
  function closeWindow(window) {
    if (backend && backend.closeWindow) {
      backend.closeWindow(window);
    } else {
      console.error("Compositor", "No backend available for window closing");
    }
  }

  // Session management
  function logout() {
    if (backend && backend.logout) {
      console.log("Compositor", "Logout requested");
      backend.logout();
    } else {
      console.error("Compositor", "No backend available for logout");
    }
  }

  function shutdown() {
    console.log("Compositor", "Shutdown requested");
    Quickshell.execDetached(["sh", "-c", "systemctl poweroff || loginctl poweroff"]);
  }

  function reboot() {
    console.log("Compositor", "Reboot requested");
    Quickshell.execDetached(["sh", "-c", "systemctl reboot || loginctl reboot"]);
  }

  function suspend() {
    console.log("Compositor", "Suspend requested");
    Quickshell.execDetached(["sh", "-c", "systemctl suspend || loginctl suspend"]);
  }

  function hibernate() {
    console.log("Compositor", "Hibernate requested");
    Quickshell.execDetached(["sh", "-c", "systemctl hibernate || loginctl hibernate"]);
  }

  property int lockAndSuspendCheckCount: 0

  function lockAndSuspend() {
    console.log("Compositor", "Lock and suspend requested");

    // If already locked, suspend immediately
    if (PanelService && PanelService.lockScreen && PanelService.lockScreen.active) {
      console.log("Compositor", "Screen already locked, suspending");
      suspend();
      return;
    }

    // Lock the screen first
    try {
      if (PanelService && PanelService.lockScreen) {
        PanelService.lockScreen.active = true;
        lockAndSuspendCheckCount = 0;

        // Wait for lock screen to be confirmed active before suspending
        lockAndSuspendTimer.start();
      } else {
        console.error("Compositor", "Lock screen not available, suspending without lock");
        suspend();
      }
    } catch (e) {
      console.error("Compositor", "Failed to activate lock screen before suspend: " + e);
      suspend();
    }
  }

  Timer {
    id: lockAndSuspendTimer
    interval: 100
    repeat: true
    running: false

    onTriggered: {
      lockAndSuspendCheckCount++;

      // Check if lock screen is now active
      if (PanelService && PanelService.lockScreen && PanelService.lockScreen.active) {
        // Verify the lock screen component is loaded
        if (PanelService.lockScreen.item) {
          console.log("Compositor", "Lock screen confirmed active, suspending");
          stop();
          lockAndSuspendCheckCount = 0;
          suspend();
        } else {
          // Lock screen is active but component not loaded yet, wait a bit more
          if (lockAndSuspendCheckCount > 20) {
            // Max 2 seconds wait
            console.log("Compositor", "Lock screen active but component not loaded, suspending anyway");
            stop();
            lockAndSuspendCheckCount = 0;
            suspend();
          }
        }
      } else {
        // Lock screen not active yet, keep checking
        if (lockAndSuspendCheckCount > 30) {
          // Max 3 seconds wait
          console.log("Compositor", "Lock screen failed to activate, suspending anyway");
          stop();
          lockAndSuspendCheckCount = 0;
          suspend();
        }
      }
    }
  }
}
