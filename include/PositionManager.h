#ifndef POSITIONMANAGER_H
#define POSITIONMANAGER_H

#include <QObject>
#include <ChartObjects.h>
#include <CsvLoader.h>
#include <TimeframeAggregator.h>

class PositionManager : public QObject
{
    Q_OBJECT
public:
    explicit PositionManager(CsvLoader* loader,
                             TimeframeAggregator *agg,
                             QObject *parent = nullptr);
    void setPositions(QList<Position> newList);
    QList<Position> getPositions();
    QList<Position> positionList;

public slots:
    void run();

signals:
    void positionListReady(QList<Position> list);

private:
    CsvLoader*              m_loader;
    TimeframeAggregator*    m_agg;
    QVariantList            m_candles;
};

#endif // POSITIONMANAGER_H
