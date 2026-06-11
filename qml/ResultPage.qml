import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    SplitView.minimumWidth: 50
    SplitView.fillWidth: true

    Rectangle {
        anchors.fill: parent
        color: "#0b0b17"

        HorizontalHeaderView {
            id: horizontalHeader
            syncView: tableView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            delegate: Rectangle {
                color: "#2a5175"
                implicitHeight: 40
                Text {
                    anchors.centerIn: parent
                    text: model.display
                    font.bold: true
                    font.pixelSize: 22
                    color: "white"
                }
            }
        }

        TableView {
            id: tableView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: horizontalHeader.bottom
            anchors.bottom: parent.bottom
            anchors.margins: 10
            columnSpacing: 2
            rowSpacing: 2
            clip: true
            model: positionModel
            delegate: Rectangle {
                color: column != 5 ? "transparent" : Win ? "#00aa55" : "#cc3333"
                implicitWidth: 200
                implicitHeight: 40
                border.color: "grey"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: {
                        switch(column) {
                        case 0: return EntryPrice
                        case 1: return StopLoss
                        case 2: return TakeProfit
                        case 3: return Timeframe
                        case 4: return Type
                        case 5: return (Win) ? "win" : "fail"
                        }
                    }
                    font.pixelSize: 17
                    color: "white"
                }
            }
        }
    }
}
