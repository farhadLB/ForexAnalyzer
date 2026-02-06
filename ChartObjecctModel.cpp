#include <ChartObjecctModel.h>

// ---------------- Constructor ----------------
ChartObjectModel::ChartObjectModel(QObject *parent)
    : QObject(parent)
{
}

// ---------------- Manual objects ----------------
void ChartObjectModel::addTrendline(int sIdx, double sPrice, int eIdx, double ePrice)
{
    Trendline t;
    t.startIndex = sIdx;
    t.endIndex   = eIdx;
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

// ---------------- Accessors ----------------
QVariantList ChartObjectModel::trendlines() const
{
    QVariantList list;
    for (const auto &t : m_manualTrendlines) {
        QVariantMap m;
        m["startIndex"] = t.startIndex;
        m["endIndex"]   = t.endIndex;
        m["startPrice"] = t.startPrice;
        m["endPrice"]   = t.endPrice;
        list.append(m);
    }
    for (const auto &t : m_autoTrendlines) {
        QVariantMap m;
        m["startIndex"] = t.startIndex;
        m["endIndex"]   = t.endIndex;
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
