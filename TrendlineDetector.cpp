#include <TrendlineDetector.h>
#include <QVariantMap>
#include <QtMath>
#include <QObject>

TrendlineDetector::TrendlineDetector(QObject *parent)
    : QObject(parent)
{
}

QVariantList TrendlineDetector::detectTrendlines(const QVariantList &candles)
{
    QVariantList trendlines;

    if(candles.size() < 2) return trendlines;

    // --- اول، پیدا کردن local highs/lows ---
    QList<QPair<int,double>> localHighs;
    QList<QPair<int,double>> localLows;

    for(int i = m_lookback; i < candles.size()-m_lookback; ++i)
    {
        double high = m_useShadows ? candles[i].toMap()["high"].toDouble()
                                   : candles[i].toMap()["close"].toDouble();
        double low  = m_useShadows ? candles[i].toMap()["low"].toDouble()
                                   : candles[i].toMap()["close"].toDouble();

        bool isHigh = true;
        bool isLow  = true;

        for(int j=1; j<=m_lookback; ++j){
            double prevHigh = m_useShadows ? candles[i-j].toMap()["high"].toDouble()
                                          : candles[i-j].toMap()["close"].toDouble();
            double nextHigh = m_useShadows ? candles[i+j].toMap()["high"].toDouble()
                                          : candles[i+j].toMap()["close"].toDouble();
            if(prevHigh > high || nextHigh > high) isHigh=false;

            double prevLow = m_useShadows ? candles[i-j].toMap()["low"].toDouble()
                                         : candles[i-j].toMap()["close"].toDouble();
            double nextLow = m_useShadows ? candles[i+j].toMap()["low"].toDouble()
                                         : candles[i+j].toMap()["close"].toDouble();
            if(prevLow < low || nextLow < low) isLow=false;
        }

        if(isHigh) localHighs.append({i, high});
        if(isLow)  localLows.append({i, low});
    }

    // --- حالا خطوط روند صعودی (connect lows) ---
    for(int i=0; i<localLows.size()-1; ++i){
        Trendline t;
        t.startIndex = localLows[i].first;
        t.startPrice = localLows[i].second;
        t.endIndex   = localLows[i+1].first;
        t.endPrice   = localLows[i+1].second;
        trendlines.append(QVariantMap{
            {"startIndex", t.startIndex},
            {"endIndex", t.endIndex},
            {"startPrice", t.startPrice},
            {"endPrice", t.endPrice}
        });
    }

    // --- خطوط روند نزولی (connect highs) ---
    for(int i=0; i<localHighs.size()-1; ++i){
        Trendline t;
        t.startIndex = localHighs[i].first;
        t.startPrice = localHighs[i].second;
        t.endIndex   = localHighs[i+1].first;
        t.endPrice   = localHighs[i+1].second;
        trendlines.append(QVariantMap{
            {"startIndex", t.startIndex},
            {"endIndex", t.endIndex},
            {"startPrice", t.startPrice},
            {"endPrice", t.endPrice}
        });
    }

    return trendlines;
}
