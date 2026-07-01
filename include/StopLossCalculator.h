#ifndef STOPLOSSCALCULATOR_H
#define STOPLOSSCALCULATOR_H

#include <QObject>
#include <PositionManager.h>
#include <EntryPointCalculator.h>
#include <TimeframeAggregator.h>
#include <LevelDetector.h>
#include <CsvLoader.h>
#include <CandleUtils.h>
#include <QThread>

class StopLossCalculator : public QObject
{
    Q_OBJECT
public:
    explicit StopLossCalculator(CsvLoader *loader,
                                PositionManager *pos,
                                TimeframeAggregator *agg,
                                EntryPointCalculator *entry,
                                QObject *parent = nullptr);

    void firstPivot(int backdrop,
                    TimeframeAggregator::Timeframe leveltf,
                    TimeframeAggregator::Timeframe breaktf);
    LevelDetector levelDetector;

public slots:
    void runStopLoss(int stopLookback,
                     int takeProfitLookback,
                     int candleCountForTP,
                     TimeframeAggregator::Timeframe takeProfitTF,
                     TimeframeAggregator::Timeframe breakTF,
                     double rewradToRisk);

signals:
    void stopLossReady(int takeProfitLookback,
                       int candleCountForTP,
                       TimeframeAggregator::Timeframe takeProfitTF,
                       TimeframeAggregator::Timeframe breakTF,
                       double rewradToRisk);

private:
    PositionManager*      m_pos;
    EntryPointCalculator* m_entry;
    TimeframeAggregator*  m_agg;
    CsvLoader*            m_loader;
    QList<Position>       m_positionList;
    QVariantList          m_candles;
    QVariantList          m_levels;
};

#endif // STOPLOSSCALCULATOR_H
