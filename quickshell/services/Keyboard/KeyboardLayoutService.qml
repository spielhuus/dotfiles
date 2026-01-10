import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.Compositor
pragma Singleton

Singleton {
    // English variants
    // FIXED: Ukrainian language code should map to Ukraine
    // Nordic countries
    // Western/Central European Germanic
    // Romance languages (Western/Southern Europe)
    // Eastern European Romance
    // Slavic languages (Eastern Europe)
    // Ukrainian language code
    // Celtic languages (Western Europe)
    // Baltic languages (Northern Europe)
    // Other European languages
    // West/Southwest Asian languages
    // South American languages
    // East Asian languages
    // Southeast Asian languages
    // South Asian languages
    // African languages
    // Layout variants

    id: root

    property string currentLayout: qsTr("system.unknown-layout")
    property string previousLayout: ""
    property bool isInitialized: false
    // Comprehensive language name to ISO code mapping
    property var languageMap: {
        "english": "us",
        "american": "us",
        "united states": "us",
        "us english": "us",
        "british": "gb",
        "uk": "ua",
        "united kingdom": "gb",
        "english (uk)": "gb",
        "canadian": "ca",
        "canada": "ca",
        "canadian english": "ca",
        "australian": "au",
        "australia": "au",
        "swedish": "se",
        "svenska": "se",
        "sweden": "se",
        "norwegian": "no",
        "norsk": "no",
        "norway": "no",
        "danish": "dk",
        "dansk": "dk",
        "denmark": "dk",
        "finnish": "fi",
        "suomi": "fi",
        "finland": "fi",
        "icelandic": "is",
        "íslenska": "is",
        "iceland": "is",
        "german": "de",
        "deutsch": "de",
        "germany": "de",
        "austrian": "at",
        "austria": "at",
        "österreich": "at",
        "swiss": "ch",
        "switzerland": "ch",
        "schweiz": "ch",
        "suisse": "ch",
        "dutch": "nl",
        "nederlands": "nl",
        "netherlands": "nl",
        "holland": "nl",
        "belgian": "be",
        "belgium": "be",
        "belgië": "be",
        "belgique": "be",
        "french": "fr",
        "français": "fr",
        "france": "fr",
        "canadian french": "ca",
        "spanish": "es",
        "español": "es",
        "spain": "es",
        "castilian": "es",
        "italian": "it",
        "italiano": "it",
        "italy": "it",
        "portuguese": "pt",
        "português": "pt",
        "portugal": "pt",
        "catalan": "ad",
        "català": "ad",
        "andorra": "ad",
        "romanian": "ro",
        "română": "ro",
        "romania": "ro",
        "russian": "ru",
        "русский": "ru",
        "russia": "ru",
        "polish": "pl",
        "polski": "pl",
        "poland": "pl",
        "czech": "cz",
        "čeština": "cz",
        "czech republic": "cz",
        "slovak": "sk",
        "slovenčina": "sk",
        "slovakia": "sk",
        "uk": "ua",
        "ukrainian": "ua",
        "українська": "ua",
        "ukraine": "ua",
        "bulgarian": "bg",
        "български": "bg",
        "bulgaria": "bg",
        "serbian": "rs",
        "srpski": "rs",
        "serbia": "rs",
        "croatian": "hr",
        "hrvatski": "hr",
        "croatia": "hr",
        "slovenian": "si",
        "slovenščina": "si",
        "slovenia": "si",
        "bosnian": "ba",
        "bosanski": "ba",
        "bosnia": "ba",
        "macedonian": "mk",
        "македонски": "mk",
        "macedonia": "mk",
        "irish": "ie",
        "gaeilge": "ie",
        "ireland": "ie",
        "welsh": "gb",
        "cymraeg": "gb",
        "wales": "gb",
        "scottish": "gb",
        "gàidhlig": "gb",
        "scotland": "gb",
        "estonian": "ee",
        "eesti": "ee",
        "estonia": "ee",
        "latvian": "lv",
        "latviešu": "lv",
        "latvia": "lv",
        "lithuanian": "lt",
        "lietuvių": "lt",
        "lithuania": "lt",
        "hungarian": "hu",
        "magyar": "hu",
        "hungary": "hu",
        "greek": "gr",
        "ελληνικά": "gr",
        "greece": "gr",
        "albanian": "al",
        "shqip": "al",
        "albania": "al",
        "maltese": "mt",
        "malti": "mt",
        "malta": "mt",
        "turkish": "tr",
        "türkçe": "tr",
        "turkey": "tr",
        "arabic": "ar",
        "العربية": "ar",
        "arab": "ar",
        "hebrew": "il",
        "עברית": "il",
        "israel": "il",
        "brazilian": "br",
        "brazilian portuguese": "br",
        "brasil": "br",
        "brazil": "br",
        "japanese": "jp",
        "日本語": "jp",
        "japan": "jp",
        "korean": "kr",
        "한국어": "kr",
        "korea": "kr",
        "south korea": "kr",
        "chinese": "cn",
        "中文": "cn",
        "china": "cn",
        "simplified chinese": "cn",
        "traditional chinese": "tw",
        "taiwan": "tw",
        "繁體中文": "tw",
        "thai": "th",
        "ไทย": "th",
        "thailand": "th",
        "vietnamese": "vn",
        "tiếng việt": "vn",
        "vietnam": "vn",
        "hindi": "in",
        "हिन्दी": "in",
        "india": "in",
        "afrikaans": "za",
        "south africa": "za",
        "south african": "za",
        "qwerty": "us",
        "dvorak": "us",
        "colemak": "us",
        "workman": "us",
        "azerty": "fr",
        "norman": "fr",
        "qwertz": "de"
    }

    // Updates current layout from various format strings. Called by compositors
    function setCurrentLayout(layoutString) {
        root.currentLayout = extractLayoutCode(layoutString);
    }

    // Extract layout code from various format strings using Commons data
    function extractLayoutCode(layoutString) {
        if (!layoutString)
            return qsTr("system.unknown-layout");

        const str = layoutString.toLowerCase();
        if (str.includes("ger"))
            return "CH";

        // If it's already a short code (2-3 chars), return as-is
        if (/^[a-z]{2,3}(\+.*)?$/.test(str))
            return str.split('+')[0];

        // Extract from parentheses like "English (US)"
        const parenMatch = str.match(/\(([a-z]{2,3})\)/);
        if (parenMatch)
            return parenMatch[1];

        // Check for exact matches or partial matches in language map from Commons
        const entries = Object.entries(languageMap);
        for (var i = 0; i < entries.length; i++) {
            const lang = entries[i][0];
            const code = entries[i][1];
            if (str.includes(lang))
                return code;

        }
        // If nothing matches, try first 2-3 characters if they look like a code
        const codeMatch = str.match(/^([a-z]{2,3})/);
        return codeMatch ? codeMatch[1] : qsTr("system.unknown-layout");
    }

    // Watch for layout changes and show toast
    onCurrentLayoutChanged: {
        // Update previousLayout after checking for changes
        const layoutChanged = isInitialized && currentLayout !== previousLayout && currentLayout !== qsTr("system.unknown-layout") && previousLayout !== "" && previousLayout !== qsTr("system.unknown-layout");
        // Update previousLayout for next comparison
        previousLayout = currentLayout;
    }
    Component.onCompleted: {
        initializationTimer.start();
    }

    Timer {
        id: initializationTimer

        interval: 2000
        onTriggered: {
            isInitialized = true;
            previousLayout = currentLayout;
        }
    }

}
