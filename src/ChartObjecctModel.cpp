#include <include/ChartObjecctModel.h>
#include <QDebug>

// ---------------- Constructor ----------------
ChartObjectModel::ChartObjectModel(QObject *parent)
    : QObject(parent)
{
}

// ---------------- Manual objects ----------------
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

// ---------------- Auto objects ----------------
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
        h.price = m["price"].toDouble();
        m_autoLevels.append(h);
    }
    emit objectsChanged();
}

void ChartObjectModel::setAutoTrendlines(const QVariantList &lines, const int start) {
    m_autoTrendlines.clear();
    for(const QVariant &l : lines){
        QVariantMap m = l.toMap();
        Trendline t;
        t.startTime  = m["startTime"].toLongLong();
        t.endTime    = m["endTime"].toLongLong();
        t.startPrice = m["startPrice"].toDouble();
        t.endPrice   = m["endPrice"].toDouble();
        m_autoTrendlines.append(t);
    }
    emit objectsChanged();
}

// ---------------- Accessors ----------------
QVariantList ChartObjectModel::trendlines() const
{
    QVariantList list;
    for (const auto &t : m_manualTrendlines) {
        QVariantMap m;
        m["startTime"] = t.startTime;
        m["endTime"]   = t.endTime;
        m["startPrice"] = t.startPrice;
        m["endPrice"]   = t.endPrice;
        list.append(m);
    }
    for (const auto &t : m_autoTrendlines) {
        QVariantMap m;
        m["startTime"] = t.startTime;
        m["endTime"]   = t.endTime;
        m["startPrice"] = t.startPrice;
        m["endPrice"]   = t.endPrice;
        list.append(m);
    }
    return list;
}

QVariantList ChartObjectModel::horizontalLevels() const
{
    QVariantList list;
    for (const auto &l : m_manualLevels) {
        QVariantMap m;
        m["price"] = l.price;
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
        m["price"] = l.price;
        list.append(m);
    }
    // Auto
    for (const auto &l : m_autoLevels) {
        QVariantMap m;
        m["price"] = l.price;
        list.append(m);
    }
    return list;
}

QVariantList ChartObjectModel::allTrendlines() const {
    QVariantList list;
    for(const auto &t : m_manualTrendlines){
        QVariantMap m;
        m["startTime"] = t.startTime;
        m["endTime"]   = t.endTime;
        m["startPrice"] = t.startPrice;
        m["endPrice"]   = t.endPrice;
        list.append(m);
    }
    for(const auto &t : m_autoTrendlines){
        QVariantMap m;
        m["startTime"] = t.startTime;
        m["endTime"]   = t.endTime;
        m["startPrice"] = t.startPrice;
        m["endPrice"]   = t.endPrice;
        list.append(m);
    }
    return list;
}
