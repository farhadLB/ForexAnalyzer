import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"


Rectangle {
    implicitWidth: 200
    SplitView.maximumWidth: 300
    color: "#0b0b17"
    CustomButton{
        anchors.centerIn: parent
    }
}
