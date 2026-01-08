import QtQuick
import Quickshell
import "root:/" // for Globals
import qs.config

LazyLoader {
  id: root

  property Item relativeItem: null
  property Item displayItem: null
  property PopupContext popupContext: Globals.popupContext
  property bool hoverable: false;
  readonly property bool hovered: item?.hovered ?? false
  required default property Component contentDelegate
  active: displayItem != null && popupContext.popup == this

  onRelativeItemChanged: {
    if (relativeItem == null) {
      if (item != null) item.hideTimer.start();
    } else {
      if (item != null) item.hideTimer.stop();
      displayItem = relativeItem;
      popupContext.popup = this;
    }
  }

  PopupWindow {
    anchor {
      window: root.displayItem.QsWindow.window
      rect.y: anchor.window.height + 3
      rect.x: anchor.window.contentItem.mapFromItem(root.displayItem, root.displayItem.width / 2, 0).x
      edges: Edges.Top
      gravity: Edges.Bottom
    }

    visible: true

    property alias hovered: body.containsMouse;

    property Timer hideTimer: Timer {
      interval: 250
      onTriggered: root.popupContext.popup = null;
    }

    color: "transparent"

    Region { id: emptyRegion }
    mask: root.hoverable ? null : emptyRegion

    implicitWidth: body.implicitWidth
    implicitHeight: body.implicitHeight

    MouseArea {
      id: body

      anchors.fill: parent
      implicitWidth: content.implicitWidth + 10
      implicitHeight: content.implicitHeight + 10

      hoverEnabled: root.hoverable

      Rectangle {
        anchors.fill: parent

        radius: 5
        border.width: 1
        color: Config.theme.osdBgColor
        border.color:Config.theme.osdBorderColor 

        Loader {
          id: content
          anchors.centerIn: parent
          sourceComponent: contentDelegate
          active: true
        }
      }
    }
  }
}
