import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: root
    property string buttonText: "Custom"
    property string iconSource: "../../assets/candle-white-small.svg"
    property int iconSize: 20
    property int textSize: 13
    hoverEnabled: true
    contentItem: RowLayout{
        spacing: 15
        Image {
            source: root.iconSource
            Layout.maximumWidth: root.iconSize
            Layout.maximumHeight: root.iconSize
        }
        Text {
            text: root.buttonText
            font.pixelSize: root.textSize
            color: "white"
        }
    }
    Material.background: Material.primary
    Material.elevation: 10
}
