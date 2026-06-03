#include <QtTest>
#include "CsvLoader.h"   // works because forexanalyzer_lib exposes include/

class TestCsvLoader : public QObject
{
    Q_OBJECT
private slots:

    void testLoadsCorrectRowCount()
    {
        CsvLoader Loader;
        QString fileUrl = "file:///C:/Users/LENOVO/Desktop/XAUUSD.csv";
        QSignalSpy spy(&Loader, SIGNAL(fileLoaded(int)));
        Loader.loadFile(fileUrl);
        QCOMPARE(spy.count(), 2);
    }
};

QTEST_MAIN(TestCsvLoader)
#include "tst_csvloader.moc"
