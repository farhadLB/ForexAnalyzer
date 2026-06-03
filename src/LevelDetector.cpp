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
            m["isResistance"]= false;
            levels.append(m);
            qInfo() << "false";
        }

        if(isLow){
            QVariantMap m;
            m["price"]=low;
            m["isResistance"]= true;
            levels.append(m);
            qInfo() << "true";
        }
    }

    return levels;
}
