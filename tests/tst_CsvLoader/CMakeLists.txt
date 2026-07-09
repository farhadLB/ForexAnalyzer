qt_add_executable(tst_csvloader tst_csvloader.cpp)
qt_add_executable(tst_aggregator tst_aggregator.cpp)

target_link_libraries(tst_csvloader PRIVATE
    Qt6::Concurrent
    Qt6::Test
    forexanalyzer_lib   # ← has CsvLoader + include paths, no main() conflict
)

target_link_libraries(tst_aggregator PRIVATE
    Qt6::Test
    forexanalyzer_lib
)

add_test(NAME tst_csvloader COMMAND tst_csvloader)
add_test(NAME tst_aggregator COMMAND tst_aggregator)
