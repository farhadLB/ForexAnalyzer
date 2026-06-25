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
    property bool showPosition: false
    property int timeframe: 0

    ColumnLayout{
        anchors.fill: parent

        CandleChart {
            id: chart
            Layout.fillHeight: true
            Layout.fillWidth: true
            crossVisible: crossToggle.checked
            tlineExtended: centerItem.extended
            currentTimeframe: centerItem.timeframe
            positionVisible: centerItem.showPosition
        }

        RowLayout{
            spacing: 10
            Layout.margins: 10

            ComboBox{
                id: tfCombo
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

            CustomToggle {
                id: crossToggle
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 10
                text: "crosshair"
            }

            CustomButton {
                text: "Auto Levels"
                onClicked: {
                    var start = chart.firstVisibleIndex
                    var end   = Math.min(chart.candles.length, start + chart.visibleCount)

                    var visibleCandles = []
                    for(var i=start;i<end;i++)
                        visibleCandles.push(chart.candles[i])

                    var levels = levelDetector.detectLocalLevels(visibleCandles,backdrop)

                    chartObjects.clearAutoLevels()
                    chartObjects.setAutoLevels(levels)
                }
            }

            CustomButton {
                text:"Auto Trendlines"
                onClicked:{
                    var start = chart.firstVisibleIndex
                    var end   = Math.min(chart.candles.length, start + chart.visibleCount)

                    var visibleCandles = []
                    for(var i=start;i<end;i++)
                        visibleCandles.push(chart.candles[i])

                    var lines = trendlineDetector.detectTrendlines(visibleCandles)
                    // chartObjects.clearAutoTrendlines()
                    chartObjects.setAutoTrendlines(lines, start)
                }
            }

            CustomButton {
                text: "Clear Levels"
                onClicked: {
                    chartObjects.clearAutoLevels()
                    chartObjects.clearAutoTrendlines()
                }
            }
            Button {
                text: "←"
                Layout.fillWidth: true
                onClicked: chart.prevPosition()
            }
            Button {
                text: "→"
                onClicked: chart.nextPosition()
            }
        }
    }

    Connections {
        target: csvLoader

        function onCandlesReady(list) {
            rawCandles = list
            chart.candles = list
            chart.rawCandles = list
            tfCombo.currentIndex = 0
        }
    }
}
