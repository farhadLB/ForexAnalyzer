import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "popups"
import ForexAnalyzer 1.0

Rectangle {
    id: centerItem
    SplitView.minimumWidth: 50
    SplitView.fillWidth: true
    color: GUIParameters.background

    property var rawCandles: []
    property double backdrop: 50
    property bool extended: false
    property int timeframe: 0
    property bool showChart: false
    property var stackRef

    ColumnLayout{
        anchors.fill: parent

        Rectangle{
            id:chartBorder
            color: "transparent"
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 10
            border.color: "grey"
            border.width: 1
            radius: 5
            visible: showChart

            CandleChart {
                id: chart
                anchors.fill: parent
                anchors.margins: 5
                crossVisible: tools.crossVisible
                tlineExtended: centerItem.extended
                currentTimeframe: centerItem.timeframe
                isLoading: csvLoader.isLoading
                visible: showChart
                themeToggle: themeToggle.checked

                RowLayout{
                    id: dataInfo
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 80
                    anchors.topMargin: 20
                    width: 150
                    height: 40
                    visible: !candleModel.isFromCSV
                    Item{
                        id: flagsItem
                        Layout.fillHeight: true
                        Layout.minimumWidth: 50
                        Layout.alignment: Qt.AlignVCenter
                        Layout.margins: 8
                        Rectangle{
                            id: backRec
                            width: parent.height
                            height: parent.height
                            radius: parent.height
                            color: "transparent"
                            Image {
                                anchors.fill: parent
                                source: symbolToFlag(tdWorker.first)
                            }
                        }
                        Rectangle{
                            id: frontRec
                            width: parent.height
                            height: parent.height
                            radius: parent.height
                            x: parent.height / 2
                            color: "transparent"
                            Image {
                                anchors.fill: parent
                                source: symbolToFlag(tdWorker.second)
                            }
                        }
                    }
                    Text {
                        text: tdWorker.symbolDesc
                        color: GUIParameters.textOnPrimary
                        font.pixelSize: GUIParameters.fontSizeNormal
                    }
                }

                ChartTools{
                    id: tools
                    anchors.left: parent.left
                    anchors.top: dataInfo.visible ? dataInfo.bottom : chart.top
                    anchors.leftMargin: 80
                    anchors.topMargin: 20
                    chartRef: chart
                    visible: toolsToggle.checked
                }
            }
        }

        Image {
            id: chartImage
            Layout.fillHeight: true
            Layout.fillWidth: true
            source: tdWorker.isLoading ? "" : "../assets/chart.jpg"
            visible: !showChart || tdWorker.isLoading

            Rectangle {
                anchors.fill: parent
                color: "#80111827"
                visible: csvLoader.isLoading || tdWorker.isLoading
                z: 10

                BusyIndicator {
                    anchors.centerIn: parent
                    running: csvLoader.isLoading || tdWorker.isLoading
                }
            }

            Rectangle{
                id: overlay
                anchors.fill: parent
                color: GUIParameters.background
                opacity: 0.92
                visible: !tdWorker.isLoading
                Column{
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        id: line1
                        text: "Open your .csv file form File menu"
                        color: GUIParameters.textOnPrimary
                        opacity: 0.9
                        font.pixelSize: 18
                    }
                    Rectangle{
                        color: GUIParameters.textOnPrimary
                        opacity: 0.9
                        width: line1.width + 20
                        height: 1
                    }

                    Text {
                        text: "Set the modifications"
                        color: GUIParameters.textOnPrimary
                        opacity: 0.9
                        font.pixelSize: 18
                    }
                    Text {
                        text: "Run the backtest to see the strategy result"
                        color: GUIParameters.textOnPrimary
                        opacity: 0.9
                        font.pixelSize: 18
                    }
                    Text {
                        text: "Show the result positions by \"Show Positions\" button"
                        color: GUIParameters.textOnPrimary
                        opacity: 0.9
                        font.pixelSize: 18
                    }
                }
            }
        }

        Item{
            Layout.fillWidth: true
            Layout.minimumHeight: 60
            Layout.margins: 10
            Layout.alignment: Qt.AlignBottom
            RowLayout{
                spacing: 10
                anchors.left: parent.left
                CustomButton{
                    buttonText: "Load Chart Data"
                    iconSource: GUIParameters.load
                    onClicked: {
                        if(!loadPopup.popupRef.visible){
                            loadPopup.popupRef.open()
                        }
                    }
                    CustomToolTip{
                        visible: parent.hovered
                        text: "Add data to chart"
                    }

                }
                CustomButton{
                    buttonText: "Modifications"
                    iconSource: GUIParameters.slider
                    onClicked: {
                        if(!stratPopup.popupRef.visible){
                            stratPopup.popupRef.open()
                        }
                    }
                    CustomToolTip{
                        visible: parent.hovered
                        text: "Strategy Modifications"
                    }
                }
                CustomButton{
                    buttonText: "Run"
                    iconSource: "../../assets/play-green.svg"
                    iconColor: GUIParameters.titleBar
                    onClicked: {
                        if(!candleModel.isEmpty){
                            positionManager.startCalculation()
                            stackRef.currentIndex = 1
                        }
                    }
                    CustomToolTip{
                        visible: parent.hovered
                        text: "Run the back test"
                    }
                }
            }
            RowLayout{
                spacing: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                CustomToggle {
                    id: toolsToggle
                    diameter: 40
                    iconSource: GUIParameters.tools
                    checked: true
                    CustomToolTip{
                        visible: parent.hovered
                        text: toolsToggle.checked ? "Hide Chart Tools" : "Show Chart Tools"
                    }
                }
                CustomToggle {
                    id: themeToggle
                    diameter: 40
                    iconSource: checked ? GUIParameters.moonOn : GUIParameters.sunOn
                    checked: false
                    CustomToolTip{
                        visible: parent.hovered
                        text: themeToggle.checked ? "Dark Mode" : "Light Mode"
                    }
                    onCheckedChanged: {
                        if(checked)
                            GUIParameters.lightTheme()
                        else
                            GUIParameters.darkTheme()
                    }
                }
                Text {
                    id: comboLabel
                    text: "Timeframe:"
                    font.pixelSize: 16
                    color: GUIParameters.textOnPrimary
                }

                CustomComboBox{
                    id: tfCombo
                    model: ["1m", "5m", "15m", "1h", "4h", "Daily"]
                    enabled: !tools.positionChecked
                    Component.onCompleted: {
                        currentIndex = Aggregator.comboIndex
                    }

                    onCurrentIndexChanged: {
                        Aggregator.comboIndex = currentIndex
                        if (!rawCandles || rawCandles.length === 0) return;
                        var selected = model[currentIndex]
                        var tf = Aggregator.getTimeframe(selected);
                        var newCandles = Aggregator.aggregate(rawCandles, tf)
                        candleModel.loadCandles(newCandles)
                        centerItem.timeframe = tf
                        Aggregator.setTimeframe(selected);
                    }
                    CustomToolTip{
                        visible: parent.hovered && !parent.enabled
                        text: "Hide positions to change the timeframe"
                    }
                }
            }
        }
        CustomProgressBar {
            Layout.alignment: Qt.AlignBottom
            Layout.leftMargin: 10
            Layout.bottomMargin: 5
            barHeight: 6
            from: 0; to: 100
            value: csvLoader.progress
            visible: csvLoader.isLoading
            onCancelClicked: csvLoader.cancelLoad()
        }
    }

    StrategyPopup{
        id: stratPopup
    }

    LoadChartPopup{
        id: loadPopup
    }


    Connections {
        target: csvLoader

        function onCandlesReady(list) {
            rawCandles = list
            centerItem.showChart = true
        }

        function onFileLoaded(count) {
            tdWorker.stopStreaming()
            Qt.callLater(function() {
                chart.rawCandles = rawCandles
                tfCombo.currentIndex = 0
            })
        }
        function onCloseCsvFile() {
            rawCandles = []
            centerItem.showChart = false
        }
    }
    Connections {
        target: Aggregator
        function onComboIndexChanged() {
            tfCombo.currentIndex = Aggregator.comboIndex
        }
    }
    Connections {
        target: candleModel
        function onClearingModel() {
            centerItem.showChart = false
        }
    }
    Connections {
        target: tdWorker
        function onFileLoaded() {
            centerItem.showChart = true
        }
    }
    function symbolToFlag(symbol) {
        switch (symbol) {
        case "EUR" : return GUIParameters.eur
        case "USD" : return GUIParameters.usd
        case "AUD" : return GUIParameters.aud
        case "CHF" : return GUIParameters.chf
        case "GBP" : return GUIParameters.gbp
        case "NZD" : return GUIParameters.nzd
        case "JPY" : return GUIParameters.jpy
        case "CAD" : return GUIParameters.cad
        }
    }
}
