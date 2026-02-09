#include "include/TimeframeAggregator.h"
#include <QDebug>
#include <algorithm>

QVariantList TimeframeAggregator::aggregate(const QVariantList &rawCandles, Timeframe tf)
{
    if (rawCandles.isEmpty())
        return {};

    int step = 1;  // default = 1m

    switch(tf){
    case M1:  step = 1; break;
    case M5:  step = 5; break;
    case M15: step = 15; break;
    case H1:  step = 60; break;
    case H4:  step = 240; break;
    case D1:  step = 1440; break;
    }

    QVariantList result;
    int count = rawCandles.size();
    int index = 0;

    while (index < count) {

        int endIndex = qMin(index + step, count);

        QVariantMap first = rawCandles[index].toMap();
        double high = first["high"].toDouble();
        double low  = first["low"].toDouble();
        double open = first["open"].toDouble();
        double close= first["close"].toDouble();
        double volume = first["volume"].toDouble();
        QDateTime time = QDateTime::fromMSecsSinceEpoch(first["time"].toLongLong());

        for (int i=index+1; i<endIndex; ++i) {
            QVariantMap c = rawCandles[i].toMap();
            high = qMax(high, c["high"].toDouble());
            low  = qMin(low, c["low"].toDouble());
            close = c["close"].toDouble();  // آخرین کندل
            volume += c["volume"].toDouble();
        }

        QVariantMap agg;
        agg["time"] = time.toMSecsSinceEpoch();
        agg["open"] = open;
        agg["high"] = high;
        agg["low"]  = low;
        agg["close"]= close;
        agg["volume"]= volume;

        result.append(agg);

        index = endIndex;
    }

    return result;
}
