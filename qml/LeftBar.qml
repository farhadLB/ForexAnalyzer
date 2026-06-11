import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "components"


Rectangle {
    implicitWidth: 300
    SplitView.maximumWidth: 400
    color: "#0b0b17"

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
                                color: "grey"
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
                                color: "grey"
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
                                color: "grey"
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
                                color: "grey"
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
                                color: "grey"
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
                                color: "grey"
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
                text: "Result Page"
                onClicked: {
                    text =  (text === "Result Page") ? "Chart Page" : "Result Page"
                    stackRef.currentIndex = (stackRef.currentIndex === 1) ? 0 : 1
                }
            }
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
