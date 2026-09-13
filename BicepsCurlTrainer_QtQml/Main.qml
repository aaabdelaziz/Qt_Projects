import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import BicepsCurlTrainer

ApplicationWindow {
    id: root
    width: 1240
    height: 880
    minimumWidth: 1040
    minimumHeight: 820
    visible: true
    title: "Biceps Curl Trainer"
    color: "#0a0f14"

    readonly property color surface: "#111923"
    readonly property color panel: "#182433"
    readonly property color controlSurface: "#101a24"
    readonly property color panelBorder: "#355166"
    readonly property color textPrimary: "#f8fbff"
    readonly property color textSecondary: "#b6c6d6"
    readonly property color accent: "#2ee66b"
    readonly property color blue: "#22d3ee"
    readonly property color amber: "#facc15"
    readonly property color muscle: "#ff3d6e"
    readonly property color danger: "#fb7185"
    readonly property bool workoutComplete: workoutController.sessionState === "Complete"
    property string roundCelebration: ""

    Item {
        id: keyboardController
        anchors.fill: parent
        focus: true
        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) {
                return
            }

            if (root.workoutComplete) {
                event.accepted = event.key === Qt.Key_Up || event.key === Qt.Key_Down
            } else if (event.key === Qt.Key_Up) {
                workoutController.curlUp()
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                workoutController.lowerDown()
                event.accepted = true
            }
        }

        Keys.onReleased: (event) => {
            if (event.isAutoRepeat) {
                return
            }

            if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
                workoutController.stopArm()
                event.accepted = true
            }
        }

        Component.onCompleted: forceActiveFocus()
    }

    Connections {
        target: workoutController

        function onRoundCompleted(message) {
            root.roundCelebration = message
            celebrationTimer.restart()
        }
    }

    Timer {
        id: celebrationTimer
        interval: 2600
        onTriggered: root.roundCelebration = ""
    }

    header: ToolBar {
        height: 66
        background: Rectangle {
            color: "#0f1822"
            border.color: root.panelBorder
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 18

            Label {
                Layout.fillWidth: true
                text: "Biceps Curl Trainer"
                color: root.textPrimary
                font.pixelSize: 25
                font.weight: Font.DemiBold
            }

            Label {
                text: workoutController.sessionState
                color: workoutController.running ? root.accent : root.amber
                font.pixelSize: 17
                font.weight: Font.Bold
            }

            Switch {
                text: "Manual"
                enabled: !root.workoutComplete
                checked: workoutController.manualMode
                palette.windowText: root.textPrimary
                focusPolicy: Qt.NoFocus
                onToggled: workoutController.manualMode = checked
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 22

        ColumnLayout {
            Layout.preferredWidth: 370
            Layout.fillHeight: true
            spacing: 18

            PhotoMuscleOverlay {
                Layout.fillWidth: true
                Layout.preferredHeight: 330
                activation: workoutController.activation
                elbowAngle: workoutController.elbowAngle
                loadKg: workoutController.loadKg
                maxLoadKg: 40
                celebrationMessage: root.roundCelebration
                muscleColor: root.muscle
                surfaceColor: root.surface
                borderColor: root.panelBorder
            }

            CoachPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                cue: workoutController.coachCue
                formScore: workoutController.formScore
                pushProgress: (workoutController.elbowAngle - 48) / 117
                accentColor: root.accent
                warningColor: root.amber
                dangerColor: root.muscle
                surfaceColor: root.panel
                borderColor: root.panelBorder
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: root.surface
                border.color: root.panelBorder

                CurlMotionView {
                    anchors.fill: parent
                    anchors.margins: 20
                    elbowAngle: workoutController.elbowAngle
                    activation: workoutController.activation
                    muscleColor: root.muscle
                    accentColor: root.accent
                    lineColor: root.textPrimary
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 154
                radius: 8
                color: root.panel
                border.color: root.panelBorder

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    MetricCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        label: "Set"
                        value: workoutController.currentSet + "/" + workoutController.targetSets
                        unit: "round"
                        accentColor: root.blue
                    }

                    MetricCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        label: "Reps"
                        value: workoutController.currentRep + "/" + workoutController.targetReps
                        unit: "target"
                        accentColor: root.accent
                    }

                    MetricCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        label: "Done"
                        value: workoutController.completedRounds
                        unit: "rounds"
                        accentColor: root.muscle
                    }

                    MetricCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        label: "Load"
                        value: workoutController.loadKg
                        unit: "kg"
                        accentColor: root.amber
                    }

                    MetricCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        label: "Form"
                        value: Math.round(workoutController.formScore)
                        unit: "score"
                        accentColor: workoutController.formScore < 76 ? root.amber : root.accent
                    }

                    MetricCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        label: "Time"
                        value: workoutController.elapsedTime
                        unit: "elapsed"
                        accentColor: root.textPrimary
                    }
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 310
            Layout.fillHeight: true
            spacing: 18

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 668
                radius: 8
                color: root.controlSurface
                border.color: root.panelBorder
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    Label {
                        Layout.fillWidth: true
                        text: "Training Controls"
                        color: root.textPrimary
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ControlButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            text: root.workoutComplete ? "New Start" : (workoutController.running ? "Pause" : (workoutController.sessionState === "Paused" ? "Continue" : "Start"))
                            baseColor: workoutController.running ? root.amber : root.accent
                            pressedColor: workoutController.running ? "#fde68a" : "#86efac"
                            textColor: "#06130c"
                            onClicked: workoutController.running ? workoutController.pause() : (workoutController.sessionState === "Paused" ? workoutController.resume() : workoutController.start())
                        }

                        ControlButton {
                            Layout.preferredWidth: 92
                            Layout.preferredHeight: 46
                            text: "Reset"
                            baseColor: root.danger
                            pressedColor: "#fecdd3"
                            textColor: "#1d0710"
                            onClicked: workoutController.reset()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 108
                        radius: 8
                        color: "#142131"
                        border.color: "#27445a"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Label {
                                Layout.fillWidth: true
                                text: "Plan"
                                color: root.blue
                                font.pixelSize: 15
                                font.weight: Font.Bold
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Label {
                                        Layout.fillWidth: true
                                        text: "Rounds"
                                        color: root.textPrimary
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                    }

                                    SpinBox {
                                        id: roundsSpinBox
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 42
                                        from: workoutController.completedRounds + 1
                                        to: 8
                                        value: workoutController.selectedRounds
                                        editable: true
                                        enabled: !workoutController.running && !root.workoutComplete
                                        onValueModified: workoutController.selectedRounds = value

                                        background: Rectangle {
                                            radius: 8
                                            color: roundsSpinBox.enabled ? "#0c1721" : "#161f28"
                                            border.color: roundsSpinBox.enabled ? root.blue : "#304050"
                                        }

                                        up.indicator: Rectangle {
                                            x: roundsSpinBox.width - width
                                            y: 0
                                            width: 34
                                            height: roundsSpinBox.height / 2
                                            radius: 6
                                            color: roundsSpinBox.enabled ? root.blue : "#334155"
                                            border.color: "#a5f3fc"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "+"
                                                color: "#06131a"
                                                font.pixelSize: 15
                                                font.weight: Font.Bold
                                            }
                                        }

                                        down.indicator: Rectangle {
                                            x: roundsSpinBox.width - width
                                            y: roundsSpinBox.height / 2
                                            width: 34
                                            height: roundsSpinBox.height / 2
                                            radius: 6
                                            color: roundsSpinBox.enabled ? "#2563eb" : "#334155"
                                            border.color: "#93c5fd"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "-"
                                                color: "#eff6ff"
                                                font.pixelSize: 16
                                                font.weight: Font.Bold
                                            }
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Label {
                                        Layout.fillWidth: true
                                        text: "Pushes"
                                        color: root.textPrimary
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                    }

                                    SpinBox {
                                        id: pushesSpinBox
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 42
                                        from: 1
                                        to: 30
                                        value: workoutController.pushesPerRound
                                        editable: true
                                        enabled: !workoutController.running && !root.workoutComplete
                                        onValueModified: workoutController.pushesPerRound = value

                                        background: Rectangle {
                                            radius: 8
                                            color: pushesSpinBox.enabled ? "#0c1721" : "#161f28"
                                            border.color: pushesSpinBox.enabled ? root.accent : "#304050"
                                        }

                                        up.indicator: Rectangle {
                                            x: pushesSpinBox.width - width
                                            y: 0
                                            width: 34
                                            height: pushesSpinBox.height / 2
                                            radius: 6
                                            color: pushesSpinBox.enabled ? root.accent : "#334155"
                                            border.color: "#bbf7d0"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "+"
                                                color: "#06130c"
                                                font.pixelSize: 15
                                                font.weight: Font.Bold
                                            }
                                        }

                                        down.indicator: Rectangle {
                                            x: pushesSpinBox.width - width
                                            y: pushesSpinBox.height / 2
                                            width: 34
                                            height: pushesSpinBox.height / 2
                                            radius: 6
                                            color: pushesSpinBox.enabled ? "#15803d" : "#334155"
                                            border.color: "#86efac"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "-"
                                                color: "#ecfdf5"
                                                font.pixelSize: 16
                                                font.weight: Font.Bold
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 8
                        color: "#142131"
                        border.color: "#27445a"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            ControlButton {
                                text: "-"
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 46
                                baseColor: "#334155"
                                pressedColor: "#64748b"
                                textColor: root.textPrimary
                                onClicked: workoutController.decreaseLoad()
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Label {
                                    Layout.fillWidth: true
                                    text: "Load"
                                    color: root.textSecondary
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 12
                                }

                                Label {
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    text: workoutController.loadKg + " kg"
                                    color: root.amber
                                    font.pixelSize: 28
                                    font.weight: Font.Bold
                                }
                            }

                            ControlButton {
                                text: "+"
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 46
                                baseColor: root.amber
                                pressedColor: "#fde68a"
                                textColor: "#1c1403"
                                onClicked: workoutController.increaseLoad()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 108
                        radius: 8
                        color: "#142131"
                        border.color: "#27445a"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Label {
                                Layout.fillWidth: true
                                text: "Arm Movement"
                                color: root.blue
                                font.pixelSize: 15
                                font.weight: Font.Bold
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                MovementButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 58
                                    enabled: !root.workoutComplete
                                    text: "Curl Up"
                                    activeColor: root.accent
                                    idleColor: "#193c2b"
                                    borderColor: "#2ee66b"
                                    onPressedHold: workoutController.curlUp()
                                    onReleasedHold: workoutController.stopArm()
                                }

                                MovementButton {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 58
                                    enabled: !root.workoutComplete
                                    text: "Lower"
                                    activeColor: root.blue
                                    idleColor: "#163246"
                                    borderColor: "#22d3ee"
                                    onPressedHold: workoutController.lowerDown()
                                    onReleasedHold: workoutController.stopArm()
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 82
                        radius: 8
                        color: "#142131"
                        border.color: "#27445a"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    Layout.fillWidth: true
                                    text: "Manual Elbow"
                                    color: root.textPrimary
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }

                                Label {
                                    text: Math.round(workoutController.elbowAngle) + " deg"
                                    color: root.blue
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }
                            }

                            Slider {
                                id: elbowSlider
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                enabled: workoutController.manualMode && !root.workoutComplete
                                from: 48
                                to: 165
                                value: workoutController.elbowAngle
                                focusPolicy: Qt.NoFocus
                                onMoved: workoutController.setManualAngle(value)

                                background: Rectangle {
                                    x: elbowSlider.leftPadding
                                    y: elbowSlider.topPadding + elbowSlider.availableHeight / 2 - height / 2
                                    width: elbowSlider.availableWidth
                                    height: 8
                                    radius: 4
                                    color: "#263746"

                                    Rectangle {
                                        width: elbowSlider.visualPosition * parent.width
                                        height: parent.height
                                        radius: 4
                                        color: root.muscle
                                    }
                                }

                                handle: Rectangle {
                                    x: elbowSlider.leftPadding + elbowSlider.visualPosition * (elbowSlider.availableWidth - width)
                                    y: elbowSlider.topPadding + elbowSlider.availableHeight / 2 - height / 2
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: elbowSlider.enabled ? root.amber : "#64748b"
                                    border.color: root.textPrimary
                                    border.width: 2
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 104
                        radius: 8
                        color: "#142131"
                        border.color: "#27445a"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    Layout.fillWidth: true
                                    text: "Completed Pushes"
                                    color: root.textSecondary
                                    font.pixelSize: 13
                                }

                                Label {
                                    text: workoutController.currentRep + " / " + workoutController.pushesPerRound
                                    color: workoutController.currentRep >= workoutController.pushesPerRound ? root.accent : root.textPrimary
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    Layout.fillWidth: true
                                    text: "Session Pushes"
                                    color: root.textSecondary
                                    font.pixelSize: 13
                                }

                                Label {
                                    text: workoutController.totalPushesCompleted
                                    color: root.blue
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    Layout.fillWidth: true
                                    text: "Rounds Done"
                                    color: root.textSecondary
                                    font.pixelSize: 13
                                }

                                Label {
                                    text: workoutController.completedRounds + " / " + workoutController.selectedRounds
                                    color: workoutController.completedRounds >= workoutController.selectedRounds ? root.accent : root.textPrimary
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }

                }
            }

            SetHistoryList {
                Layout.fillWidth: true
                Layout.fillHeight: true
                history: workoutController.setHistory
                surfaceColor: root.surface
                borderColor: root.panelBorder
                textPrimary: root.textPrimary
                textSecondary: root.textSecondary
                accentColor: root.accent
            }
        }
    }
}
