#pragma once
#include <QObject>
#include <QVariantList>

class LevelDetector : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE QVariantList detectLocalLevels(const QVariantList &candles, int lookback);
};
