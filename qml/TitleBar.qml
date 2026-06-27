import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

Item{
    id: mainItem
    width: parent.width
    height: 40
    property var root
    Rectangle {
        id: titleBar
        color: "#2a2a40"
        anchors.fill: parent
        property bool closedByButton: false

        MouseArea {
            anchors.fill: parent
            onPressed: (mouse) => {
                root.startSystemMove()
                if (filePopup.visible && !titleBar.closedByButton) {
                    filePopup.close()
                }
                titleBar.closedByButton = false
            }
        }

        RowLayout {
            height: parent.height
            width: 200
            anchors.left: parent.left
            Rectangle{
                Layout.fillHeight: true
                Layout.minimumWidth: 50
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "File"
                    font.pixelSize: 14
                    color: "white"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: (mouse) => {
                        mouse.accepted = true  // blocks background MouseArea
                        if (filePopup.visible) {
                            filePopup.close()
                        } else {
                            filePopup.open()
                        }
                    }
                }
            }
            Rectangle{
                Layout.fillHeight: true
                Layout.minimumWidth: 50
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "Preferences"
                    font.pixelSize: 14
                    color: "white"
                }
            }
            Rectangle{
                Layout.fillHeight: true
                Layout.minimumWidth: 50
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "About"
                    font.pixelSize: 14
                    color: "white"
                }
            }
        }

        RowLayout {
            height: parent.height
            width: 60
            anchors.right: parent.right
            anchors.rightMargin: 10
            Rectangle{
                id: minButton
                width: root.buttonRadius
                height: root.buttonRadius
                radius: root.buttonRadius / 2
                color: "grey"

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: minButton.color = "orange"
                    onExited: minButton.color = "grey"
                    onClicked: {
                        root.showMinimized()
                    }
                }
            }
            Rectangle{
                id: maxButton
                width: root.buttonRadius
                height: root.buttonRadius
                radius: root.buttonRadius / 2
                color: "grey"

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: maxButton.color = "green"
                    onExited: maxButton.color = "grey"
                    onClicked: {
                        if (root.visibility === Window.Maximized)
                            root.showNormal()
                        if (root.visibility === Window.Minimized)
                            root.showNormal()
                        else
                            root.showMaximized()
                    }
                }
            }
            Rectangle{
                id: closeButton
                width: root.buttonRadius
                height: root.buttonRadius
                radius: root.buttonRadius / 2
                color: "grey"

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: closeButton.color = "red"
                    onExited: closeButton.color = "grey"
                    onClicked: {
                        root.close()
                    }
                }
            }
        }
    }

    Popup{
        id: filePopup
        width: 150
        height: 300
        y: mainItem.height
        x: 5
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 1 }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: 1 }
        }

        background: Rectangle{
            anchors.fill: parent
            color: "#2a2a40"
            ColumnLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 10
                spacing: 0
                Rectangle{
                    id: openRec
                    Layout.fillWidth: true
                    Layout.minimumHeight: 25
                    color: "transparent"
                    Text{
                        anchors.fill: parent
                        text: "    Open File"
                        font.pixelSize: 14
                        color: "white"
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: openRec.color = "#3e3e59"
                        onExited: openRec.color  = "transparent"
                        onClicked: {
                            fileDialog.open()
                            filePopup.close()
                        }
                    }
                }
                Rectangle{
                    id: closeRec
                    Layout.fillWidth: true
                    Layout.minimumHeight: 25
                    color: "transparent"
                    Text{
                        anchors.fill: parent
                        text: "    Close File"
                        font.pixelSize: 14
                        color: "white"
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: closeRec.color = "#3e3e59"
                        onExited: closeRec.color  = "transparent"
                    }
                }
                Rectangle{
                    id: saveRec
                    Layout.fillWidth: true
                    Layout.minimumHeight: 25
                    color: "transparent"
                    Text{
                        anchors.fill: parent
                        text: "    Save Result"
                        font.pixelSize: 14
                        color: "white"
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: saveRec.color = "#3e3e59"
                        onExited: saveRec.color  = "transparent"
                    }
                }
            }
        }
    }
    FileDialog {
        id: fileDialog
        title: "Select Forex CSV"
        nameFilters: ["CSV files (*.csv)"]
        onAccepted: {
            csvLoader.loadFile(fileDialog.selectedFile)
            stackRef.currentIndex = 0
        }
    }
}
