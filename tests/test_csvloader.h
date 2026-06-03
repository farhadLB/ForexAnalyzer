#ifndef TEST_CSVLOADER_H
#define TEST_CSVLOADER_H

#include <QObject>
#include <QTest>
#include <QSignalSpy>
#include "../include/CsvLoader.h"

class testCsvLoader : public QObject
{
    Q_OBJECT
public:
    explicit testCsvLoader(QObject *parent = nullptr);

signals:

private slots:
    void initTestCase();
    void doNothing();
};

#endif // TEST_CSVLOADER_H
