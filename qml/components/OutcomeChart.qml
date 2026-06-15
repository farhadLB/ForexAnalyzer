import QtQuick
import QtCharts
import QtQuick.Layouts

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    property int  initialMoney: 1000
    property real risk: 1
    property int  maxX: 20
    property int  minY: 0
    property int  maxY: 20

    ColumnLayout{
        anchors.fill: parent
        CircularGauge{
            id: winrateGauge
            Layout.maximumHeight: 250
            Layout.maximumWidth: 250
            percentage: 0;
        }

        ChartView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            antialiasing: true
            legend.visible: false
            theme: ChartView.ChartThemeDark

            Component.onCompleted: {
                backgroundColor = "transparent"
                plotAreaColor = "transparent"
            }

            ValueAxis {
                id: valueAxisX
                min: 0
                max: root.maxX
                labelFormat: "%.0f"
                tickCount: root.maxX < 20 ? root.maxX : 20
                gridLineColor: Qt.rgba(0.5, 0.5, 0.5, 0.3)
            }
            ValueAxis {
                id: valueAxisY
                min: root.minY
                max: root.maxY
                tickCount: 15
                gridLineColor: Qt.rgba(0.5, 0.5, 0.5, 0.3)
            }

            AreaSeries {
                id: areaSeries
                axisX: valueAxisX
                axisY: valueAxisY
                upperSeries: LineSeries {
                    id: areaChart
                }
            }
        }
    }

    Connections {
        target: positionManager
        function onPositionListReady(){
            areaSeries.upperSeries.clear()
            var values = []
            var incomeValues = []
            var income = root.initialMoney

            var positionsInfo = positionManager.positionsInfo()
            winrateGauge.percentage = positionsInfo.winRate

            values = positionManager.getPositionsForQML()
            for(var i=0; i < values.length; i++){
                income += values[i].yValue * risk * (income/100)
                incomeValues.push(income)
            }
            root.minY = Math.min(...incomeValues)
            root.maxY = Math.max(...incomeValues) * 1.05
            root.maxX = incomeValues.length + 1
            for(var j=0; j < incomeValues.length; j++){
                areaChart.append(j, incomeValues[j])
            }
        }
    }
}
