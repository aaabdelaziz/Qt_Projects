import QtQuick
import QtQuick.Controls

Button {
    id: root

    focusPolicy: Qt.NoFocus

    property color activeColor: "#16c784"
    property color idleColor: "#273440"
    property color borderColor: "#32414d"

    signal pressedHold()
    signal releasedHold()

    down: pressArea.pressed
    font.pixelSize: 16
    font.weight: Font.DemiBold

    background: Rectangle {
        radius: 8
        color: root.down ? root.activeColor : (root.hovered ? Qt.lighter(root.idleColor, 1.18) : root.idleColor)
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.down ? Qt.lighter(root.activeColor, 1.16) : Qt.lighter(root.idleColor, root.hovered ? 1.28 : 1.14) }
            GradientStop { position: 0.62; color: root.down ? root.activeColor : root.idleColor }
            GradientStop { position: 1.0; color: root.down ? Qt.darker(root.activeColor, 1.22) : Qt.darker(root.idleColor, 1.28) }
        }
        border.color: root.down || root.hovered ? root.activeColor : root.borderColor
        border.width: 2

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.bottomMargin: 4
            height: 3
            radius: 2
            color: Qt.rgba(0, 0, 0, root.down ? 0.08 : 0.24)
        }
    }

    contentItem: Text {
        text: root.text
        color: root.down ? "#06130c" : "#f8fbff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font: root.font
        elide: Text.ElideRight
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        onPressed: root.pressedHold()
        onReleased: root.releasedHold()
        onCanceled: root.releasedHold()
    }
}
