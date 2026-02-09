import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "components"


Rectangle {
    implicitWidth: 200
    SplitView.maximumWidth: 300
    color: "#0b0b17"

    property var chartRef

    FileDialog {
        id: fileDialog
        title: "Select Forex CSV"
        nameFilters: ["CSV files (*.csv)"]
        onAccepted: {
            // تبدیل URL به path واقعی
            csvLoader.loadFile(fileDialog.selectedFile)
        }
    }
    ColumnLayout{
        width: parent.width
        height: 360

        Rectangle{
            Layout.minimumWidth: 180
            Layout.maximumWidth: 280
            Layout.preferredHeight: 80
            Layout.maximumHeight: 80
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            border.width: 2
            border.color: "grey"
            color: "transparent"
            radius: 8

            ColumnLayout{
                anchors.fill: parent

                Text{
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: 5
                    text: "Horizantal Levels"
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                }

                RowLayout{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 5

                    Text{
                        text: "Sensitivity"
                        font.pixelSize: 14
                        color: "grey"
                    }

                    Slider{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        from: 10
                        to: 200
                        value: 50
                        snapMode: Slider.SnapAlways
                        onValueChanged: {
                            chartRef.backdrop = value
                        }
                    }
                }
            }
        }

        Rectangle{
            Layout.minimumWidth: 180
            Layout.maximumWidth: 280
            Layout.preferredHeight: 180
            Layout.maximumHeight: 180
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            border.width: 2
            border.color: "grey"
            color: "transparent"
            radius: 8

            ColumnLayout{
                anchors.fill: parent
                Text{
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: 5
                    text: "Trendline Controls"
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                }

                RowLayout{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 5

                    Text{
                        text: "Sensitivity"
                        font.pixelSize: 14
                        color: "grey"
                    }

                    Slider{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        from: 1
                        to: 50
                        value: 20
                        stepSize: 1
                        snapMode: Slider.SnapAlways
                        onValueChanged: {
                            trendlineDetector.lookback = value
                        }
                    }
                }
            }
        }


        CustomButton{
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
            Layout.margins: 10
            text: "Load CSV File"
            onClicked: fileDialog.open()
        }
    }
}
