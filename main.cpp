#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <CsvLoader.h>
#include <TimeframeAggregator.h>
#include <ChartObjecctModel.h>
#include <LevelDetector.h>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    CsvLoader csvLoader;
    TimeframeAggregator aggregator;
    ChartObjectModel chartObjects;
    LevelDetector levelDetector;

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.rootContext()->setContextProperty("csvLoader", &csvLoader);
    engine.rootContext()->setContextProperty("aggregator", &aggregator);
    engine.rootContext()->setContextProperty("chartObjects",&chartObjects);
    engine.rootContext()->setContextProperty("levelDetector",&levelDetector);
    engine.loadFromModule("ForexAnalyzer", "Main");

    return app.exec();
}
