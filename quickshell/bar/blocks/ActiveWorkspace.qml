import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services.Compositor
import "../"

BarText {
    id: root
    property int chopLength: 30 
    property string activeWindowTitle: CompositorService.activeWindowTitle

    symbolText: {
        var str = activeWindowTitle;
        if (!str) return "";

        for (var i = 0; i < Config.bar.rewriteRules.length; i++) {
            var rule = Config.bar.rewriteRules[i];
            if (str.match(rule.pattern)) {
                return str.replace(rule.pattern, rule.replacement);
            }
        }

        return str.length > root.chopLength ? str.slice(0, root.chopLength) + '...' : str;
    }
}
