import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"

BarBlock {
  id: text
  content: BarText {
    symbolText: ` ${Math.floor(percentFree)}%`
  }

  property real percentFree

  Process {
    id: memProc
    command: ["dgop", "memory", "--json"]
    running: true

    stdout: SplitParser { 
      onRead: { 
        try { 
          let json = JSON.parse(data); 
          percentFree = Math.floor(json.free / json.total * 100); 
        } catch (e) { 
          console.error("JSON parse error:", e); 
          percentFree = 0; 
        } 
      } 
    } 
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: memProc.running = true
  }
}
