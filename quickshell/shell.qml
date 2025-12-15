//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import "bar"
import "wlogout"
import qs.modules.chat
import qs
// import qs.components
// import qs.launcher
// import qs.modules

ShellRoot {
  property bool showLogout: false

  Bar {}
  // Background {}
  // PanelLoader {
  //   id: leftSidebarLoader
  //   identifier: "sidebarLeft"
  //   component: SidebarLeft {}
  //   active: GlobalStates.sidebarLeftOpen // Bind active to the global state
  // }

    // PanelLoader { identifier: "sidebarLeft"; component: SidebarLeft {} }

    // component PanelLoader: LazyLoader {
    //     required property string identifier
    //     property bool extraCondition: true
    //     active: false // Config.ready && Config.options.enabledPanels.includes(identifier) && extraCondition
    //   }

    // Load the Chat Window
    ChatWindow {
        id: myChatWindow
        visible: false
      }

  Logout {
    id: logoutWidget

     visible: showLogout
      onVisibleChanged: {
          if (!visible) showLogout = false
      }
  }   

IpcHandler {
    target: "Chat"
    function toggle(): void {
      myChatWindow.visible = !myChatWindow.visible
    }
  }

  IpcHandler {
    target: "Logout"
    function toggle(): void {
      logoutWidget.visible = !logoutWidget.visible
    }
  }
}
