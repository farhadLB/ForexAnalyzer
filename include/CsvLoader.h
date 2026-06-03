#pragma once

#include <QObject>
#include <QVector>
#include <QDateTime>
#include "ChartObjects.h"

class CsvLoader : public QObject
{
    Q_OBJECT
public:
    explicit CsvLoader(QObject *parent = nullptr);

    Q_INVOKABLE bool loadFile(const QString &filePath);

signals:
    void fileLoaded(int candleCount);
    void error(QString message);
    void candlesReady(QVariantList candles);
    void axisRangeReady(double min1, double min2);

private:
    QVector<Candle> m_data;
};
