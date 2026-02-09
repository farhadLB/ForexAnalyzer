#pragma once
#include <QObject>
#include <QVariantList>
#include <include/ChartObjects.h>

class TrendlineDetector : public QObject
{
    Q_OBJECT
public:
    explicit TrendlineDetector(QObject *parent = nullptr);

    // -------- تنظیمات ----------
    Q_PROPERTY(int lookback READ lookback WRITE setLookback NOTIFY lookbackChanged)
    Q_PROPERTY(bool useShadows READ useShadows WRITE setUseShadows NOTIFY useShadowsChanged)

    int lookback() const { return m_lookback; }
    void setLookback(int val) { m_lookback = val; emit lookbackChanged(); }

    bool useShadows() const { return m_useShadows; }
    void setUseShadows(bool val) { m_useShadows = val; emit useShadowsChanged(); }

    // -------- متد اصلی --------
    Q_INVOKABLE QVariantList detectTrendlines(const QVariantList &candles);

signals:
    void lookbackChanged();
    void useShadowsChanged();
    void trendlinesFound();

private:
    int m_lookback = 20;    // فاصله برای پیدا کردن local high/low
    bool m_useShadows = true;  // true = از high/low کندل استفاده کن
};
