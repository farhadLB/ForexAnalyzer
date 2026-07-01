#pragma once
#include <QObject>
#include <QVariant>
#include <QDateTime>
#include <ChartObjects.h>

class TimeframeAggregator : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString timeframe READ timeframeGetter WRITE setTimeframe NOTIFY timeframeChanged FINAL)
    Q_PROPERTY(int comboIndex READ comboIndex WRITE setComboIndex NOTIFY comboIndexChanged FINAL)
public:
    explicit TimeframeAggregator(QObject *parent = nullptr) : QObject(parent) {}

    enum Timeframe { M1, M5, M15, H1, H4, D1 };
    Q_ENUM(Timeframe)

    Q_INVOKABLE QVariantList aggregate(const QVariantList &rawCandles, Timeframe tf);

    Q_INVOKABLE int getTimeframe(const QString &tf) {
        if (tf == "1m") return M1;
        if (tf == "5m") return M5;
        if (tf == "15m") return M15;
        if (tf == "1h") return H1;
        if (tf == "4h") return H4;
        if (tf == "Daily") return D1;
        return M1;
    }

    Timeframe getEnumTimeframe(const QString &tf);

    Q_INVOKABLE void setTimeframe(const QString &newTimeframe);
    Q_INVOKABLE QVariantMap indexAggregate(int index, Timeframe fromTimeframe, Timeframe toTimeframe);
    QString timeframeGetter();
    QString timeframeToString(Timeframe tf);

    int comboIndex() const;
    void setComboIndex(int newComboIndex);

signals:
    void timeframeChanged();
    void aggReady(QVariantList candles);
    void comboIndexChanged();

private:
    QString m_timeframe = "1m";
    int     m_comboIndex= 0;
};
