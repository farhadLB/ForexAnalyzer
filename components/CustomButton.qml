import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button{
    width: 70
    height: 50
    background: Rectangle{
        id: innerRec
        anchors.fill: parent
        color: "red"
        radius: 10
    }
}

