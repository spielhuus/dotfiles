import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"

BarBlock {
  id: text
  content: BarText {
    symbolText: ` ${Math.floor(cpuLoad)}%`
  }

  property real cpuLoad

  Process {
    id: cpuProc
    command: ["dgop", "cpu", "--json"]
    running: true
    stdout: SplitParser { 
      onRead: { 
        try { 
          let json = JSON.parse(data); 
          console.log("cpu load: " + json.usage);
          cpuLoad = json.usage ?? 0; 
        } catch (e) { 
          console.error("JSON parse error:", e); 
          cpuLoad = 0; 
        } 
      } 
    } 
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: cpuProc.running = true
  }
}
