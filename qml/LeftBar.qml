import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "components"


Rectangle {
    implicitWidth: 300
    SplitView.maximumWidth: 400
    color: "#111827"

    property var chartRef
    property var stackRef

    ColumnLayout{
        anchors.fill: parent


        ScrollView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            contentWidth: availableWidth

            Column {
                id: menuColumn
                width: parent.width
                spacing: 8
                padding: 8

                AccordionItem {
                    title: "Horizantal Level"
                    content: ColumnLayout{
                        spacing: 8

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: levelLabel
                                text: "Sensitivity"
                                font.pixelSize: 14
                                color: "white"
                            }

                            Slider{
                                id: levelSlider
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                from: 10
                                to: 200
                                value: 50
                                stepSize: 1
                                snapMode: Slider.SnapAlways
                                onValueChanged: {
                                    chartRef.backdrop = value
                                }
                            }
                            Text {
                                id: levelValue
                                Layout.minimumWidth: 30
                                Layout.alignment: Qt.AlignRight
                                text: levelSlider.value
                                font.pixelSize: 14
                                color: "white"
                            }
                        }
                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: thresholdLabel
                                text: "threshold"
                                font.pixelSize: 14
                                color: "white"
                            }

                            Slider{
                                id: thresholdSlider
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                from: 0
                                to: 20
                                value: 0
                                stepSize: 1
                                snapMode: Slider.SnapAlways
                                onValueChanged: {
                                    levelDetector.threshold = value
                                }
                            }
                            Text {
                                id: thresholdValue
                                Layout.minimumWidth: 30
                                Layout.alignment: Qt.AlignRight
                                text: thresholdSlider.value
                                font.pixelSize: 14
                                color: "white"
                            }
                        }
                    }
                }

                AccordionItem {
                    title: "TrendLine"
                    content: ColumnLayout {

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: trendLabel
                                text: "Sensitivity"
                                font.pixelSize: 14
                                color: "white"
                            }

                            Slider{
                                id: trendSlider
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                from: 1
                                to: 30
                                value: 10
                                stepSize: 1
                                snapMode: Slider.SnapAlways
                                onValueChanged: {
                                    trendlineDetector.lookback = value
                                }
                            }
                            Text {
                                id: trendValue
                                Layout.minimumWidth: 10
                                Layout.alignment: Qt.AlignRight
                                text: trendSlider.value
                                font.pixelSize: 14
                                color: "white"
                            }
                        }
                        RowLayout{
                            Layout.fillWidth: true
                            Layout.minimumHeight: 80
                            Layout.maximumHeight: 100
                            Layout.alignment: Qt.AlignHCenter
                            Layout.margins: 5
                            CustomToggle{
                                text: "Extend"
                                checked: false
                                Layout.fillWidth: true
                                onCheckedChanged: {
                                    chartRef.extended = !chartRef.extended
                                }
                            }
                            CustomToggle{
                                text: "Strict"
                                checked: true
                                Layout.fillWidth: true
                                onCheckedChanged: {
                                    trendlineDetector.strict = !trendlineDetector.strict
                                }
                            }
                        }
                        TextField{
                            Layout.alignment: Qt.AlignHCenter
                            Layout.margins: 10
                            Layout.maximumHeight: 40
                            placeholderText: "threshold:"
                            placeholderTextColor: "white"
                            Material.theme: Material.Dark
                            onAccepted: {
                                trendlineDetector.penetrationThreshold = parseFloat(text)
                            }
                        }
                    }
                }

                // --- Positions Accordion ---
                AccordionItem {
                    title: "Positions"
                    content: ColumnLayout{
                        spacing: 8
                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            CustomToggle{
                                text: "show positions"
                                checked: false
                                Layout.fillWidth: true
                                onCheckedChanged: {
                                    chartRef.showPosition = !chartRef.showPosition
                                }
                            }
                            CustomButton{
                                Layout.fillWidth: true
                                text: "Run"
                                onClicked: {
                                    if (!chartRef.rawCandles || chartRef.rawCandles.length === 0) return;
                                    positionManager.startCalculation()
                                    stackRef.currentIndex = 1
                                }
                            }
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5
                            Text{
                                id: leveltf
                                Layout.minimumWidth: 120
                                text: "Level Timeframe: "
                                font.pixelSize: 14
                                color: "white"
                            }
                            ComboBox{
                                id: levelCombo
                                model: ["1m", "5m", "15m", "1h", "4h", "Daily"]
                                Material.theme: Material.Dark

                                onActivated: {
                                    positionManager.leveltf = model[currentIndex]
                                }
                            }
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5
                            Text{
                                id: breaktf
                                Layout.minimumWidth: 120
                                text: "Break Timeframe: "
                                font.family: "Book Antiqua"
                                font.pixelSize: 14
                                color: "white"
                            }
                            ComboBox{
                                id: breakCombo
                                model: ["1m", "5m", "15m", "1h", "4h", "Daily"]
                                Material.theme: Material.Dark
                                onActivated: {
                                    positionManager.breaktf = model[currentIndex]
                                }
                            }
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: entryLookback
                                Layout.minimumWidth: 120
                                text: "Entry Sensetivity"
                                font.pixelSize: 14
                                color: "white"
                            }

                            Slider{
                                id: entrySlider
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                from: 1
                                to: 100
                                value: 50
                                stepSize: 1
                                snapMode: Slider.SnapAlways
                                onValueChanged: {
                                    positionManager.entryLookback = value
                                }
                            }
                            Text {
                                id: entryValue
                                Layout.minimumWidth: 10
                                Layout.alignment: Qt.AlignRight
                                text: entrySlider.value
                                font.pixelSize: 14
                                color: "white"
                            }
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: entryThresholdLabel
                                Layout.minimumWidth: 120
                                text: "Entry threshold"
                                font.pixelSize: 14
                                color: "white"
                            }

                            Slider{
                                id: entryThresholdSlider
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                from: 0.1
                                to: 3.0
                                value: 0.1
                                stepSize: 0.1
                                // snapMode: Slider.SnapAlways
                                onValueChanged: {
                                    positionManager.entryThreshold = parseFloat(value.toFixed(1))
                                }
                            }
                            Text {
                                id: entryThresholdValue
                                Layout.minimumWidth: 30
                                Layout.alignment: Qt.AlignRight
                                text: entryThresholdSlider.value.toFixed(1)
                                font.pixelSize: 14
                                color: "white"
                            }
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: entryGap
                                Layout.minimumWidth: 120
                                text: "level gap filter"
                                font.pixelSize: 14
                                color: "white"
                            }

                            Slider{
                                id: entryGapSlider
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                from: 0
                                to: 2
                                value: 1
                                stepSize: 0.1
                                snapMode: Slider.SnapAlways
                                onValueChanged: {
                                    positionManager.levelFilterGap = parseFloat(value.toFixed(1))
                                }
                            }
                            Text {
                                id: entryGapValue
                                Layout.minimumWidth: 10
                                Layout.alignment: Qt.AlignRight
                                text: entryGapSlider.value.toFixed(1)
                                font.pixelSize: 14
                                color: "white"
                            }
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: breakCandles
                                Layout.minimumWidth: 120
                                text: "Break Candles:"
                                font.pixelSize: 14
                                color: "white"
                            }

                            TextField{
                                Layout.alignment: Qt.AlignHCenter
                                Layout.margins: 10
                                Layout.maximumHeight: 40
                                placeholderTextColor: "white"
                                Material.theme: Material.Dark
                                onAccepted: {
                                    positionManager.candleCountForBreak = parseFloat(text)
                                }
                            }
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: stopLookback
                                text: "Stop Sensetivity"
                                Layout.minimumWidth: 120
                                font.pixelSize: 14
                                color: "white"
                            }

                            Slider{
                                id: stopSlider
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                from: 1
                                to: 100
                                value: 30
                                stepSize: 1
                                snapMode: Slider.SnapAlways
                                onValueChanged: {
                                    positionManager.stopLookback = value
                                }
                            }
                            Text {
                                id: stopValue
                                Layout.minimumWidth: 10
                                Layout.alignment: Qt.AlignRight
                                text: stopSlider.value
                                font.pixelSize: 14
                                color: "white"
                            }
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: takeProfitLookback
                                Layout.minimumWidth: 120
                                text: "TP Sensetivity"
                                font.pixelSize: 14
                                color: "white"
                            }

                            Slider{
                                id: takeProfitSlider
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                from: 1
                                to: 100
                                value: 50
                                stepSize: 1
                                snapMode: Slider.SnapAlways
                                onValueChanged: {
                                    positionManager.takeProfitLookback = value
                                }
                            }
                            Text {
                                id: takeProfitValue
                                Layout.minimumWidth: 10
                                Layout.alignment: Qt.AlignRight
                                text: takeProfitSlider.value
                                font.pixelSize: 14
                                color: "white"
                            }
                        }

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            Text{
                                id: tPCandles
                                Layout.minimumWidth: 120
                                text: "TP Candles: "
                                font.pixelSize: 14
                                color: "white"
                            }

                            TextField{
                                Layout.alignment: Qt.AlignHCenter
                                Layout.margins: 10
                                Layout.maximumHeight: 40
                                placeholderTextColor: "white"
                                Material.theme: Material.Dark
                                onAccepted: {
                                    positionManager.candleCountForTP = parseFloat(text)
                                }
                            }
                        }
                    }
                }

            }
        }

        RowLayout{
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            CustomButton{
                Layout.alignment: Qt.AlignBottom
                Layout.margins: 10
                text: "Load CSV File"
                onClicked: fileDialog.open()
            }
            CustomButton{
                Layout.alignment: Qt.AlignBottom
                Layout.margins: 10
                Layout.minimumWidth: 120
                text: "Result Page"
                onClicked: {
                    text =  (text === "Result Page") ? "Chart Page" : "Result Page"
                    stackRef.currentIndex = (stackRef.currentIndex === 1) ? 0 : 1
                }
            }
        }
        CustomProgressBar {
            Layout.fillWidth: true
            Layout.margins: 10
            barHeight: 9
            from: 0; to: 100
            value: csvLoader.progress
            visible: csvLoader.isLoading
            onCancelClicked: csvLoader.cancelLoad()
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select Forex CSV"
        nameFilters: ["CSV files (*.csv)"]
        onAccepted: {
            csvLoader.loadFile(fileDialog.selectedFile)
        }
    }
}
