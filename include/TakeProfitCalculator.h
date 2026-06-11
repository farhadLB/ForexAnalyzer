#ifndef TAKEPROFITCALCULATOR_H
#define TAKEPROFITCALCULATOR_H

#include <QObject>
#include <PositionManager.h>
#include <EntryPointCalculator.h>
#include <TimeframeAggregator.h>
#include <LevelDetector.h>
#include <CsvLoader.h>

class TakeProfitCalculator : public QObject
{
    Q_OBJECT
public:
    explicit TakeProfitCalculator(CsvLoader *loader,
                                  PositionManager *pos,
                                  TimeframeAggregator *agg,
                                  EntryPointCalculator *entry,
                                  QObject *parent = nullptr);

    void firstPivot(int backdrop, int candleCount, QString timeframe);
    LevelDetector levelDetector;

public slots:
    void runTakeProfit();

signals:
    void takeProfitReady();

private:
    PositionManager*      m_pos;
    EntryPointCalculator* m_entry;
    TimeframeAggregator*  m_agg;
    CsvLoader*            m_loader;
    QList<Position>       m_positionList;
    QVariantList          m_candles;
    QVariantList          m_levels;
};

#endif // TAKEPROFITCALCULATOR_H
