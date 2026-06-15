import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

ColumnLayout{
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    property real   percentage: 25          // 0–100
    property color  ringColor: "#A855F7"   // filled arc color
    property color  trackColor: "#3B2F6B"  // background arc color
    property color  textColor: "#FFFFFF"
    property int    ringWidth: 20
    property string label: "Win rate"

    Item {
        id: gauge


        Layout.preferredHeight: 240
        Layout.preferredWidth: 240
        Layout.minimumHeight: 120
        Layout.minimumWidth: 120
        Layout.fillWidth: true
        Layout.fillHeight: true

        readonly property real _radius:     Math.min(width, height) / 2 - ringWidth / 2
        readonly property real _cx:         width  / 2
        readonly property real _cy:         height / 2
        readonly property real _startAngle: -90                        // 12 o'clock
        readonly property real _sweepAngle: percentage / 100 * 360

        // Helper: degrees → radians
        function _rad(deg) { return deg * Math.PI / 180 }

        // Helper: point on circle
        function _pt(angleDeg) {
            return Qt.point(
                        _cx + _radius * Math.cos(_rad(angleDeg)),
                        _cy + _radius * Math.sin(_rad(angleDeg))
                        )
        }

        // --- Background track ---
        Shape {
            anchors.fill: parent
            ShapePath {
                strokeColor:    root.trackColor
                strokeWidth:    root.ringWidth
                fillColor:      "transparent"
                capStyle:       ShapePath.RoundCap
                joinStyle:      ShapePath.RoundJoin

                PathAngleArc {
                    centerX:        gauge._cx
                    centerY:        gauge._cy
                    radiusX:        gauge._radius
                    radiusY:        gauge._radius
                    startAngle:     gauge._startAngle
                    sweepAngle:     360
                }
            }
        }

        // --- Filled arc ---
        Shape {
            anchors.fill: parent
            visible: root.percentage > 0

            ShapePath {
                strokeColor:    root.ringColor
                strokeWidth:    root.ringWidth
                fillColor:      "transparent"
                capStyle:       ShapePath.RoundCap

                PathAngleArc {
                    centerX:    gauge._cx
                    centerY:    gauge._cy
                    radiusX:    gauge._radius
                    radiusY:    gauge._radius
                    startAngle: gauge._startAngle
                    sweepAngle: gauge._sweepAngle
                }
            }
        }

        // --- Percentage label ---
        Text {
            anchors.centerIn: parent
            text:  Math.round(root.percentage) + "%"
            color: root.textColor
            font {
                pixelSize:  root.width * 0.15
                weight:     Font.DemiBold
            }
        }
    }
    Text {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter
        text: root.label
        color: root.textColor
        font {
            pixelSize:  root.width * 0.15
            weight:     Font.DemiBold
        }
    }
}
