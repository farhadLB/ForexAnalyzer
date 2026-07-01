import QtQuick
import QtQuick.Controls

ToolTip {
    id: root

    // --- General properties ---
    property int    showDelay:    500     // ms before appearing
    property int    hideAfter:    3000    // ms before auto-hide
    property real   fadeInMs:     180     // fade-in duration
    property real   fadeOutMs:    130     // fade-out duration
    property real   scaleFrom:    0.90    // starting scale on enter
    property color  bgColor:      GUIParameters.textOnPrimary
    property color  textColor:    GUIParameters.background
    property color  borderColor:  "#444444"
    property real   borderRadius: 6
    property real   borderWidth:  1

    delay:   root.showDelay
    timeout: root.hideAfter

    // --- transitions ---
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0.0; to: 1.0
                duration: root.fadeInMs
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "scale"
                from: root.scaleFrom; to: 1.0
                duration: root.fadeInMs
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1.0; to: 0.0
                duration: root.fadeOutMs
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "scale"
                from: 1.0; to: root.scaleFrom
                duration: root.fadeOutMs
                easing.type: Easing.InCubic
            }
        }
    }

    transformOrigin: Item.Bottom

    // --- Content ---
    contentItem: Text {
        text:            root.text
        color:           root.textColor
        font.pixelSize:  GUIParameters.fontSizeSmall
        font.family:     Qt.application.font.family
        renderType:      Text.NativeRendering
        wrapMode:        Text.WordWrap
        width:           Math.min(implicitWidth, 280)
    }

    // --- Background ---
    background: Rectangle {
        color:        root.bgColor
        radius:       root.borderRadius
        border.color: root.borderColor
        border.width: root.borderWidth
        opacity: 0.9

        Rectangle {
            anchors {
                top:        parent.top
                left:       parent.left
                right:      parent.right
                topMargin:  1
                leftMargin: root.borderRadius
                rightMargin: root.borderRadius
            }
            height:  1
            color:   Qt.lighter(root.bgColor, 1.6)
            opacity: 0.5
        }
    }

    leftPadding:   10
    rightPadding:  10
    topPadding:    6
    bottomPadding: 6
}
