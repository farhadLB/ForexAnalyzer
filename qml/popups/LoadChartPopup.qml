import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

Item {
    anchors.fill: parent
    property alias popupRef: popup
    Popup{
        id: popup

        property int leftMarginValue: 15
        property int buttonHeight: 30
        property int tabIndex: 0

        width: 400
        height: 170
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
            color: GUIParameters.background
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
                text: "Import Chart Data"
                color: GUIParameters.textOnPrimary
                font.pixelSize: GUIParameters.fontSizeTitle
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 20
            }
            RowLayout{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 50
                spacing: 30
                CustomButton{
                    buttonText: "From CSV File"
                    iconSource: GUIParameters.slider
                    iconVisible: false
                    textSize: GUIParameters.fontSizeNormal
                    onClicked: {
                        fileDialog.open()
                        popup.close()
                    }
                }
                CustomButton{
                    buttonText: "From API"
                    iconSource: GUIParameters.slider
                    iconVisible: false
                    textSize: GUIParameters.fontSizeNormal
                    onClicked: {
                        if(tdWorker.hasApiKey()){
                            chartObjects.clearPositions()
                            positionModel.clearData()
                            tdWorker.stream("1min")
                            candleModel.isFromCSV = false
                            stackRef.currentIndex = 0
                            popup.close()
                        }
                        else{
                            stackRef.currentIndex = 3
                            popup.close()
                        }
                    }
                }
            }
        }
    }
    FileDialog {
        id: fileDialog
        title: "Select Forex CSV"
        nameFilters: ["CSV files (*.csv)"]
        onAccepted: {
            GUIParameters.positionChecked = true
            chartObjects.clearPositions()
            csvLoader.loadFile(fileDialog.selectedFile)
            candleModel.isFromCSV = true
        }
    }
}
