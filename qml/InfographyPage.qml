import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: rootInfo
    SplitView.minimumWidth: 50
    SplitView.fillWidth: true

    Rectangle {
        id: background
        anchors.fill: parent
        color: GUIParameters.background

        Rectangle {
            anchors.fill: parent
            color: "#80111827"
            visible: positionManager.isLoading
            z: 10

            BusyIndicator {
                anchors.centerIn: parent
                running: positionManager.isLoading
            }
        }

        ColumnLayout{
            anchors.fill: parent
            StackLayout{
                id: stack
                Layout.fillHeight: true
                Layout.fillWidth: true
                currentIndex: 0
                OutcomeChart{}
                ResultPage{}
            }
        }
    }
}
