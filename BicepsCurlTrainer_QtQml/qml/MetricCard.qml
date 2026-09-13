import QtQuick

Rectangle {
    id: root

    property string label: ""
    property string value: ""
    property string unit: ""
    property color accentColor: "#16c784"

    radius: 8
    color: "#111b25"
    border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.45)

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 7

        Text {
            width: parent.width
            text: root.label
            color: "#b6c6d6"
            font.pixelSize: 13
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root.value
            color: root.accentColor
            font.pixelSize: 29
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root.unit
            color: "#8ea1b3"
            font.pixelSize: 13
            elide: Text.ElideRight
        }
    }
}
