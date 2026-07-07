import QtQuick
import QtQuick.Layouts
import "components"

Rectangle {
    id: root

    property real apiKey
    property var  stackRef
    readonly property real separatorMargin: 4

    Layout.fillWidth: true
    Layout.fillHeight: true
    color: GUIParameters.background
    Rectangle{
        id: borderArea
        anchors.fill: parent
        anchors.margins: 10
        color: "transparent"
        radius: 15
        border.color: "grey"
        border.width: 1

        ColumnLayout{
            anchors.fill: parent
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 15
            Text {
                id: title
                text: "API Settings"
                color: GUIParameters.textOnPrimary
                font.pixelSize: GUIParameters.fontSizeTitle
                font.bold: true
            }
            Rectangle{
                id: firstRec
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 100
                radius: 15
                color: GUIParameters.primary
                Row{
                    anchors.fill: parent
                    spacing: 20
                    anchors.margins: 10
                    Text{
                        id: apiKeyLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: "API Key:"
                        font.pixelSize: GUIParameters.fontSizeNormal
                        color: GUIParameters.textOnPrimary
                    }

                    CustomTextField{
                        id: apiTextField
                        anchors.verticalCenter: parent.verticalCenter
                        fieldWidth: 270
                        placeholderTextColor: GUIParameters.textOnPrimary
                        onAccepted: {
                            tdWorker.setApiKey(text)
                        }
                    }
                    CustomButton{
                        id: acceptButton
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        iconVisible: false
                        textSize: 15
                        buttonText: "Accept"
                        onClicked: {
                            apiTextField.accepted()
                        }
                    }
                    CustomButton{
                        id: runButton
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        iconVisible: false
                        textSize: 15
                        buttonText: "Run API"
                        onClicked: {
                            if(tdWorker.isConnected()){
                                tdWorker.stopStreaming()
                            }

                            if(tdWorker.hasApiKey()){
                                tdWorker.stream("1min")
                                stackRef.currentIndex = 0
                                candleModel.isFromCSV = false
                            }
                            else{
                                apiKeyWarning.visible = true
                            }
                        }
                        CustomToolTip{
                            id: apiKeyWarning
                            text: "Error: No API Key!"
                        }
                    }
                    Text{
                        id: apiWarning
                        anchors.verticalCenter: parent.verticalCenter
                        text: "( Currently only TwelveData.com API keys are accepted. )"
                        font.pixelSize: GUIParameters.fontSizeNormal
                        color: GUIParameters.textOnPrimary
                    }
                }
            }
            Rectangle{
                id: secondRec
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 500
                radius: 15
                color: GUIParameters.primary

                    CurrencyModel{
                        id: currencyModel
                    }

                    ListView{
                        id: currencyListView
                        width: parent.width
                        height: parent.height
                        z: 1
                        model: currencyModel
                        clip: true
                        focus: true
                        currentIndex: -1

                        delegate: Item {
                            id: delegateRoot
                            width: ListView.view.width
                            height: 50

                            property bool hovered: false
                            readonly property bool selected: ListView.isCurrentItem

                            Component{
                                id: pairComponent
                                ColumnLayout{
                                    anchors.fill: parent
                                    Rectangle{
                                        id: pairBackground
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        radius: 5
                                        color: delegateRoot.selected
                                                ? GUIParameters.secondary
                                                : (delegateRoot.hovered
                                                    ? GUIParameters.secondary
                                                    : "transparent")
                                        RowLayout{
                                            anchors.fill: parent
                                            Item{
                                                id: flagsItem
                                                Layout.fillHeight: true
                                                Layout.minimumWidth: 50
                                                Layout.alignment: Qt.AlignVCenter
                                                Layout.margins: 8
                                                Rectangle{
                                                    id: backRec
                                                    width: parent.height
                                                    height: parent.height
                                                    radius: parent.height
                                                    color: "transparent"
                                                    Image {
                                                        anchors.fill: parent
                                                        source: symbolToFlag(first)
                                                    }
                                                }
                                                Rectangle{
                                                    id: frontRec
                                                    width: parent.height
                                                    height: parent.height
                                                    radius: parent.height
                                                    x: parent.height / 2
                                                    color: "transparent"
                                                    Image {
                                                        anchors.fill: parent
                                                        source: symbolToFlag(second)
                                                    }
                                                }
                                            }
                                            Text{
                                                id: label
                                                text: first + "/" + second
                                                color: GUIParameters.textOnPrimary
                                                font.pixelSize: GUIParameters.fontSizeNormal
                                                font.bold: true
                                                Layout.minimumWidth: 200
                                            }
                                            Text{
                                                id: description
                                                text: symbolToFull(first) + " vs " + symbolToFull(second)
                                                color: GUIParameters.textOnPrimary
                                                font.pixelSize: GUIParameters.fontSizeNormal
                                                Layout.minimumWidth: 350
                                            }
                                            Text{
                                                id: categoryLabel
                                                text: category
                                                color: GUIParameters.textOnPrimary
                                                font.pixelSize: GUIParameters.fontSizeNormal
                                                Layout.minimumWidth: 150
                                            }
                                        }
                                    }
                                    Rectangle{
                                        id: pairSeperator
                                        Layout.alignment: Qt.AlignHCenter
                                        width: parent.width - root.separatorMargin
                                        height: 1
                                        color: GUIParameters.outline
                                        opacity: 0.5
                                    }
                                }
                            }

                            Loader {
                                id: loader
                                anchors.fill: parent
                                sourceComponent: pairComponent
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                z: 1
                                onEntered: delegateRoot.hovered = true
                                onExited: delegateRoot.hovered = false
                                onClicked: {
                                    currencyListView.currentIndex = index
                                    tdWorker.setSymbol(first, second)
                                    tdWorker.first = first
                                    tdWorker.second = second
                                    tdWorker.symbolDesc = (symbolToFull(first) + " vs " + symbolToFull(second))
                                }
                            }
                        }
                    }
            }
        }
    }
    function symbolToFull(symbol) {
        switch (symbol) {
        case "EUR" : return "Euro"
        case "USD" : return "US Dollar"
        case "AUD" : return "Australian Dollar"
        case "CHF" : return "Swiss Franc"
        case "GBP" : return "Great British Pound"
        case "NZD" : return "New Zealand Dollar"
        case "JPY" : return "Japanese Yen"
        case "CAD" : return "Canadian Dollar"
        }
    }
    function symbolToFlag(symbol) {
        switch (symbol) {
        case "EUR" : return GUIParameters.eur
        case "USD" : return GUIParameters.usd
        case "AUD" : return GUIParameters.aud
        case "CHF" : return GUIParameters.chf
        case "GBP" : return GUIParameters.gbp
        case "NZD" : return GUIParameters.nzd
        case "JPY" : return GUIParameters.jpy
        case "CAD" : return GUIParameters.cad
        }
    }
}
