import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.minimumWidth: 700
    Layout.minimumHeight: 500
    property int  sortColumn: -1
    property bool sortAscending: true
    property int hoveredRow: -1

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
                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: model.display
                        font.bold: true
                        font.pixelSize: 17
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        visible: sortColumn === column
                        text: sortAscending ? "▲" : "▼"
                        font.pixelSize: 13
                        color: "#add8ff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.sortColumn === column)
                            root.sortAscending = !sortAscending
                        else {
                            root.sortColumn    = column
                            root.sortAscending = true
                        }
                        positionModel.sort(
                                    column,
                                    root.sortAscending ? Qt.AscendingOrder : Qt.DescendingOrder
                                    )
                        tableView.model = null
                        tableView.model = positionModel
                    }
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
                id: rec
                color: {
                    if (root.hoveredRow === row)
                        return "#1e3a5f"
                    return row % 2 === 0 ? "transparent" : "#2f373d"
                }
                implicitWidth:  column != 3 ? 150 : 200
                implicitHeight: 40

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.hoveredRow = row
                    onExited:  root.hoveredRow = -1
                }

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
