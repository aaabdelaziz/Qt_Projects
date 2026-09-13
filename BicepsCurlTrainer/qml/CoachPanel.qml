import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string cue: ""
    property real formScore: 0
    property real pushProgress: 0
    property color accentColor: "#16c784"
    property color warningColor: "#ffb545"
    property color dangerColor: "#ff3d6e"
    property color surfaceColor: "#202a33"
    property color borderColor: "#32414d"
    readonly property real clampedPushProgress: Math.max(0, Math.min(1, pushProgress))

    radius: 8
    color: surfaceColor
    border.color: borderColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Text {
            Layout.fillWidth: true
            text: root.cue
            color: "#f4f7fb"
            font.pixelSize: 24
            font.weight: Font.Medium
            wrapMode: Text.WordWrap
            lineHeight: 1.06
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 12
            radius: 6
            color: "#111820"

            Rectangle {
                width: parent.width * root.clampedPushProgress
                height: parent.height
                radius: 6
                color: root.clampedPushProgress < 0.5
                       ? Qt.rgba(
                             root.accentColor.r + (root.warningColor.r - root.accentColor.r) * root.clampedPushProgress * 2,
                             root.accentColor.g + (root.warningColor.g - root.accentColor.g) * root.clampedPushProgress * 2,
                             root.accentColor.b + (root.warningColor.b - root.accentColor.b) * root.clampedPushProgress * 2,
                             1.0)
                       : Qt.rgba(
                             root.warningColor.r + (root.dangerColor.r - root.warningColor.r) * (root.clampedPushProgress - 0.5) * 2,
                             root.warningColor.g + (root.dangerColor.g - root.warningColor.g) * (root.clampedPushProgress - 0.5) * 2,
                             root.warningColor.b + (root.dangerColor.b - root.warningColor.b) * (root.clampedPushProgress - 0.5) * 2,
                             1.0)

                Behavior on width {
                    NumberAnimation {
                        duration: 90
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: Math.round(root.clampedPushProgress * 100) + "% extension progress"
            color: root.clampedPushProgress > 0.72 ? root.dangerColor : "#9aa8b6"
            horizontalAlignment: Text.AlignRight
            font.pixelSize: 13
            font.weight: Font.Medium
            elide: Text.ElideRight
        }
    }
}
