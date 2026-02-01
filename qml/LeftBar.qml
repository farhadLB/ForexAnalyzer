import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"


Rectangle {
    implicitWidth: 200
    SplitView.maximumWidth: 300
    color: "#0b0b17"

    FileDialog {
        id: fileDialog
        title: "Select Forex CSV"
        nameFilters: ["CSV files (*.csv)"]
        onAccepted: {
            // تبدیل URL به path واقعی
            csvLoader.loadFile(fileDialog.selectedFile)
        }
    }
    Column {
        anchors.fill: parent
        spacing: 20

        Button {
            text: "Load CSV File"
            onClicked: fileDialog.open()
        }

        Text {
            id: statusText
            text: "No file loaded"
            color: "white"
        }
    }
    Connections {
        target: csvLoader

        function onFileLoaded(count) {
            statusText.text = "Loaded candles: " + count
        }

        function onError(message) {
            statusText.text = "Error: " + message
        }
    }
}
