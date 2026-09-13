# Learning Guide

## 1. Run The App

Open this file in Qt Creator:

```text
Car_DashBoard_Speedometer/CMakeLists.txt
```

Select a Desktop Qt 6 kit and run the app.

If Qt Creator asks for CMake variables and your Qt install is not auto-detected, use your Qt prefix path. On this machine, related projects use:

```text
CMAKE_PREFIX_PATH=/Users/ahmedabdelaziz/MyBrain/Qt/6.10.2/macos
```

## 2. Use The App

Start by looking at the application output in the README:

![Car Dashboard Speedometer animated demo](../Images/car_dashboard_demo.gif)

The animation shows how the speed value drives the needle, arc, label, and high-speed visual state.

1. Click the app window once to make sure it has keyboard focus.
2. Hold **Up Arrow** to accelerate.
3. Release **Up Arrow** to coast down slowly.
4. Hold **Down Arrow** to brake.
5. Watch the needle rotate as the speed changes.
6. Watch the digital readout turn red above `120 km/h`.

## 3. Understand `main.cpp`

The C++ file is only the Qt application bootstrap:

```cpp
QGuiApplication app(argc, argv);
QQmlApplicationEngine engine;
engine.loadFromModule("Car_DashBoard_Speedometer", "Main");
return app.exec();
```

The important idea: C++ starts the app, then QML owns the UI and simulation.

## 4. Understand `CMakeLists.txt`

The project creates one executable:

```cmake
qt_add_executable(appCar_DashBoard_Speedometer
    main.cpp
)
```

Then it registers `Main.qml` as a QML module:

```cmake
qt_add_qml_module(appCar_DashBoard_Speedometer
    URI Car_DashBoard_Speedometer
    QML_FILES
        Main.qml
)
```

That module URI is why C++ can load:

```cpp
engine.loadFromModule("Car_DashBoard_Speedometer", "Main");
```

## 5. Understand The Speedometer Dial

Open `Main.qml`.

The dashboard uses a `Dial`:

```qml
Dial {
    id: speedometer
    from: 0
    to: 180
    value: 0
}
```

`Dial` is useful because it already maps `value` to an angle. The project replaces the default visuals with a custom background and handle.

## 6. Understand Keyboard Input

The app uses two boolean flags:

```qml
property bool acceleration: false
property bool braking: false
```

When the Up Arrow is held, `acceleration` becomes true. When the Down Arrow is held, `braking` becomes true. Releasing each key sets the matching flag back to false.

## 7. Understand The Simulation Loop

The timer runs every `16 ms`:

```qml
Timer {
    interval: 16
    running: true
    repeat: true
}
```

The logic is:

```text
if accelerating: speed increases
else if braking: speed decreases quickly
else: speed coasts down slowly
```

Then the speed is clamped to the valid range:

```text
0 <= speed <= 180
```

## 8. Understand The Custom Visuals

The visual target for this section is shown below:

![Car Dashboard Speedometer high-speed state](../Images/meter_4.png)

The `background` item draws:

- Red speed arc.
- Tick marks.
- Number labels.

The `handle` item draws:

- Red needle.
- Center pivot.

The digital speed readout is a `Text` item that changes color:

```qml
color: speedometer.value > 120 ? "#e74c3c" : "white"
```

## 9. What To Say About It

Say:

> I built this as a Qt/QML automotive dashboard component. It uses a customized Qt Quick Dial, timer-driven speed simulation, keyboard input, Canvas rendering, and a responsive digital readout. The main focus is showing how to turn a standard Qt control into a polished product-specific UI.
