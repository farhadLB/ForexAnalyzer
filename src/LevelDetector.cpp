#include <LevelDetector.h>

QVariantList LevelDetector::detectLocalLevels(const QVariantList &candles,int lookback)
{
    QVariantList levels;

    for(int i=lookback; i<candles.size()-lookback; i++)
    {
        double high = candles[i].toMap()["high"].toDouble();
        double low  = candles[i].toMap()["low"].toDouble();

        bool isHigh=true;
        bool isLow=true;

        for(int j=1;j<=lookback;j++){
            if(candles[i-j].toMap()["high"].toDouble() > high) isHigh=false;
            if(candles[i+j].toMap()["high"].toDouble() > high) isHigh=false;

            if(candles[i-j].toMap()["low"].toDouble() < low) isLow=false;
            if(candles[i+j].toMap()["low"].toDouble() < low) isLow=false;
        }

        if(isHigh){
            QVariantMap m;
            m["price"]=high;
            m["isResistance"]= true;
            m["idx"] = i;
            m["breakIndex"] = -1;
            levels.append(m);
        }

        if(isLow){
            QVariantMap m;
            m["price"]=low;
            m["isResistance"]= false;
            m["idx"] = i;
            m["breakIndex"] = -1;
            levels.append(m);
        }
    }

    // detectLevelBreaks(&levels, candles);
    emit levelsReady(levels);
    return levels;
}

QVariantList LevelDetector::filterCloseLevels(QVariantList levels, double gap)
{
    QVariantList sorted = levels;

    std::sort(sorted.begin(), sorted.end(), [](const QVariant &a, const QVariant &b) {
        return a.toMap()["price"].toDouble() < b.toMap()["price"].toDouble();
    });

    QVariantList result;
    for (const QVariant &v : sorted) {
        QVariantMap current = v.toMap();

        if (result.isEmpty()) {
            result.append(current);
            continue;
        }

        QVariantMap last = result.last().toMap();
        double diff = qAbs(current["price"].toDouble() - last["price"].toDouble());

        if (diff < gap) {
            // keep whichever level formed earlier
            if (current["idx"].toInt() < last["idx"].toInt()) {
                result.removeLast();
                result.append(current);
            }
            // else discard 'current', keep 'last'
        } else {
            result.append(current);
        }
    }

    return result;
}

void LevelDetector::detectLevelBreaks(QVariantList* levels,  const QVariantList &candles)
{

    for(QVariant& v : *levels){
        QVariantMap level = v.toMap();
        for(int i=level["idx"].toInt() + 10; i<candles.size(); i++){
            if(level["isResistance"].toBool()){
                if(candles[i].toMap()["close"].toDouble() > level["price"].toDouble() + m_threshold){
                    level["breakIndex"] = i;
                    level["breakTime"]  = candles[i].toMap()["time"].toLongLong();
                    break;
                }
            }
            else{
                if(candles[i].toMap()["close"].toDouble() < level["price"].toDouble() - m_threshold){
                    level["breakIndex"] = i;
                    level["breakTime"]  = candles[i].toMap()["time"].toLongLong();
                    break;
                }
            }
        }
        v = level;
    }
}

double LevelDetector::stopLossLevel(const QVariantList &candles ,const QVariantList &levels, int backdrop)
{
    double stopLossPrice    = 0;

    for(QVariant v: levels){
        QVariantMap level = v.toMap();
        int  firstIdx     = level["idx"].toInt();
        int  lastIdx      = level["breakIdx"].toInt();
        bool isResistance = level["isResistance"].toBool();
        QVariantList subCandles = candles.mid(firstIdx, lastIdx-firstIdx);
        QVariantList SLlevels   = detectLocalLevels(subCandles, backdrop);
        if(isResistance){
            double high = SLlevels[0].toMap()["price"].toDouble();
            for(int i = 1; i<SLlevels.size(); i++){
                if(SLlevels[i].toMap()["price"].toDouble() > high){
                    high = SLlevels[i].toMap()["price"].toDouble();
                    stopLossPrice = SLlevels[i].toMap()["price"].toDouble();
                }
            }
        }
        else{
            double low = SLlevels[0].toMap()["price"].toDouble();
            for(int i = 1; i<SLlevels.size(); i++){
                if(SLlevels[i].toMap()["price"].toDouble() < low){
                    low = SLlevels[i].toMap()["price"].toDouble();
                    stopLossPrice = SLlevels[i].toMap()["price"].toDouble();
                }
            }
        }
    }
    return stopLossPrice;
}


double LevelDetector::threshold() const
{
    return m_threshold;
}

void LevelDetector::setThreshold(double newThreshold)
{
    if (qFuzzyCompare(m_threshold, newThreshold))
        return;
    m_threshold = newThreshold;
    emit thresholdChanged();
}
