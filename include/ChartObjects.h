#pragma once
#include <QtGlobal>
#include <QDateTime>

struct Candle {
    QDateTime time;
    double open;
    double high;
    double low;
    double close;
    double volume;
};


struct Trendline {
    qint64 startTime;
    qint64 endTime;
    double startPrice;
    double endPrice;
    QString timeframe;
};


struct HorizontalLevel {
    double price;
    bool isResistance;
};
