import QtQuick
import QtQuick.Controls

Button {
    id: root
    implicitWidth: 100
    implicitHeight: 40
    text: "Custom"
    flat: true
    hoverEnabled: true

    background: Rectangle {
        anchors.fill: parent
        radius: 10
        color: root.pressed ? "green"
               : root.hovered ? "blue"
               : root.down ? "red"
               : "black"
        border.color: "white"
        border.width: 1
    }

    contentItem: Text {
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: 16
        color: "white"
    }
}
