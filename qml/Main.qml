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

        Rectangle{
            id: leftMenu
            height: parent.height - titleBar.height
            width: 150
            color: "#3e3e59"
            anchors.left: parent.left
            anchors.top: titleBar.bottom
            ColumnLayout{
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                Rectangle{
                    Layout.minimumHeight: 60
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    color: myStack.currentIndex !== 0 ? "#3e3e59" : "#111827"
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
                            source: myStack.currentIndex !== 0 ? "../assets/candle-grey-small.svg" : "../assets/candle-white-small.svg"
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 5
                        }
                        Text {
                            Layout.minimumWidth: 50
                            height: 20
                            text: "Candle Chart"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignLeft
                            color: myStack.currentIndex !== 0 ? "grey" : "white"
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            myStack.currentIndex = 0
                        }
                    }
                }
                Rectangle{
                    Layout.minimumHeight: 60
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    color: myStack.currentIndex !== 1 ? "#3e3e59" : "#111827"
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
                            source: myStack.currentIndex !== 1 ? "../assets/chart-line-grey.svg" : "../assets/chart-line-white.svg"
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 5
                        }
                        Text {
                            Layout.minimumWidth: 50
                            height: 20
                            text: "Stretegy Result"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignLeft
                            color: myStack.currentIndex !== 1 ? "grey" : "white"

                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            myStack.currentIndex = 1
                        }
                    }
                }
                Rectangle{
                    Layout.minimumHeight: 60
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    color: myStack.currentIndex !== 2 ? "#3e3e59" : "#111827"
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
                            source: myStack.currentIndex !== 2 ? "../assets/table-grey.svg" : "../assets/table-white.svg"
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 5
                        }
                        Text {
                            Layout.minimumWidth: 50
                            height: 20
                            text: "Positions Table"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignLeft
                            color: myStack.currentIndex !== 2 ? "grey" : "white"
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            myStack.currentIndex = 2
                        }
                    }
                }
            }
        }

        Item {
            id: windowArea
            width: parent.width - leftMenu.width
            height: parent.height - titleBar.height
            anchors.right: parent.right
            anchors.top: titleBar.bottom
            StackLayout{
                id: myStack
                currentIndex: 0
                anchors.fill: parent
                ChartPage{
                    id: chartPage
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
