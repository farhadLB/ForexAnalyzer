#pragma once
#include <QObject>
#include <QVariant>
#include <QDateTime>
#include "CsvLoader.h"  // برای struct Candle

class TimeframeAggregator : public QObject {
    Q_OBJECT
public:
    explicit TimeframeAggregator(QObject *parent = nullptr) : QObject(parent) {}

    enum Timeframe { M1, M5, M15, H1, H4, D1 };
    Q_ENUM(Timeframe)

    Q_INVOKABLE QVariantList aggregate(const QVariantList &rawCandles, Timeframe tf);

    Q_INVOKABLE int getTimeframe(const QString &tf) {
        if (tf == "1m") return M1;
        if (tf == "5m") return M5;
        if (tf == "15m") return M15;
        if (tf == "1h") return H1;
        if (tf == "4h") return H4;
        if (tf == "Daily") return D1;
        return M1;
    }
};
