# Interview Talk Track

## Short Pitch

This is a Qt 6/QML biceps curl trainer. It combines a C++ workout engine with a dynamic QML training interface that visualizes muscle activation, elbow angle, tempo, sets, reps, and form quality.

## What It Demonstrates

- Modern C++ backend state management.
- Qt properties, signals, and invokable commands.
- QML component composition.
- Canvas-based custom dynamic visuals.
- A realistic fitness-domain interaction model.

## Technical Explanation

`BicepsWorkoutController` is the source of truth. It updates the workout using a `QTimer`, calculates guided curl motion, detects reps, computes form score, and emits signals. QML binds to those properties and repaints the training illustrations.

## Best Walkthrough Order

1. Show guided mode and press **Start**.
2. Point out the photo-based biceps heat overlay and animated arm.
3. Show the tempo phase changing.
4. Configure rounds and pushes per round.
5. Switch to manual mode and hold **Curl Up** / **Lower Down**, or use keyboard Up/Down, to control the arm.
6. Explain that QML controls call `Q_INVOKABLE` C++ methods.
7. Show set history after a completed set.

## Strong Closing Sentence

This project is intentionally small, but it uses the architecture I would use in production Qt/QML: C++ controls the workout domain model and QML stays a fast, reactive, visual layer.
