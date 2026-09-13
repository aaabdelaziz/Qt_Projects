import QtQuick
import QtQuick.Controls

Button {
    id: root

    focusPolicy: Qt.NoFocus

    property color baseColor: "#22c55e"
    property color pressedColor: "#86efac"
    property color textColor: "#06130c"
    property color borderColor: Qt.lighter(baseColor, 1.18)
    property color shadowColor: Qt.darker(baseColor, 1.45)

    implicitHeight: 44
    font.pixelSize: text.length <= 1 ? 22 : 15
    font.weight: Font.Bold

    background: Rectangle {
        radius: 8
        color: root.down ? root.pressedColor : root.baseColor
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.down ? root.pressedColor : Qt.lighter(root.baseColor, 1.16) }
            GradientStop { position: 0.58; color: root.down ? root.baseColor : root.baseColor }
            GradientStop { position: 1.0; color: root.down ? Qt.darker(root.baseColor, 1.22) : root.shadowColor }
        }
        border.color: root.enabled ? root.borderColor : "#33404a"
        border.width: 2
        opacity: root.enabled ? 1.0 : 0.44

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            anchors.bottomMargin: 3
            height: 3
            radius: 2
            color: Qt.rgba(0, 0, 0, root.down ? 0.10 : 0.28)
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.topMargin: 4
            height: 2
            radius: 1
            color: Qt.rgba(1, 1, 1, root.down ? 0.16 : 0.32)
        }
    }

    contentItem: Text {
        text: root.text
        color: root.enabled ? root.textColor : "#8b98a5"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font: root.font
        style: Text.Raised
        styleColor: Qt.rgba(1, 1, 1, 0.20)
    }
}
