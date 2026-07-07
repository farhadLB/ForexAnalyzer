#include "PositionModel.h"

int PositionModel::rowCount(const QModelIndex &parent) const
{
    return m_positionList.size();
}

int PositionModel::columnCount(const QModelIndex &parent) const
{
    return 11;
}

QVariant PositionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_positionList.size())
        return QVariant();

    const Position &pos = m_positionList[index.row()];

    if (role == Qt::DisplayRole) {
        switch (index.column()) {
        case 0: return index.row();
        case 1: return pos.EntryPointPrice;
        case 2: return pos.StopLossPrice;
        case 3: return pos.TakeProfitPrice;
        case 4: return pos.Timeframe;
        case 5: return pos.isBullish;
        case 6: return pos.isWin;
        case 7: return pos.ADX;
        case 8: return pos.PlusDI;
        case 9: return pos.MinusDI;
        case 10: return pos.TrendAligned;
        }
    }

    switch (role) {
    case IdxRole:           return index.row();
    case EntryRole:         return pos.EntryPointPrice;
    case StopLossRole:      return pos.StopLossPrice;
    case TakeProfitRole:    return pos.TakeProfitPrice;
    case TimeframeRole:     return pos.Timeframe;
    case PositionTypeRole:  return pos.isBullish;
    case WinRole:           return pos.isWin;
    case ADXRole:           return pos.ADX;
    case PlusDIRole:        return pos.PlusDI;
    case MinusDIRole:       return pos.MinusDI;
    case TrendAlignedRole:  return pos.TrendAligned;
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
        {WinRole,           "Win"},
        {ADXRole,           "ADX"},
        {PlusDIRole,        "PlusDI"},
        {MinusDIRole,       "MinusDI"},
        {TrendAlignedRole,  "TrendAligned"}
    };
}

void PositionModel::clearData()
{
    beginResetModel();
    m_positionList.clear();
    endResetModel();
}

void PositionModel::setPositionList(QList<Position> newList)
{
    beginResetModel();
    m_positionList = newList;
    qDebug() << "size: " << m_positionList.size();
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
        case 7: return "ADX";
        case 8: return "PlusDI";
        case 9: return "MinusDI";
        case 10: return "TrendAligned";
        }
    }
    return QAbstractTableModel::headerData(section, orientation, role);
}
