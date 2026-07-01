import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import "components"

Item{
    id: mainItem
    width: parent.width
    height: 40
    property var root
    Rectangle {
        id: titleBar
        color: GUIParameters.titleBar
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
                    font.pixelSize: GUIParameters.fontSizeNormal
                    color: GUIParameters.textOnPrimary
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
                    font.pixelSize: GUIParameters.fontSizeNormal
                    color: GUIParameters.textOnPrimary
                }
            }
            Rectangle{
                Layout.fillHeight: true
                Layout.minimumWidth: 50
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "About"
                    font.pixelSize: GUIParameters.fontSizeNormal
                    color: GUIParameters.textOnPrimary
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
                    CustomToolTip{
                        visible: parent.containsMouse
                        text: "Minimize"
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
                        else
                            root.showMaximized()
                    }
                    CustomToolTip{
                        visible: parent.containsMouse
                        text: "Maximize"
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
                    CustomToolTip{
                        visible: parent.containsMouse
                        text: "Close"
                    }
                }
            }
        }
    }

    Popup{
        id: filePopup
        width: 150
        height: 150
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
            id: popUpRec
            anchors.fill: parent
            color: GUIParameters.titleBar

            ColumnLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 10
                spacing: 0
                Rectangle{
                    id: openRec
                    Layout.fillWidth: true
                    Layout.minimumHeight: 35
                    color: "transparent"
                    Text{
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "    Open File"
                        font.pixelSize: GUIParameters.fontSizeNormal
                        color: GUIParameters.textOnPrimary
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: openRec.color = GUIParameters.primary
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
                    Layout.minimumHeight: 35
                    color: "transparent"
                    z: -1
                    Text{
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "    Close File"
                        font.pixelSize: GUIParameters.fontSizeNormal
                        color: GUIParameters.textOnPrimary
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: closeRec.color = GUIParameters.primary
                        onExited: closeRec.color  = "transparent"
                        onClicked: {
                            csvLoader.closeFile()
                            filePopup.close()
                        }
                    }
                }
                Rectangle{
                    id: saveRec
                    Layout.fillWidth: true
                    Layout.minimumHeight: 35
                    color: "transparent"
                    Text{
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "    Save Result"
                        font.pixelSize: GUIParameters.fontSizeNormal
                        color: GUIParameters.textOnPrimary
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: saveRec.color = GUIParameters.primary
                        onExited: saveRec.color  = "transparent"
                    }
                }
                Rectangle{
                    id: exitRec
                    Layout.fillWidth: true
                    Layout.minimumHeight: 35
                    color: "transparent"
                    Text{
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "    Exit"
                        font.pixelSize: GUIParameters.fontSizeNormal
                        color: GUIParameters.textOnPrimary
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: exitRec.color = GUIParameters.primary
                        onExited: exitRec.color  = "transparent"
                        onClicked: {
                            root.close()
                        }
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
