#pragma once
#include <QObject>
#include <QVariantList>
#include <QVector>
#include <ChartObjects.h>

class ChartObjectModel : public QObject
{
    Q_OBJECT
public:
    explicit ChartObjectModel(QObject *parent = nullptr);

    // --- Manual objects (for later (not used yet)) ---
    Q_INVOKABLE void addTrendline(qint64 sTime, double sPrice, qint64 eTime, double ePrice);
    Q_INVOKABLE void addHorizontalLevel(double price);

    // --- Auto objects ---
    Q_INVOKABLE void clearAutoLevels();
    Q_INVOKABLE void clearAutoTrendlines();
    Q_INVOKABLE void setAutoLevels(const QVariantList &levels);
    Q_INVOKABLE void setAutoTrendlines(const QVariantList &lines, const int start);

    Q_INVOKABLE QVariantList allTrendlines() const;                 // manual + auto trendlines
    Q_INVOKABLE QVariantList allLevels() const;                     // manual + auto

public slots:

    // --- Positions ---
    Q_INVOKABLE QVariantList positions();
    void getPositions(QList<Position> newList);

signals:
    void objectsChanged();

private:
    // --- Manual ---
    QVector<Trendline> m_manualTrendlines; // in case we want to add manual lines
    QVector<HorizontalLevel> m_manualLevels;

    // --- Auto ---
    QVector<Trendline>          m_autoTrendlines;
    QVector<HorizontalLevel>    m_autoLevels;
    QList<Position>             m_positionList;
};
