#include "TimeframeAggregator.h"
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
            close = c["close"].toDouble();
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
    emit aggReady(result);
    return result;
}

TimeframeAggregator::Timeframe TimeframeAggregator::getEnumTimeframe(const QString &tf)
{
    if (tf == "1m") return TimeframeAggregator::M1;
    if (tf == "5m") return TimeframeAggregator::M5;
    if (tf == "15m") return TimeframeAggregator::M15;
    if (tf == "1h") return TimeframeAggregator::H1;
    if (tf == "4h") return TimeframeAggregator::H4;
    if (tf == "Daily") return TimeframeAggregator::D1;
    return M1;
}

void TimeframeAggregator::setTimeframe(const QString &newTimeframe)
{
    if (m_timeframe == newTimeframe)
        return;
    m_timeframe = newTimeframe;
    emit timeframeChanged();
}

QString TimeframeAggregator::timeframeGetter()
{
    return m_timeframe;
}

QVariantMap TimeframeAggregator::indexAggregate(int index, Timeframe fromTimeframe, Timeframe toTimeframe)
{

    int fromCoeff = 1;
    int toCoeff   = 1;

    switch (fromTimeframe) {
    case M1:  fromCoeff = 1; break;
    case M5:  fromCoeff = 5; break;
    case M15: fromCoeff = 15; break;
    case H1:  fromCoeff = 60; break;
    case H4:  fromCoeff = 240; break;
    case D1:  fromCoeff = 1440; break;
    }

    switch (toTimeframe) {
    case M1:  toCoeff = 1; break;
    case M5:  toCoeff = 5; break;
    case M15: toCoeff = 15; break;
    case H1:  toCoeff = 60; break;
    case H4:  toCoeff = 240; break;
    case D1:  toCoeff = 1440; break;
    }

    double ratio    = static_cast<double>(fromCoeff) / toCoeff;
    int newIndex    = std::ceil(index * ratio);
    QVariantMap map;

    map["index"] = newIndex;
    map["ratio"] = ratio;

    return map;
}

QString TimeframeAggregator::timeframeToString(Timeframe tf)
{
    QString strTimeframe;
    switch (tf) {
    case M1:  strTimeframe = "1m"; break;
    case M5:  strTimeframe = "5m"; break;
    case M15: strTimeframe = "15m"; break;
    case H1:  strTimeframe = "1h"; break;
    case H4:  strTimeframe = "4h"; break;
    case D1:  strTimeframe = "Daily"; break;
    }
    return strTimeframe;
}
