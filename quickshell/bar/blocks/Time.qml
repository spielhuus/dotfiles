import QtQuick
import "../"

BarBlock {
  id: root
  property bool showDate: false

  content: BarText {
    // Show calendar icon + date if toggled, otherwise just time
    symbolText: root.showDate ? ` ${Datetime.date}` : `${Datetime.time}`
  }

  onClicked: () => {
    root.showDate = !root.showDate
  }
}
