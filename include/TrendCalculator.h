#pragma once
#include <QVector>
#include "ChartObjects.h"

class TrendCalculator
{
public:
    explicit TrendCalculator(int period = 28);

    struct TrendSeries {
        QVector<double> adx;
        QVector<double> plusDI;
        QVector<double> minusDI;
        int warmupBars;
    };

    TrendSeries compute(const QVector<Candle>& candles) const;

private:
    int m_period;

    static double trueRange(const Candle& cur, const Candle& prev);
    static double plusDM(const Candle& cur, const Candle& prev);
    static double minusDM(const Candle& cur, const Candle& prev);
};
