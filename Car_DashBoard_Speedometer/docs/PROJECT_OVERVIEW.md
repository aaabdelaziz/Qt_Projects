# Project Overview

## Summary

This is a Qt 6/QML automotive dashboard speedometer. I built it to demonstrate custom Qt Quick UI work: a styled gauge, keyboard interaction, timer-driven animation, and real-time visual feedback.

![Car Dashboard Speedometer animated demo](../Images/car_dashboard_demo.gif)

## What It Demonstrates

- Qt Quick application setup with CMake.
- QML-first UI composition.
- Custom styling of a Qt Quick `Dial`.
- Keyboard input and focus handling.
- Timer-driven animation at roughly 60 FPS.
- Canvas rendering for dynamic gauge graphics.
- `Repeater`-based tick marks and number labels.
- Simple simulation logic with clamped speed values.

## Technical Explanation

The C++ layer is intentionally small. It creates the Qt application, creates the QML engine, handles QML loading failure, and loads the `Main.qml` file from the registered QML module.

The QML layer owns the product behavior. It uses a `Dial` as the speed model, then replaces the default control visuals with a custom dashboard design. A `Timer` updates the current speed every `16 ms`. Keyboard handlers set acceleration and braking flags, and the timer uses those flags to increase, decrease, or coast the speed value.

The gauge visuals are not static images. The needle angle follows the `Dial` value, tick marks and labels are generated with a `Repeater`, and the speed arc is drawn with a QML `Canvas`.

## Suggested Walkthrough

1. Run the app and click the window so keyboard focus is active.
2. Hold `Up Arrow` and explain acceleration.
3. Release `Up Arrow` and explain coasting.
4. Hold `Down Arrow` and explain braking.
5. Point out the digital speed readout and high-speed color change above `120 km/h`.
6. Open `Main.qml` and show the custom `Dial` background and handle.
7. Show the `Timer` block and explain the simulation update loop.
8. Open `main.cpp` and explain that C++ is used as a clean Qt bootstrap.

## Design Intent

This project is intentionally compact, but it shows the core skills needed for professional Qt/QML UI work: custom controls, smooth interaction, state-driven rendering, and clean separation between C++ application startup and QML interface behavior.
