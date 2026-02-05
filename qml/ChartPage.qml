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

    ColumnLayout{
        anchors.fill: parent

        CandleChart {
            id: chart
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        RowLayout{
            spacing: 10

            Repeater {
                model: ["1m", "5m", "15m", "1h", "4h", "Daily"]

                Button {
                    text: modelData
                    onClicked: {
                        if (!rawCandles || rawCandles.length === 0) return;
                        var tf = aggregator.getTimeframe(modelData);
                        var newCandles = aggregator.aggregate(rawCandles, tf)
                        chart.candles = newCandles
                    }
                }
            }
            Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 10
                text: "toggle crosshair"
                onClicked: chart.crossVisible = !chart.crossVisible
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
