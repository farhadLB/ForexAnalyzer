import QtQuick
import QtQuick.Controls

Button{
    id: root
    implicitWidth: 70
    implicitHeight: 40
    flat: true

    background: Rectangle{
        anchors.fill: parent
        radius: 10
        color: root.hovered ? "blue" : root.pressed ? "green" : root.clicked ? "grey" : root.down ? "red" : "black"
    }
    contentItem: Text {
        id: title
        anchors.centerIn: parent
        text: "hello"
        font.pixelSize: 15
    }
}
