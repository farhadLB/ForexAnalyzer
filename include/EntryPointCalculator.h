#ifndef ENTRYPOINTCALCULATOR_H
#define ENTRYPOINTCALCULATOR_H

#include <QObject>
#include <ChartObjects.h>
#include <LevelDetector.h>
#include <TimeframeAggregator.h>
#include <CsvLoader.h>
#include <PositionManager.h>
#include <CandleUtils.h>
#include <TrendCalculator.h>


class EntryPointCalculator : public QObject
{
    Q_OBJECT
public:
    EntryPointCalculator(CsvLoader *loader,
                         PositionManager *pos,
                         TimeframeAggregator *agg,
                         int strategy = LevelBreak,
                         QObject *parent = nullptr);

    enum strategies {
        LevelBreak
    };

    QVariantList getLevels();
    double ATR(const QVector<Candle> &candles);
    double PivotATR(QVector<Candle> *candles, const int start, const int end);

public slots:
    void HorizantalLevelBreak(TimeframeAggregator::Timeframe leveltf,
                              TimeframeAggregator::Timeframe breaktf,
                              int candleCount = 1000,
                              int lookback = 10,
                              double threshold = 0.1,
                              double gap = 1);

    void runEntryPoint(TimeframeAggregator::Timeframe leveltf,
                       TimeframeAggregator::Timeframe breaktf,
                       int candleCountForBreak,
                       int entryLookback,
                       double entryThreshold,
                       double levelFilterGap,
                       int stopLookback,
                       int takeProfitLookback,
                       int candleCountForTP,
                       double rewradToRisk);
signals:
    void entryPointReady(int stopLookback,
                         int takeProfitLookback,
                         int candleCountForTP,
                         TimeframeAggregator::Timeframe takeProfitTF,
                         TimeframeAggregator::Timeframe breaktf,
                         double rewradToRisk
                         );

private:
    QVariantList        m_candles;
    LevelDetector       m_levelDetector;
    QVariantList        m_levels;
    QList<Position>     m_positionList;
    TimeframeAggregator *m_agg;
    CsvLoader           *m_loader;
    PositionManager     *m_pos;
    int                 m_strategy;
    TrendCalculator     m_trendCalc;

};

#endif // ENTRYPOINTCALCULATOR_H
