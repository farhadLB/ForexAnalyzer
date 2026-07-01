import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root
    width: 200
    height: 50
    property bool crossVisible: false
    property var chartRef
    property bool positionChecked: positionToggle.checked
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
                id: crossToggle
                diameter: 40
                iconSource: GUIParameters.crosshairIcon
                onCheckedChanged: {
                    root.crossVisible = !root.crossVisible
                }
                CustomToolTip{
                    visible: parent.hovered
                    text: "Crosshair"
                }
            }
            CustomToggle {
                id: positionToggle
                diameter: 40
                iconSize: 25
                iconSource: GUIParameters.dollar
                enabled: false
                onClicked: {
                    chartRef.positionVisible = ! chartRef.positionVisible
                }
                CustomToolTip{
                    visible: parent.hovered
                    text: positionToggle.checked ? "Hide Positions" : "Show Positions"
                }
            }
            CustomRoundButton {
                diameter: 40
                iconSource: enabled ? GUIParameters.leftArrow : GUIParameters.leftArrowOff
                onClicked: chart.prevPosition()
                enabled: positionToggle.checked
                CustomToolTip{
                    visible: parent.hovered
                    text: "Previous Positions"
                }
            }
            CustomRoundButton {
                diameter: 40
                iconSource: enabled ? GUIParameters.rightArrow : GUIParameters.rightArrowOff
                onClicked: chart.nextPosition()
                enabled: positionToggle.checked
                CustomToolTip{
                    visible: parent.hovered
                    text: "Next Positions"
                }
            }
        }
    }
    Connections{
        target: positionManager
        function onPositionListReady(){
            positionToggle.enabled = true
        }
    }
    Connections{
        target: csvLoader
        function onCloseCsvFile(){
            positionToggle.enabled = false
        }
    }
}
