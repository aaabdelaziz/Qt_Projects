import QtQuick

Item {
    id: root

    property real elbowAngle: 165
    property real activation: 0
    property color muscleColor: "#ff5c7a"
    property color accentColor: "#16c784"
    property color lineColor: "#f4f7fb"

    Behavior on elbowAngle {
        NumberAnimation {
            duration: 90
            easing.type: Easing.OutCubic
        }
    }

    Behavior on activation {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Canvas {
        id: motionCanvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const shoulder = { x: width * 0.40, y: height * 0.35 }
            const upperLength = height * 0.22
            const forearmLength = height * 0.24
            const elbow = { x: shoulder.x + upperLength * 0.15, y: shoulder.y + upperLength }
            const curlRadians = (root.elbowAngle - 90) * Math.PI / 180
            const wrist = {
                x: elbow.x + Math.cos(curlRadians) * forearmLength,
                y: elbow.y + Math.sin(curlRadians) * forearmLength
            }

            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            const backgroundGradient = ctx.createLinearGradient(0, 0, width, height)
            backgroundGradient.addColorStop(0, "#1c2630")
            backgroundGradient.addColorStop(1, "#111820")
            ctx.fillStyle = backgroundGradient
            ctx.fillRect(0, 0, width, height)

            ctx.strokeStyle = "#2f3e4b"
            ctx.lineWidth = 1
            for (let i = 1; i < 5; ++i) {
                ctx.beginPath()
                ctx.moveTo(0, i * height / 5)
                ctx.lineTo(width, i * height / 5)
                ctx.stroke()
            }

            ctx.strokeStyle = "#dce5ef"
            ctx.lineWidth = 9
            ctx.beginPath()
            ctx.arc(shoulder.x, shoulder.y - 58, 34, 0, Math.PI * 2)
            ctx.stroke()

            ctx.strokeStyle = "#748391"
            ctx.lineWidth = 16
            ctx.beginPath()
            ctx.moveTo(shoulder.x, shoulder.y - 20)
            ctx.lineTo(shoulder.x, shoulder.y + 185)
            ctx.stroke()

            ctx.strokeStyle = "#9ba7b4"
            ctx.lineWidth = 26
            ctx.beginPath()
            ctx.moveTo(shoulder.x, shoulder.y)
            ctx.lineTo(elbow.x, elbow.y)
            ctx.lineTo(wrist.x, wrist.y)
            ctx.stroke()

            ctx.strokeStyle = Qt.rgba(1.0, 0.36, 0.48, 0.35 + root.activation * 0.65)
            ctx.lineWidth = 18 + root.activation * 10
            ctx.beginPath()
            ctx.moveTo(shoulder.x + 8, shoulder.y + 14)
            ctx.quadraticCurveTo(elbow.x - 18, elbow.y - 30, elbow.x - 3, elbow.y - 2)
            ctx.stroke()
m
            ctx.fillStyle = root.accentColor
            ctx.beginPath()
            ctx.arc(elbow.x, elbow.y, 8, 0, Math.PI * 2)
            ctx.fill()

            ctx.fillStyle = "#f4f7fb"
            ctx.font = "600 18px sans-serif"
            ctx.textAlign = "center"
            ctx.fillText(Math.round(root.elbowAngle) + " deg elbow angle", width * 0.72, height * 0.22)

            ctx.strokeStyle = root.accentColor
            ctx.lineWidth = 8
            ctx.beginPath()
            ctx.arc(width * 0.72, height * 0.40, 72, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * root.activation)
            ctx.stroke()

            ctx.fillStyle = root.muscleColor
            ctx.font = "700 34px sans-serif"
            ctx.fillText(Math.round(root.activation * 100) + "%", width * 0.72, height * 0.42)
            ctx.fillStyle = "#9aa8b6"
            ctx.font = "15px sans-serif"
            ctx.fillText("biceps activation", width * 0.72, height * 0.47)
        }

        Connections {
            target: root
            function onElbowAngleChanged() { motionCanvas.requestPaint() }
            function onActivationChanged() { motionCanvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }
}
