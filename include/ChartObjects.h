#pragma once
#include <QtGlobal>

struct Trendline {
    qint64 startTime;
    qint64 endTime;
    double startPrice;
    double endPrice;
    QString timeframe;
};


struct HorizontalLevel {
    double price;
};
