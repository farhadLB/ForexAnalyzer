#include <QtTest>
#include "CsvLoader.h"

class TestCsvLoader : public QObject
{
    Q_OBJECT
private slots:

    void testLoadsCorrectRowCount()
    {
        CsvLoader Loader;
        QString fileUrl = "";
        QSignalSpy spy(&Loader, SIGNAL(fileLoaded(int)));
        Loader.loadFile(fileUrl);
        QCOMPARE(spy.count(), 2);
    }
};

QTEST_MAIN(TestCsvLoader)
#include "tst_csvloader.moc"
