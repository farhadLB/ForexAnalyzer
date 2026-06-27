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
        color: "#111827"
        ColumnLayout{
            anchors.fill: parent

            // TabBar{
            //     Layout.preferredWidth: 250
            //     Layout.preferredHeight: 40
            //     Layout.margins: 10
            //     Material.background: Material.primary
            //     currentIndex: 0
            //     TabButton{
            //         id: chartButton
            //         text: "Chart"
            //         width: 100
            //         onClicked: {
            //             stack.currentIndex = 0
            //         }
            //     }
            //     TabButton{
            //         id: tableButton
            //         text: "Positions table"
            //         width: 150
            //         onClicked: {
            //             stack.currentIndex = 1
            //         }
            //     }
            // }
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
