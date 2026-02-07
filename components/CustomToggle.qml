import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Button {

    id: root
    text: "Custom"
    hoverEnabled: true
    checkable: true
    checked: true
    Material.background: checked ? Material.LightBlue : Material.BlueGrey
    Material.elevation: 10

}
