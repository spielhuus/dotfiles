import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property alias theme: internalTheme
    property alias bar: barObj
    property alias chat: chatObj

    QtObject {
        // Edit fields, close buttons

        id: internalTheme

        property int bar_font_size: 18
        property string barBgColor: "#c1000000"
        property string osdBgColor: "#c1111111"
        property string osdBorderColor: "#66111111"
        property string iconColor: "#05D9E8"
        property string buttonBorderColor: "#aa000000"
        property string buttonBgColor: "#c1000000"
        property string barHover: "#aaaaaaaa"
        property string bar_text_color: "#ffffff"
        property string background_color: "#000000"
        property string fontFamily: "Verdana"
        property string fontSymbol: "Symbols Nerd Font Mono"
        property int fontSize: 16
        // --- Chat Window Settings ---
        property int chatWidth: 1200
        property int chatHeight: 800
        // Chat Layout Dimensions (GUI Elements)
        property int chatSidebarWidth: 260
        property int chatHeaderHeight: 50
        property int chatInputAreaHeight: 80
        property int chatInputHeight: 50
        property int chatInputRadius: 25
        property int chatSendBtnSize: 40
        property int chatSendBtnRadius: 20
        property int chatBubbleRadius: 12
        property int chatOverlayHeight: 26
        property int chatOverlayRadius: 13
        property int chatOverlayMargin: 4
        property int chatOverlayPadding: 12
        property int chatRoleSize: 20
        // Sidebar headers
        property int chatFsSmall: 20
        // Sidebar items, overlay icons
        property int chatFsMedium: 14
        // Header labels, input text
        property int chatFsStandard: 14
        // Chat message content
        property int chatFsText: 18
        property int chatFsLarge: 40
        // Chat Colors
        property string chatBgSidebar: "#171717"
        property string chatBgMain: "#212121"
        property string chatBgInput: "#2F2F2F"
        property string chatBgHover: "#333333"
        property string chatBgOverlay: "#EE222222"
        property string chatBubbleUser: "#3E3E3E"
        property string chatBubbleAi: "#2a2a2a"
        property string chatBorderDark: "#333333"
        property string chatBorderMedium: "#444444"
        property string chatBorderLight: "#555555"
        property string chatTextPrimary: "#E0E0E0"
        property string chatTextSecondary: "#cccccc"
        property string chatTextDim: "#888888"
        property string chatTextDark: "#666666"
        property string chatDangerColor: "#ff6666"
        property string chatDangerHover: "#FF5555"
    }

    QtObject {
        id: chatObj

        property string homeDir: Quickshell.env("HOME")
        property string chatDirectory: homeDir + "/.config/lungan"
        property string historyDirectory: homeDir + "/.local/share/nvim/lungan"
        property string defaultEndpoint: "http://localhost:8080/v1/chat/completions"
    }

    QtObject {
        id: barObj

        property var rewriteRules: [{
            "pattern": /^nvim\s+(.*)/,
            "replacement": "<font color='#00aa00'></font>&nbsp;&nbsp;$1"
        }, {
            "pattern": /^lua\s+(.*)/,
            "replacement": "<font color='#0000ff'></font>&nbsp;&nbsp;$1"
        }, {
            "pattern": /^python\s+(.*)/,
            "replacement": "<font color='#ffc107'>󰌠</font>&nbsp;&nbsp;$1"
        }, {
            "pattern": /^(.*)\s-\sBrave$/,
            "replacement": "<font color='#FFCC00'></font>&nbsp;&nbsp;$1"
        }, {
            "pattern": /^(.*)\s-\sMozilla Thunderbird$/,
            "replacement": "<font color='#FF9900'></font>&nbsp;&nbsp;$1"
        }, {
            "pattern": /^Newsflash$/,
            "replacement": "📰&nbsp;Newsflash"
        }, {
            "pattern": /^\s*ollama\s+(.*)/,
            "replacement": "🦙&nbsp;$1"
        }]
    }

}
