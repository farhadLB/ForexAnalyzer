import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Basic.impl

T.ProgressBar {
    id: control
    property int    barHeight:           8
    property color  backgroundColor: "#a39e9d"
    property color  fillColor:       "#00aa55"
    property bool cancelVisible: false
    signal cancelClicked()

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    contentItem: ProgressBarImpl {
        implicitHeight: control.barHeight
        implicitWidth: 116
        scale: control.mirrored ? -1 : 1
        progress: control.position
        indeterminate: control.visible && control.indeterminate
        color: control.fillColor
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control.barHeight
        y: (control.height - height) / 2
        height: control.barHeight
        color: control.backgroundColor
    }
    Text {
        id: cancelButton
        text: "✕"
        color: "white"
        font.pixelSize: 14
        font.bold: true
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: cancelVisible

    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: cancelVisible = true
        onExited:  cancelVisible = false

        onClicked: (mouse) => {
            const mapped = mapToItem(cancelButton, mouse.x, mouse.y)
            if (cancelButton.contains(Qt.point(mapped.x, mapped.y))) {
                control.cancelClicked()
            }
        }
    }
}
