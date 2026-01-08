import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "root:/"

Text {
    property string mainFont: Theme.get.bar.fontFamily
    property string symbolFont: Theme.get.bar.fontSymbol
    property int pointSize: Theme.get.bar.fontSize
    property int symbolSize: pointSize * 1.4
    property string symbolText
    property bool dim

    function wrapSymbols(text) {
        if (!text)
            return "";

        const isSymbol = (codePoint) => {
            return (codePoint >= 57344 && codePoint <= 63743) || (codePoint >= 983040 && codePoint <= 1.04858e+06) || (codePoint >= 1.04858e+06 && codePoint <= 1.11411e+06);
        };
        return text.replace(/./ug, (c) => {
            return isSymbol(c.codePointAt(0)) ? `<span style='font-family: ${symbolFont}; letter-spacing: 5px; font-size: ${symbolSize}px'>${c}</span>` : c;
        });
    }

    text: wrapSymbols(symbolText)
    anchors.centerIn: parent
    color: dim ? "#CCCCCC" : "white"
    textFormat: Text.RichText

    font {
        family: mainFont
        pointSize: pointSize
    }

    Text {
        id: textcopy

        visible: false
        text: parent.text
        textFormat: parent.textFormat
        color: parent.color
        font: parent.font
        // Sync geometry and elision to parent so the shadow matches the visible text
        width: parent.width
        elide: parent.elide
        horizontalAlignment: parent.horizontalAlignment
    }

    DropShadow {
        anchors.fill: parent
        horizontalOffset: 1
        verticalOffset: 1
        color: "#000000"
        source: textcopy
    }

}
