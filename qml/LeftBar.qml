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
        spacing: 0

        Rectangle{
            id: candleItem
            property bool hovered: false
            Layout.minimumHeight: 70
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            color: stackRef.currentIndex === 0
                   ? GUIParameters.background
                   : (hovered ? GUIParameters.hover : GUIParameters.primary)
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
                hoverEnabled: true
                onEntered: candleItem.hovered = true
                onExited: candleItem.hovered = false
                onClicked: {
                    stackRef.currentIndex = 0
                }
            }
        }

        Rectangle{
            id: strategyItem
            property bool hovered: false
            Layout.minimumHeight: 70
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            color: stackRef.currentIndex === 1
                   ? GUIParameters.background
                   : (hovered ? GUIParameters.hover : GUIParameters.primary)
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
                hoverEnabled: true
                onEntered: strategyItem.hovered = true
                onExited: strategyItem.hovered = false
                onClicked: {
                    stackRef.currentIndex = 1
                }
            }
        }

        Rectangle{
            id: tableItem
            property bool hovered: false
            Layout.minimumHeight: 70
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            color: stackRef.currentIndex === 2
                   ? GUIParameters.background
                   : (hovered ? GUIParameters.hover : GUIParameters.primary)
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
                hoverEnabled: true
                onEntered: tableItem.hovered = true
                onExited: tableItem.hovered = false
                onClicked: {
                    stackRef.currentIndex = 2
                }
            }
        }

        Rectangle{
            id: apiItem
            property bool hovered: false
            Layout.minimumHeight: 70
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            color: stackRef.currentIndex === 3
                   ? GUIParameters.background
                   : (hovered ? GUIParameters.hover : GUIParameters.primary)
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
                    source: stackRef.currentIndex !== 3 ? GUIParameters.apiOff : GUIParameters.apiOn
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: 5
                }
                Text {
                    Layout.minimumWidth: 50
                    height: 20
                    text: "API Settings"
                    font.pixelSize: GUIParameters.fontSizeNormal
                    Layout.alignment: Qt.AlignLeft
                    color: stackRef.currentIndex !== 3 ? GUIParameters.textOff : GUIParameters.textOnPrimary
                }
            }
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                onEntered: apiItem.hovered = true
                onExited: apiItem.hovered = false
                onClicked: {
                    stackRef.currentIndex = 3
                }
            }
        }
    }
}
