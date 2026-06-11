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
    qint64  startTime;
    qint64  endTime;
    double  startPrice;
    double  endPrice;
    QString timeframe;
};


struct HorizontalLevel {
    double price;
    bool   isResistance;
    int    idx;
    int    breakIndex;
    qint64 breakTime;
};

struct Position {
    double  EntryPointPrice;
    double  StopLossPrice;
    double  TakeProfitPrice;
    int     EntryIdx;
    int     EndIdx;
    int     LevelIdx;
    QString Timeframe;
    bool    isBullish;
    bool    isWin;
};
