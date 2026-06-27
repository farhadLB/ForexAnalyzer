#pragma once
#include <QVariantList>
#include <QVector>
#include <QDateTime>
#include "ChartObjects.h"

namespace CandleUtils
{
inline QVector<Candle> toStructArray(const QVariantList &candles)
{
    QVector<Candle> out;
    out.reserve(candles.size());
    for (const QVariant &v : candles) {
        const QVariantMap m = v.toMap();
        Candle c;
        c.time   = QDateTime::fromMSecsSinceEpoch(m["time"].toLongLong());
        c.open   = m["open"].toDouble();
        c.high   = m["high"].toDouble();
        c.low    = m["low"].toDouble();
        c.close  = m["close"].toDouble();
        c.volume = m["volume"].toDouble();
        out.append(c);
    }
    return out;
}
}
