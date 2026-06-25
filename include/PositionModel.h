#ifndef POSITIONMODEL_H
#define POSITIONMODEL_H

#include <QObject>
#include <QAbstractTableModel>
#include <ChartObjects.h>

class PositionModel : public QAbstractTableModel
{
    Q_OBJECT
public:

    enum roles{
        IdxRole = Qt::DisplayRole + 1,
        EntryRole,
        StopLossRole,
        TakeProfitRole,
        TimeframeRole,
        PositionTypeRole,
        WinRole
    };

    QVariant headerData(int section, Qt::Orientation orientation, int role) const;
    int rowCount(const QModelIndex &parent) const;
    int columnCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

public slots:
    void setPositionList(QList<Position> newList);

private:
    QList<Position> m_positionList;

};

#endif // POSITIONMODEL_H
