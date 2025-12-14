//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import "bar"
import "wlogout"
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

  Chat {
    id: chatWidget
    visible: false
  }

  Logout {
    id: logoutWidget

     visible: showLogout
      
      // Allow the window to close itself (sets shared property to false)
      onVisibleChanged: {
          if (!visible) showLogout = false
      }
  }   
  // IpcHandler {
  //     target: "sidebarLeft"
  //
  //     function toggle(): void {
  //       console.log("toggle sidebar")
  //         GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen
  //     }
  //
  //     function close(): void {
  //         GlobalStates.sidebarLeftOpen = false
  //     }
  //
  //     function open(): void {
  //         GlobalStates.sidebarLeftOpen = true
  //     }
  //   }

  IpcHandler {
    target: "Chat"
    function toggle(): void {
      chatWidget.visible = !chatWidget.visible
    }
  }

  IpcHandler {
    target: "Logout"
    function toggle(): void {
      logoutWidget.visible = !logoutWidget.visible
    }
  }
}
