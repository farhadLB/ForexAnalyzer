#include "StopLossCalculator.h"

StopLossCalculator::StopLossCalculator(CsvLoader *loader,
                                       PositionManager *pos,
                                       TimeframeAggregator *agg,
                                       EntryPointCalculator *entry,
                                       QObject *parent)
    : QObject(parent), m_loader(loader), m_pos(pos), m_agg(agg), m_entry(entry) {
}

void StopLossCalculator::firstPivot(int backdrop,
                                    TimeframeAggregator::Timeframe leveltf,
                                    TimeframeAggregator::Timeframe breaktf)
{
    m_positionList          = m_pos->getPositions();
    m_candles               = m_loader->getCandles();
    m_levels                = m_entry->getLevels();
    double stopLossPrice    = 0;
    QVariantList aggCandles;

    if(leveltf != TimeframeAggregator::M1){
        aggCandles = m_agg->aggregate(m_candles, leveltf);
    }
    else{
        aggCandles = m_candles;
    }

    for(int i=0; i<m_levels.size(); i++){
        QVariantMap level       = m_levels[i].toMap();
        int  firstIdx           = level["idx"].toInt();
        int  lastIdxRaw         = level["breakIndex"].toInt();
        QVariantMap  map        = m_agg->indexAggregate(lastIdxRaw, breaktf, leveltf);
        int  lastIdx            = map["index"].toInt();
        bool isResistance       = level["isResistance"].toBool();
        double breakThreshold   = level["breakThreshold"].toDouble();
        QVariantList subCandles = aggCandles.mid(firstIdx, lastIdx-firstIdx);
        QVariantList SLlevels   = levelDetector.detectLocalLevels(subCandles, backdrop);
        if(!SLlevels.isEmpty()){
            if(isResistance){
                double high = SLlevels[0].toMap()["price"].toDouble();
                // if(!SLlevels[0].toMap()["isResistance"].toBool()){
                //     if(aggCandles[lastIdx].toMap()["close"].toDouble() - high > breakThreshold){
                //         stopLossPrice = SLlevels[0].toMap()["price"].toDouble();
                //     }
                // }
                for(int j = 0; j<SLlevels.size(); j++){
                    // if(!SLlevels[j].toMap()["isResistance"].toBool()){
                        double candidate = SLlevels[j].toMap()["price"].toDouble();
                        if(candidate > high && aggCandles[lastIdx].toMap()["close"].toDouble() - candidate > breakThreshold){
                            high = candidate;
                            stopLossPrice = candidate;
                        }
                    // }
                }
            }
            else{
                double low = SLlevels[0].toMap()["price"].toDouble();
                // if(SLlevels[0].toMap()["isResistance"].toBool()){
                //     if(low - aggCandles[lastIdx].toMap()["close"].toDouble() > breakThreshold){
                //         stopLossPrice = SLlevels[0].toMap()["price"].toDouble();
                //     }
                // }
                for(int j = 0; j<SLlevels.size(); j++){
                    // if(SLlevels[j].toMap()["isResistance"].toBool()){
                        if(SLlevels[j].toMap()["price"].toDouble() < low && low - aggCandles[lastIdx].toMap()["close"].toDouble() > breakThreshold){
                            low = SLlevels[j].toMap()["price"].toDouble();
                            stopLossPrice = SLlevels[j].toMap()["price"].toDouble();
                        }
                    // }
                }
            }
            m_positionList[i].StopLossPrice = stopLossPrice;
            stopLossPrice = 0;
        }

        else{
            m_positionList[i].StopLossPrice = 0;
        }
    }

    m_pos->setPositions(m_positionList);
}

void StopLossCalculator::runStopLoss(int stopLookback,
                                     int takeProfitLookback,
                                     int candleCountForTP,
                                     TimeframeAggregator::Timeframe takeProfitTF,
                                     TimeframeAggregator::Timeframe breakTF)
{
    firstPivot(stopLookback, takeProfitTF, breakTF);
    emit stopLossReady(takeProfitLookback, candleCountForTP, takeProfitTF, breakTF);
}
