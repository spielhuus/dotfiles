import QtQuick
import Quickshell.Io
import "../"

BarBlock {
  id: root

  // A Process component to launch the wlogout shell
  readonly property var logoutProcess: Process {
    command: ["quickshell", "wlogout/shell.qml"]
  }

  // The content of the block is a BarText component
  content: BarText {
    // Using a Nerd Font icon for power/logout
    symbolText: "󰐥"
  }

  // When the block is clicked, launch the wlogout process in a detached state
  onClicked: function() {
    console.log("Launching wlogout...")
    // Use startDetached() to launch a new, independent GUI process
    logoutProcess.startDetached()
  }
}
