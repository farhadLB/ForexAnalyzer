#include "include/TrendlineDetector.h"
#include <QVariantMap>
#include <QtMath>

QVariantList TrendlineDetector::detectTrendlines(const QVariantList &candles)
{
    QVariantList result;
    if(candles.size() < m_lookback*2+1)
        return result;

    struct Pivot { int idx; double price; };

    QList<Pivot> highs;
    QList<Pivot> lows;

    // -------- Detect pivots ----------
    for(int i=m_lookback; i<candles.size()-m_lookback; ++i)
    {
        auto map = candles[i].toMap();

        double high = m_useShadows ? map["high"].toDouble()
                                   : map["close"].toDouble();
        double low  = m_useShadows ? map["low"].toDouble()
                                  : map["close"].toDouble();

        bool isHigh=true, isLow=true;

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

    // -------- UP trendlines ----------
    for(int i=0;i<lows.size()-1;++i)
    {
        for(int j=i+1;j<lows.size();++j)
        {
            int sIdx = lows[i].idx;
            int eIdx = lows[j].idx;

            double sPrice = lows[i].price;
            double ePrice = lows[j].price;

            if(ePrice <= sPrice) continue; // Higher Low

            // STRICT breakout check
            if(m_strict)
            {
                double midHigh = -1e20;
                for(int k=sIdx;k<=eIdx;++k)
                    midHigh = qMax(midHigh, candles[k].toMap()["high"].toDouble());

                bool breakout=false;
                for(int k=eIdx+1;k<candles.size();++k)
                    if(candles[k].toMap()["high"].toDouble() > midHigh){
                        breakout=true;
                        break;
                    }

                if(!breakout) continue;
            }

            double slope = (ePrice - sPrice)/(eIdx - sIdx);

            bool valid=true;
            for(int k=sIdx;k<candles.size();++k)
            {
                double linePrice = sPrice + slope*(k-sIdx);
                double actualLow = candles[k].toMap()["low"].toDouble();

                if(actualLow < linePrice*(1.0 - m_penetrationThreshold)){
                    valid=false;
                    break;
                }
            }

            if(valid)
            {
                QVariantMap m;
                m["startTime"]  = candles[sIdx].toMap()["time"].toLongLong();
                m["endTime"]    = candles[eIdx].toMap()["time"].toLongLong();
                m["startPrice"] = sPrice;
                m["endPrice"]   = ePrice;
                m["timeframe"]  = m_agg->timeframeGetter();
                result.append(m);
            }
        }
    }

    // -------- DOWN trendlines ----------
    for(int i=0;i<highs.size()-1;++i)
    {
        for(int j=i+1;j<highs.size();++j)
        {
            int sIdx = highs[i].idx;
            int eIdx = highs[j].idx;

            double sPrice = highs[i].price;
            double ePrice = highs[j].price;

            if(ePrice >= sPrice) continue; // Lower High

            if(m_strict)
            {
                double midLow = 1e20;
                for(int k=sIdx;k<=eIdx;++k)
                    midLow = qMin(midLow, candles[k].toMap()["low"].toDouble());

                bool breakout=false;
                for(int k=eIdx+1;k<candles.size();++k)
                    if(candles[k].toMap()["low"].toDouble() < midLow){
                        breakout=true;
                        break;
                    }

                if(!breakout) continue;
            }

            double slope = (ePrice - sPrice)/(eIdx - sIdx);

            bool valid=true;
            for(int k=sIdx;k<candles.size();++k)
            {
                double linePrice = sPrice + slope*(k-sIdx);
                double actualHigh = candles[k].toMap()["high"].toDouble();

                if(actualHigh > linePrice*(1.0 + m_penetrationThreshold)){
                    valid=false;
                    break;
                }
            }

            if(valid)
            {
                QVariantMap m;
                m["startTime"]  = candles[sIdx].toMap()["time"].toLongLong();
                m["endTime"]    = candles[eIdx].toMap()["time"].toLongLong();
                m["startPrice"] = sPrice;
                m["endPrice"]   = ePrice;
                m["timeframe"]  = m_agg->timeframeGetter();
                result.append(m);
            }
        }
    }
    emit resultFound(result);
    return result;
}

