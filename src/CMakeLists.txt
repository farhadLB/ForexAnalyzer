add_library(forexanalyzer_lib STATIC
    # Headers — MOC needs to see these
    ${CMAKE_SOURCE_DIR}/include/CsvLoader.h
    ${CMAKE_SOURCE_DIR}/include/TimeframeAggregator.h
    ${CMAKE_SOURCE_DIR}/include/ChartObjects.h
    ${CMAKE_SOURCE_DIR}/include/ChartObjectModel.h
    ${CMAKE_SOURCE_DIR}/include/LevelDetector.h
    ${CMAKE_SOURCE_DIR}/include/TrendlineDetector.h
    ${CMAKE_SOURCE_DIR}/include/HLevelBreaked.h

    # Sources
    CsvLoader.cpp
    TimeframeAggregator.cpp
    ChartObjectModel.cpp
    LevelDetector.cpp
    TrendlineDetector.cpp
    HLevelBreaked.cpp
)

target_link_libraries(forexanalyzer_lib PUBLIC Qt6::Core)

target_include_directories(forexanalyzer_lib PUBLIC
    ${CMAKE_SOURCE_DIR}/include
)
