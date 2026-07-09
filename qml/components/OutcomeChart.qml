import QtQuick
import QtCharts
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    property real  initialMoney:    1000
    property real  finalMoney:      0
    property real  risk:            1
    property real  maxX:            20
    property real  minY:            0
    property real  maxY:            20
    property real  totalPos:        0
    property real  successPos:      0
    property real  failedPos:       0
    property real  strategyGain:    0
    property double  averageRtoR:   0

    ScrollView{
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        contentHeight: columnLayout.implicitHeight

        ColumnLayout{
            id: columnLayout
            width: parent.width
            Rectangle{
                Layout.preferredHeight: 250
                Layout.fillWidth: true
                Layout.margins: 5
                color: "transparent"
                radius: 15
                border.color: "grey"
                border.width: 1

                RowLayout{
                    anchors.fill: parent

                    CircularGauge{
                        id: winrateGauge
                        ringWidth: 15
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
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
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: "Successful Positions: "
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: "Failed Positions: "
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: "Average Reward to Risk Ratio: "
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: "Initial Equity: "
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: "Final Equity: "
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: "Strategy Gain: "
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                    }
                    ColumnLayout{
                        Layout.fillHeight: true
                        Layout.maximumWidth: 300
                        Text {
                            text: root.totalPos
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: root.successPos
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: root.failedPos
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: root.averageRtoR.toFixed(2)
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: root.initialMoney + " ($)"
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: root.finalMoney + " ($)"
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                        Text {
                            text: root.strategyGain
                            color: GUIParameters.textOnPrimary
                            font.pixelSize: GUIParameters.fontSizeLarge
                        }
                    }
                }
            }

            Rectangle{
                id: outcomeChart
                Layout.preferredHeight: 500
                Layout.fillWidth: true
                Layout.margins: 5
                color: "transparent"
                radius: 15
                border.color: "grey"
                border.width: 1
                ChartView {
                    id: chart
                    anchors.fill: parent
                    antialiasing: true
                    legend.visible: false
                    theme: GUIParameters.chartTheme

                    function applyTransparentStyle() {
                        backgroundColor = "transparent"
                        plotAreaColor = "transparent"
                        areaSeries.color = GUIParameters.secondaryHighlight
                        valueAxisX.gridLineColor = Qt.rgba(0.5, 0.5, 0.5, 0.3)
                        valueAxisY.gridLineColor = Qt.rgba(0.5, 0.5, 0.5, 0.3)
                    }

                    Component.onCompleted: applyTransparentStyle()

                    Connections {
                        target: GUIParameters

                        function onChartThemeChanged() {
                            chart.applyTransparentStyle()
                        }
                    }

                    ValueAxis {
                        id: valueAxisX
                        min: 0
                        max: root.maxX
                        labelFormat: "%.0f"
                        titleText: "Number of positions"
                        tickCount: root.maxX < 20 ? root.maxX : 20
                        gridLineColor: Qt.rgba(0.5, 0.5, 0.5, 0.3)
                    }
                    ValueAxis {
                        id: valueAxisY
                        min: root.minY
                        max: root.maxY
                        titleText: "Equity ($)"
                        tickCount: 15
                        gridLineColor: Qt.rgba(0.5, 0.5, 0.5, 0.3)
                    }

                    AreaSeries {
                        id: areaSeries
                        axisX: valueAxisX
                        axisY: valueAxisY
                        color: GUIParameters.secondaryHighlight
                        upperSeries: LineSeries {
                            id: areaChart
                        }
                    }
                }
            }

            Rectangle{
                id: winTable
                Layout.preferredHeight: 500
                Layout.fillWidth: true
                Layout.margins: 5
                color: "transparent"
                radius: 15
                border.color: "grey"
                border.width: 1
                visible: false
                ChartView {
                    id: winChart
                    anchors.fill: parent
                    antialiasing: true
                    legend.visible: true
                    theme: GUIParameters.chartTheme

                    function applyTransparentStyle() {
                        backgroundColor = "transparent"
                        plotAreaColor = "transparent"
                        areaSeries2.color = "green"
                        valueAxisX.gridLineColor = Qt.rgba(0.5, 0.5, 0.5, 0.3)
                        valueAxisY.gridLineColor = Qt.rgba(0.5, 0.5, 0.5, 0.3)
                    }

                    Component.onCompleted: applyTransparentStyle()

                    Connections {
                        target: GUIParameters

                        function onChartThemeChanged() {
                            winChart.applyTransparentStyle()
                        }
                    }

                    ValueAxis {
                        id: valueAxisX2
                        min: 0
                        max: root.maxX
                        labelFormat: "%.0f"
                        tickCount: root.maxX < 20 ? root.maxX : 20
                        gridLineColor: Qt.rgba(0.5, 0.5, 0.5, 0.3)
                    }
                    ValueAxis {
                        id: valueAxisY2
                        min: root.minY
                        max: root.maxY
                        tickCount: 15
                        gridLineColor: Qt.rgba(0.5, 0.5, 0.5, 0.3)
                    }

                    AreaSeries {
                        id: areaSeries2
                        axisX: valueAxisX2
                        axisY: valueAxisY2
                        color: GUIParameters.secondaryHighlight
                        upperSeries: LineSeries {
                            id: winSeries
                        }
                    }
                }
            }
            Rectangle{
                id: loseTable
                Layout.preferredHeight: 500
                Layout.fillWidth: true
                Layout.margins: 5
                color: "transparent"
                radius: 15
                border.color: "grey"
                border.width: 1
                visible: false
                ChartView {
                    id: loseChart
                    anchors.fill: parent
                    antialiasing: true
                    legend.visible: false
                    theme: GUIParameters.chartTheme

                    function applyTransparentStyle() {
                        backgroundColor = "transparent"
                        plotAreaColor = "transparent"
                        areaSeries3.color = "red"
                        valueAxisX.gridLineColor = Qt.rgba(0.5, 0.5, 0.5, 0.3)
                        valueAxisY.gridLineColor = Qt.rgba(0.5, 0.5, 0.5, 0.3)
                    }

                    Component.onCompleted: applyTransparentStyle()

                    Connections {
                        target: GUIParameters

                        function onChartThemeChanged() {
                            loseChart.applyTransparentStyle()
                        }
                    }

                    ValueAxis {
                        id: valueAxisX3
                        min: 0
                        max: root.maxX
                        labelFormat: "%.0f"
                        tickCount: root.maxX < 20 ? root.maxX : 20
                        gridLineColor: Qt.rgba(0.5, 0.5, 0.5, 0.3)
                    }
                    ValueAxis {
                        id: valueAxisY3
                        min: root.minY
                        max: root.maxY
                        tickCount: 15
                        gridLineColor: Qt.rgba(0.5, 0.5, 0.5, 0.3)
                    }

                    AreaSeries {
                        id: areaSeries3
                        axisX: valueAxisX3
                        axisY: valueAxisY3
                        color: GUIParameters.secondaryHighlight
                        upperSeries: LineSeries {
                            id: loseSeries
                        }
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

            winSeries.clear()
            loseSeries.clear()

            var wins = Array(24).fill(0)
            var losses = Array(24).fill(0)

            // Count positions per hour
            for (var i = 0; i < values.length; i++) {
                var hour = values[i].time

                if (values[i].isWin)
                    wins[hour]++
                else
                    losses[hour]++
            }

            // Add to chart
            for (var h = 0; h < 24; h++) {
                winSeries.append(h, wins[h])
                loseSeries.append(h, losses[h])
            }

            // Update axes
            valueAxisX2.min = 0
            valueAxisX2.max = 23

            valueAxisX3.min = 0
            valueAxisX3.max = 23

            var maxCount = Math.max(
                        ...wins,
                        ...losses
                        )

            valueAxisY2.min = 0
            valueAxisY2.max = maxCount + 1

            valueAxisY3.min = 0
            valueAxisY3.max = maxCount + 1

            for(var i=0; i < values.length; i++){
                income += values[i].yValue * risk * (income/100)
                incomeValues.push(income)
            }
            root.finalMoney = income.toFixed(1)
            root.minY = Math.min(...incomeValues)
            root.maxY = Math.max(...incomeValues) * 1.05
            root.maxX = incomeValues.length + 1
            for(var j=0; j < incomeValues.length; j++){
                areaChart.append(j, incomeValues[j])
            }
        }
    }
    Connections {
        target: csvLoader
        function onCandlesReady() {
            areaChart.clear()
            winrateGauge.percentage = 0
            root.totalPos = 0
            root.successPos = 0
            root.failedPos = 0
            root.averageRtoR = 0
            root.strategyGain = 0
        }
        function onCloseCsvFile() {
            areaChart.clear()
            winrateGauge.percentage = 0
            root.totalPos = 0
            root.successPos = 0
            root.failedPos = 0
            root.averageRtoR = 0
            root.strategyGain = 0
        }
    }
    Connections {
        target: tdWorker
        function onCandlesReady() {
            areaChart.clear()
            winrateGauge.percentage = 0
            root.totalPos = 0
            root.successPos = 0
            root.failedPos = 0
            root.averageRtoR = 0
            root.strategyGain = 0
        }
    }
}
