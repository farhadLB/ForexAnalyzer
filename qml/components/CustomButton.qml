import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: root
    property string buttonText: "Custom"
    property string iconSource: "../../assets/candle-white-small.svg"
    property int iconSize: 20
    property int textSize: GUIParameters.fontSizeSmall
    property color iconColor: GUIParameters.secondary
    property bool iconVisible: true

    hoverEnabled: true
    contentItem: RowLayout{
        spacing: 15
        Image {
            source: root.iconSource
            Layout.maximumWidth: root.iconSize
            Layout.maximumHeight: root.iconSize
            visible: root.iconVisible
        }
        Text {
            text: root.buttonText
            font.pixelSize: root.textSize
            Layout.alignment: Qt.AlignHCenter
            color: GUIParameters.textOnPrimary
        }
    }
    Material.background: root.iconColor
    Material.elevation: 10
}
