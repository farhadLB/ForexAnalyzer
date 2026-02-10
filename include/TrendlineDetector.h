#ifndef TRENDLINEDETECTOR_H
#define TRENDLINEDETECTOR_H

#include <QObject>
#include <QVariantList>

class TrendlineDetector : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int lookback READ lookback WRITE setLookback NOTIFY parametersChanged)
    Q_PROPERTY(bool useShadows READ useShadows WRITE setUseShadows NOTIFY parametersChanged)
    Q_PROPERTY(double penetrationThreshold READ penetrationThreshold WRITE setPenetrationThreshold NOTIFY parametersChanged)
    Q_PROPERTY(bool strict READ strict WRITE setStrict NOTIFY strictChanged)

public:
    explicit TrendlineDetector(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList detectTrendlines(const QVariantList &candles);

    int lookback() const { return m_lookback; }
    void setLookback(int v) { m_lookback=v; }

    bool useShadows() const { return m_useShadows; }
    void setUseShadows(bool v) { m_useShadows=v; }

    double penetrationThreshold() const { return m_penetrationThreshold; }
    void setPenetrationThreshold(double v) { m_penetrationThreshold=v; }

    bool strict() const { return m_strict; }
    void setStrict(bool v) { m_strict=v;
        emit strictChanged();
    }

private:
    int m_lookback = 10;
    bool m_useShadows = true;
    double m_penetrationThreshold = 0.0001;
    bool m_strict = true;

signals:
    void resultFound(const QVariantList &lines);
    void parametersChanged();
    void strictChanged();
    void trendlinesFound(const QVariantList &lines);
};

#endif
