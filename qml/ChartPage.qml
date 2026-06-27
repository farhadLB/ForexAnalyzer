import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import ForexAnalyzer 1.0

Rectangle {
    id: centerItem
    SplitView.minimumWidth: 50
    SplitView.fillWidth: true
    color: "#111827"

    property var rawCandles: []
    property double backdrop: 50
    property bool extended: false
    property int timeframe: 0
    property bool showChart: false

    ColumnLayout{
        anchors.fill: parent

        CandleChart {
            id: chart
            Layout.fillHeight: true
            Layout.fillWidth: true
            crossVisible: tools.crossVisible
            tlineExtended: centerItem.extended
            currentTimeframe: centerItem.timeframe
            isLoading: csvLoader.isLoading
            visible: showChart
            ChartTools{
                id: tools
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 80
                anchors.topMargin: 20
            }
        }

        Image {
            id: chartImage
            Layout.fillHeight: true
            Layout.fillWidth: true
            source: "../assets/chart.jpg"
            visible: !showChart

            Rectangle {
                anchors.fill: parent
                color: "#80111827"
                visible: csvLoader.isLoading
                z: 10

                BusyIndicator {
                    anchors.centerIn: parent
                    running: csvLoader.isLoading
                }
            }

            Rectangle{
                id: overlay
                anchors.fill: parent
                color: "#111827"
                opacity: 0.92
                Column{
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        id: line1
                        text: "Select your .csv file"
                        color: "white"
                        opacity: 0.9
                        font.pixelSize: 18
                    }
                    Rectangle{
                        color: "white"
                        opacity: 0.9
                        width: line1.width + 20
                        height: 1
                    }

                    Text {
                        text: "Set the configuration from settings panel."
                        color: "white"
                        opacity: 0.9
                        font.pixelSize: 18
                    }
                    Text {
                        text: "Run the backtest to see the strategy result."
                        color: "white"
                        opacity: 0.9
                        font.pixelSize: 18
                    }
                    Text {
                        text: "(Currently only the Histdata.com files are supported)"
                        color: "white"
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
                anchors.bottom: parent.bottom
                CustomButton{
                    buttonText: "Modifications"
                    iconSource: "../../assets/slider-white-small.svg"
                    onClicked: {
                        if(!stratPopup.popupRef.visible){
                            stratPopup.popupRef.open()
                        }
                    }
                }
                CustomButton{
                    buttonText: "Run"
                    iconSource: "../../assets/play-green.svg"
                    onClicked: {
                        positionManager.startCalculation()
                    }
                }
            }
            RowLayout{
                spacing: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                Text {
                    id: comboLabel
                    text: "Timeframe:"
                    font.pixelSize: 16
                    color: "white"
                }

                ComboBox{
                    id: tfCombo
                    width: 20
                    model: ["1m", "5m", "15m", "1h", "4h", "Daily"]
                    Material.theme: Material.Dark
                    onActivated: (index) => {
                                     if (!rawCandles || rawCandles.length === 0) return;
                                     var selected = model[index]
                                     var tf = Aggregator.getTimeframe(selected);
                                     var newCandles = Aggregator.aggregate(rawCandles, tf)
                                     chart.candles = newCandles
                                     centerItem.timeframe = tf
                                     Aggregator.setTimeframe(selected);
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


    Connections {
        target: csvLoader

        function onCandlesReady(list) {
            rawCandles = list
            centerItem.showChart = true
        }

        function onFileLoaded(count) {
            Qt.callLater(function() {
                chart.candles = rawCandles
                chart.rawCandles = rawCandles
                tfCombo.currentIndex = 0
            })
        }
    }
}
