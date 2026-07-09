#include <QtTest>
#include <TimeframeAggregator.h>
#include <ChartObjects.h>

class TestAggregator : public QObject
{
    Q_OBJECT
private slots:
    void test_M5_Aggregation_CandleCount();
    void test_M5_Aggregation_ohlc();
    void test_lessCandlesThanStep();
    void test_M5_aggregation_firstCandleTime();

};

QVariantMap makeCandle(qint64 timeMs, double open, double high, double low, double close) {
    QVariantMap m;
    m["time"]  = timeMs;
    m["open"]  = open;
    m["high"]  = high;
    m["low"]   = low;
    m["close"] = close;
    return m;
}

// --- Aggregate 10 candles in M5 and comapre the result candles count ---
void TestAggregator::test_M5_Aggregation_CandleCount()
{
    QVariantList candles;
    for(int i = 0; i < 10; i++){
        candles.append(makeCandle(i * 60000, 1.1, 1.2, 1.0, 1.15));
    }
    TimeframeAggregator agg;
    QVariantList result = agg.aggregate(candles, TimeframeAggregator::M5);
    QCOMPARE(result.size(), 2);
}

// --- Aggregate 5 candles in M5 and compare the OHLC values
void TestAggregator::test_M5_Aggregation_ohlc()
{
    QVariantList input;
    input.append(makeCandle(0,      1.10, 1.15, 1.08, 1.12));  // open of group
    input.append(makeCandle(60000,  1.12, 1.20, 1.10, 1.18));  // highest high
    input.append(makeCandle(120000, 1.18, 1.19, 1.05, 1.10));  // lowest low
    input.append(makeCandle(180000, 1.09, 1.13, 1.09, 1.11));
    input.append(makeCandle(240000, 1.11, 1.14, 1.10, 1.17));  // close of group

    TimeframeAggregator agg;
    QVariantList result = agg.aggregate(input, TimeframeAggregator::M5);
    QVariantMap candle = result[0].toMap();
    QCOMPARE(candle["open"].toDouble(),  1.10);
    QCOMPARE(candle["high"].toDouble(),  1.20);
    QCOMPARE(candle["low"].toDouble(),   1.05);
    QCOMPARE(candle["close"].toDouble(), 1.17);
}

// 3 candles with M5 should still produce 1 candle
void TestAggregator::test_lessCandlesThanStep()
{
    QVariantList input;
    input.append(makeCandle(0,      1.10, 1.15, 1.08, 1.12));
    input.append(makeCandle(60000,  1.12, 1.18, 1.10, 1.15));
    input.append(makeCandle(120000, 1.15, 1.20, 1.12, 1.19));

    TimeframeAggregator agg;
    QVariantList result = agg.aggregate(input, TimeframeAggregator::M5);

    QCOMPARE(result.size(), 1);
    QCOMPARE(result[0].toMap()["open"].toDouble(),  1.10);
    QCOMPARE(result[0].toMap()["high"].toDouble(),  1.20);
    QCOMPARE(result[0].toMap()["low"].toDouble(),   1.08);
    QCOMPARE(result[0].toMap()["close"].toDouble(), 1.19);
}

// Time of M5 candle should be time of first M1 candle in the group
void TestAggregator::test_M5_aggregation_firstCandleTime()
{
    QVariantList input;
    qint64 startTime = 1700000000000LL;
    for (int i = 0; i < 5; ++i)
        input.append(makeCandle(startTime + i * 60000, 1.1, 1.2, 1.0, 1.15));

    TimeframeAggregator agg;
    QVariantList result = agg.aggregate(input, TimeframeAggregator::M5);

    QCOMPARE(result.size(), 1);
    QCOMPARE(result[0].toMap()["time"].toLongLong(), startTime);
}

QTEST_MAIN(TestAggregator)
#include "tst_aggregator.moc"

