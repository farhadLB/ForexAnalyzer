#include "EntryPointCalculator.h"

EntryPointCalculator::EntryPointCalculator(CsvLoader *loader,
                                           PositionManager *pos,
                                           TimeframeAggregator *agg,
                                           int strategy,
                                           QObject *parent): QObject(parent), m_loader(loader), m_pos(pos), m_agg(agg), m_strategy(strategy){}

QVariantList EntryPointCalculator::getLevels()
{
    return m_levels;
}

// --- Calculate the Average True Range for a range of candles ---
double EntryPointCalculator::ATR(const QVector<Candle> &candles)
{
    double rangeSum = 0;
    for (const Candle &c : candles)
        rangeSum += std::abs(c.high - c.low);
    return rangeSum / candles.size();
}

// double EntryPointCalculator::ATR(QVariantList candles)
// {
//     double rangeSum = 0;
//     for(int i = 0; i < candles.size(); i++){
//             rangeSum += std::abs(candles[i].toMap()["high"].toDouble() - candles[i].toMap()["low"].toDouble()) ;
//     }
//     double atrValue = rangeSum/candles.size();
//     return atrValue;
// }

// void EntryPointCalculator::HorizantalLevelBreak(TimeframeAggregator::Timeframe leveltf, // timeframe to draw the level
//                                                 TimeframeAggregator::Timeframe breaktf, // timeframe to evaluate the breaktime
//                                                 int candleCount,    // number of candles to search for break
//                                                 int lookback,       // level calculation lookback
//                                                 double threshold,   // break calculation threshold
//                                                 double gap
//                                                 )
// {
//     m_positionList.clear();
//     m_levels.clear();
//     m_candles = m_loader->getCandles();
//     QVariantList aggCandles     = m_agg->aggregate(m_candles, leveltf);
//     QVariantList levels         = m_levelDetector.detectLocalLevels(aggCandles, lookback);
//     QVariantList filteredLevels = m_levelDetector.filterCloseLevels(levels, gap);
//     QVariantList breakCandles   = m_agg->aggregate(m_candles, breaktf);
//     double  averageTrueRange = ATR(aggCandles);

//     int searchSize;
//     for(QVariant& v : filteredLevels){
//         QVariantMap level = v.toMap();
//         QVariantMap map = m_agg->indexAggregate(level["idx"].toInt(), leveltf, breaktf);

//         int     levelIndex       = map["index"].toInt();
//         int     ratio            = map["ratio"].toInt();
//         int     newCandleCount   = candleCount * ratio;

//         // --- Specify how many candles after level index should be checked using searchSize --- //
//         if(levelIndex + newCandleCount < breakCandles.size()){
//             searchSize = levelIndex + newCandleCount;
//         }
//         else{
//             searchSize = breakCandles.size();
//         }

//         // --- calculating the break index and Time --- //
//         for(int i=levelIndex + 10; i<searchSize; i++){
//             if(level["isResistance"].toBool()){
//                 if(breakCandles[i].toMap()["close"].toDouble() > level["price"].toDouble() + threshold * averageTrueRange){
//                     level["breakIndex"] = i;
//                     level["breakTime"]  = breakCandles[i].toMap()["time"].toLongLong();
//                     level["breakThreshold"] = threshold;
//                     break;
//                 }
//             }
//             else{
//                 if(breakCandles[i].toMap()["close"].toDouble() < level["price"].toDouble() - threshold * averageTrueRange){
//                     level["breakIndex"] = i;
//                     level["breakTime"]  = breakCandles[i].toMap()["time"].toLongLong();
//                     level["breakThreshold"] = threshold;
//                     break;
//                 }
//             }
//         }

//         // --- make a list of poistions with this entry point --- //
//         if(level["breakIndex"] != -1){
//             Position pos;
//             pos.EntryPointPrice = breakCandles[level["breakIndex"].toInt()].toMap()["close"].toDouble();
//             pos.EntryIdx        = level["breakIndex"].toInt();
//             pos.Timeframe       = m_agg->timeframeToString(breaktf);
//             pos.isBullish       = level["isResistance"].toBool();
//             pos.LevelIdx        = level["idx"].toInt();
//             pos.LevelPrice      = level["price"].toDouble();
//             m_positionList.append(pos);
//             m_levels.append(level);
//         }
//     }
//     m_pos->setPositions(m_positionList);
// }

void EntryPointCalculator::HorizantalLevelBreak(TimeframeAggregator::Timeframe leveltf, // timeframe to draw the level
                                                TimeframeAggregator::Timeframe breaktf, // timeframe to evaluate the breaktime
                                                int candleCount,    // number of candles to search for break
                                                int lookback,       // level calculation lookback
                                                double threshold,   // break calculation threshold
                                                double gap
                                                )
{
    m_positionList.clear();
    m_levels.clear();
    m_candles = m_loader->getCandles();

    QVariantList aggCandles     = m_agg->aggregate(m_candles, leveltf);
    QVariantList levels         = m_levelDetector.detectLocalLevels(aggCandles, lookback);
    QVariantList filteredLevels = m_levelDetector.filterCloseLevels(levels, gap);
    QVariantList breakCandlesRaw = m_agg->aggregate(m_candles, breaktf);

    const QVector<Candle> aggData   = CandleUtils::toStructArray(aggCandles);
    const QVector<Candle> breakData = CandleUtils::toStructArray(breakCandlesRaw);

    double averageTrueRange = ATR(aggData);

    for (QVariant &v : filteredLevels) {
        QVariantMap level = v.toMap();
        QVariantMap map   = m_agg->indexAggregate(level["idx"].toInt(), leveltf, breaktf);

        int levelIndex     = map["index"].toInt();
        int newCandleCount = candleCount * map["ratio"].toInt();
        int searchSize     = qMin(levelIndex + newCandleCount, breakData.size());

        const double levelPrice  = level["price"].toDouble();
        const bool isResistance  = level["isResistance"].toBool();
        const double breakTarget = isResistance
                                       ? levelPrice + threshold * averageTrueRange
                                       : levelPrice - threshold * averageTrueRange;

        for (int i = levelIndex + 10; i < searchSize; i++) {
            const double close = breakData[i].close;   // direct struct access
            if ((isResistance && close > breakTarget) ||
                (!isResistance && close < breakTarget))
            {
                level["breakIndex"]     = i;
                level["breakTime"]      = breakData[i].time.toMSecsSinceEpoch();
                level["breakThreshold"] = threshold;
                break;
            }
        }

        if (level["breakIndex"] != -1) {
            Position pos;
            pos.EntryPointPrice = breakData[level["breakIndex"].toInt()].close;
            pos.EntryIdx        = level["breakIndex"].toInt();
            pos.Timeframe       = m_agg->timeframeToString(breaktf);
            pos.isBullish       = isResistance;
            pos.LevelIdx        = level["idx"].toInt();
            pos.LevelPrice      = levelPrice;
            m_positionList.append(pos);
            m_levels.append(level);
        }
    }
    m_pos->setPositions(m_positionList);
}

void EntryPointCalculator::runEntryPoint(TimeframeAggregator::Timeframe leveltf,
                                         TimeframeAggregator::Timeframe breaktf,
                                         int candleCountForBreak,
                                         int entryLookback,
                                         double entryThreshold,
                                         double levelFilterGap,
                                         int stopLookback,
                                         int takeProfitLookback,
                                         int candleCountForTP)
{
    if(m_strategy == LevelBreak){
        HorizantalLevelBreak(leveltf, breaktf, candleCountForBreak, entryLookback, entryThreshold, levelFilterGap);
        emit entryPointReady(stopLookback, takeProfitLookback, candleCountForTP, leveltf, breaktf);
    }
}
