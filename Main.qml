import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "qml"

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
                implicitWidth: 8
                implicitHeight: 2
                color: SplitHandle.pressed ? "grey"
                                           : (SplitHandle.hovered ? "darkgrey" : "grey")
            }
            LeftBar{}
            ChartPage{}
        }
    }
}
