#include <ChartObjectModel.h>
#include <QDebug>

ChartObjectModel::ChartObjectModel(QObject *parent)
    : QObject(parent)
{
}

// --- Manual objects ---
void ChartObjectModel::addTrendline(qint64 sTime,double sPrice,
                                    qint64 eTime,double ePrice)
{
    Trendline t;
    t.startTime  = sTime;
    t.endTime    = eTime;
    t.startPrice = sPrice;
    t.endPrice   = ePrice;

    m_manualTrendlines.append(t);
    emit objectsChanged();
}

void ChartObjectModel::addHorizontalLevel(double price)
{
    HorizontalLevel l;
    l.price = price;
    m_manualLevels.append(l);
    emit objectsChanged();
}

// --- Auto objects ---
void ChartObjectModel::clearAutoLevels()
{
    m_autoLevels.clear();
    emit objectsChanged();
}

void ChartObjectModel::clearAutoTrendlines() {
    m_autoTrendlines.clear();
    emit objectsChanged();
}

void ChartObjectModel::setAutoLevels(const QVariantList &levels)
{
    m_autoLevels.clear();
    for (const QVariant &l : levels) {
        QVariantMap m = l.toMap();
        HorizontalLevel h;
        h.price        = m["price"].toDouble();
        h.isResistance = m["isResistance"].toBool();
        h.idx          = m["idx"].toInt();
        h.breakIndex   = m["breakIndex"].toInt();
        h.breakTime    = m["breakTime"].toLongLong();
        m_autoLevels.append(h);
    }
    emit objectsChanged();
}

void ChartObjectModel::setAutoTrendlines(const QVariantList &lines, const int start) {
    for(const QVariant &l : lines){
        QVariantMap m = l.toMap();
        Trendline t;
        t.startTime  = m["startTime"].toLongLong();
        t.endTime    = m["endTime"].toLongLong();
        t.startPrice = m["startPrice"].toDouble();
        t.endPrice   = m["endPrice"].toDouble();
        t.timeframe  = m["timeframe"].toString();
        m_autoTrendlines.append(t);
    }
    emit objectsChanged();
}


QVariantList ChartObjectModel::allTrendlines() const
{
    QVariantList list;
    for (const auto &t : m_manualTrendlines) {
        QVariantMap m;
        m["startTime"] = t.startTime;
        m["endTime"]   = t.endTime;
        m["startPrice"] = t.startPrice;
        m["endPrice"]   = t.endPrice;
        m["timeframe"]   = t.timeframe;
        list.append(m);
    }
    for (const auto &t : m_autoTrendlines) {
        QVariantMap m;
        m["startTime"] = t.startTime;
        m["endTime"]   = t.endTime;
        m["startPrice"] = t.startPrice;
        m["endPrice"]   = t.endPrice;
        m["timeframe"]   = t.timeframe;
        list.append(m);
    }
    return list;
}


QVariantList ChartObjectModel::allLevels() const
{
    QVariantList list;
    // Manual
    for (const auto &l : m_manualLevels) {
        QVariantMap m;
        m["price"]        = l.price;
        m["isResistance"] = l.isResistance;
        m["idx"]          = l.idx;
        m["breakIndex"]   = l.breakIndex;
        m["breakTime"]    = l.breakTime;
        list.append(m);
    }
    // Auto
    for (const auto &l : m_autoLevels) {
        QVariantMap m;
        m["price"]        = l.price;
        m["isResistance"] = l.isResistance;
        m["idx"]          = l.idx;
        m["breakIndex"]   = l.breakIndex;
        m["breakTime"]    = l.breakTime;
        list.append(m);
    }
    return list;
}

QVariantList ChartObjectModel::positions()
{

    QVariantList list;
    for(const auto &p : std::as_const(m_positionList)) {
        QVariantMap m;
        m["EntryPointPrice"]    = p.EntryPointPrice;
        m["StopLossPrice"]      = p.StopLossPrice;
        m["TakeProfitPrice"]    = p.TakeProfitPrice;
        m["EntryIdx"]           = p.EntryIdx;
        m["EndIdx"]             = p.EndIdx;
        m["LevelIdx"]           = p.LevelIdx;
        m["Timeframe"]          = p.Timeframe;
        m["isBullish"]          = p.isBullish;
        m["isWin"]              = p.isWin;
        m["RewardToRisk"]       = p.RewardToRisk;
        m["outcome"]            = p.outcome;
        m["LevelPrice"]         = p.LevelPrice;
        m["ATR"]                = p.ATR;
        list.append(m);
    }
    return list;
}

void ChartObjectModel::getPositions(QList<Position> newList)
{
    m_positionList = newList;
}
