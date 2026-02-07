#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <CsvLoader.h>
#include <TimeframeAggregator.h>
#include <ChartObjecctModel.h>
#include <LevelDetector.h>
#include <TrendlineDetector.h>


int main(int argc, char *argv[])
{

    qputenv("QT_QUICK_CONTROLS_MATERIAL_ACCENT", "white");
    QQuickStyle::setStyle("Material");

    QApplication app(argc, argv);
    CsvLoader csvLoader;
    TimeframeAggregator aggregator;
    ChartObjectModel chartObjects;
    LevelDetector levelDetector;
    TrendlineDetector trendlineDetector;

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
    engine.rootContext()->setContextProperty("trendlineDetector",&trendlineDetector);
    engine.loadFromModule("ForexAnalyzer", "Main");

    return app.exec();
}
