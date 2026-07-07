#include "StopLossCalculator.h"

StopLossCalculator::StopLossCalculator(CandleModel *model,
                                       CsvLoader *loader,
                                       PositionManager *pos,
                                       TimeframeAggregator *agg,
                                       EntryPointCalculator *entry,
                                       QObject *parent)
    : QObject(parent), m_model(model), m_loader(loader), m_pos(pos), m_agg(agg), m_entry(entry) {
}

void StopLossCalculator::firstPivot(int backdrop,
                                    TimeframeAggregator::Timeframe leveltf,
                                    TimeframeAggregator::Timeframe breaktf)
{
    m_positionList = m_pos->getPositions();
    m_candles      = m_model->candles();
    m_levels       = m_entry->getLevels();

    QVariantList aggCandlesRaw = (leveltf != TimeframeAggregator::M1)
                                     ? m_agg->aggregate(m_candles, leveltf)
                                     : m_candles;

    const QVector<Candle> aggData = CandleUtils::toStructArray(aggCandlesRaw);

    for (int i = 0; i < m_levels.size(); i++) {
        QVariantMap level = m_levels[i].toMap();

        int  firstIdx       = level["idx"].toInt();
        int  lastIdxRaw     = level["breakIndex"].toInt();
        QVariantMap map     = m_agg->indexAggregate(lastIdxRaw, breaktf, leveltf);
        int  lastIdx        = map["index"].toInt();
        bool isResistance   = level["isResistance"].toBool();
        double breakThresh  = level["breakThreshold"].toDouble();
        double entryPrice   = m_positionList[i].EntryPointPrice;
        double pivotATR     = m_positionList[i].ATR;

        // bounds check
        if (firstIdx < 0 || lastIdx <= firstIdx || lastIdx >= aggData.size()) {
            m_positionList[i].StopLossPrice = 0;
            continue;
        }

        QVariantList subCandles = aggCandlesRaw.mid(firstIdx, lastIdx - firstIdx);
        QVariantList SLlevels   = levelDetector.detectLocalLevels(subCandles, backdrop);

        if (SLlevels.isEmpty()) {
            m_positionList[i].StopLossPrice = 0;
            continue;
        }

        const double closeAtBreak = aggData[lastIdx].close;
        double stopLossPrice = 0;

        if (isResistance) {
            double best = -1e20;
            for (const QVariant &sv : SLlevels) {
                const QVariantMap sm = sv.toMap();
                const double candidate = sm["price"].toDouble();
                if (candidate > best && closeAtBreak - candidate > pivotATR && candidate < entryPrice) {
                    best = candidate;
                    stopLossPrice = candidate;
                }
            }
        } else {
            double best = 1e20;
            for (const QVariant &sv : SLlevels) {
                const QVariantMap sm = sv.toMap();
                const double candidate = sm["price"].toDouble();
                if (candidate < best && candidate - closeAtBreak > pivotATR && candidate > entryPrice) {
                    best = candidate;
                    stopLossPrice = candidate;
                }
            }
        }

        m_positionList[i].StopLossPrice = stopLossPrice;
    }

    m_pos->setPositions(m_positionList);
}

void StopLossCalculator::runStopLoss(int stopLookback,
                                     int takeProfitLookback,
                                     int candleCountForTP,
                                     TimeframeAggregator::Timeframe takeProfitTF,
                                     TimeframeAggregator::Timeframe breakTF,
                                     double rewradToRisk)
{
    firstPivot(stopLookback, takeProfitTF, breakTF);
    emit stopLossReady(takeProfitLookback, candleCountForTP, takeProfitTF, breakTF, rewradToRisk);
}
