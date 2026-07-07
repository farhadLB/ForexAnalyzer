#pragma once
#include <QObject>
#include <QWebSocket>
#include <QTimer>
#include <QVariantList>
#include <QMap>
#include <limits>
#include <ChartObjects.h>
#include <QSharedPointer>
#include <QNetworkReply>

class TwelveDataWorker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionChanged)

public:
    explicit TwelveDataWorker(QObject *parent = nullptr);
    ~TwelveDataWorker();

    Q_PROPERTY(bool isLoading READ isLoading WRITE setIsLoading NOTIFY isLoadingChanged FINAL)
    Q_PROPERTY(QString symbolDesc READ symbolDesc WRITE setSymbolDesc NOTIFY symbolDescChanged FINAL)
    Q_PROPERTY(QString first READ first WRITE setFirst NOTIFY firstChanged FINAL)
    Q_PROPERTY(QString second READ second WRITE setSecond NOTIFY secondChanged FINAL)
    Q_INVOKABLE void stream(const QString &interval);
    Q_INVOKABLE void setApiKey(const QString &apiKey);
    Q_INVOKABLE void setSymbol(const QString &first, const QString &second);
    Q_INVOKABLE bool hasApiKey();
    Q_INVOKABLE bool isConnected() const;
    void openWebSocket();
    QString symbolDesc() const;
    QString first() const;
    QString second() const;
    void setSymbolDesc(const QString &newSymbolDesc);
    void setFirst(const QString &newFirst);
    void setSecond(const QString &newSecond);
    bool isLoading() const;
    void setIsLoading(bool newIsLoading);

signals:
    void candlesReady(QSharedPointer<QVariantList> candles);
    void candleUpdated(QVariantMap candle);       // live update to last candle
    void candleAppended(QVariantMap candle);      // new candle started
    void axisRangeReady(double minY, double maxY);
    void fileLoaded(int count);
    void progressChanged(int percent);
    void connectionChanged(bool connected);
    void error(QString message);

    void symbolDescChanged();
    void firstChanged();
    void secondChanged();
    void isLoadingChanged();

public slots:
    Q_INVOKABLE void stopStreaming();

private slots:
    void onConnected();
    void onDisconnected();
    void onMessageReceived(const QString &message);
    void onPingTimer();

private:
    void subscribe();
    void fetchSnapshot();
    void processPrice(const QJsonObject &obj);
    QVariantMap candleToMap(const Candle &c) const;
    void updateAxisRange(double low, double high);
    void setupSocket();


    QWebSocket          *m_socket;
    QTimer              *m_pingTimer;
    QTimer              *m_reconnectTimer;

    QString              m_symbol = "EUR/USD";
    QString              m_symbolDesc = "Euro vs US Dollar";
    QString              m_first = "EUR";
    QString              m_second = "USD";
    QString              m_interval;
    QString              m_apiKey;
    bool                 m_connected = false;
    bool                 m_isLoading = false;
    double               m_minY = std::numeric_limits<double>::max();
    double               m_maxY = std::numeric_limits<double>::lowest();
    int                  m_reconnectAttempts = 0;
    QNetworkReply        *m_pendingReply = nullptr;

    // Current building candle
    Candle               m_currentCandle;
    bool                 m_hasCurrentCandle = false;
    QDateTime            m_currentCandleTime;
    int                  m_intervalSeconds = 60;


};
