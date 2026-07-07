import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

TextField {
    id: root

    property real  fieldRadius:    8
    property real  fieldWidth:     160
    property color baseColor:      GUIParameters.titleBar
    property color activeBorder:   GUIParameters.secondaryHighlight
    property color borderColor:    root.enabled ? GUIParameters.secondary : "grey"
    property color textColor:      root.enabled ? GUIParameters.textOnPrimary : "grey"
    property color placeholderColor: root.enabled ? Qt.darker(GUIParameters.textOnPrimary, 1.6) : "grey"

    implicitWidth:  root.fieldWidth
    implicitHeight: 42

    color:                root.textColor
    placeholderTextColor: root.placeholderColor
    selectionColor:       GUIParameters.secondary
    selectedTextColor:    GUIParameters.textOnPrimary
    font.pixelSize:       GUIParameters.fontSizeNormal
    verticalAlignment:     TextInput.AlignVCenter
    leftPadding:   12
    rightPadding:  12
    selectByMouse: true

    // ── Background ─────────────────────────────────────────────────────────
    background: Rectangle {
        implicitWidth:  root.implicitWidth
        implicitHeight: root.implicitHeight
        radius:         root.fieldRadius
        color:          root.baseColor
        border.color:   root.activeFocus ? root.activeBorder : root.borderColor
        border.width:   root.activeFocus ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Rectangle {
            id: disabledOverlay
            anchors.fill: parent
            radius: root.fieldRadius
            visible: !root.enabled
            color: "grey"
            opacity: 0.3
            Behavior on visible { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }
    }
}
