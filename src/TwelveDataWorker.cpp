#include "TwelveDataWorker.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDateTime>
#include <QTimeZone>
#include <QtWebSockets/QWebSocket>

static int intervalToSeconds(const QString &interval) {
    if (interval == "1min")  return 60;
    if (interval == "5min")  return 300;
    if (interval == "15min") return 900;
    if (interval == "30min") return 1800;
    if (interval == "45min") return 2700;
    if (interval == "1h")    return 3600;
    return 60;
}

TwelveDataWorker::TwelveDataWorker(QObject *parent)
    : QObject(parent)
    , m_socket(new QWebSocket(QString(), QWebSocketProtocol::VersionLatest, this))
    , m_pingTimer(new QTimer(this))
    , m_reconnectTimer(new QTimer(this))
{
    QObject::connect(m_socket, &QWebSocket::connected,    this, &TwelveDataWorker::onConnected);
    QObject::connect(m_socket, &QWebSocket::disconnected, this, &TwelveDataWorker::onDisconnected);
    QObject::connect(m_socket, &QWebSocket::textMessageReceived,
                     this, &TwelveDataWorker::onMessageReceived);

    setupSocket();
    m_pingTimer->setInterval(10000);
    QObject::connect(m_pingTimer, &QTimer::timeout, this, &TwelveDataWorker::onPingTimer);

    // Auto-reconnect
    m_reconnectTimer->setSingleShot(true);
    QObject::connect(m_reconnectTimer, &QTimer::timeout, this, [this]() {
        if (!m_symbol.isEmpty())
            openWebSocket();
    });
}

TwelveDataWorker::~TwelveDataWorker() {
    if (m_socket) {
        m_socket->blockSignals(true);
        m_socket->abort();
    }
}

void TwelveDataWorker::stream(const QString &interval)
{
    stopStreaming();
    m_interval        = interval;
    m_intervalSeconds = intervalToSeconds(interval);
    m_hasCurrentCandle = false;

    emit progressChanged(10);
    setIsLoading(true);
    fetchSnapshot();
}

void TwelveDataWorker::setApiKey(const QString &apiKey)
{
    m_apiKey = apiKey;
}

void TwelveDataWorker::setSymbol(const QString &first, const QString &second)
{
    m_symbol = first + "/" + second;
    emit symbolDescChanged();
}

bool TwelveDataWorker::hasApiKey()
{
    return !m_apiKey.isEmpty();
}

void TwelveDataWorker::fetchSnapshot()
{
    // Get last 1000 closed candles as the initial chart data
    auto *nam = new QNetworkAccessManager(this);
    QString url = QString(
                      "https://api.twelvedata.com/time_series"
                      "?symbol=%1&interval=%2&outputsize=1000&apikey=%3&format=JSON&timezone=UTC"
                      ).arg(m_symbol, m_interval, m_apiKey);

    m_pendingReply = nam->get(QNetworkRequest(QUrl(url)));

    QNetworkReply *reply = m_pendingReply;

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, nam]() {
        reply->deleteLater();
        nam->deleteLater();

        if (reply != m_pendingReply) return;
        m_pendingReply = nullptr;

        if (reply->error() != QNetworkReply::NoError) {
            if (reply->error() == QNetworkReply::OperationCanceledError) return;
            emit error("Snapshot fetch failed: " + reply->errorString());
            return;
        }

        const QJsonObject root = QJsonDocument::fromJson(reply->readAll()).object();

        if (root["status"].toString() != "ok") {
            qDebug() << "STATUS:" << root["status"].toString();
            emit error("Twelve Data error: " + root["message"].toString());
            return;
        }

        // qDebug() << "Status OK, candle count:" << root["values"].toArray().size();


        const QJsonArray values = root["values"].toArray();
        auto list = QSharedPointer<QVariantList>::create();
        list->reserve(values.size());

        for (int i = values.size() - 1; i >= 0; --i) {
            const QJsonObject bar = values[i].toObject();
            QDateTime time = QDateTime::fromString(
                bar["datetime"].toString(), "yyyy-MM-dd HH:mm:ss");
            time.setTimeZone(QTimeZone::UTC);

            const double open  = bar["open"].toString().toDouble();
            const double high  = bar["high"].toString().toDouble();
            const double low   = bar["low"].toString().toDouble();
            const double close = bar["close"].toString().toDouble();

            QVariantMap m;
            m["time"]  = time.toMSecsSinceEpoch();
            m["open"]  = open;
            m["high"]  = high;
            m["low"]   = low;
            m["close"] = close;
            list->append(m);

            m_minY = std::min(m_minY, low);
            m_maxY = std::max(m_maxY, high);
        }

        emit progressChanged(60);
        emit fileLoaded(list->size());
        emit candlesReady(list);
        emit axisRangeReady(m_minY, m_maxY);
        emit progressChanged(100);
        setIsLoading(false);

        openWebSocket();
    });
}

void TwelveDataWorker::openWebSocket()
{
    m_socket->open(QUrl("wss://ws.twelvedata.com/v1/quotes/price?apikey=" + m_apiKey));
}

void TwelveDataWorker::stopStreaming()
{
    m_pingTimer->stop();
    m_reconnectTimer->stop();

    if (m_pendingReply) {
        m_pendingReply->blockSignals(true);
        m_pendingReply->abort();
        m_pendingReply = nullptr;
    }

    if (m_socket->state() != QAbstractSocket::UnconnectedState) {
        m_socket->blockSignals(true);
        m_socket->abort();
        m_socket->blockSignals(false);
    }

    setupSocket();

    m_connected = false;
    setIsLoading(false);
    emit connectionChanged(false);
}

bool TwelveDataWorker::isConnected() const {
    return m_connected;
}

void TwelveDataWorker::onConnected()
{
    m_connected = true;
    m_reconnectAttempts = 0;
    m_pingTimer->start();
    emit connectionChanged(true);
    subscribe();
}

void TwelveDataWorker::subscribe()
{
    QJsonObject msg;
    msg["action"] = "subscribe";
    msg["params"] = QJsonObject{
        {"symbols", m_symbol}
    };
    m_socket->sendTextMessage(QJsonDocument(msg).toJson(QJsonDocument::Compact));
}

void TwelveDataWorker::onDisconnected()
{
    m_connected = false;
    m_pingTimer->stop();
    emit connectionChanged(false);

    if (m_reconnectAttempts < 6) {
        int delay = std::min(2000 * (1 << m_reconnectAttempts), 30000);
        m_reconnectAttempts++;
        emit error(QString("Disconnected. Reconnecting in %1s...").arg(delay / 1000));
        m_reconnectTimer->start(delay);
    } else {
        emit error("Max reconnect attempts reached. Call connect() to retry.");
    }
}

void TwelveDataWorker::onPingTimer()
{
    // Twelve Data requires a heartbeat every 10s or it closes the connection
    QJsonObject ping;
    ping["action"] = "heartbeat";
    m_socket->sendTextMessage(QJsonDocument(ping).toJson(QJsonDocument::Compact));
}

void TwelveDataWorker::onMessageReceived(const QString &message)
{
    const QJsonObject obj = QJsonDocument::fromJson(message.toUtf8()).object();
    const QString event = obj["event"].toString();

    if (event == "price")      { processPrice(obj); return; }
    if (event == "heartbeat")  { return; }
    if (event == "subscribe-status") {
        if (obj["status"].toString() != "ok")
            emit error("Subscribe failed: " + obj["message"].toString());
        return;
    }
}

void TwelveDataWorker::processPrice(const QJsonObject &obj)
{
    // Twelve Data sends: { event, symbol, price, timestamp }
    const double price = obj["price"].toDouble();
    const qint64 timestamp = obj["timestamp"].toVariant().toLongLong() * 1000LL; // to ms
    const QDateTime time   = QDateTime::fromMSecsSinceEpoch(timestamp, QTimeZone::UTC);

    const qint64 intervalMs    = m_intervalSeconds * 1000LL;
    const qint64 candleStartMs = (timestamp / intervalMs) * intervalMs;
    const QDateTime candleTime = QDateTime::fromMSecsSinceEpoch(candleStartMs, QTimeZone::UTC);

    if (!m_hasCurrentCandle) {
        m_currentCandle = { candleTime, price, price, price, price, 0 };
        m_currentCandleTime = candleTime;
        m_hasCurrentCandle = true;

    } else if (candleTime != m_currentCandleTime) {
        emit candleAppended(candleToMap(m_currentCandle));
        m_currentCandle = { candleTime, price, price, price, price, 0 };
        m_currentCandleTime = candleTime;

    } else {
        m_currentCandle.high  = std::max(m_currentCandle.high, price);
        m_currentCandle.low   = std::min(m_currentCandle.low,  price);
        m_currentCandle.close = price;
    }

    updateAxisRange(m_currentCandle.low, m_currentCandle.high);
    emit candleUpdated(candleToMap(m_currentCandle));
}

QVariantMap TwelveDataWorker::candleToMap(const Candle &c) const {
    return {
        {"time",  c.time.toMSecsSinceEpoch()},
        {"open",  c.open},
        {"high",  c.high},
        {"low",   c.low},
        {"close", c.close}
    };
}

void TwelveDataWorker::updateAxisRange(double low, double high) {
    bool changed = false;
    if (low  < m_minY) { m_minY = low;  changed = true; }
    if (high > m_maxY) { m_maxY = high; changed = true; }
    if (changed) emit axisRangeReady(m_minY, m_maxY);
}

void TwelveDataWorker::setupSocket()
{
    if (m_socket) {
        m_socket->blockSignals(true);
        m_socket->abort();
        m_socket->deleteLater();
    }

    m_socket = new QWebSocket(QString(), QWebSocketProtocol::VersionLatest, this);

    QObject::connect(m_socket, &QWebSocket::connected,
                     this, &TwelveDataWorker::onConnected);
    QObject::connect(m_socket, &QWebSocket::disconnected,
                     this, &TwelveDataWorker::onDisconnected);
    QObject::connect(m_socket, &QWebSocket::textMessageReceived,
                     this, &TwelveDataWorker::onMessageReceived);
}

bool TwelveDataWorker::isLoading() const
{
    return m_isLoading;
}

void TwelveDataWorker::setIsLoading(bool newIsLoading)
{
    if (m_isLoading == newIsLoading)
        return;
    m_isLoading = newIsLoading;
    emit isLoadingChanged();
}

QString TwelveDataWorker::second() const
{
    return m_second;
}

void TwelveDataWorker::setSecond(const QString &newSecond)
{
    if (m_second == newSecond)
        return;
    m_second = newSecond;
    emit secondChanged();
}

QString TwelveDataWorker::first() const
{
    return m_first;
}

void TwelveDataWorker::setFirst(const QString &newFirst)
{
    if (m_first == newFirst)
        return;
    m_first = newFirst;
    emit firstChanged();
}

QString TwelveDataWorker::symbolDesc() const
{
    return m_symbolDesc;
}

void TwelveDataWorker::setSymbolDesc(const QString &newSymbolDesc)
{
    if (m_symbolDesc == newSymbolDesc)
        return;
    m_symbolDesc = newSymbolDesc;
    emit symbolDescChanged();
}
