// #pragma once

// #include <QObject>
// #include <QVector>
// #include <QDateTime>
// #include "ChartObjects.h"

// class CsvLoader : public QObject
// {
//     Q_OBJECT
// public:
//     explicit CsvLoader(QObject *parent = nullptr);

//     Q_INVOKABLE bool loadFile(const QString &filePath);

//     QVariantList getCandles();

// signals:
//     void fileLoaded(int candleCount);
//     void error(QString message);
//     void candlesReady(QVariantList candles);
//     void axisRangeReady(double min1, double min2);

// private:
//     QVector<Candle> m_data;
//     QVariantList m_candles;
// };


#pragma once
#include <QObject>
#include <QThread>
#include <QVariantList>
#include "CsvWorker.h"

class CsvLoader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)

public:
    explicit CsvLoader(QObject *parent = nullptr);
    ~CsvLoader();

    Q_INVOKABLE void loadFile(const QString &filePath);
    Q_INVOKABLE void cancelLoad();

    bool isLoading() const { return m_isLoading; }
    int  progress()  const { return m_progress; }
    QVariantList getCandles() const { return m_candles; }

signals:
    void isLoadingChanged();
    void progressChanged();
    void fileLoaded(int candleCount);
    void candlesReady(QVariantList candles);
    void axisRangeReady(double min, double max);
    void error(QString message);

    // internal signal to trigger worker across thread boundary
    void startWorker(const QString &filePath);

private:
    void setIsLoading(bool v);
    void setProgress(int v);

    QThread    *m_thread = nullptr;
    CsvWorker  *m_worker = nullptr;
    bool        m_isLoading = false;
    int         m_progress  = 0;
    QVariantList m_candles;

};
