#include "CsvLoader.h"
#include <QFile>
#include <QTextStream>
#include <QLocale>
#include <QUrl>
#include <QDebug>

CsvLoader::CsvLoader(QObject *parent)
    : QObject(parent)
{
}


bool CsvLoader::loadFile(const QString &fileUrl)
{
    QUrl url(fileUrl);
    QString path = url.isLocalFile() ? url.toLocalFile() : fileUrl;

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit error("Cannot open file");
        return false;
    }

    m_data.clear();
    QTextStream in(&file);

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty())
            continue;

        QStringList f = line.split(',');
        if (f.size() != 7)
            continue;

        QString dt = f[0] + " " + f[1];
        QDateTime time = QDateTime::fromString(dt, "yyyy.MM.dd HH:mm");
        if (!time.isValid())
            continue;

        Candle c;
        c.time   = time;
        c.open   = f[2].toDouble();
        c.high   = f[3].toDouble();
        c.low    = f[4].toDouble();
        c.close  = f[5].toDouble();
        c.volume = f[6].toDouble();

        m_data.append(c);
    }

    emit fileLoaded(m_data.size());

    QVariantList list;

    for (const Candle &c : std::as_const(m_data)) {
        QVariantMap m;
        m["time"]  = c.time.toMSecsSinceEpoch();
        m["open"]  = c.open;
        m["high"]  = c.high;
        m["low"]   = c.low;
        m["close"] = c.close;
        list.append(m);
    }

    emit candlesReady(list);

    double minY = std::numeric_limits<double>::max();
    double maxY = std::numeric_limits<double>::lowest();

    for (const Candle &c : std::as_const(m_data)) {
        minY = std::min(minY, c.low);
        maxY = std::max(maxY, c.high);
    }

    emit axisRangeReady(minY, maxY);


    return true;
}
