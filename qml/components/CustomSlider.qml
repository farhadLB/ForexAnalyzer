import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

Slider {
    id: root

    property real  trackRadius:    4
    property real  handleRadius:   10
    property color baseColor:      GUIParameters.titleBar
    property color activeBorder:   GUIParameters.secondaryHighlight
    property color fillColor:      GUIParameters.secondary
    property color handleColor:    GUIParameters.primary
    property color borderColor:    root.enabled ? GUIParameters.secondary : "grey"
    property color textColor:      root.enabled ? GUIParameters.textOnPrimary : "grey"
    property int   decimal:        0

    implicitWidth:  200
    implicitHeight: 42

    from:  0
    to:    100
    value: 0

    // --- Track ---
    background: Rectangle {
        x: 0
        y: (root.height - height) / 2
        width:  root.availableWidth
        height: 6
        radius: root.trackRadius
        color:  root.baseColor
        border.color: root.pressed ? root.activeBorder : root.borderColor
        border.width: root.pressed ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Rectangle {
            id: disabledOverlay
            anchors.fill: parent
            radius: root.trackRadius
            visible: !root.enabled
            color: "grey"
            opacity: 0.3
            Behavior on visible { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }

        // --- Filled portion ---
        Rectangle {
            width:  root.visualPosition * parent.width
            height: parent.height
            radius: root.trackRadius
            color:  root.enabled ? root.fillColor : "transparent"
            visible: root.enabled
            Behavior on width { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        }
    }

    // --- Handle ---
    handle: Rectangle {
        id: handleRect
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: (root.height - height) / 2
        width:  root.handleRadius * 2
        height: root.handleRadius * 2
        radius: root.handleRadius
        color:  root.handleColor
        border.color: root.pressed ? root.activeBorder : root.borderColor
        border.width: root.pressed ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 120 } }
        scale: root.pressed ? 1.1 : 1.0
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: !root.enabled
            color: "grey"
            opacity: 0.3
        }
    }

    // --- value label above handle ---
    Text {
        visible: root.pressed
        text:    value.toFixed(root.decimal)
        color:   root.textColor
        font:    root.font
        x: handleRect.x + handleRect.width / 2 - width / 2
        y: handleRect.y - height - 4
        opacity: root.pressed ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }
}
