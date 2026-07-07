#include "TakeProfitCalculator.h"


TakeProfitCalculator::TakeProfitCalculator(CandleModel *model,
                                           CsvLoader *loader,
                                           PositionManager *pos,
                                           TimeframeAggregator *agg,
                                           EntryPointCalculator *entry,
                                           QObject *parent)
    : QObject(parent), m_model(model), m_loader(loader), m_pos(pos), m_agg(agg), m_entry(entry) {
}

void TakeProfitCalculator::firstPivot(int backdrop,
                                      int candleCount,
                                      TimeframeAggregator::Timeframe leveltf,
                                      TimeframeAggregator::Timeframe breaktf,
                                      double rewradToRisk)
{
    m_candles               = m_model->candles();
    m_levels                = m_entry->getLevels();
    m_positionList          = m_pos->getPositions();
    double takeProfitPrice  = 0;
    QVariantList aggCandles;
    int firstIdx            = 0;

    if(leveltf != TimeframeAggregator::M1){
        aggCandles = m_agg->aggregate(m_candles, leveltf);
    }
    else{
        aggCandles = m_candles;
    }

    const QVector<Candle> aggData   = CandleUtils::toStructArray(aggCandles);

    for(int i=0; i<m_levels.size(); i++){
        QVariantMap level = m_levels[i].toMap();
        takeProfitPrice = 0;
        double risk = std::abs(m_positionList[i].StopLossPrice - m_positionList[i].EntryPointPrice) * rewradToRisk ;
        m_positionList[i].TakeProfitPrice = 0;

        if(level["idx"].toInt() - candleCount > 0){
            firstIdx = level["idx"].toInt() - candleCount;
        }
        else{
            firstIdx = 0;
        }

        int  lastIdx      = level["idx"].toInt();
        bool isResistance = level["isResistance"].toBool();
        int  levelBreakIdx= level["breakIndex"].toInt();
        QVariantMap map   = m_agg->indexAggregate(levelBreakIdx, breaktf, leveltf);
        QVariantList subCandles = aggCandles.mid(firstIdx, lastIdx-firstIdx);
        QVariantList TPlevels   = levelDetector.detectLocalLevels(subCandles, backdrop);
        if(!TPlevels.isEmpty()){
            if(isResistance){
                double high = aggData[map["index"].toInt()].close;
                for(int j = 0; j<TPlevels.size(); j++){
                    if(TPlevels[j].toMap()["price"].toDouble() > high && TPlevels[j].toMap()["price"].toDouble() - m_positionList[i].EntryPointPrice >= risk){
                        high = TPlevels[j].toMap()["price"].toDouble();
                        takeProfitPrice = TPlevels[j].toMap()["price"].toDouble();
                        m_positionList[i].TakeProfitPrice = takeProfitPrice;
                    }
                    else{
                        takeProfitPrice = m_positionList[i].EntryPointPrice + risk;
                        m_positionList[i].TakeProfitPrice = takeProfitPrice;
                    }
                }
            }
            else{
                double low = aggData[map["index"].toInt()].close;
                for(int j = 0; j<TPlevels.size(); j++){
                    if(TPlevels[j].toMap()["price"].toDouble() < low  &&  m_positionList[i].EntryPointPrice - TPlevels[j].toMap()["price"].toDouble() >= risk){
                        low = TPlevels[j].toMap()["price"].toDouble();
                        takeProfitPrice = TPlevels[j].toMap()["price"].toDouble();
                        m_positionList[i].TakeProfitPrice = takeProfitPrice;
                    }
                    else{
                        takeProfitPrice = m_positionList[i].EntryPointPrice - risk;
                        m_positionList[i].TakeProfitPrice = takeProfitPrice;
                    }
                }
            }
        }
        else if(TPlevels.isEmpty() || takeProfitPrice == 0){
            if(m_positionList[i].StopLossPrice != 0){
                if(m_positionList[i].isBullish){
                    takeProfitPrice = m_positionList[i].EntryPointPrice + risk;
                    m_positionList[i].TakeProfitPrice = takeProfitPrice;
                }
                else{
                    takeProfitPrice = m_positionList[i].EntryPointPrice - risk;
                    m_positionList[i].TakeProfitPrice = takeProfitPrice;
                }
            }
        }
    }
    m_pos->setPositions(m_positionList);
}

void TakeProfitCalculator::runTakeProfit(int takeProfitLookback,
                                         int candleCountForTP,
                                         TimeframeAggregator::Timeframe leveltf,
                                         TimeframeAggregator::Timeframe breaktf,
                                         double rewradToRisk)
{
    firstPivot(takeProfitLookback, candleCountForTP, leveltf, breaktf, rewradToRisk);
    emit takeProfitReady(leveltf);
}
