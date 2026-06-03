#pragma once
#include <QObject>
#include <QVariantList>
#include <TimeframeAggregator.h>

class TrendlineDetector : public QObject
{
    Q_OBJECT
public:
    TrendlineDetector(TimeframeAggregator* agg, QObject *parent = nullptr): QObject(parent), m_agg(agg){}

    Q_INVOKABLE QVariantList detectTrendlines(const QVariantList &candles);

    Q_PROPERTY(int lookback READ lookback WRITE setLookback NOTIFY parametersChanged)
    Q_PROPERTY(bool useShadows READ useShadows WRITE setUseShadows NOTIFY parametersChanged)
    Q_PROPERTY(double penetrationThreshold READ penetrationThreshold WRITE setPenetrationThreshold NOTIFY parametersChanged)
    Q_PROPERTY(bool strict READ strict WRITE setStrict NOTIFY strictChanged)

    int lookback() const { return m_lookback; }
    void setLookback(int v){ m_lookback = v; }

    bool strict() const { return m_strict; }
    void setStrict(bool v){ m_strict = v;
        emit strictChanged();
    }

    bool useShadows() const { return m_useShadows; }
    void setUseShadows(bool v){ m_useShadows = v; }

    double penetrationThreshold() const { return m_penetrationThreshold; }
    void setPenetrationThreshold(double v){ m_penetrationThreshold = v; }

signals:
    void resultFound(const QVariantList &lines);
    void parametersChanged();
    void strictChanged();
    void trendlinesFound(const QVariantList &lines);

private:
    int m_lookback = 10;
    bool m_strict = true;
    bool m_useShadows = true;
    double m_penetrationThreshold = 0.0001;
    TimeframeAggregator* m_agg;
};
