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
#include <TwelveDataWorker.h>
#include <CandleModel.h>
#include <CsvWorker.h>


int main(int argc, char *argv[])
{

    QQuickStyle::setStyle("Material");
    QApplication     app(argc, argv);
    CsvLoader        *csvLoader = new CsvLoader();
    TimeframeAggregator aggregator;
    ChartObjectModel    chartObjects;
    PositionModel       positionModel;
    TrendlineDetector   trendlineDetector(&aggregator);
    LevelDetector       levelDetector;
    QSortFilterProxyModel proxy;
    proxy.setSourceModel(&positionModel);

    QThread *workerThread = new QThread();
    TwelveDataWorker   *tdWorker    = new TwelveDataWorker();
    CandleModel        *candleModel = new CandleModel();
    CsvWorker          *csvWorker   = new CsvWorker();

    PositionManager     positionManager(candleModel ,csvLoader, &aggregator);
    EntryPointCalculator    entrypoint(candleModel ,csvLoader, &positionManager, &aggregator);
    StopLossCalculator      stoploss(candleModel ,csvLoader, &positionManager, &aggregator, &entrypoint);
    TakeProfitCalculator    takeprofit(candleModel ,csvLoader, &positionManager, &aggregator, &entrypoint);

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

    QObject::connect(
        candleModel,
        &CandleModel::clearingModel,
        tdWorker,
        &TwelveDataWorker::stopStreaming);

    QObject::connect(tdWorker, &TwelveDataWorker::candlesReady,
                     candleModel, qOverload<QSharedPointer<QVariantList>>(&CandleModel::loadCandles));

    QObject::connect(csvLoader, &CsvLoader::candlesReady,
                     candleModel, qOverload<QSharedPointer<QVariantList>>(&CandleModel::loadCandles));


    QObject::connect(tdWorker,  &TwelveDataWorker::candleUpdated,
                     candleModel, &CandleModel::updateLast);

    QObject::connect(tdWorker,  &TwelveDataWorker::candleAppended,
                     candleModel, &CandleModel::append);

    workerThread->start();

    qmlRegisterSingletonInstance(
        "ForexAnalyzer",
        1, 0,
        "Aggregator",
        &aggregator
        );

    engine.rootContext()->setContextProperty("csvLoader",           csvLoader);
    engine.rootContext()->setContextProperty("chartObjects",        &chartObjects);
    engine.rootContext()->setContextProperty("levelDetector",       &levelDetector);
    engine.rootContext()->setContextProperty("trendlineDetector",   &trendlineDetector);
    engine.rootContext()->setContextProperty("proxyModel",          &proxy);
    engine.rootContext()->setContextProperty("positionModel",       &positionModel);
    engine.rootContext()->setContextProperty("positionManager",     &positionManager);
    engine.rootContext()->setContextProperty("tdWorker",            tdWorker);
    engine.rootContext()->setContextProperty("candleModel",         candleModel);
    engine.rootContext()->setContextProperty("tdWorker",            tdWorker);
    engine.rootContext()->setContextProperty("csvWorker",           csvWorker);
    engine.loadFromModule("ForexAnalyzer", "Main");

    return app.exec();
}
