import QtQuick

Rectangle {
    id: root

    property real activation: 0
    property color muscleColor: "#ff5c7a"
    property color surfaceColor: "#171f27"
    property color borderColor: "#32414d"

    radius: 8
    color: surfaceColor
    border.color: borderColor

    Canvas {
        id: anatomy
        anchors.fill: parent
        anchors.margins: 20

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const cx = width / 2
            const headY = height * 0.18
            const torsoTop = height * 0.31
            const alpha = 0.35 + root.activation * 0.65

            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            ctx.strokeStyle = "#dce5ef"
            ctx.lineWidth = 5
            ctx.beginPath()
            ctx.arc(cx, headY, 28, 0, Math.PI * 2)
            ctx.stroke()

            ctx.strokeStyle = "#7d8996"
            ctx.lineWidth = 7
            ctx.beginPath()
            ctx.moveTo(cx, torsoTop)
            ctx.lineTo(cx, height * 0.72)
            ctx.moveTo(cx - 62, torsoTop + 18)
            ctx.lineTo(cx + 62, torsoTop + 18)
            ctx.moveTo(cx - 44, height * 0.72)
            ctx.lineTo(cx + 44, height * 0.72)
            ctx.stroke()

            ctx.strokeStyle = "#8c99a6"
            ctx.lineWidth = 15
            ctx.beginPath()
            ctx.moveTo(cx - 62, torsoTop + 20)
            ctx.quadraticCurveTo(cx - 104, height * 0.44, cx - 92, height * 0.59)
            ctx.moveTo(cx + 62, torsoTop + 20)
            ctx.quadraticCurveTo(cx + 104, height * 0.44, cx + 92, height * 0.59)
            ctx.stroke()

            ctx.strokeStyle = Qt.rgba(1.0, 0.36, 0.48, alpha)
            ctx.lineWidth = 22 + root.activation * 10
            ctx.beginPath()
            ctx.moveTo(cx - 70, height * 0.37)
            ctx.quadraticCurveTo(cx - 105, height * 0.49, cx - 88, height * 0.59)
            ctx.moveTo(cx + 70, height * 0.37)
            ctx.quadraticCurveTo(cx + 105, height * 0.49, cx + 88, height * 0.59)
            ctx.stroke()

            ctx.fillStyle = "#f4f7fb"
            ctx.font = "600 18px sans-serif"
            ctx.textAlign = "center"
            ctx.fillText("Biceps focus", cx, height - 38)

            ctx.fillStyle = "#9aa8b6"
            ctx.font = "14px sans-serif"
            ctx.fillText(Math.round(root.activation * 100) + "% activation", cx, height - 16)
        }

        Connections {
            target: root
            function onActivationChanged() { anatomy.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
