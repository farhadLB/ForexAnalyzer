#pragma once
#include <QtGlobal>

struct Trendline {
    qint64 startTime;
    qint64 endTime;
    double startPrice;
    double endPrice;
};


struct HorizontalLevel {
    double price;
};
