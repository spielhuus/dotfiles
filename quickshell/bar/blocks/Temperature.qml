import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.services
import "../"

BarBlock {
  id: text
  content: BarText {
    symbolText: cpuTemp
  }

  property string cpuTemp: {
    const temp = Math.round(SystemUsage.cpuTemp);
    let tempIcon = "";
    let color = "#ffffffff";
    if (temp <= 20) tempIcon = "";
    else if (temp <= 40) tempIcon = "";
    else if (temp <= 60) tempIcon = "";
    else if (temp <= 80) { tempIcon = ""; color = "orange"; }
    else { tempIcon = ""; color = "red"; }
    return `<font color="${color}">${tempIcon}${temp}°C</font>`;
  }

  Component.onCompleted: SystemUsage.refCount++
  Component.onDestruction: SystemUsage.refCount--
}
