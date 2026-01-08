import "../"
import QtQuick
import qs.services.Keyboard

BarBlock {
    // Example for Hyprland:
    // Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"])
    // Example for Niri:
    // Quickshell.execDetached(["niri", "msg", "action", "switch-layout", "next"])

    id: root

    onClicked: {
        console.log("Current layout: " + KeyboardLayoutService.currentLayout);
    }

    content: BarText {
        symbolText: `󰌌 ${KeyboardLayoutService.currentLayout.toUpperCase()}`
    }

}
