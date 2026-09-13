cmake_minimum_required(VERSION 3.24)

project(BicepsCurlTrainer VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Qml)

qt_standard_project_setup(REQUIRES 6.5)
qt_policy(SET QTP0004 NEW)

qt_add_executable(biceps_curl_trainer
    main.cpp
    biceps_workout_controller.cpp
    biceps_workout_controller.h
)

qt_add_qml_module(biceps_curl_trainer
    URI BicepsCurlTrainer
    VERSION 1.0
    QML_FILES
        Main.qml
        qml/AnatomyFocusView.qml
        qml/CoachPanel.qml
        qml/ControlButton.qml
        qml/CurlMotionView.qml
        qml/MetricCard.qml
        qml/MovementButton.qml
        qml/PhotoMuscleOverlay.qml
        qml/SetHistoryList.qml
        qml/TempoTimeline.qml
    RESOURCES
        assets/biceps_curl_reference.png
)

target_link_libraries(biceps_curl_trainer
    PRIVATE
        Qt6::Quick
        Qt6::Qml
)

set_target_properties(biceps_curl_trainer PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)
