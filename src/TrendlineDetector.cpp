// #include <include/TrendlineDetector.h>
// #include <QVariantMap>
// #include <QtMath>
// #include <QObject>

// TrendlineDetector::TrendlineDetector(QObject *parent)
//     : QObject(parent)
// {
// }

// QVariantList TrendlineDetector::detectTrendlines(const QVariantList &candles)
// {
//     QVariantList trendlines;

//     if(candles.size() < 2) return trendlines;

//     // --- اول، پیدا کردن local highs/lows ---
//     QList<QPair<int,double>> localHighs;
//     QList<QPair<int,double>> localLows;

//     for(int i = m_lookback; i < candles.size()-m_lookback; ++i)
//     {
//         double high = m_useShadows ? candles[i].toMap()["high"].toDouble()
//                                    : candles[i].toMap()["close"].toDouble();
//         double low  = m_useShadows ? candles[i].toMap()["low"].toDouble()
//                                    : candles[i].toMap()["close"].toDouble();

//         bool isHigh = true;
//         bool isLow  = true;

//         for(int j=1; j<=m_lookback; ++j){
//             double prevHigh = m_useShadows ? candles[i-j].toMap()["high"].toDouble()
//                                           : candles[i-j].toMap()["close"].toDouble();
//             double nextHigh = m_useShadows ? candles[i+j].toMap()["high"].toDouble()
//                                           : candles[i+j].toMap()["close"].toDouble();
//             if(prevHigh > high || nextHigh > high) isHigh=false;

//             double prevLow = m_useShadows ? candles[i-j].toMap()["low"].toDouble()
//                                          : candles[i-j].toMap()["close"].toDouble();
//             double nextLow = m_useShadows ? candles[i+j].toMap()["low"].toDouble()
//                                          : candles[i+j].toMap()["close"].toDouble();
//             if(prevLow < low || nextLow < low) isLow=false;
//         }

//         if(isHigh) localHighs.append({i, high});
//         if(isLow)  localLows.append({i, low});
//     }

//     // --- حالا خطوط روند صعودی (connect lows) ---
//     for(int i=0; i<localLows.size()-1; ++i){
//         Trendline t;
//         t.startIndex = localLows[i].first;
//         t.startPrice = localLows[i].second;
//         t.endIndex   = localLows[i+1].first;
//         t.endPrice   = localLows[i+1].second;
//         trendlines.append(QVariantMap{
//             {"startIndex", t.startIndex},
//             {"endIndex", t.endIndex},
//             {"startPrice", t.startPrice},
//             {"endPrice", t.endPrice}
//         });
//     }

//     // --- خطوط روند نزولی (connect highs) ---
//     for(int i=0; i<localHighs.size()-1; ++i){
//         Trendline t;
//         t.startIndex = localHighs[i].first;
//         t.startPrice = localHighs[i].second;
//         t.endIndex   = localHighs[i+1].first;
//         t.endPrice   = localHighs[i+1].second;
//         trendlines.append(QVariantMap{
//             {"startIndex", t.startIndex},
//             {"endIndex", t.endIndex},
//             {"startPrice", t.startPrice},
//             {"endPrice", t.endPrice}
//         });
//     }

//     return trendlines;
//     emit trendlinesFound();
// }

#include "include/TrendlineDetector.h"
#include <QVariantMap>
#include <QtMath>

TrendlineDetector::TrendlineDetector(QObject *parent)
    : QObject(parent)
{
}

QVariantList TrendlineDetector::detectTrendlines(const QVariantList &candles)
{
    QVariantList result;
    if(candles.size() < m_lookback*2+1)
        return result;

    QList<QPair<int,double>> highs;
    QList<QPair<int,double>> lows;

    // --------- 1. Detect local highs/lows ----------
    for(int i=m_lookback; i<candles.size()-m_lookback; ++i)
    {
        auto map = candles[i].toMap();

        double high = m_useShadows ? map["high"].toDouble()
                                   : map["close"].toDouble();
        double low  = m_useShadows ? map["low"].toDouble()
                                  : map["close"].toDouble();

        bool isHigh = true;
        bool isLow  = true;

        for(int j=1;j<=m_lookback;++j)
        {
            auto prev = candles[i-j].toMap();
            auto next = candles[i+j].toMap();

            double ph = m_useShadows ? prev["high"].toDouble() : prev["close"].toDouble();
            double nh = m_useShadows ? next["high"].toDouble() : next["close"].toDouble();
            if(ph > high || nh > high) isHigh=false;

            double pl = m_useShadows ? prev["low"].toDouble() : prev["close"].toDouble();
            double nl = m_useShadows ? next["low"].toDouble() : next["close"].toDouble();
            if(pl < low || nl < low) isLow=false;
        }

        if(isHigh) highs.append({i,high});
        if(isLow)  lows.append({i,low});
    }

    // --------- 2. Uptrend lines (Low -> Higher Low) ----------
    for(int i=0;i<lows.size();++i)
    {
        for(int j=i+1;j<lows.size();++j)
        {
            if(lows[j].second <= lows[i].second)
                continue; // باید higher low باشد

            int sIdx = lows[i].first;
            int eIdx = lows[j].first;
            double sPrice = lows[i].second;
            double ePrice = lows[j].second;

            double slope = (ePrice - sPrice) / (eIdx - sIdx);

            bool valid=true;

            for(int k=sIdx;k<=eIdx;++k)
            {
                double linePrice = sPrice + slope*(k-sIdx);
                double actualLow = m_useShadows ?
                                       candles[k].toMap()["low"].toDouble() :
                                       candles[k].toMap()["close"].toDouble();

                if(actualLow < linePrice*(1.0 - m_penetrationThreshold))
                {
                    valid=false;
                    break;
                }
            }

            if(valid){
                result.append(QVariantMap{
                    {"startIndex", sIdx},
                    {"endIndex", eIdx},
                    {"startPrice", sPrice},
                    {"endPrice", ePrice},
                    {"type", "up"}
                });
            }
        }
    }

    // --------- 3. Downtrend lines (High -> Lower High) ----------
    for(int i=0;i<highs.size();++i)
    {
        for(int j=i+1;j<highs.size();++j)
        {
            if(highs[j].second >= highs[i].second)
                continue; // باید lower high باشد

            int sIdx = highs[i].first;
            int eIdx = highs[j].first;
            double sPrice = highs[i].second;
            double ePrice = highs[j].second;

            double slope = (ePrice - sPrice) / (eIdx - sIdx);

            bool valid=true;

            for(int k=sIdx;k<=eIdx;++k)
            {
                double linePrice = sPrice + slope*(k-sIdx);
                double actualHigh = m_useShadows ?
                                        candles[k].toMap()["high"].toDouble() :
                                        candles[k].toMap()["close"].toDouble();

                if(actualHigh > linePrice*(1.0 + m_penetrationThreshold))
                {
                    valid=false;
                    break;
                }
            }

            if(valid){
                result.append(QVariantMap{
                    {"startIndex", sIdx},
                    {"endIndex", eIdx},
                    {"startPrice", sPrice},
                    {"endPrice", ePrice},
                    {"type", "down"}
                });
            }
        }
    }
    emit trendlinesFound(result);
    return result;
}

