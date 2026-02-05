import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: centerItem
    SplitView.minimumWidth: 50
    SplitView.fillWidth: true
    color: "#0b0b17"

    ColumnLayout{
        anchors.fill: parent

        CandleChart {
            id: chart
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 10
            text: "toggle crosshair"
            onClicked: chart.crossVisible = !chart.crossVisible
        }
    }


    Connections {
        target: csvLoader

        function onCandlesReady(list) {
            chart.candles = list
        }
    }

}
