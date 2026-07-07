#include "CandleModel.h"
#include <limits>

CandleModel::CandleModel(QObject *parent) : QObject(parent) {}

QVariantList CandleModel::candles() const {
    return m_candles;
}

bool CandleModel::isEmpty() const {
    return m_candles.isEmpty();
}

void CandleModel::loadCandles(QSharedPointer<QVariantList> candles)
{
    qDebug() << "loadCandles(shared) called with" << candles->size() << "candles";
    loadCandles(*candles);
}

void CandleModel::loadCandles(const QVariantList &candles)
{
    qDebug() << "loadCandles(plain) called with" << candles.size() << "candles";
    m_candles = candles;
    emit candlesChanged();
    recalcAxisRange();
}

void CandleModel::updateLast(const QVariantMap &candle)
{
    if (m_candles.isEmpty()) {
        m_candles.append(candle);
    } else {
        m_candles[m_candles.size() - 1] = candle;
    }
    emit lastCandleUpdated();
    double high = candle["high"].toDouble();
    double low  = candle["low"].toDouble();

    bool needsRescale = false;
    if (!m_candles.isEmpty()) {
        for (const QVariant &v : std::as_const(m_candles)) {
            const QVariantMap c = v.toMap();
            if (low  < c["low"].toDouble())  { needsRescale = true; break; }
            if (high > c["high"].toDouble()) { needsRescale = true; break; }
        }
    }
    if (needsRescale) recalcAxisRange();
}

void CandleModel::append(const QVariantMap &candle)
{
    m_candles.append(candle);
    emit candlesChanged();
    recalcAxisRange();
}

void CandleModel::clear()
{
    m_candles.clear();
    emit candlesChanged();
    emit clearingModel();
}

void CandleModel::recalcAxisRange()
{
    if (m_candles.isEmpty()) return;

    double minY = std::numeric_limits<double>::max();
    double maxY = std::numeric_limits<double>::lowest();

    for (const QVariant &v : std::as_const(m_candles)) {
        const QVariantMap c = v.toMap();
        minY = std::min(minY, c["low"].toDouble());
        maxY = std::max(maxY, c["high"].toDouble());
    }

    emit axisRangeReady(minY, maxY);
}

bool CandleModel::isFromCSV() const
{
    return m_isFromCSV;
}

void CandleModel::setIsFromCSV(bool newIsFromCSV)
{
    if (m_isFromCSV == newIsFromCSV)
        return;
    m_isFromCSV = newIsFromCSV;
    emit isFromCSVChanged();
}