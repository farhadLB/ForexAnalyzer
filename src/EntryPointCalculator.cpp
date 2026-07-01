#include "EntryPointCalculator.h"
#include <deque>

EntryPointCalculator::EntryPointCalculator(CsvLoader *loader,
                                           PositionManager *pos,
                                           TimeframeAggregator *agg,
                                           int strategy,
                                           QObject *parent): QObject(parent), m_loader(loader), m_pos(pos), m_agg(agg), m_strategy(strategy){}

QVariantList EntryPointCalculator::getLevels()
{
    return m_levels;
}

// --- calculate the length of pivot to use as Average True Range ---
double EntryPointCalculator::PivotATR(QVector<Candle>* candles, const int start, const int end)
{
    if (start >= end)
        return 0.0;

    double maximum = -1e20;
    double minimum =  1e20;
    for (int i = start; i < end; ++i) {
        if ((*candles)[i].low < minimum)
            minimum = (*candles)[i].low;
        if ((*candles)[i].high > maximum)
            maximum = (*candles)[i].high;
    }
    return maximum - minimum;
}

void EntryPointCalculator::HorizantalLevelBreak(TimeframeAggregator::Timeframe leveltf,
                                                TimeframeAggregator::Timeframe breaktf,
                                                int candleCount,
                                                int lookback,
                                                double threshold,
                                                double gap
                                                )
{
    m_positionList.clear();
    m_levels.clear();
    m_candles = m_loader->getCandles();

    QVariantList aggCandles      = m_agg->aggregate(m_candles, leveltf);
    QVariantList levels          = m_levelDetector.detectLocalLevels(aggCandles, lookback);
    qDebug() << levels.size() << "levels found";
    QVariantList filteredLevels  = m_levelDetector.filterCloseLevels(levels, gap);
    qDebug() << filteredLevels.size() << "filtered levels found";
    QVariantList breakCandlesRaw = m_agg->aggregate(m_candles, breaktf);

    QVector<Candle> breakData     = CandleUtils::toStructArray(breakCandlesRaw);

    const int n          = breakData.size();
    const int windowSize = 10;

    // Precompute sliding window max high and min low
    QVector<double> pivotATRCache(n, 0.0);
    std::deque<int> maxDeque, minDeque;

    for (int i = 0; i < n; i++) {
        while (!maxDeque.empty() && maxDeque.front() < i - windowSize)
            maxDeque.pop_front();
        while (!minDeque.empty() && minDeque.front() < i - windowSize)
            minDeque.pop_front();

        while (!maxDeque.empty() && breakData[maxDeque.back()].high <= breakData[i].high)
            maxDeque.pop_back();
        maxDeque.push_back(i);

        while (!minDeque.empty() && breakData[minDeque.back()].low >= breakData[i].low)
            minDeque.pop_back();
        minDeque.push_back(i);

        if (i >= windowSize - 1)
            pivotATRCache[i] = breakData[maxDeque.front()].high - breakData[minDeque.front()].low;
    }

    TrendCalculator::TrendSeries trend = m_trendCalc.compute(breakData);

    for (QVariant &v : filteredLevels) {
        QVariantMap level = v.toMap();
        QVariantMap map   = m_agg->indexAggregate(level["idx"].toInt(), leveltf, breaktf);

        int levelIndex     = map["index"].toInt();
        int newCandleCount = candleCount * map["ratio"].toInt();
        int searchSize     = qMin(levelIndex + newCandleCount, n);

        const double levelPrice = level["price"].toDouble();
        const bool isResistance = level["isResistance"].toBool();

        for (int i = levelIndex + 10; i < searchSize; i++) {
            const double close      = breakData[i].close;
            int cacheIdx            = qMin(i + windowSize, n) - 1;
            double pivotTrueRange   = pivotATRCache[cacheIdx];
            const double breakTarget = isResistance
                                           ? levelPrice + threshold * pivotTrueRange
                                           : levelPrice - threshold * pivotTrueRange;
            if ((isResistance && close > breakTarget) ||
                (!isResistance && close < breakTarget))
            {
                level["breakIndex"]     = i;
                level["breakTime"]      = breakData[i].time.toMSecsSinceEpoch();
                level["breakThreshold"] = threshold;
                level["ATR"]            = pivotTrueRange;
                bool trendReady = i >= trend.warmupBars;
                level["ADX"]            = trendReady ? trend.adx[i] : -1.0;
                level["plusDI"]         = trendReady ? trend.plusDI[i] : 0.0;
                level["minusDI"]        = trendReady ? trend.minusDI[i] : 0.0;
                level["trendAligned"]   = trendReady
                    ? (isResistance ? (trend.plusDI[i] > trend.minusDI[i])
                                    : (trend.minusDI[i] > trend.plusDI[i]))
                    : QVariant();
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
            pos.time            = level["breakTime"].toLongLong();
            pos.ATR             = level["ATR"].toDouble();
            pos.ADX             = level["ADX"].toDouble();
            pos.PlusDI          = level["plusDI"].toDouble();
            pos.MinusDI         = level["minusDI"].toDouble();
            pos.TrendAligned    = level["trendAligned"].toBool();
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
                                         int candleCountForTP,
                                         double rewradToRisk)
{
    if(m_strategy == LevelBreak){
        HorizantalLevelBreak(leveltf, breaktf, candleCountForBreak, entryLookback, entryThreshold, levelFilterGap);
        emit entryPointReady(stopLookback, takeProfitLookback, candleCountForTP, leveltf, breaktf, rewradToRisk);
    }
}
