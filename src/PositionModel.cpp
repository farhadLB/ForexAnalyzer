#include "PositionModel.h"

int PositionModel::rowCount(const QModelIndex &parent) const
{
    return m_positionList.size();
}

int PositionModel::columnCount(const QModelIndex &parent) const
{
    return 6;
}

QVariant PositionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_positionList.size()){
        return QVariant();
    }
    switch (role) {
    case EntryRole:         return m_positionList[index.row()].EntryPointPrice;
    case StopLossRole:      return m_positionList[index.row()].StopLossPrice;
    case TakeProfitRole:    return m_positionList[index.row()].TakeProfitPrice;
    case TimeframeRole:     return m_positionList[index.row()].Timeframe;
    case PositionTypeRole:  return m_positionList[index.row()].isBullish;
    case WinRole:           return m_positionList[index.row()].isWin;
    }
    return QVariant();
}

QHash<int, QByteArray> PositionModel::roleNames() const
{
    return {
        {Qt::DisplayRole,   "display"},
        {EntryRole,         "EntryPrice"},
        {StopLossRole,      "StopLoss"},
        {TakeProfitRole,    "TakeProfit"},
        {TimeframeRole,     "Timeframe"},
        {PositionTypeRole,  "Type"},
        {WinRole,           "Win"}
    };
}

void PositionModel::setPositionList(QList<Position> newList)
{
    beginResetModel();
    m_positionList = newList;
    qInfo()<< m_positionList.size();
    endResetModel();
}

QVariant PositionModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (orientation == Qt::Horizontal && role == Qt::DisplayRole) {
        switch (section) {
        case 0: return "Entry Price";
        case 1: return "Stop Loss";
        case 2: return "Take Profit";
        case 3: return "Timeframe";
        case 4: return "Bullish";
        case 5: return "Successful";
        }
    }
    return QAbstractTableModel::headerData(section, orientation, role);
}
