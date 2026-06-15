import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.minimumWidth: 700
    Layout.minimumHeight: 500

    Rectangle {
        anchors.fill: parent
        color: "#111827"

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
                    font.pixelSize: 17
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
                // color: column === 6
                //        ? (Win ? "#00aa55" : "#cc3333")
                //        : (row % 2 === 0 ? "transparent" : "#949fa8")

                color: row % 2 === 0 ? "transparent" : "#2f373d"

                implicitWidth:  column != 3 ? 150 : 200
                implicitHeight: 40
                Text {
                    anchors.centerIn: parent
                    text: {
                        switch(column) {
                        case 0: return Idx + 1
                        case 1: return EntryPrice
                        case 2: return StopLoss
                        case 3: return TakeProfit.toFixed(3)
                        case 4: return Timeframe
                        case 5: return Type
                        case 6: return (Win) ? "success" : "fail"
                        }
                    }
                    font.pixelSize: 17
                    font.bold: column === 6 ? true : false
                    color: column === 6 ? (Win ? "#00aa55" : "#cc3333") : "white"
                }
            }
        }
    }
}
