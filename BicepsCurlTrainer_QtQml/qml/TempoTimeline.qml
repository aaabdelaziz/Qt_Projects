import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property real progress: 0
    property string phase: ""
    property color accentColor: "#16c784"
    property color surfaceColor: "#202a33"
    property color borderColor: "#32414d"

    radius: 8
    color: surfaceColor
    border.color: borderColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: "Tempo"
                color: "#f4f7fb"
                font.pixelSize: 17
                font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                Layout.preferredWidth: 132
                Layout.preferredHeight: 30
                radius: 8
                color: "#0b151d"
                border.color: root.accentColor
                border.width: 1

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    text: root.phase.length > 0 ? root.phase : "Ready"
                    color: root.accentColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font.pixelSize: 15
                    font.weight: Font.Bold
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 12
            radius: 6
            color: "#111820"

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.progress))
                height: parent.height
                radius: 6
                color: root.accentColor

                Behavior on width {
                    NumberAnimation {
                        duration: 90
                    }
                }
            }
        }
    }
}
