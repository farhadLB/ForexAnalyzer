#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSortFilterProxyModel>
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
#include <QThread>

int main(int argc, char *argv[])
{

    QQuickStyle::setStyle("Material");
    QApplication     app(argc, argv);
    CsvLoader           csvLoader;
    TimeframeAggregator aggregator;
    ChartObjectModel    chartObjects;
    PositionModel       positionModel;
    PositionManager     positionManager(&csvLoader, &aggregator);
    TrendlineDetector   trendlineDetector(&aggregator);
    LevelDetector       levelDetector;
    QSortFilterProxyModel proxy;
    proxy.setSourceModel(&positionModel);

    EntryPointCalculator    entrypoint(&csvLoader, &positionManager, &aggregator);
    StopLossCalculator      stoploss(&csvLoader, &positionManager, &aggregator, &entrypoint);
    TakeProfitCalculator    takeprofit(&csvLoader, &positionManager, &aggregator, &entrypoint);

    QThread *workerThread = new QThread();
    entrypoint.moveToThread(workerThread);
    stoploss.moveToThread(workerThread);
    takeprofit.moveToThread(workerThread);


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
        &positionManager,
        &PositionManager::initialValues,
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

    workerThread->start();

    qmlRegisterSingletonInstance(
        "ForexAnalyzer",
        1, 0,
        "Aggregator",
        &aggregator
        );

    engine.rootContext()->setContextProperty("csvLoader",           &csvLoader);
    engine.rootContext()->setContextProperty("chartObjects",        &chartObjects);
    engine.rootContext()->setContextProperty("levelDetector",       &levelDetector);
    engine.rootContext()->setContextProperty("trendlineDetector",   &trendlineDetector);
    engine.rootContext()->setContextProperty("proxyModel",          &proxy);
    engine.rootContext()->setContextProperty("positionModel",       &positionModel);
    engine.rootContext()->setContextProperty("positionManager",     &positionManager);
    engine.loadFromModule("ForexAnalyzer", "Main");

    return app.exec();
}
