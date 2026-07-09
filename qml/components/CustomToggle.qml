import QtQuick
import QtQuick.Controls

Button {
    id: root

    property url   iconSource:   GUIParameters.candleOn
    property real  diameter:     48
    property real  iconSize:     20

    property color checkedColor: GUIParameters.secondary
    property color baseColor:    GUIParameters.titleBar
    property color rippleColor:  GUIParameters.secondaryHighlight

    checkable: true

    width:  diameter
    height: diameter
    implicitWidth:  diameter
    implicitHeight: diameter

    leftPadding:   0
    rightPadding:  0
    topPadding:    0
    bottomPadding: 0

    background: Rectangle {
        id: bg
        anchors.fill: parent
        radius: width / 2

        color: {
            if (root.pressed)       return Qt.darker(root.checkedColor, 1.15)
            if (root.checked)       return root.checkedColor
            if (root.hovered && root.enabled)       return root.rippleColor
            return root.baseColor
        }

        Rectangle{
            id: disabledOverlay
            anchors.fill: parent
            color: "grey"
            opacity: 0.2
            z: 10
            visible: !root.enabled
            radius: parent.width / 2

            Behavior on visible {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }

        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        scale: root.pressed ? 0.93 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }
    }

    contentItem: Item {
        implicitWidth:  root.diameter
        implicitHeight: root.diameter

        Image {
            anchors.centerIn: parent
            width:  root.iconSize
            height: root.iconSize
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            opacity: root.enabled ? 1.0 : 0.38

            Behavior on opacity {
                NumberAnimation { duration: 120 }
            }
        }
    }
    Accessible.role:        Accessible.Button
    Accessible.checkable:   true
    Accessible.checked:     root.checked
    Accessible.name:        root.text !== "" ? root.text : "icon button"
}

