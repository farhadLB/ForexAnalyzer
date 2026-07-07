pragma Singleton
import QtQuick
import QtCharts

Item {

    // Main
    property color primary:            "#262626"
    property color textOnPrimary:      "white"
    property color textOff:            "grey"
    property color secondary:          "#2b8579"
    property color textOnSecondary:    "white"
    property color secondaryHighlight: "#50a297"
    property color secondaryBright:    "#74e3d4"
    property color secondaryDim:       "#4e605e"
    property color outline:            "grey"
    property color background:         "#1f1f1f"
    property color titleBar:           "#343434"
    property color menuPrimary:        "#202020"
    property var   chartTheme:         ChartView.ChartThemeDark

    // Icons
    property string dollar:     "../../assets/dollar-white.svg"
    property string crosshairIcon:  "../../assets/crosshair-white.svg"
    property string leftArrow:  "../../assets/left-arrow-white.svg"
    property string leftArrowOff:  "../../assets/left-arrow-grey.svg"
    property string rightArrow: "../../assets/right-arrow-white.svg"
    property string rightArrowOff: "../../assets/right-arrow-grey.svg"
    property string tools: "../../assets/tools-white.svg"
    property string slider: "../../assets/slider-white-small.svg"
    property string load: "../../assets/load-white.svg"
    property string sunOn: "../../assets/sun-white.svg"
    property string sunOff: "../../assets/sun-grey.svg"
    property string moonOn: "../../assets/moon-white.svg"
    property string moonOff: "../../assets/moon-grey.svg"
    property string candleOff: "../assets/candle-grey-small.svg"
    property string candleOn:"../assets/candle-white-small.svg"
    property string chartOff: "../assets/chart-line-grey.svg"
    property string chartOn: "../assets/chart-line-white.svg"
    property string tableOff: "../assets/table-grey.svg"
    property string tableOn: "../assets/table-white.svg"
    property string apiOn: "../assets/api-white.svg"
    property string apiOff: "../assets/api-grey.svg"

    // Flags
    property string aud: "../assets/flags/aud.svg"
    property string cad: "../assets/flags/cad.svg"
    property string chf: "../assets/flags/chf.svg"
    property string eur: "../assets/flags/eur.svg"
    property string gbp: "../assets/flags/gbp.svg"
    property string jpy: "../assets/flags/jpy.svg"
    property string nzd: "../assets/flags/nzd.svg"
    property string usd: "../assets/flags/usd.svg"

    // Candles
    property color bullCandle:         "#00aa55"
    property color bearCandle:         "#cc3333"

    // Chart overlays
    property color crosshair:          "#ffffff"
    property color supportLevel:       "#00ffaa"
    property color resistanceLevel:    "#ff4444"
    property color trendline1m:        "skyblue"
    property color trendline5m:        "orange"
    property color trendline15m:       "#4466ff"
    property color trendlineDefault:   "yellow"

    // Position zones
    property color profitZone:         "#4466ff"
    property color lossZone:           "#4466ff"

    // Typography
    property int fontSizeSmall:        12
    property int fontSizeNormal:       14
    property int fontSizeLarge:        16
    property int fontSizeTitle:        20
    property string fontFamily:        "sans-serif"

    // Layout
    property real leftMargin:          60
    property real topMargin:           10
    property real bottomMargin:        20

    function lightTheme(){
        // Main
        primary=            "#f0eff2"
        textOnPrimary=      "black"
        textOff=            "grey"
        secondary=          "#2b8579"
        textOnSecondary=    "black"
        secondaryHighlight= "#50a297"
        secondaryBright=    "#74e3d4"
        secondaryDim=       "#4e605e"
        background=         "#ffffff"
        titleBar=           "#e0e0e0"
        menuPrimary=        "#202020"
        chartTheme =        ChartView.ChartThemeLight

        // Icons
        dollar=     "../../assets/dollar-black.svg"
        crosshairIcon=  "../../assets/crosshair-black.svg"
        leftArrow=  "../../assets/left-arrow-black.svg"
        rightArrow= "../../assets/right-arrow-black.svg"
        tools= "../../assets/tools-black.svg"
        slider= "../../assets/slider-black-small.svg"
        load= "../../assets/load-black.svg"
        sunOn= "../../assets/sun-black.svg"
        moonOn= "../../assets/moon-black.svg"
        candleOff= "../assets/candle-grey-small.svg"
        candleOn="../assets/candle-black-small.svg"
        chartOff= "../assets/chart-line-grey.svg"
        chartOn= "../assets/chart-line-black.svg"
        tableOff= "../assets/table-grey.svg"
        tableOn= "../assets/table-black.svg"
        apiOff= "../assets/api-grey.svg"
        apiOn= "../assets/api-black.svg"

    }

    function darkTheme(){
        // Main
        primary=            "#262626"
        textOnPrimary=      "white"
        textOff=            "grey"
        secondary=          "#2b8579"
        textOnSecondary=    "white"
        secondaryHighlight= "#50a297"
        secondaryBright=    "#74e3d4"
        secondaryDim=       "#4e605e"
        background=         "#1f1f1f"
        titleBar=           "#343434"
        menuPrimary=        "#202020"
        chartTheme =        ChartView.ChartThemeDark

        // Icons
        dollar=     "../../assets/dollar-white.svg"
        crosshairIcon=  "../../assets/crosshair-white.svg"
        leftArrow=  "../../assets/left-arrow-white.svg"
        rightArrow= "../../assets/right-arrow-white.svg"
        tools= "../../assets/tools-white.svg"
        slider= "../../assets/slider-white-small.svg"
        load= "../../assets/load-white.svg"
        sunOn= "../../assets/sun-white.svg"
        moonOn= "../../assets/moon-white.svg"
        candleOff= "../assets/candle-grey-small.svg"
        candleOn="../assets/candle-white-small.svg"
        chartOff= "../assets/chart-line-grey.svg"
        chartOn= "../assets/chart-line-white.svg"
        tableOff= "../assets/table-grey.svg"
        tableOn= "../assets/table-white.svg"
        apiOff= "../assets/api-grey.svg"
        apiOn= "../assets/api-white.svg"
    }
}
