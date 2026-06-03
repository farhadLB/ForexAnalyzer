import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: parent.width
    property string title: "Title"
    property alias content: contentLoader.sourceComponent

    property bool isOpen: false

    implicitHeight: column.implicitHeight
    Column {
        id: column
        width: parent.width - 10
        spacing: 0

        Rectangle {
            id: header
            width: parent.width
            height: 50
            color: isOpen ? "#13bcd6" : "#06a5bd"
            radius: 10

            RowLayout{
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8
                layoutDirection: Qt.LeftToRight

                Text {
                    text: root.title
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Text {
                    text: isOpen ? "▲" : "▼"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.isOpen = !root.isOpen
            }
        }

        Loader {
            id: contentLoader
            width: parent.width
            height: isOpen ? implicitHeight : 0
            opacity: isOpen ? 1 : 0
            visible: isOpen || (height > 0)

            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            onLoaded: {
                // اطمینان از اینکه محتوا تمام عرض را بگیرد
                if (item) item.width = Qt.binding(() => contentLoader.width)
            }
        }
    }
}
