#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <CsvLoader.h>
#include <TimeframeAggregator.h>
#include <ChartObjectModel.h>
#include <LevelDetector.h>
#include <TrendlineDetector.h>
#include <PositionManager.h>
#include <PositionModel.h>
#include <EntryPointCalculator.h>
#include <StopLossCalculator.h>
#include <TakeProfitCalculator.h>

int main(int argc, char *argv[])
{

    qputenv("QT_QUICK_CONTROLS_MATERIAL_ACCENT", "white");
    QQuickStyle::setStyle("Material");
    QGuiApplication     app(argc, argv);
    CsvLoader           csvLoader;
    TimeframeAggregator aggregator;
    ChartObjectModel    chartObjects;
    PositionModel       positionModel;
    PositionManager     positionManager(&csvLoader, &aggregator);
    TrendlineDetector   trendlineDetector(&aggregator);
    LevelDetector       levelDetector;

    EntryPointCalculator    entrypoint(&csvLoader, &positionManager, &aggregator);
    StopLossCalculator      stoploss(&csvLoader, &positionManager, &aggregator, &entrypoint);
    TakeProfitCalculator    takeprofit(&csvLoader, &positionManager, &aggregator, &entrypoint);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    QObject::connect(
        &positionManager,
        &PositionManager::positionListReady,
        &positionModel,
        &PositionModel::setPositionList);

    QObject::connect(
        &csvLoader,
        &CsvLoader::candlesReady,
        &entrypoint,
        &EntryPointCalculator::runEntryPoint);

    QObject::connect(
        &entrypoint,
        &EntryPointCalculator::entryPointReady,
        &stoploss,
        &StopLossCalculator::runStopLoss);


    QObject::connect(
        &stoploss,
        &StopLossCalculator::stopLossReady,
        &takeprofit,
        &TakeProfitCalculator::runTakeProfit);

    QObject::connect(
        &takeprofit,
        &TakeProfitCalculator::takeProfitReady,
        &positionManager,
        &PositionManager::run);

    QObject::connect(
        &positionManager,
        &PositionManager::positionListReady,
        &chartObjects,
        &ChartObjectModel::getPositions);


    // positionManager.run();

    engine.rootContext()->setContextProperty("csvLoader",           &csvLoader);
    engine.rootContext()->setContextProperty("chartObjects",        &chartObjects);
    engine.rootContext()->setContextProperty("levelDetector",       &levelDetector);
    engine.rootContext()->setContextProperty("trendlineDetector",   &trendlineDetector);
    engine.rootContext()->setContextProperty("positionModel",       &positionModel);
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
