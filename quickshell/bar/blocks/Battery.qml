import QtQuick
import Quickshell.Io
import qs.services
import "../"

BarBlock {
    visible: Battery.available
    content: BarText {
        symbolText: batteryDisplay
    }

    readonly property string batteryDisplay: {
      const percent = Math.round(Battery.percentage*100.0);
        let icon = "";
        if (Battery.isCharging) {
            icon = ""; // Charging icon
        } else {
            // discharge icons
            if (percent <= 10) icon = "󰁺";      // Empty/Critical
            else if (percent <= 30) icon = "󰁼";
            else if (percent <= 50) icon = "󰁾";
            else if (percent <= 70) icon = "󰂀";
            else if (percent <= 90) icon = "󰂂";
            else icon = "󰁹";                    // Full
        }

        // Define Colors based on state
        let color = "#ffffff";
        if (percent <= 20 && !Battery.isCharging) {
            color = "red";
        } else if (Battery.isCharging) {
            color = "#00FF00"; // Green when charging
        }

        return `<font color="${color}">${icon}${percent}%</font>`;
    }
}
