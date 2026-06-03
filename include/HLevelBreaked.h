#ifndef HLEVELBREAKED_H
#define HLEVELBREAKED_H

#include <QObject>
#include <CsvLoader.h>
#include <LevelDetector.h>

class HLevelBreaked : public QObject
{
    Q_OBJECT
public:
    explicit HLevelBreaked(CsvLoader* csvLoader,QObject *parent = nullptr);
    LevelDetector levelDetector;

public slots:
    void getCandles(QVariantList list);
    void getLevels();

private:
    QVariantList Candles;
    QVariantList m_levels;
};

#endif // HLEVELBREAKED_H
