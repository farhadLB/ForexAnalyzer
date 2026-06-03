#include "hlevelbreaked.h"

HLevelBreaked::HLevelBreaked(CsvLoader *csvLoader, QObject *parent): QObject(parent) {
    connect(csvLoader, &CsvLoader::candlesReady, this, &HLevelBreaked::getCandles);
}

void HLevelBreaked::getCandles(QVariantList list)
{
    Candles = list;
}

void HLevelBreaked::getLevels()
{
    QVariantList subList;

    for(int i=0; i<Candles.size(); i++){
        subList = Candles.mid(i, qMin(250, Candles.size()-i));
        m_levels = levelDetector.detectLocalLevels(subList, 10);
        // we have the levels here
    }
}
