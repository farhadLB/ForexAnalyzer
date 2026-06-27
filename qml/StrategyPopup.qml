import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent
    property alias popupRef: popup
    Popup{
        id: popup

        property int leftMarginValue: 15
        property int buttonHeight: 30
        property int tabIndex: 0

        width: 800
        height: 600
        modal: true
        closePolicy: Popup.NoAutoClose | Popup.CloseOnEscape
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 1 }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: 1 }
        }
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        background: Rectangle{
            id: bg
            width: popup.width
            height: popup.height
            color: "#111827"
            radius: 10
            Rectangle{
                id: closeButton
                width: 15
                height: 15
                radius: 15
                color: "grey"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.topMargin: 10
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: closeButton.color = "red"
                    onExited: closeButton.color = "grey"
                    onClicked: {
                        popup.close()
                    }
                }
            }
            Text {
                id: title
                text: "Stretegy Settings"
                color: "white"
                font.pixelSize: 20
                font.bold: true
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: popup.leftMarginValue
            }
            RowLayout{
                id: tabBar
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 50
                anchors.leftMargin: popup.leftMarginValue
                spacing: 1
                width: 270
                Rectangle{
                    id: entryButton
                    width: 90
                    height: popup.buttonHeight
                    color: popup.tabIndex === 0 ? "#202c48" : "#3e3e59"
                    topRightRadius: 5
                    topLeftRadius: 5
                    Text {
                        anchors.centerIn: parent
                        text: "Entry Point"
                        font.pixelSize: 14
                        color: "white"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            stopButton.height = popup.buttonHeight
                            takeProfitButton.height = popup.buttonHeight
                            entryButton.height = popup.buttonHeight + 5
                            popup.tabIndex = 0
                        }
                    }
                }
                Rectangle{
                    id: stopButton
                    width: 90
                    height: popup.buttonHeight
                    color: popup.tabIndex === 1 ? "#202c48" : "#3e3e59"
                    topRightRadius: 5
                    topLeftRadius: 5
                    Text {
                        anchors.centerIn: parent
                        text: "Stop Loss"
                        font.pixelSize: 14
                        color: "white"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            takeProfitButton.height = popup.buttonHeight
                            entryButton.height = popup.buttonHeight
                            stopButton.height = popup.buttonHeight + 5
                            popup.tabIndex = 1
                        }
                    }
                }
                Rectangle{
                    id: takeProfitButton
                    width: 90
                    height: popup.buttonHeight
                    color: popup.tabIndex === 2 ? "#202c48" : "#3e3e59"
                    topRightRadius: 5
                    topLeftRadius: 5
                    Text {
                        anchors.centerIn: parent
                        text: "Take Profit"
                        font.pixelSize: 14
                        color: "white"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            stopButton.height = popup.buttonHeight
                            entryButton.height = popup.buttonHeight
                            takeProfitButton.height = popup.buttonHeight + 5
                            popup.tabIndex = 2
                        }
                    }
                }
            }
            Rectangle{
                id: main
                width: popup.width - 40
                height: popup.height - 150
                anchors.top: tabBar.bottom
                anchors.left: parent.left
                anchors.leftMargin: popup.leftMarginValue
                color: "#202c48"
                topRightRadius: 10
                bottomLeftRadius: 10
                bottomRightRadius: 10
                Item{
                    id: entryWindow
                    anchors.fill: parent
                    visible: popup.tabIndex === 0
                    ColumnLayout{
                        anchors.fill: parent
                        anchors.topMargin: 40
                        anchors.leftMargin: 10
                        anchors.bottomMargin: 40

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10
                            spacing: 200

                            RowLayout{
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text{
                                    id: leveltf
                                    Layout.minimumWidth: 120
                                    text: "Level Timeframe: "
                                    font.pixelSize: 13
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
                                Layout.alignment: Qt.AlignRight
                                Text{
                                    id: breaktf
                                    Layout.minimumWidth: 120
                                    text: "Break Timeframe: "
                                    font.family: "Book Antiqua"
                                    font.pixelSize: 13
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
                        }
                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10

                            Text{
                                id: entryLookback
                                Layout.minimumWidth: 120
                                text: "Entry Sensetivity"
                                font.pixelSize: 13
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
                                onValueChanged: {
                                    positionManager.entryLookback = value
                                }
                            }
                            Text {
                                id: entryValue
                                Layout.minimumWidth: 10
                                Layout.alignment: Qt.AlignRight
                                text: entrySlider.value
                                font.pixelSize: 13
                                color: "white"
                            }
                        }
                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10

                            Text{
                                id: entryThresholdLabel
                                Layout.minimumWidth: 120
                                text: "Entry threshold"
                                font.pixelSize: 13
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
                                onValueChanged: {
                                    positionManager.entryThreshold = parseFloat(value.toFixed(1))
                                }
                            }
                            Text {
                                id: entryThresholdValue
                                Layout.minimumWidth: 10
                                Layout.alignment: Qt.AlignRight
                                text: entryThresholdSlider.value.toFixed(1)
                                font.pixelSize: 13
                                color: "white"
                            }
                        }
                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10

                            Text{
                                id: entryGap
                                Layout.minimumWidth: 120
                                text: "level gap filter"
                                font.pixelSize: 13
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
                                onValueChanged: {
                                    positionManager.levelFilterGap = parseFloat(value.toFixed(1))
                                }
                            }
                            Text {
                                id: entryGapValue
                                Layout.minimumWidth: 10
                                Layout.alignment: Qt.AlignRight
                                text: entryGapSlider.value.toFixed(1)
                                font.pixelSize: 13
                                color: "white"
                            }
                        }
                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10

                            Text{
                                id: breakCandles
                                Layout.minimumWidth: 120
                                text: "Break Candles:"
                                font.pixelSize: 13
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
                    }
                }
                Item {
                    id: stopWindow
                    anchors.fill: parent
                    visible: popup.tabIndex === 1
                    ColumnLayout{
                        anchors.fill: parent
                        anchors.topMargin: 40
                        anchors.leftMargin: 10
                        anchors.bottomMargin: 40
                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10

                            Text{
                                id: stopLookback
                                text: "Stop Sensetivity"
                                Layout.minimumWidth: 120
                                font.pixelSize: 13
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
                                font.pixelSize: 13
                                color: "white"
                            }
                        }
                    }
                }
                Item {
                    id: takeProfitWindow
                    anchors.fill: parent
                    visible: popup.tabIndex === 2
                    ColumnLayout{
                        anchors.fill: parent
                        anchors.topMargin: 40
                        anchors.leftMargin: 10
                        anchors.bottomMargin: 40

                        RowLayout{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10

                            Text{
                                id: takeProfitLookback
                                Layout.minimumWidth: 120
                                text: "TP Sensetivity"
                                font.pixelSize: 13
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
                                font.pixelSize: 13
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
    }
}
