#include "CsvWorker.h"
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QTimeZone>
#include <QUrl>
#include <limits>

CsvWorker::CsvWorker(QObject *parent) : QObject(parent) {}

void CsvWorker::requestCancel()
{
    m_cancelRequested.store(true);
}

// --- DateTime Parser from CSV file ---
static QDateTime parseDateTime(const QByteArray &datePart, const QByteArray &timePart)
{
    if (datePart.size() < 10 || timePart.size() < 5)
        return QDateTime();

    const int year  = datePart.sliced(0, 4).toInt();
    const int month = datePart.sliced(5, 2).toInt();
    const int day   = datePart.sliced(8, 2).toInt();
    const int hour  = timePart.sliced(0, 2).toInt();
    const int min   = timePart.sliced(3, 2).toInt();

    return QDateTime(QDate(year, month, day), QTime(hour, min), QTimeZone::UTC);
}

void CsvWorker::loadFile(const QString &filePath)
{
    m_cancelRequested.store(false);

    QUrl url(filePath);
    QString path = url.isLocalFile() ? url.toLocalFile() : filePath;

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit error("Cannot open file: " + path);
        return;
    }

    const qint64 totalSize = file.size();
    QVector<Candle> data;
    data.reserve(100000);

    while (!file.atEnd()) {
        if (m_cancelRequested.load()) {
            emit error("Cancelled");
            return;
        }

        const QByteArray line = file.readLine().trimmed();
        if (line.isEmpty()) continue;

        const QList<QByteArray> f = line.split(',');
        if (f.size() != 7) continue;

        const QDateTime time = parseDateTime(f[0].trimmed(), f[1].trimmed());
        if (!time.isValid()) continue;

        Candle c;
        c.time   = time;
        c.open   = f[2].toDouble();
        c.high   = f[3].toDouble();
        c.low    = f[4].toDouble();
        c.close  = f[5].toDouble();
        c.volume = f[6].toDouble();
        data.append(c);

        if (data.size() % 2000 == 0)
            emit progressChanged(int(file.pos() * 100 / totalSize));
    }

    QVariantList list;
    list.reserve(data.size());
    double minY = std::numeric_limits<double>::max();
    double maxY = std::numeric_limits<double>::lowest();

    for (const Candle &c : std::as_const(data)) {
        QVariantMap m;
        m["time"]  = c.time.toMSecsSinceEpoch();
        m["open"]  = c.open;
        m["high"]  = c.high;
        m["low"]   = c.low;
        m["close"] = c.close;
        list.append(m);

        minY = std::min(minY, c.low);
        maxY = std::max(maxY, c.high);
    }

    emit progressChanged(100);
    emit fileLoaded(data.size());
    emit candlesReady(list);
    emit axisRangeReady(minY, maxY);
}
