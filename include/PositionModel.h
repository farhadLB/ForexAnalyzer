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
        EntryRole = Qt::DisplayRole + 1,
        StopLossRole,
        TakeProfitRole,
        TimeframeRole,
        PositionTypeRole,
        WinRole
    };

    int rowCount(const QModelIndex &parent) const;
    int columnCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

public slots:
    // TODO: connect this slot to position model
    void setPositionList(QList<Position> newList);

private:
    QList<Position> m_positionList;


    // QAbstractItemModel interface
public:
    QVariant headerData(int section, Qt::Orientation orientation, int role) const;
};

#endif // POSITIONMODEL_H
