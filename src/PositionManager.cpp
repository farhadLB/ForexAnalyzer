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

QVariantList PositionManager::getPositionsForQML()
{
    QVariantList list;
    for(const Position &pos: std::as_const(positionList)){
        QVariantMap m;
        m["yValue"] = pos.outcome;
        list.append(m);
    }
    return list;
}

void PositionManager::startCalculation()
{
    TimeframeAggregator::Timeframe newleveltf = m_agg->getEnumTimeframe(m_leveltf);
    TimeframeAggregator::Timeframe newbreaktf = m_agg->getEnumTimeframe(m_breaktf);
    emit initialValues(newleveltf,
                       newbreaktf,
                       m_candleCountForBreak,
                       m_entryLookback,
                       m_entryThreshold,
                       m_levelFilterGap,
                       m_stopLookback,
                       m_takeProfitLookback,
                       m_candleCountForTP,
                       m_takeProfitTF
                       );
}

QVariantMap PositionManager::positionsInfo()
{
    int total               = positionList.size();
    int successfulPosCnt    = 0;
    double riskToRewardSum  = 0;
    int strategyGain        = 0;

    for(int i=0; i<positionList.size(); i++){

        if(positionList[i].isWin){
            successfulPosCnt++;
        }
        riskToRewardSum += std::abs(positionList[i].RewardToRisk);
        strategyGain    += positionList[i].outcome;
    }

    QVariantMap m;
    m["totalPositions"]         = total;
    m["successfulPositions"]    = successfulPosCnt;
    m["failedPositions"]        = total - successfulPosCnt;
    m["winRate"]                = successfulPosCnt * 100 / total;
    m["averageRtoR"]            = riskToRewardSum / total;
    m["strategyGain"]           = strategyGain;

    return m;
}

void PositionManager::removeStopNA(QList<Position> *positions)
{
    positions->removeIf([] (const Position &pos){
        return pos.StopLossPrice == 0;
    });
}

void PositionManager::removeSameEntries(QList<Position> *positions)
{
    const QList<Position> snapshot = *positions;
    for(const Position &p : snapshot){
        double entryPrice   = p.EntryPointPrice;
        double levelPrice   = p.LevelPrice;
        bool   isBullish    = p.isBullish;

        if(isBullish){
            positions->removeIf([entryPrice, levelPrice] (const Position &pos){
                return pos.EntryPointPrice == entryPrice && pos.LevelPrice <levelPrice;
            });
        }
        else{
            positions->removeIf([entryPrice, levelPrice] (const Position &pos){
                return pos.EntryPointPrice == entryPrice && pos.LevelPrice > levelPrice;
            });
        }
    }
}

void PositionManager::run(TimeframeAggregator::Timeframe timeframe)
{
    m_candles           = m_loader->getCandles();
    QVariantList        aggCandles;

    if(timeframe != TimeframeAggregator::M1){
        aggCandles = m_agg->aggregate(m_candles, timeframe);
    }
    else{
        aggCandles = m_candles;
    }
    for(Position &pos: positionList){
        int i = pos.EntryIdx + 1;
        bool closed = false;

        for(; i<aggCandles.size() - 1; i++){
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

        if(pos.StopLossPrice != pos.EntryPointPrice){
            pos.RewardToRisk = std::abs(pos.TakeProfitPrice - pos.EntryPointPrice) / std::abs(pos.StopLossPrice - pos.EntryPointPrice);
        }
        else{
            pos.RewardToRisk = 0;
        }
        if(pos.isWin){
            pos.outcome = pos.RewardToRisk;
        }
        else{
            pos.outcome = -1;
        }
    }
    removeStopNA(&positionList);
    removeSameEntries(&positionList);
    emit positionListReady(positionList);
}

double PositionManager::levelFilterGap() const
{
    return m_levelFilterGap;
}

void PositionManager::setLevelFilterGap(double newLevelFilterGap)
{
    if (qFuzzyCompare(m_levelFilterGap, newLevelFilterGap))
        return;
    m_levelFilterGap = newLevelFilterGap;
    emit levelFilterGapChanged();
}

QString PositionManager::takeProfitTF() const
{
    return m_takeProfitTF;
}

void PositionManager::setTakeProfitTF(const QString &newTakeProfitTF)
{
    if (m_takeProfitTF == newTakeProfitTF)
        return;
    m_takeProfitTF = newTakeProfitTF;
    emit takeProfitTFChanged();
}

int PositionManager::candleCountForTP() const
{
    return m_candleCountForTP;
}

void PositionManager::setCandleCountForTP(int newCandleCountForTP)
{
    if (m_candleCountForTP == newCandleCountForTP)
        return;
    m_candleCountForTP = newCandleCountForTP;
    emit candleCountForTPChanged();
}

int PositionManager::takeProfitLookback() const
{
    return m_takeProfitLookback;
}

void PositionManager::setTakeProfitLookback(int newTakeProfitLookback)
{
    if (m_takeProfitLookback == newTakeProfitLookback)
        return;
    m_takeProfitLookback = newTakeProfitLookback;
    emit takeProfitLookbackChanged();
}

int PositionManager::stopLookback() const
{
    return m_stopLookback;
}

void PositionManager::setStopLookback(int newStopLookback)
{
    if (m_stopLookback == newStopLookback)
        return;
    m_stopLookback = newStopLookback;
    emit stopLookbackChanged();
}

double PositionManager::entryThreshold() const
{
    return m_entryThreshold;
}

void PositionManager::setEntryThreshold(double newEntryThreshold)
{
    if (qFuzzyCompare(m_entryThreshold, newEntryThreshold))
        return;
    m_entryThreshold = newEntryThreshold;
    emit entryThresholdChanged();
}

int PositionManager::entryLookback() const
{
    return m_entryLookback;
}

void PositionManager::setEntryLookback(int newEntryLookback)
{
    if (m_entryLookback == newEntryLookback)
        return;
    m_entryLookback = newEntryLookback;
    emit entryLookbackChanged();
}

int PositionManager::candleCountForBreak() const
{
    return m_candleCountForBreak;
}

void PositionManager::setcandleCountForBreak(int newcandleCountForBreak)
{
    if (m_candleCountForBreak == newcandleCountForBreak)
        return;
    m_candleCountForBreak = newcandleCountForBreak;
    emit candleCountForBreakChanged();
}

QString PositionManager::breaktf() const
{
    return m_breaktf;
}

void PositionManager::setBreaktf(const QString &newBreaktf)
{
    if (m_breaktf == newBreaktf)
        return;
    m_breaktf = newBreaktf;
    emit breaktfChanged();
}

QString PositionManager::leveltf() const
{
    return m_leveltf;
}

void PositionManager::setLeveltf(const QString &newLeveltf)
{
    if (m_leveltf == newLeveltf)
        return;
    m_leveltf = newLeveltf;
    emit leveltfChanged();
}
