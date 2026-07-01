import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Window {
    id: root
    width: 1480
    height: 820
    visible: true
    title: "Forex Analyzer"
    flags: Qt.Window | Qt.FramelessWindowHint
    property int buttonRadius: 15
    property var stackRef: myStack
    Item{
        anchors.fill: parent
        TitleBar {
            id: titleBar
            root: root
        }

        LeftBar{
            id: leftBar
            height: parent.height - titleBar.height
            width: 150
            anchors.left: parent.left
            anchors.top: titleBar.bottom
            stackRef: myStack
        }

        Item {
            id: windowArea
            width: parent.width - leftBar.width
            height: parent.height - titleBar.height
            anchors.right: parent.right
            anchors.top: titleBar.bottom
            StackLayout{
                id: myStack
                currentIndex: 0
                anchors.fill: parent
                ChartPage{
                    id: chartPage
                    stackRef: myStack
                }
                InfographyPage{
                    id: infoPage
                }
                ResultPage{
                    id: resultPage
                }
            }
        }
    }
}
