//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import "bar"
import qs.modules
import qs.modules.logout
import qs

ShellRoot {
  property bool showLogout: false

  Bar {}
  NotificationPopup {} 
  VolumeOSD {} 
  Wallpaper {} 
  LockScreen {}

  ChatWindow {
    id: myChatWindow
    visible: false
  }

  AppLauncher {
    id: appLauncher
  }

  LogoutMenu {
    id: logoutWidget
    
    // Bind visibility to the shell property
    visible: showLogout
    
    // When the window closes itself (via Esc or Button click), update the shell property
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
