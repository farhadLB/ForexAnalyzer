#pragma once
#include <QObject>
#include <QVariantList>
#include <QVariantMap>

class CandleModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList candles READ candles NOTIFY candlesChanged)
    Q_PROPERTY(bool isEmpty READ isEmpty NOTIFY candlesChanged)
    Q_PROPERTY(bool isFromCSV READ isFromCSV WRITE setIsFromCSV NOTIFY isFromCSVChanged FINAL)

public:
    explicit CandleModel(QObject *parent = nullptr);

    QVariantList candles() const;
    bool isEmpty() const;

    // Called from QML or C++
    Q_INVOKABLE void loadCandles(QSharedPointer<QVariantList> candles);
    Q_INVOKABLE void loadCandles(const QVariantList &candles);
    Q_INVOKABLE void updateLast(const QVariantMap &candle);     // live tick update
    Q_INVOKABLE void append(const QVariantMap &candle);         // new candle started
    Q_INVOKABLE void clear();

    bool isFromCSV() const;
    void setIsFromCSV(bool newIsFromCSV);

signals:
    void candlesChanged();          // triggers chart re-render with onCandlesChanged
    void lastCandleUpdated();       // for tick updates only
    void axisRangeReady(double minY, double maxY);
    void clearingModel();
    void isFromCSVChanged();

private:
    void recalcAxisRange();

    QVariantList m_candles;
    bool         m_isFromCSV = false;
};