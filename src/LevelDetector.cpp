#include "LevelDetector.h"
#include <QtConcurrent/QtConcurrentMap>
#include <QMutex>
#include <algorithm>

QVariantList LevelDetector::detectLocalLevels(const QVariantList &candles, int lookback)
{
    const QVector<Candle> data = CandleUtils::toStructArray(candles);  // one-time conversion
    const int size = data.size();

    // build index list to iterate over
    QVector<int> indices;
    indices.reserve(size - 2 * lookback);
    for (int i = lookback; i < size - lookback; ++i)
        indices.append(i);

    QMutex mutex;
    QVariantList levels;

    QtConcurrent::blockingMap(indices, [&](int i) {
        const double high = data[i].high;
        const double low  = data[i].low;
        bool isHigh = true;
        bool isLow  = true;

        for (int j = 1; j <= lookback; ++j) {
            if (data[i - j].high > high) { isHigh = false; }
            if (data[i + j].high > high) { isHigh = false; }
            if (data[i - j].low  < low)  { isLow  = false; }
            if (data[i + j].low  < low)  { isLow  = false; }
            if (!isHigh && !isLow) break;  // early exit
        }

        if (isHigh || isLow) {
            QMutexLocker locker(&mutex);
            if (isHigh) {
                QVariantMap m;
                m["price"]        = high;
                m["isResistance"] = true;
                m["idx"]          = i;
                m["breakIndex"]   = -1;
                levels.append(m);
            }
            if (isLow) {
                QVariantMap m;
                m["price"]        = low;
                m["isResistance"] = false;
                m["idx"]          = i;
                m["breakIndex"]   = -1;
                levels.append(m);
            }
        }
    });

    // sort by index since parallel execution breaks order
    std::sort(levels.begin(), levels.end(), [](const QVariant &a, const QVariant &b) {
        return a.toMap()["idx"].toInt() < b.toMap()["idx"].toInt();
    });

    emit levelsReady(levels);
    return levels;
}

QVariantList LevelDetector::filterCloseLevels(QVariantList levels, double gap)
{
    QVariantList sorted = levels;

    std::sort(sorted.begin(), sorted.end(), [](const QVariant &a, const QVariant &b) {
        return a.toMap()["price"].toDouble() < b.toMap()["price"].toDouble();
    });

    QVariantList result;
    for (const QVariant &v : sorted) {
        QVariantMap current = v.toMap();

        if (result.isEmpty()) {
            result.append(current);
            continue;
        }

        QVariantMap last = result.last().toMap();
        double diff = qAbs(current["price"].toDouble() - last["price"].toDouble());

        if (diff < gap) {
            // keep whichever level formed earlier
            if (current["idx"].toInt() < last["idx"].toInt()) {
                result.removeLast();
                result.append(current);
            }
            // else discard 'current', keep 'last'
        } else {
            result.append(current);
        }
    }

    return result;
}
