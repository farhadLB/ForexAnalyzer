import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: centerItem
    SplitView.minimumWidth: 50
    SplitView.fillWidth: true
    color: "#0b0b17"

    property var rawCandles: []
    property double backdrop: 50

    ColumnLayout{
        anchors.fill: parent

        CandleChart {
            id: chart
            Layout.fillHeight: true
            Layout.fillWidth: true
            crossVisible: crossToggle.checked
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
                        var tf = aggregator.getTimeframe(modelData);
                        var newCandles = aggregator.aggregate(rawCandles, tf)
                        chart.candles = newCandles
                    }
                }
            }
            CustomToggle {
                id: crossToggle
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 10
                text: "crosshair"
                // onClicked: chart.crossVisible = !chart.crossVisible
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
                    chartObjects.clearAutoTrendlines()
                    chartObjects.setAutoTrendlines(lines)
                }
            }

            CustomButton {
                text: "Clear Levels"
                onClicked: {
                    chartObjects.clearAutoLevels()
                    chartObjects.clearAutoTrendlines()
                }
            }

            Slider{
                from: 10
                to: 200
                value: 50
                snapMode: Slider.SnapAlways
                onValueChanged: {
                    backdrop = value
                }
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
