#pragma once

#include <QObject>
#include <QVector>
#include <QDateTime>

struct Candle {
    QDateTime time;
    double open;
    double high;
    double low;
    double close;
    double volume;
};

class CsvLoader : public QObject
{
    Q_OBJECT
public:
    explicit CsvLoader(QObject *parent = nullptr);

    Q_INVOKABLE bool loadFile(const QString &filePath);
    Q_INVOKABLE void printCsv();

signals:
    void fileLoaded(int candleCount);
    void error(QString message);
    void candlesReady(QVariantList candles);
    void axisRangeReady(double min1, double min2);

private:
    QVector<Candle> m_data;
};
