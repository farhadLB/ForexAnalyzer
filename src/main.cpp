#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <include/CsvLoader.h>
#include <include/TimeframeAggregator.h>
#include <include/ChartObjecctModel.h>
#include <include/LevelDetector.h>
#include <include/TrendlineDetector.h>


int main(int argc, char *argv[])
{

    qputenv("QT_QUICK_CONTROLS_MATERIAL_ACCENT", "white");
    QQuickStyle::setStyle("Material");

    QGuiApplication app(argc, argv);
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
