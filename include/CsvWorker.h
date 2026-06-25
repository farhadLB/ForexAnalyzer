#pragma once
#include <QObject>
#include <QVector>
#include <QVariantList>
#include <atomic>
#include "ChartObjects.h"

class CsvWorker : public QObject
{
    Q_OBJECT
public:
    explicit CsvWorker(QObject *parent = nullptr);
    void requestCancel();

public slots:
    void loadFile(const QString &filePath);

signals:
    void progressChanged(int percent);
    void candlesReady(QVariantList candles);
    void axisRangeReady(double min, double max);
    void fileLoaded(int candleCount);
    void error(QString message);

private:
    std::atomic<bool> m_cancelRequested{false};
};
