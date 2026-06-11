#include "PositionManager.h"

PositionManager::PositionManager(CsvLoader *loader,
                                 TimeframeAggregator *agg,
                                 QObject *parent): m_loader(loader), m_agg(agg), QObject(parent) {
}

void PositionManager::setPositions(QList<Position> newList)
{
    positionList = newList;
}

QList<Position> PositionManager::getPositions()
{
    return positionList;
}

void PositionManager::run()
{
    m_candles           = m_loader->getCandles();
    // QString timeframe   = positionList[0].Timeframe;
    QString timeframe   = "1m";
    int tf              = m_agg->getTimeframe(timeframe);
    QVariantList        aggCandles;

    TimeframeAggregator::Timeframe positionTf = static_cast<TimeframeAggregator::Timeframe>(tf);
    if(positionTf != TimeframeAggregator::M1){
        aggCandles = m_agg->aggregate(m_candles, positionTf);
    }
    else{
        aggCandles = m_candles;
    }
    for(Position &pos: positionList){
        int i = pos.EntryIdx;
        bool closed = false;

        for(; i<aggCandles.size(); i++){
            if(pos.isBullish){
                if(aggCandles[i].toMap()["high"].toDouble() >= pos.TakeProfitPrice){
                    pos.isWin = true;
                    pos.EndIdx = i;
                    closed = true;
                    break;
                }
                else if(aggCandles[i].toMap()["low"].toDouble() <= pos.StopLossPrice){
                    pos.isWin = false;
                    pos.EndIdx = i;
                    closed = true;
                    break;
                }
            }
            else{
                if(aggCandles[i].toMap()["low"].toDouble() <= pos.TakeProfitPrice){
                    pos.isWin = true;
                    pos.EndIdx = i;
                    closed = true;
                    break;
                }
                else if(aggCandles[i].toMap()["high"].toDouble() >= pos.StopLossPrice){
                    pos.isWin = false;
                    pos.EndIdx = i;
                    closed = true;
                    break;
                }
            }
        }
        if(!closed){
            pos.EndIdx = aggCandles.size() - 1;
            pos.isWin  = false;
        }
    }
    emit positionListReady(positionList);
}
