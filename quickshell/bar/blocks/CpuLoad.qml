import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 
import Quickshell
import Quickshell.Io
import qs.services
import "../"

BarBlock {
  id:text
    content: BarText {
      symbolText: ` ${Math.floor(cpuPerc)}%`
    }

  property string cpuPerc: {
    const perc = SystemUsage.cpuPerc;
    return perc * 100.0
  }
  property string gpuPerc: {
    const perc = SystemUsage.gpuPerc;
    return perc * 100.0
  }

  Component.onCompleted: SystemUsage.refCount++
  Component.onDestruction: SystemUsage.refCount--
}
