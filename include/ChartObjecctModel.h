#pragma once
#include <QObject>
#include <QVariantList>
#include <QVector>
#include <include/ChartObjects.h>

class ChartObjectModel : public QObject
{
    Q_OBJECT
public:
    explicit ChartObjectModel(QObject *parent = nullptr);

    // --- Manual objects ---
    Q_INVOKABLE void addTrendline(qint64 sTime, double sPrice, qint64 eTime, double ePrice);
    Q_INVOKABLE void addHorizontalLevel(double price);

    // --- Auto objects ---
    Q_INVOKABLE void clearAutoLevels();
    Q_INVOKABLE void clearAutoTrendlines();
    Q_INVOKABLE void setAutoLevels(const QVariantList &levels);
    Q_INVOKABLE void setAutoTrendlines(const QVariantList &lines, const int start);

    // --- Accessors ---
    Q_INVOKABLE QVariantList trendlines() const;           // manual + auto trendlines (در صورت نیاز)
    Q_INVOKABLE QVariantList horizontalLevels() const;     // فقط manual
    Q_INVOKABLE QVariantList allLevels() const;            // manual + auto
    Q_INVOKABLE QVariantList allTrendlines() const;            // manual + auto

signals:
    void objectsChanged();

private:
    // --- Manual ---
    QVector<Trendline> m_manualTrendlines;
    QVector<HorizontalLevel> m_manualLevels;

    // --- Auto ---
    QVector<Trendline> m_autoTrendlines;     // اگر بخواهیم auto trendline هم اضافه کنیم
    QVector<HorizontalLevel> m_autoLevels;
};
