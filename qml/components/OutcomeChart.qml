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
    property int  totalPos: 0
    property int  successPos: 0
    property int  failedPos: 0
    property int  strategyGain: 0
    property double  averageRtoR: 0

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 10
        Rectangle{
            Layout.preferredHeight: 250
            Layout.fillWidth: true
            Layout.margins: 5
            color: "transparent"
            radius: 15
            border.color: "grey"
            border.width: 2

            RowLayout{
                anchors.fill: parent

                CircularGauge{
                    id: winrateGauge
                    ringWidth: 15
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.maximumHeight: 200
                    Layout.maximumWidth: 200
                    percentage: 0;
                }

                Rectangle{
                    height: parent.height - 50
                    width: 2
                    color: "grey"
                    radius: 1
                }
                ColumnLayout{
                    Layout.fillHeight: true
                    Layout.maximumWidth: 300
                    Layout.leftMargin: 20
                    Text {
                        text: "Total Positions: "
                        color: "white"
                        font.pixelSize: 18
                    }
                    Text {
                        text: "Successful Positions: "
                        color: "white"
                        font.pixelSize: 18
                    }
                    Text {
                        text: "Failed Positions: "
                        color: "white"
                        font.pixelSize: 18
                    }
                    Text {
                        text: "Average Reward to Risk Ratio: "
                        color: "white"
                        font.pixelSize: 18
                    }
                    Text {
                        text: "Strategy Gain: "
                        color: "white"
                        font.pixelSize: 18
                    }
                }
                ColumnLayout{
                    Layout.fillHeight: true
                    Layout.maximumWidth: 300
                    Text {
                        text: root.totalPos
                        color: "white"
                        font.pixelSize: 18
                    }
                    Text {
                        text: root.successPos
                        color: "white"
                        font.pixelSize: 18
                    }
                    Text {
                        text: root.failedPos
                        color: "white"
                        font.pixelSize: 18
                    }
                    Text {
                        text: root.averageRtoR.toFixed(2)
                        color: "white"
                        font.pixelSize: 18
                    }
                    Text {
                        text: root.strategyGain
                        color: "white"
                        font.pixelSize: 18
                    }
                }
            }
        }

        Rectangle{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 5
            color: "transparent"
            radius: 15
            border.color: "grey"
            border.width: 2
            ChartView {
                anchors.fill: parent
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
                    color: "#A855F7"
                    upperSeries: LineSeries {
                        id: areaChart
                    }
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
            root.totalPos = positionsInfo.totalPositions
            root.successPos = positionsInfo.successfulPositions
            root.failedPos = positionsInfo.failedPositions
            root.averageRtoR = positionsInfo.averageRtoR
            root.strategyGain = positionsInfo.strategyGain

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
