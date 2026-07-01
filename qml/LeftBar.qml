import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "components"


Rectangle{
    id: leftMenu
    color: GUIParameters.primary
    property var stackRef

    ColumnLayout{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        Rectangle{
            Layout.minimumHeight: 60
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            color: stackRef.currentIndex !== 0 ? GUIParameters.primary : GUIParameters.background
            RowLayout{
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15
                Image {
                    Layout.maximumWidth: 25
                    Layout.maximumHeight: 25
                    antialiasing: true
                    source: stackRef.currentIndex !== 0 ? GUIParameters.candleOff : GUIParameters.candleOn
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: 5
                }
                Text {
                    Layout.minimumWidth: 50
                    height: 20
                    text: "Candle Chart"
                    font.pixelSize: GUIParameters.fontSizeNormal
                    Layout.alignment: Qt.AlignLeft
                    color: stackRef.currentIndex !== 0 ? GUIParameters.textOff : GUIParameters.textOnPrimary
                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    stackRef.currentIndex = 0
                }
            }
        }
        Rectangle{
            Layout.minimumHeight: 60
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            color: stackRef.currentIndex !== 1 ? GUIParameters.primary : GUIParameters.background
            RowLayout{
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15
                Image {
                    Layout.maximumWidth: 25
                    Layout.maximumHeight: 25
                    antialiasing: true
                    source: stackRef.currentIndex !== 1 ? GUIParameters.chartOff : GUIParameters.chartOn
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: 5
                }
                Text {
                    Layout.minimumWidth: 50
                    height: 20
                    text: "Stretegy Result"
                    font.pixelSize: GUIParameters.fontSizeNormal
                    Layout.alignment: Qt.AlignLeft
                    color: stackRef.currentIndex !== 1 ? GUIParameters.textOff : GUIParameters.textOnPrimary

                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    stackRef.currentIndex = 1
                }
            }
        }
        Rectangle{
            Layout.minimumHeight: 60
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            color: stackRef.currentIndex !== 2 ? GUIParameters.primary : GUIParameters.background
            RowLayout{
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15
                Image {
                    Layout.maximumWidth: 25
                    Layout.maximumHeight: 25
                    antialiasing: true
                    source: stackRef.currentIndex !== 2 ? GUIParameters.tableOff : GUIParameters.tableOn
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: 5
                }
                Text {
                    Layout.minimumWidth: 50
                    height: 20
                    text: "Positions Table"
                    font.pixelSize: GUIParameters.fontSizeNormal
                    Layout.alignment: Qt.AlignLeft
                    color: stackRef.currentIndex !== 2 ? GUIParameters.textOff : GUIParameters.textOnPrimary
                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    stackRef.currentIndex = 2
                }
            }
        }
    }
}
