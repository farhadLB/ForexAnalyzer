import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    width: 1920
    height: 1080
    visible: true
    title: "Forex Analyzer"
    Item{
        anchors.fill: parent
        SplitView {
            anchors.fill: parent
            handle: Rectangle {
                implicitWidth: 6
                implicitHeight: 2
                radius: 2
                color: SplitHandle.pressed ? "grey"
                                           : (SplitHandle.hovered ? "darkgrey" : "grey")

                Rectangle {
                    width: parent.width - 4
                    height: parent.height
                    radius: 2
                    color: "#0b0b17"
                    anchors.centerIn: parent
                }
            }
            LeftBar{
                id: leftBar
                chartRef: chartPage
                stackRef: myStack
            }
            StackLayout{
                id: myStack
                currentIndex: 0
                SplitView.minimumWidth: 50
                SplitView.fillWidth: true
                ChartPage{
                    id: chartPage
                }
                // ResultPage{
                //     id: resultPage
                // }
                InfographyPage{
                    id: resultPage
                }
            }
        }
    }
}
