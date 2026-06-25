qt_add_executable(tst_csvloader tst_csvloader.cpp)

target_link_libraries(tst_csvloader PRIVATE
    Qt6::Concurrent
    Qt6::Test
    forexanalyzer_lib   # ← has CsvLoader + include paths, no main() conflict
)

add_test(NAME tst_csvloader COMMAND tst_csvloader)
