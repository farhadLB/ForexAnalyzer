import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root
    width: 300
    height: 60
    property bool crossVisible: false
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 40
        color: "#8073809c"
        RowLayout{
            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10
            CustomToggle {
                id: positionToggle
                iconSource: "../../assets/position-white.svg"
            }
            CustomToggle {
                id: crossToggle
                onCheckedChanged: {
                    root.crossVisible = !root.crossVisible
                }
            }
            Button {
                text: "←"
                onClicked: chart.prevPosition()
            }
            Button {
                text: "→"
                onClicked: chart.nextPosition()
            }
        }
    }
}
