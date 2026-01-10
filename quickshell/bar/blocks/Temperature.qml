import "../"
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.config
import qs.services

BarBlock {
    id: text

    property string cpuTemp: {
        const temp = Math.round(SystemUsage.cpuTemp);
        let tempIcon = "";
        let color = "#ffffffff";
        if (temp <= 20) {
            tempIcon = "";
        } else if (temp <= 40) {
            tempIcon = "";
        } else if (temp <= 60) {
            tempIcon = "";
        } else if (temp <= 80) {
            tempIcon = "";
            color = Configs.theme.warn;
        } else if (temp <= 90) {
            tempIcon = "";
            color = Configs.theme.severe;
        } else {
            tempIcon = "";
            color = Configs.theme.critical;
        }
        return `<font color="${color}">${tempIcon}${temp}°C</font>`;
    }

    Component.onCompleted: SystemUsage.refCount++
    Component.onDestruction: SystemUsage.refCount--

    content: BarText {
        symbolText: cpuTemp
    }

}
