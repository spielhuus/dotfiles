import QtQuick
import QtQuick.Layouts
import qs.services.Compositor
import "../"

BarText {
  id: root
  property int chopLength: 30 

  property string activeWindowTitle: CompositorService.getFocusedWindowTitle()
  text: {
    var str = activeWindowTitle
    if (!str) return ""
    return str.length > root.chopLength ? str.slice(0, root.chopLength) + '...' : str;
  }
}
