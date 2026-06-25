#pragma once
#include <QObject>
#include <QVariantList>
#include <ChartObjects.h>
#include <QtConcurrent/QtConcurrentMap>
#include <QVector>

class LevelDetector : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE QVariantList detectLocalLevels(const QVariantList &candles, int lookback);
    QVariantList filterCloseLevels(QVariantList levels, double gap);

signals:
    void levelsReady(QVariantList levels);

private:
    static QVector<Candle> toStructArray(const QVariantList &candles);
};
