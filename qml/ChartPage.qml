import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts

Rectangle {
    id: centerItem
    SplitView.minimumWidth: 50
    SplitView.fillWidth: true
    color: "#0b0b17"
    // ChartView {
    //     anchors.fill: parent
    //     anchors.margins: 5
    //     antialiasing: true
    //     backgroundColor: "#0b0b17"
    //     legend.visible: false

    //     ValueAxis{
    //         id: xAxis
    //         color: "white"
    //         min: 0
    //         max: 5
    //         tickCount: 20
    //         gridLineColor: "#b3808080"
    //     }

    //     ValueAxis{
    //         id: yAxis
    //         color: "white"
    //         min: 0
    //         max: 5
    //         tickCount: 20
    //         gridLineColor: "#b3808080"
    //     }

    //     LineSeries {
    //         name: "Line"
    //         axisX: xAxis
    //         axisY: yAxis
    //         XYPoint { x: 0; y: 0 }
    //         XYPoint { x: 1.1; y: 2.1 }
    //         XYPoint { x: 1.9; y: 3.3 }
    //         XYPoint { x: 2.1; y: 2.1 }
    //         XYPoint { x: 2.9; y: 4.9 }
    //         XYPoint { x: 3.4; y: 3.0 }
    //         XYPoint { x: 4.1; y: 3.3 }
    //     }
    // }
    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        ChartView {
            id: chart
            Layout.fillWidth: true
            Layout.fillHeight: true
            antialiasing: true
            theme: ChartView.ChartThemeDark


            DateTimeAxis { id: axisX; format: "MM-dd HH:mm"; tickCount: 6 }
            ValueAxis { id: axisY; labelFormat: "%.2f"; tickCount: 10 }

            CandlestickSeries {
                id: candleSeries
                axisX: axisX
                axisY: axisY
                increasingColor: "lime"
                decreasingColor: "red"
                bodyOutlineVisible: false
            }
        }
    }
    Connections {
        target: csvLoader

        function onCandlesReady(candles) {
            if (candles.length === 0)
                return

            candleSeries.clear()

            for (let i = 0; i < candles.length; ++i) {
                let c = candles[i]
                candleSeries.append(c.open, c.high, c.low, c.close, c.time)
            }

            axisX.min = new Date(candles[0].time)
            axisX.max = new Date(candles[candles.length - 1].time)
        }
        function onAxisRangeReady(minY, maxY) {
            axisY.min = minY
            axisY.max = maxY
        }
    }

}
