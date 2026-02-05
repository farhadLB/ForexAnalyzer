#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <CsvLoader.h>
#include <TimeframeAggregator.h>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    CsvLoader csvLoader;
    TimeframeAggregator aggregator;

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.rootContext()->setContextProperty("csvLoader", &csvLoader);
    engine.rootContext()->setContextProperty("aggregator", &aggregator);
    engine.loadFromModule("ForexAnalyzer", "Main");

    return app.exec();
}
