import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

ComboBox {
    id: root

    property real  comboRadius:    8
    property color baseColor:      GUIParameters.titleBar
    property color activeBorder:   GUIParameters.secondaryHighlight
    property color dropdownColor:  GUIParameters.primary
    property color highlightColor: GUIParameters.secondary
    property color borderColor:    root.enabled ? GUIParameters.secondary : "grey"
    property color textColor:      root.enabled ? GUIParameters.textOnPrimary : "grey"

    implicitWidth:  100
    implicitHeight: 42

    // --- Background ---
    background: Rectangle {
        implicitWidth:  root.implicitWidth
        implicitHeight: root.implicitHeight
        radius:         root.comboRadius
        color:          root.baseColor
        border.color:   root.popup.visible ? root.activeBorder : root.borderColor
        border.width:   root.popup.visible ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Rectangle{
            id: disabledOverlay
            anchors.fill: parent
            radius: root.comboRadius
            visible: !root.enabled
            color: "grey"
            opacity: 0.3
            Behavior on visible {NumberAnimation {duration: 150; easing.type: Easing.OutCubic}}
        }
    }

    // --- Selected text ---
    contentItem: Item {
        implicitWidth:  root.implicitWidth
        implicitHeight: root.implicitHeight

        Text {
            anchors {
                left:           parent.left
                right:          parent.right
                top:            parent.top
                bottom:         parent.bottom
                leftMargin:     12
                rightMargin:    32
            }
            text:              root.displayText
            font:              root.font
            color:             root.textColor
            verticalAlignment: Text.AlignVCenter
            elide:             Text.ElideRight
        }
    }

    // --- Arrow ---
    indicator: Canvas {
        id: arrow
        x:      root.width - width - 12
        y:      (root.height - height) / 2
        width:  12
        height: 7

        rotation: root.popup.visible ? 180 : 0
        Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = root.textColor
            ctx.lineWidth   = 2
            ctx.lineCap     = "round"
            ctx.lineJoin    = "round"
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(width / 2, height)
            ctx.lineTo(width, 0)
            ctx.stroke()
        }

        Connections {
            target: root
            function onTextColorChanged() { arrow.requestPaint() }
        }
    }

    // --- Popup ---
    popup: Popup {
        y:             root.height + 4
        width:         root.width
        topPadding:    4
        bottomPadding: 4
        leftPadding:   0
        rightPadding:  0

        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 120 } }
        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 80  } }

        background: Rectangle {
            radius:       root.comboRadius
            color:        root.dropdownColor
            border.color: root.borderColor
            border.width: 1
        }

        contentItem: ListView {
            implicitHeight: contentHeight
            model:          root.delegateModel
            clip:           true
            boundsBehavior: Flickable.StopAtBounds
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }

    // --- Delegate ---
    delegate: ItemDelegate {
        id: delegateItem
        width:        root.popup.width
        height:       root.implicitHeight
        text:         modelData
        font:         root.font
        highlighted:  root.highlightedIndex === index
        hoverEnabled: true
        palette.text:            root.textColor
        palette.highlightedText: root.textColor

        background: Rectangle {
            radius: (index === 0 || index === root.count - 1) ? root.comboRadius - 2 : 0
            color:  delegateItem.highlighted ? root.highlightColor : "transparent"
        }
    }
}
