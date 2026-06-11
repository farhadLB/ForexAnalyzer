#include "StopLossCalculator.h"

StopLossCalculator::StopLossCalculator(CsvLoader *loader,
                                       PositionManager *pos,
                                       TimeframeAggregator *agg,
                                       EntryPointCalculator *entry,
                                       QObject *parent)
    : QObject(parent), m_loader(loader), m_pos(pos), m_agg(agg), m_entry(entry) {
}

void StopLossCalculator::firstPivot(int backdrop)
{
    m_positionList          = m_pos->getPositions();
    m_candles               = m_loader->getCandles();
    m_levels                = m_entry->getLevels();
    // QString strTimeframe    = m_positionList[0].Timeframe;
    QString strTimeframe    = "1m";
    int tf                  = m_agg->getTimeframe(strTimeframe);
    double stopLossPrice    = 0;
    QVariantList aggCandles;

    TimeframeAggregator::Timeframe positionTf = static_cast<TimeframeAggregator::Timeframe>(tf);
    if(positionTf != TimeframeAggregator::M1){
        aggCandles = m_agg->aggregate(m_candles, positionTf);
    }
    else{
        aggCandles = m_candles;
    }

    for(int i=0; i<m_levels.size(); i++){
        QVariantMap level = m_levels[i].toMap();
        int  firstIdx     = level["idx"].toInt();
        int  lastIdx      = level["breakIndex"].toInt();
        bool isResistance = level["isResistance"].toBool();
        QVariantList subCandles = aggCandles.mid(firstIdx, lastIdx-firstIdx);
        QVariantList SLlevels   = levelDetector.detectLocalLevels(subCandles, backdrop);
        if(isResistance){
            double high = SLlevels[0].toMap()["price"].toDouble();
            for(int i = 1; i<SLlevels.size(); i++){
                if(SLlevels[i].toMap()["price"].toDouble() > high){
                    high = SLlevels[i].toMap()["price"].toDouble();
                    stopLossPrice = SLlevels[i].toMap()["price"].toDouble();
                }
            }
        }
        else{
            double low = SLlevels[0].toMap()["price"].toDouble();
            for(int i = 1; i<SLlevels.size(); i++){
                if(SLlevels[i].toMap()["price"].toDouble() < low){
                    low = SLlevels[i].toMap()["price"].toDouble();
                    stopLossPrice = SLlevels[i].toMap()["price"].toDouble();
                }
            }
        }
        m_positionList[i].StopLossPrice = stopLossPrice;
    }
    m_pos->setPositions(m_positionList);
    emit stopLossReady();
}

void StopLossCalculator::runStopLoss()
{
    firstPivot(4);
}
