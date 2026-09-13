import QtQuick

Rectangle {
    id: root

    property real activation: 0
    property real elbowAngle: 165
    property int loadKg: 0
    property int maxLoadKg: 40
    property color muscleColor: "#ff5c7a"
    property color surfaceColor: "#171f27"
    property color borderColor: "#32414d"
    property string celebrationMessage: ""

    readonly property real loadRatio: Math.max(0, Math.min(1, loadKg / Math.max(1, maxLoadKg)))
    readonly property real effort: Math.max(0, Math.min(1, activation * 0.72 + loadRatio * 0.28))
    readonly property real normalizedCurl: Math.max(0, Math.min(1, (165 - elbowAngle) / 117))

    radius: 8
    color: surfaceColor
    border.color: borderColor
    clip: true

    Image {
        id: athletePhoto
        anchors.fill: parent
        anchors.margins: 12
        source: "qrc:/qt/qml/BicepsCurlTrainer/assets/biceps_curl_reference.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        opacity: 0.92
    }

    Rectangle {
        anchors.fill: athletePhoto
        color: "#111820"
        opacity: 0.20
    }

    Canvas {
        id: heatMap
        anchors.fill: athletePhoto
        opacity: 0.55 + root.effort * 0.45

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const effort = root.effort
            const armX = width * 0.815
            const armY = height * 0.315
            const radius = Math.min(width, height) * (0.185 + effort * 0.065)

            const gradient = ctx.createRadialGradient(
                armX,
                armY,
                radius * 0.08,
                armX,
                armY,
                radius
            )

            if (effort < 0.45) {
                gradient.addColorStop(0.00, Qt.rgba(0.30, 0.68, 1.00, 0.55 + effort * 0.22))
                gradient.addColorStop(0.45, Qt.rgba(0.10, 0.78, 0.52, 0.42 + effort * 0.18))
                gradient.addColorStop(1.00, Qt.rgba(0.10, 0.78, 0.52, 0.00))
            } else if (effort < 0.75) {
                gradient.addColorStop(0.00, Qt.rgba(1.00, 0.71, 0.27, 0.60 + effort * 0.18))
                gradient.addColorStop(0.42, Qt.rgba(1.00, 0.36, 0.48, 0.45 + effort * 0.20))
                gradient.addColorStop(1.00, Qt.rgba(1.00, 0.36, 0.48, 0.00))
            } else {
                gradient.addColorStop(0.00, Qt.rgba(1.00, 0.95, 0.46, 0.72))
                gradient.addColorStop(0.35, Qt.rgba(1.00, 0.33, 0.24, 0.70))
                gradient.addColorStop(0.72, Qt.rgba(0.93, 0.08, 0.24, 0.36))
                gradient.addColorStop(1.00, Qt.rgba(0.93, 0.08, 0.24, 0.00))
            }

            ctx.fillStyle = gradient
            ctx.beginPath()
            ctx.arc(armX, armY, radius, 0, Math.PI * 2)
            ctx.fill()

            ctx.strokeStyle = Qt.rgba(1.0, 0.20, 0.26, 0.35 + effort * 0.30)
            ctx.lineWidth = 4 + effort * 5
            ctx.beginPath()
            ctx.arc(armX, armY, radius * 0.72, 0, Math.PI * 2)
            ctx.stroke()

        }

        Connections {
            target: root
            function onActivationChanged() { heatMap.requestPaint() }
            function onLoadKgChanged() { heatMap.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }

    Rectangle {
        id: armSymbolPanel
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 98
        width: 180
        height: 154
        radius: 8
        color: "#0d1720"
        border.color: "#355166"
        border.width: 1
        opacity: 0.94

        readonly property real elbowX: 62
        readonly property real elbowY: height * 0.50

        Canvas {
            id: armAngleCanvas
            anchors.fill: parent

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()

                const elbowX = armSymbolPanel.elbowX
                const elbowY = armSymbolPanel.elbowY
                const upperLength = 50
                const forearmLength = 58
                const upperAngle = -Math.PI / 2
                const forearmAngle = upperAngle + root.elbowAngle * Math.PI / 180
                const shoulderX = elbowX + Math.cos(upperAngle) * upperLength
                const shoulderY = elbowY + Math.sin(upperAngle) * upperLength
                const wristX = elbowX + Math.cos(forearmAngle) * forearmLength
                const wristY = elbowY + Math.sin(forearmAngle) * forearmLength

                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                ctx.strokeStyle = "#16422b"
                ctx.lineWidth = 30
                ctx.beginPath()
                ctx.moveTo(shoulderX, shoulderY)
                ctx.lineTo(elbowX, elbowY)
                ctx.stroke()

                ctx.strokeStyle = "#2ee66b"
                ctx.lineWidth = 24
                ctx.beginPath()
                ctx.moveTo(shoulderX, shoulderY)
                ctx.lineTo(elbowX, elbowY)
                ctx.stroke()

                ctx.strokeStyle = "#103d50"
                ctx.lineWidth = 30
                ctx.beginPath()
                ctx.moveTo(elbowX, elbowY)
                ctx.lineTo(wristX, wristY)
                ctx.stroke()

                ctx.strokeStyle = "#22d3ee"
                ctx.lineWidth = 24
                ctx.beginPath()
                ctx.moveTo(elbowX, elbowY)
                ctx.lineTo(wristX, wristY)
                ctx.stroke()

                ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.28)
                ctx.lineWidth = 5
                ctx.beginPath()
                ctx.moveTo(shoulderX + 3, shoulderY + 8)
                ctx.lineTo(elbowX + 3, elbowY - 8)
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(elbowX + 4, elbowY + 8)
                ctx.lineTo(wristX + 4, wristY - 8)
                ctx.stroke()

                const arcRadius = 35
                ctx.strokeStyle = "#facc15"
                ctx.lineWidth = 4
                ctx.beginPath()
                ctx.arc(elbowX, elbowY, arcRadius, upperAngle, forearmAngle, false)
                ctx.stroke()

                ctx.strokeStyle = Qt.rgba(250 / 255, 204 / 255, 21 / 255, 0.28)
                ctx.lineWidth = 12
                ctx.beginPath()
                ctx.arc(elbowX, elbowY, arcRadius, upperAngle, forearmAngle, false)
                ctx.stroke()

                ctx.fillStyle = "#facc15"
                ctx.beginPath()
                ctx.arc(elbowX, elbowY, 14, 0, Math.PI * 2)
                ctx.fill()

                ctx.strokeStyle = "#fff7a6"
                ctx.lineWidth = 3
                ctx.beginPath()
                ctx.arc(elbowX, elbowY, 14, 0, Math.PI * 2)
                ctx.stroke()

                // Degree readout anchored to the arc itself (not a disconnected
                // corner label) so the number always sits next to the angle it
                // describes, on the outside of the sweep at its midpoint.
                const midAngle = (upperAngle + forearmAngle) / 2
                const labelRadius = arcRadius + 20
                const labelX = elbowX + Math.cos(midAngle) * labelRadius
                const labelY = elbowY + Math.sin(midAngle) * labelRadius

                ctx.font = "700 13px sans-serif"
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                const labelText = Math.round(root.elbowAngle) + "\u00B0"
                const labelWidth = ctx.measureText(labelText).width + 10
                const labelLeft = labelX - labelWidth / 2
                const labelTop = labelY - 10
                const labelCorner = 6

                ctx.fillStyle = "#0d1720"
                ctx.beginPath()
                ctx.moveTo(labelLeft + labelCorner, labelTop)
                ctx.lineTo(labelLeft + labelWidth - labelCorner, labelTop)
                ctx.quadraticCurveTo(labelLeft + labelWidth, labelTop, labelLeft + labelWidth, labelTop + labelCorner)
                ctx.lineTo(labelLeft + labelWidth, labelTop + 20 - labelCorner)
                ctx.quadraticCurveTo(labelLeft + labelWidth, labelTop + 20, labelLeft + labelWidth - labelCorner, labelTop + 20)
                ctx.lineTo(labelLeft + labelCorner, labelTop + 20)
                ctx.quadraticCurveTo(labelLeft, labelTop + 20, labelLeft, labelTop + 20 - labelCorner)
                ctx.lineTo(labelLeft, labelTop + labelCorner)
                ctx.quadraticCurveTo(labelLeft, labelTop, labelLeft + labelCorner, labelTop)
                ctx.closePath()
                ctx.fill()

                ctx.fillStyle = "#facc15"
                ctx.fillText(labelText, labelX, labelY + 1)
            }

            Connections {
                target: root
                function onElbowAngleChanged() { armAngleCanvas.requestPaint() }
            }

            Component.onCompleted: requestPaint()
        }

    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 82
        color: "#111820"
        opacity: 0.82
    }

    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: effortLabel.top
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        text: "Biceps load map"
        visible: root.celebrationMessage.length === 0
        color: "#f4f7fb"
        font.pixelSize: 20
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }

    Text {
        id: effortLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.bottomMargin: 16
        text: Math.round(root.effort * 100) + "% effort intensity"
        visible: root.celebrationMessage.length === 0
        color: root.effort > 0.75 ? "#ffb545" : "#9aa8b6"
        font.pixelSize: 15
        elide: Text.ElideRight
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.bottomMargin: 18
        height: 48
        radius: 8
        visible: root.celebrationMessage.length > 0
        color: "#102a1c"
        border.color: "#2ee66b"
        border.width: 2
        opacity: visible ? 1.0 : 0.0

        SequentialAnimation on scale {
            running: root.celebrationMessage.length > 0
            loops: Animation.Infinite
            NumberAnimation { to: 1.025; duration: 520; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 520; easing.type: Easing.InOutQuad }
        }

        Text {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            text: root.celebrationMessage
            color: "#d9ffe9"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.pixelSize: 18
            font.weight: Font.Bold
        }
    }

    SequentialAnimation on scale {
        running: root.effort > 0.72
        loops: Animation.Infinite
        NumberAnimation { to: 1.015; duration: 420; easing.type: Easing.OutSine }
        NumberAnimation { to: 1.0; duration: 420; easing.type: Easing.InSine }
    }
}
