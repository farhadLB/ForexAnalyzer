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

    // --- Accessors ---
    Q_INVOKABLE QVariantList allTrendlines() const;                 // manual + auto trendlines
    Q_INVOKABLE QVariantList allLevels() const;                     // manual + auto
    // Q_INVOKABLE QVariantList manualTrendlines() const;           // فقط manual
    // Q_INVOKABLE QVariantList horizontalLevels() const;           // فقط manual

signals:
    void objectsChanged();

private:
    // --- Manual ---
    QVector<Trendline> m_manualTrendlines; // in case we want to add manual lines
    QVector<HorizontalLevel> m_manualLevels;

    // --- Auto ---
    QVector<Trendline> m_autoTrendlines;
    QVector<HorizontalLevel> m_autoLevels;
};
