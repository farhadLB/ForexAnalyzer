import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import ForexAnalyzer 1.0

Rectangle {
    id: centerItem
    SplitView.minimumWidth: 50
    SplitView.fillWidth: true
    color: "#0b0b17"

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

            Repeater {
                model: ["1m", "5m", "15m", "1h", "4h", "Daily"]

                CustomButton{
                    text: modelData
                    onClicked: {
                        if (!rawCandles || rawCandles.length === 0) return;
                        var tf = Aggregator.getTimeframe(modelData);
                        var newCandles = Aggregator.aggregate(rawCandles, tf)
                        chart.candles = newCandles
                        centerItem.timeframe = tf
                        Aggregator.setTimeframe(modelData);
                    }
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
        }
    }
}
