#include "PositionModel.h"

int PositionModel::rowCount(const QModelIndex &parent) const
{
    return m_positionList.size();
}

int PositionModel::columnCount(const QModelIndex &parent) const
{
    return 7;
}

QVariant PositionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_positionList.size()){
        return QVariant();
    }
    switch (role) {
    case IdxRole:           return index.row();
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
        {IdxRole,           "Idx"},
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
        case 0: return "Position ID";
        case 1: return "Entry Price";
        case 2: return "Stop Loss";
        case 3: return "Take Profit";
        case 4: return "Timeframe";
        case 5: return "Bullish";
        case 6: return "Successful";
        }
    }
    return QAbstractTableModel::headerData(section, orientation, role);
}
