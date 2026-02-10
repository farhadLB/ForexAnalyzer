// #pragma once
// #include <QObject>
// #include <QVariantList>
// #include <include/ChartObjects.h>

// class TrendlineDetector : public QObject
// {
//     Q_OBJECT
// public:
//     explicit TrendlineDetector(QObject *parent = nullptr);

//     // -------- تنظیمات ----------
//     Q_PROPERTY(int lookback READ lookback WRITE setLookback NOTIFY lookbackChanged)
//     Q_PROPERTY(bool useShadows READ useShadows WRITE setUseShadows NOTIFY useShadowsChanged)

//     int lookback() const { return m_lookback; }
//     void setLookback(int val) { m_lookback = val; emit lookbackChanged(); }

//     bool useShadows() const { return m_useShadows; }
//     void setUseShadows(bool val) { m_useShadows = val; emit useShadowsChanged(); }

//     // -------- متد اصلی --------
//     Q_INVOKABLE QVariantList detectTrendlines(const QVariantList &candles);

// signals:
//     void lookbackChanged();
//     void useShadowsChanged();
//     void trendlinesFound();

// private:
//     int m_lookback = 20;    // فاصله برای پیدا کردن local high/low
//     bool m_useShadows = true;  // true = از high/low کندل استفاده کن
// };

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

public:
    explicit TrendlineDetector(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList detectTrendlines(const QVariantList &candles);
    bool lineIsValid(const QVariantList &candles,int i1,double p1,int i2,double p2) const;

    // --- getters ---
    int lookback() const { return m_lookback; }
    bool useShadows() const { return m_useShadows; }
    double penetrationThreshold() const { return m_penetrationThreshold; }

    // --- setters ---
    void setLookback(int v) {
        if(m_lookback == v) return;
        m_lookback = v;
        emit parametersChanged();
    }

    void setUseShadows(bool v) {
        if(m_useShadows == v) return;
        m_useShadows = v;
        emit parametersChanged();
    }

    void setPenetrationThreshold(double v) {
        if(qFuzzyCompare(m_penetrationThreshold, v)) return;
        m_penetrationThreshold = v;
        emit parametersChanged();
    }

signals:
    void trendlinesFound(const QVariantList &lines);
    void parametersChanged();

private:
    int m_lookback = 20;
    bool m_useShadows = true;
    double m_penetrationThreshold = 0.0001;
};

#endif // TRENDLINEDETECTOR_H
