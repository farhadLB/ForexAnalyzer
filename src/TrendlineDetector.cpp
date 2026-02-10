#include <include/TrendlineDetector.h>
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
    for(int i=0;i<lows.size()-1;++i)
    {
        for(int j=i+1;j<lows.size();++j)
        {
            int sIdx = lows[i].first;
            int eIdx = lows[j].first;

            double sPrice = lows[i].second;
            double ePrice = lows[j].second;

            // Higher Low
            if(ePrice <= sPrice)
                continue;

            // ---------- STRICT MODE ----------
            if(m_strict)
            {
                // highest high بین دو low
                double midHigh = -1e20;
                for(int k=sIdx;k<=eIdx;++k)
                {
                    double h = candles[k].toMap()["high"].toDouble();
                    if(h > midHigh) midHigh = h;
                }

                // آیا بعد از low دوم breakout رخ داده؟
                bool breakout = false;
                for(int k=eIdx+1;k<candles.size();++k)
                {
                    double h = candles[k].toMap()["high"].toDouble();
                    if(h > midHigh)
                    {
                        breakout = true;
                        break;
                    }
                }

                if(!breakout)
                    continue;
            }


            double slope = (ePrice - sPrice)/(eIdx - sIdx);

            bool valid=true;

            for(int k=sIdx;k<candles.size();++k)
            {
                double linePrice = sPrice + slope*(k-sIdx);

                double actualLow = candles[k].toMap()["low"].toDouble();

                if(actualLow < linePrice*(1.0 - m_penetrationThreshold))
                {
                    valid=false;
                    break;
                }
            }

            if(valid)
            {
                result.append(QVariantMap{
                    {"startIndex", sIdx},
                    {"endIndex", eIdx},
                    {"startPrice", sPrice},
                    {"endPrice", ePrice}
                });
            }
        }
    }


    // --------- 3. Downtrend lines (High -> Lower High) ----------
    for(int i=0;i<highs.size()-1;++i)
    {
        for(int j=i+1;j<highs.size();++j)
        {
            int sIdx = highs[i].first;
            int eIdx = highs[j].first;

            double sPrice = highs[i].second;
            double ePrice = highs[j].second;

            // Lower High
            if(ePrice >= sPrice)
                continue;

            // ---------- STRICT MODE ----------
            if(m_strict)
            {
                // lowest low بین دو high
                double midLow = 1e20;
                for(int k=sIdx;k<=eIdx;++k)
                {
                    double l = candles[k].toMap()["low"].toDouble();
                    if(l < midLow) midLow = l;
                }

                // breakout بعد از high دوم
                bool breakout = false;
                for(int k=eIdx+1;k<candles.size();++k)
                {
                    double l = candles[k].toMap()["low"].toDouble();
                    if(l < midLow)
                    {
                        breakout = true;
                        break;
                    }
                }

                if(!breakout)
                    continue;
            }


            double slope = (ePrice - sPrice)/(eIdx - sIdx);

            bool valid=true;

            for(int k=sIdx;k<candles.size();++k)
            {
                double linePrice = sPrice + slope*(k-sIdx);

                double actualHigh = candles[k].toMap()["high"].toDouble();

                if(actualHigh > linePrice*(1.0 + m_penetrationThreshold))
                {
                    valid=false;
                    break;
                }
            }

            if(valid)
            {
                result.append(QVariantMap{
                    {"startIndex", sIdx},
                    {"endIndex", eIdx},
                    {"startPrice", sPrice},
                    {"endPrice", ePrice}
                });
            }
        }
    }

    emit resultFound(result);
    return result;
}

