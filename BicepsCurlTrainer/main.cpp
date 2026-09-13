#include "biceps_workout_controller.h"

#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char* argv[])
{
    QGuiApplication app{argc, argv};

    BicepsWorkoutController workout_controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("workoutController", &workout_controller);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [] { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("BicepsCurlTrainer", "Main");
    return app.exec();
}
