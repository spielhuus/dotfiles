import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.services
import "../"


BarBlock {
  id: text
  content: BarText {
    symbolText: ` ${Math.floor(memPerc)}%`
  }

  property string memPerc: {
    const temp = SystemUsage.memPerc;
    return temp * 100.0
  }

  Component.onCompleted: SystemUsage.refCount++
  Component.onDestruction: SystemUsage.refCount--
}
