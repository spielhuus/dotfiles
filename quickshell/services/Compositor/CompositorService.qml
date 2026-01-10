import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    // Compositor detection
    property bool isHyprland: false
    property bool isNiri: false
    property bool isSway: false
    property bool isMango: false
    property bool isLabwc: false
    // Generic workspace and window data
    property ListModel workspaces
    property ListModel windows
    property int focusedWindowIndex: -1
    property string activeWindowTitle: ""
    // Display scale data
    property var displayScales: ({
    })
    property bool displayScalesLoaded: false
    // Backend service loader
    property var backend: null
    property int lockAndSuspendCheckCount: 0

    // Generic events
    signal workspaceChanged()
    signal activeWindowChanged()
    signal windowListChanged()

    function toggleKeyboardLayout() {
        if (backend && backend.toggleKeyboardLayout)
            backend.toggleKeyboardLayout();
        else
            console.log("CompositorService", "Current backend does not support toggling keyboard layout.");
    }

    function detectCompositor() {
        const hyprlandSignature = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
        const niriSocket = Quickshell.env("NIRI_SOCKET");
        const swaySock = Quickshell.env("SWAYSOCK");
        const currentDesktop = Quickshell.env("XDG_CURRENT_DESKTOP");
        const labwcPid = Quickshell.env("LABWC_PID");
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
            isHyprland = false;
            isNiri = true;
            isSway = false;
            isMango = false;
            isLabwc = false;
            backendLoader.sourceComponent = niriComponent;
        }
    }

    function loadDisplayScalesFromState() {
        try {
            const cached = ShellState.getDisplay();
            if (cached && Object.keys(cached).length > 0) {
                displayScales = cached;
                displayScalesLoaded = true;
            } else {
                displayScalesLoaded = true;
            }
        } catch (error) {
            displayScalesLoaded = true;
        }
    }

    function setupBackendConnections() {
        if (!backend)
            return ;

        backend.workspaceChanged.connect(() => {
            syncWorkspaces();
            workspaceChanged();
        });
        backend.activeWindowChanged.connect(() => {
            syncFocusedWindow();
            updateActiveWindowTitle(); // Update property explicitly
            activeWindowChanged();
        });
        backend.windowListChanged.connect(() => {
            syncWindows();
            updateActiveWindowTitle(); // Update property explicitly
            windowListChanged();
        });
        backend.focusedWindowIndexChanged.connect(() => {
            focusedWindowIndex = backend.focusedWindowIndex;
            updateActiveWindowTitle();
        });
        syncWorkspaces();
        syncWindows();
        focusedWindowIndex = backend.focusedWindowIndex;
        updateActiveWindowTitle();
    }

    function syncWorkspaces() {
        workspaces.clear();
        const ws = backend.workspaces;
        for (var i = 0; i < ws.count; i++) {
            workspaces.append(ws.get(i));
        }
        workspacesChanged();
    }

    function syncWindows() {
        windows.clear();
        const ws = backend.windows;
        for (var i = 0; i < ws.length; i++) {
            windows.append(ws[i]);
        }
        windowListChanged();
    }

    function syncFocusedWindow() {
        const newIndex = backend.focusedWindowIndex;
        for (var i = 0; i < windows.count && i < backend.windows.length; i++) {
            const backendFocused = backend.windows[i].isFocused;
            if (windows.get(i).isFocused !== backendFocused)
                windows.setProperty(i, "isFocused", backendFocused);

        }
        focusedWindowIndex = newIndex;
    }

    function updateActiveWindowTitle() {
        activeWindowTitle = getFocusedWindowTitle();
    }

    // Public function to get scale for a specific display
    function getDisplayScale(displayName) {
        if (!displayName || !displayScales[displayName])
            return 1;

        return displayScales[displayName].scale || 1;
    }

    // Public function to get all display info for a specific display
    function getDisplayInfo(displayName) {
        if (!displayName || !displayScales[displayName])
            return null;

        return displayScales[displayName];
    }

    // Helper function used internally and available publicly
    function getFocusedWindowTitle() {
        if (focusedWindowIndex >= 0 && focusedWindowIndex < windows.count) {
            var title = windows.get(focusedWindowIndex).title;
            if (title !== undefined)
                title = title.replace(/(\r\n|\n|\r)/g, "");

            return title || "";
        }
        return "";
    }

    function getCleanAppName(appId, fallbackTitle) {
        var name = (appId || "").split(".").pop() || fallbackTitle || "Unknown";
        return name.charAt(0).toUpperCase() + name.slice(1);
    }

    function getWindowsForWorkspace(workspaceId) {
        var windowsInWs = [];
        for (var i = 0; i < windows.count; i++) {
            var window = windows.get(i);
            if (window.workspaceId === workspaceId)
                windowsInWs.push(window);

        }
        return windowsInWs;
    }

    function switchToWorkspace(workspace) {
        if (backend && backend.switchToWorkspace)
            backend.switchToWorkspace(workspace);

    }

    function getCurrentWorkspace() {
        for (var i = 0; i < workspaces.count; i++) {
            const ws = workspaces.get(i);
            if (ws.isFocused)
                return ws;

        }
        return null;
    }

    function focusWindow(window) {
        if (backend && backend.focusWindow)
            backend.focusWindow(window);

    }

    function closeWindow(window) {
        if (backend && backend.closeWindow)
            backend.closeWindow(window);

    }

    function logout() {
        if (backend && backend.logout)
            backend.logout();

    }

    function shutdown() {
        Quickshell.execDetached(["sh", "-c", "systemctl poweroff || loginctl poweroff"]);
    }

    function reboot() {
        Quickshell.execDetached(["sh", "-c", "systemctl reboot || loginctl reboot"]);
    }

    function suspend() {
        Quickshell.execDetached(["sh", "-c", "systemctl suspend || loginctl suspend"]);
    }

    function hibernate() {
        Quickshell.execDetached(["sh", "-c", "systemctl hibernate || loginctl hibernate"]);
    }

    function lockAndSuspend() {
        if (PanelService && PanelService.lockScreen && PanelService.lockScreen.active) {
            suspend();
            return ;
        }
        try {
            if (PanelService && PanelService.lockScreen) {
                PanelService.lockScreen.active = true;
                lockAndSuspendCheckCount = 0;
                lockAndSuspendTimer.start();
            } else {
                suspend();
            }
        } catch (e) {
            suspend();
        }
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            if (typeof ShellState !== 'undefined' && ShellState.isLoaded)
                loadDisplayScalesFromState();

        });
        detectCompositor();
    }

    Connections {
        function onIsLoadedChanged() {
            if (ShellState.isLoaded)
                loadDisplayScalesFromState();

        }

        target: typeof ShellState !== 'undefined' ? ShellState : null
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

    // Backend Components
    Component {
        id: hyprlandComponent

        HyprlandService {
            id: hyprlandBackend
        }

    }

    Component {
        id: niriComponent

        NiriService {
            id: niriBackend
        }

    }

    Component {
        id: swayComponent

        SwayService {
            id: swayBackend
        }

    }

    Component {
        id: mangoComponent

        MangoService {
            id: mangoBackend
        }

    }

    Component {
        id: labwcComponent

        LabwcService {
            id: labwcBackend
        }

    }

    Timer {
        id: lockAndSuspendTimer

        interval: 100
        repeat: true
        running: false
        onTriggered: {
            lockAndSuspendCheckCount++;
            if (PanelService && PanelService.lockScreen && PanelService.lockScreen.active) {
                if (PanelService.lockScreen.item) {
                    stop();
                    lockAndSuspendCheckCount = 0;
                    suspend();
                } else {
                    if (lockAndSuspendCheckCount > 20) {
                        stop();
                        lockAndSuspendCheckCount = 0;
                        suspend();
                    }
                }
            } else {
                if (lockAndSuspendCheckCount > 30) {
                    stop();
                    lockAndSuspendCheckCount = 0;
                    suspend();
                }
            }
        }
    }

    workspaces: ListModel {
    }

    windows: ListModel {
    }

}
