#include "TakeProfitCalculator.h"


TakeProfitCalculator::TakeProfitCalculator(CsvLoader *loader,
                                           PositionManager *pos,
                                           TimeframeAggregator *agg,
                                           EntryPointCalculator *entry,
                                           QObject *parent)
    : QObject(parent), m_loader(loader), m_pos(pos), m_agg(agg), m_entry(entry) {
}

void TakeProfitCalculator::firstPivot(int backdrop, int candleCount, QString timeframe)
{
    m_candles               = m_loader->getCandles();
    m_levels                = m_entry->getLevels();
    m_positionList          = m_pos->getPositions();
    int tf                  = m_agg->getTimeframe(timeframe);
    double takeProfitPrice  = 0;
    QVariantList aggCandles;
    int firstIdx            = 0;

    TimeframeAggregator::Timeframe positionTf = static_cast<TimeframeAggregator::Timeframe>(tf);
    if(positionTf != TimeframeAggregator::M1){
        aggCandles = m_agg->aggregate(m_candles, positionTf);
    }
    else{
        aggCandles = m_candles;
    }

    for(int i=0; i<m_levels.size(); i++){
        QVariantMap level = m_levels[i].toMap();
        takeProfitPrice = 0;

        if(level["idx"].toInt() - candleCount > 0){
            firstIdx = level["idx"].toInt() - candleCount;
        }
        else{
            firstIdx = 0;
        }

        int  lastIdx      = level["idx"].toInt();
        bool isResistance = level["isResistance"].toBool();
        QVariantList subCandles = aggCandles.mid(firstIdx, lastIdx-firstIdx);
        QVariantList TPlevels   = levelDetector.detectLocalLevels(subCandles, backdrop);
        // if(!TPlevels.isEmpty()){
        //     if(isResistance){
        //         // double high = TPlevels[0].toMap()["price"].toDouble();
        //         double high = level["price"].toDouble();
        //         for(int j = 1; j<TPlevels.size(); j++){
        //             if(TPlevels[j].toMap()["price"].toDouble() > high){
        //                 high = TPlevels[j].toMap()["price"].toDouble();
        //                 takeProfitPrice = TPlevels[j].toMap()["price"].toDouble();
        //             }
        //         }
        //     }
        //     else{
        //         // double low = TPlevels[0].toMap()["price"].toDouble();
        //         double low = level["price"].toDouble();
        //         for(int j = 1; j<TPlevels.size(); j++){
        //             if(TPlevels[j].toMap()["price"].toDouble() < low){
        //                 low = TPlevels[j].toMap()["price"].toDouble();
        //                 takeProfitPrice = TPlevels[j].toMap()["price"].toDouble();
        //             }
        //         }
        //     }
        // }
        // else{
        //     double risk = std::abs(m_positionList[i].StopLossPrice - m_positionList[i].EntryPointPrice);
        //     if(m_positionList[i].isBullish)
        //         takeProfitPrice = m_positionList[i].EntryPointPrice + risk;
        //     else
        //         takeProfitPrice = m_positionList[i].EntryPointPrice - risk;
        // }
        double risk = std::abs(m_positionList[i].StopLossPrice - m_positionList[i].EntryPointPrice);
        if(m_positionList[i].isBullish)
            takeProfitPrice = m_positionList[i].EntryPointPrice + risk;
        else
            takeProfitPrice = m_positionList[i].EntryPointPrice - risk;
        m_positionList[i].TakeProfitPrice = takeProfitPrice;
    }
    m_pos->setPositions(m_positionList);
    emit takeProfitReady();
}

void TakeProfitCalculator::runTakeProfit()
{
    firstPivot(10, 800, "1m");
}
