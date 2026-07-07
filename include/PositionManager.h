#ifndef POSITIONMANAGER_H
#define POSITIONMANAGER_H

#include <QObject>
#include <QThread>
#include <ChartObjects.h>
#include <CsvLoader.h>
#include <TimeframeAggregator.h>
#include <CandleUtils.h>
#include <QTimeZone>
#include <CandleModel.h>

class PositionManager : public QObject
{
    Q_OBJECT
public:
    explicit PositionManager(CandleModel *model,
                             CsvLoader* loader,
                             TimeframeAggregator *agg,
                             QObject *parent = nullptr);

    void                        setPositions(QList<Position> newList);
    QList<Position>             getPositions();
    Q_INVOKABLE QVariantList    getPositionsForQML();
    Q_INVOKABLE void            startCalculation();
    Q_INVOKABLE QVariantMap     positionsInfo();
    void                        removeStopNA(QList<Position> *positions);      // Removes the positions that couldn't find StopLoss
    void                        removeSameEntries(QList<Position> *positions); // Keeps only one of the positions with same Entry price
    void                        removeCloseEntries(QList<Position> *positions, int distance = 50);// Remove the positions with close Entry Point

    Q_PROPERTY(QString leveltf READ leveltf WRITE setLeveltf NOTIFY leveltfChanged FINAL)
    Q_PROPERTY(QString breaktf READ breaktf WRITE setBreaktf NOTIFY breaktfChanged FINAL)
    Q_PROPERTY(int candleCountForBreak READ candleCountForBreak WRITE setcandleCountForBreak NOTIFY candleCountForBreakChanged FINAL)
    Q_PROPERTY(int entryLookback READ entryLookback WRITE setEntryLookback NOTIFY entryLookbackChanged FINAL)
    Q_PROPERTY(double entryThreshold READ entryThreshold WRITE setEntryThreshold NOTIFY entryThresholdChanged FINAL)
    Q_PROPERTY(double levelFilterGap READ levelFilterGap WRITE setLevelFilterGap NOTIFY levelFilterGapChanged FINAL)
    Q_PROPERTY(int stopLookback READ stopLookback WRITE setStopLookback NOTIFY stopLookbackChanged FINAL)
    Q_PROPERTY(int takeProfitLookback READ takeProfitLookback WRITE setTakeProfitLookback NOTIFY takeProfitLookbackChanged FINAL)
    Q_PROPERTY(int candleCountForTP READ candleCountForTP WRITE setCandleCountForTP NOTIFY candleCountForTPChanged FINAL)
    Q_PROPERTY(QString takeProfitTF READ takeProfitTF WRITE setTakeProfitTF NOTIFY takeProfitTFChanged FINAL)
    Q_PROPERTY(bool isLoading READ isLoading WRITE setIsLoading NOTIFY isLoadingChanged FINAL)
    Q_PROPERTY(double rewradToRisk READ rewradToRisk WRITE setRewradToRisk NOTIFY rewradToRiskChanged FINAL)


    // ---Q_PROPERTY getters ---
    QString leveltf() const;
    QString breaktf() const;
    int candleCountForBreak() const;
    int entryLookback() const;
    double entryThreshold() const;
    double levelFilterGap() const;
    int stopLookback() const;
    int takeProfitLookback() const;
    int candleCountForTP() const;
    QString takeProfitTF() const;
    bool isLoading() const;
    double rewradToRisk() const;

    // ---Q_PROPERTY setters ---
    void setLeveltf(const QString &newLeveltf);
    void setBreaktf(const QString &newBreaktf);
    void setcandleCountForBreak(int newcandleCountForBreak);
    void setEntryLookback(int newEntryLookback);
    void setEntryThreshold(double newentryThreshold);
    void setLevelFilterGap(double newLevelFilterGap);
    void setStopLookback(int newStopLookback);
    void setTakeProfitLookback(int newTakeProfitLookback);
    void setCandleCountForTP(int newCandleCountForTP);
    void setTakeProfitTF(const QString &newTakeProfitTF);
    void setIsLoading(bool newIsLoading);
    void setRewradToRisk(double newRewradToRisk);

    // --- The list to keep the positions ---
public:
    QList<Position>             positionList;

public slots:
    void run(TimeframeAggregator::Timeframe timeframe);

signals:
    void positionListReady(QList<Position> list);
    void calculationRequested();
    void initialValues(TimeframeAggregator::Timeframe leveltf,
                       TimeframeAggregator::Timeframe breaktf,
                       int candleCountForBreak,
                       int entryLookback,
                       double entryThreshold,
                       double levelFilterGap,
                       int stopLookback,
                       int takeProfitLookback,
                       int candleCountForTP,
                       double rewradToRisk
                       );

    // ---Q_PROPERTY signals ---
    void leveltfChanged();
    void breaktfChanged();
    void candleCountForBreakChanged();
    void entryLookbackChanged();
    void entryThresholdChanged();
    void stopLookbackChanged();
    void takeProfitLookbackChanged();
    void candleCountForTPChanged();
    void takeProfitTFChanged();

    void levelFilterGapChanged();

    void isLoadingChanged();

    void rewradToRiskChanged();

private:
    CsvLoader*              m_loader;
    CandleModel*            m_model;
    TimeframeAggregator*    m_agg;
    QVariantList            m_candles;
    QString                 m_leveltf               = "1m";
    QString                 m_breaktf               = "1m";
    int                     m_candleCountForBreak   = 500;
    int                     m_entryLookback         = 5;
    double                  m_entryThreshold        = 0.5;
    double                  m_levelFilterGap        = 0.0003;
    int                     m_stopLookback          = 3;
    int                     m_takeProfitLookback    = 3;
    int                     m_candleCountForTP      = 500;
    QString                 m_takeProfitTF          = "1m";
    bool                    m_isLoading             = false;
    double                  m_rewradToRisk          = 1;
};

#endif // POSITIONMANAGER_H
