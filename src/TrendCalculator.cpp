#include "TrendCalculator.h"
#include <cmath>
#include <algorithm>

TrendCalculator::TrendCalculator(int period) : m_period(period) {}

double TrendCalculator::trueRange(const Candle& cur, const Candle& prev)
{
    double a = cur.high - cur.low;
    double b = std::abs(cur.high - prev.close);
    double c = std::abs(cur.low - prev.close);
    return std::max({a, b, c});
}

double TrendCalculator::plusDM(const Candle& cur, const Candle& prev)
{
    double up   = cur.high - prev.high;
    double down = prev.low - cur.low;
    return (up > down && up > 0) ? up : 0.0;
}

double TrendCalculator::minusDM(const Candle& cur, const Candle& prev)
{
    double up   = cur.high - prev.high;
    double down = prev.low - cur.low;
    return (down > up && down > 0) ? down : 0.0;
}

TrendCalculator::TrendSeries TrendCalculator::compute(const QVector<Candle>& candles) const
{
    const int n = candles.size();
    TrendSeries result;
    result.adx.resize(n, 0.0);
    result.plusDI.resize(n, 0.0);
    result.minusDI.resize(n, 0.0);
    result.warmupBars = 2 * m_period;

    if (n < result.warmupBars) {
        return result;
    }

    QVector<double> tr(n, 0.0), pdm(n, 0.0), mdm(n, 0.0);
    for (int i = 1; i < n; ++i) {
        tr[i]  = trueRange(candles[i], candles[i - 1]);
        pdm[i] = plusDM(candles[i], candles[i - 1]);
        mdm[i] = minusDM(candles[i], candles[i - 1]);
    }

    double smoothedTR = 0, smoothedPDM = 0, smoothedMDM = 0;
    for (int i = 1; i <= m_period; ++i) {
        smoothedTR  += tr[i];
        smoothedPDM += pdm[i];
        smoothedMDM += mdm[i];
    }

    QVector<double> dx(n, 0.0);

    auto updateDIandDX = [&](int i) {
        double plusDI  = (smoothedTR != 0) ? 100.0 * smoothedPDM / smoothedTR : 0.0;
        double minusDI = (smoothedTR != 0) ? 100.0 * smoothedMDM / smoothedTR : 0.0;
        result.plusDI[i]  = plusDI;
        result.minusDI[i] = minusDI;
        double sum = plusDI + minusDI;
        dx[i] = (sum != 0) ? 100.0 * std::abs(plusDI - minusDI) / sum : 0.0;
    };

    updateDIandDX(m_period);

    for (int i = m_period + 1; i < n; ++i) {
        smoothedTR  = smoothedTR  - (smoothedTR  / m_period) + tr[i];
        smoothedPDM = smoothedPDM - (smoothedPDM / m_period) + pdm[i];
        smoothedMDM = smoothedMDM - (smoothedMDM / m_period) + mdm[i];
        updateDIandDX(i);
    }

    double dxSum = 0;
    int dxCount = 0;
    int adxStart = -1;
    for (int i = m_period; i < n; ++i) {
        dxSum += dx[i];
        dxCount++;
        if (dxCount == m_period) {
            result.adx[i] = dxSum / m_period;
            adxStart = i;
            break;
        }
    }

    if (adxStart >= 0) {
        for (int i = adxStart + 1; i < n; ++i) {
            result.adx[i] = ((result.adx[i - 1] * (m_period - 1)) + dx[i]) / m_period;
        }
    }

    return result;
}
