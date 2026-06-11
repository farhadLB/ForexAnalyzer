#pragma once
#include <QObject>
#include <QVariantList>

class LevelDetector : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(double threshold READ threshold WRITE setThreshold NOTIFY thresholdChanged FINAL)
    Q_INVOKABLE QVariantList detectLocalLevels(const QVariantList &candles, int lookback);
    Q_INVOKABLE double stopLossLevel(const QVariantList &candles, const QVariantList &levels, int backdrop);
    void detectLevelBreaks(QVariantList* levels, const QVariantList &candles);

    double threshold() const;
    void setThreshold(double newThreshold);

signals:
    void levelsReady(QVariantList levels);
    void thresholdChanged();

private:
    double m_threshold = 0;
};
