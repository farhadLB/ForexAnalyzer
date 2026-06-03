#include "test_csvloader.h"

testCsvLoader::testCsvLoader(QObject *parent)
    : QObject{parent}
{}

void testCsvLoader::initTestCase()
{
    CsvLoader Loader;
    QString fileUrl = "file:///C:/Users/LENOVO/Desktop/XAUUSD.csv";
    QSignalSpy spy(&Loader, SIGNAL(fileLoaded(int)));
    Loader.loadFile(fileUrl);
    QCOMPARE(spy.count(), 1);
}

void testCsvLoader::doNothing()
{
}

// QTEST_MAIN(testCsvLoader)
// #include "test_csvloader.moc"

