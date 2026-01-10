import "../"
import QtQuick
import qs.services.Compositor
import qs.services.Keyboard

BarBlock {
    id: root

    onClicked: () => {
        CompositorService.toggleKeyboardLayout();
    }

    content: BarText {
        symbolText: `󰌌 ${KeyboardLayoutService.currentLayout.toUpperCase()}`
    }

}
