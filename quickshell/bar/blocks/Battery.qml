import "../"
import QtQuick
import Quickshell.Io
import qs.config
import qs.services

BarBlock {
    readonly property string batteryDisplay: {
        const percent = Math.round(Battery.percentage * 100);
        let icon = "";
        if (Battery.isCharging) {
            icon = "";
        } else {
            // discharge icons
            if (percent <= 10)
                icon = "󰁺";
            else if (percent <= 30)
                icon = "󰁼";
            else if (percent <= 50)
                icon = "󰁾";
            else if (percent <= 70)
                icon = "󰂀";
            else if (percent <= 90)
                icon = "󰂂";
            else
                icon = "󰁹";
        }
        // Define Colors based on state
        let color = Config.theme.normal;
        if (percent <= 10 && !Battery.isCharging)
            color = Config.theme.critical;
        else if (percent <= 20 && !Battery.isCharging)
            color = Config.theme.warn;
        else if (Battery.isCharging)
            color = Config.theme.ok;
        return `<font color="${color}">${icon}${percent}%</font>`;
    }

    visible: Battery.available

    content: BarText {
        symbolText: batteryDisplay
    }

}
