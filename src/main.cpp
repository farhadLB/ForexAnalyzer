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
    TrendlineDetector trendlineDetector(&aggregator);
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.rootContext()->setContextProperty("csvLoader", &csvLoader);
    engine.rootContext()->setContextProperty("chartObjects",&chartObjects);
    engine.rootContext()->setContextProperty("levelDetector",&levelDetector);
    engine.rootContext()->setContextProperty("trendlineDetector",&trendlineDetector);
    engine.loadFromModule("ForexAnalyzer", "Main");

    //defining time aggregator as a singleton
    qmlRegisterSingletonInstance(
        "ForexAnalyzer",
        1, 0,
        "Aggregator",
        &aggregator
        );

    return app.exec();
}
