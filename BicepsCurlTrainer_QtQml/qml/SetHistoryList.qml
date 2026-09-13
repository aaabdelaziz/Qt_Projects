import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var history: []
    property color surfaceColor: "#171f27"
    property color borderColor: "#32414d"
    property color textPrimary: "#f4f7fb"
    property color textSecondary: "#9aa8b6"
    property color accentColor: "#16c784"

    radius: 8
    color: "#101923"
    border.color: borderColor
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            Layout.fillWidth: true
            text: "Set history"
            color: root.textPrimary
            font.pixelSize: 21
            font.weight: Font.Bold
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.history
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 66
                radius: 8
                color: index % 2 === 0 ? "#172536" : "#122030"
                border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.18)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "Set " + modelData.setNumber
                        color: root.textPrimary
                        font.pixelSize: 16
                        font.weight: Font.Medium
                    }

                    Text {
                        text: modelData.reps + " reps"
                        color: root.accentColor
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }

                    Text {
                        text: modelData.loadKg + " kg"
                        color: root.textSecondary
                        font.pixelSize: 14
                    }

                    Text {
                        text: Math.round(modelData.formScore)
                        color: root.accentColor
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: !root.history || root.history.length === 0
                text: "Completed sets appear here"
                color: root.textSecondary
                font.pixelSize: 15
            }
        }
    }
}
