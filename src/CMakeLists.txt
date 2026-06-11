find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)

add_library(forexanalyzer_lib STATIC
    # Headers — MOC needs to see these
    ${CMAKE_SOURCE_DIR}/include/CsvLoader.h
    ${CMAKE_SOURCE_DIR}/include/TimeframeAggregator.h
    ${CMAKE_SOURCE_DIR}/include/ChartObjects.h
    ${CMAKE_SOURCE_DIR}/include/ChartObjectModel.h
    ${CMAKE_SOURCE_DIR}/include/LevelDetector.h
    ${CMAKE_SOURCE_DIR}/include/TrendlineDetector.h
    ${CMAKE_SOURCE_DIR}/include/EntryPointCalculator.h
    ${CMAKE_SOURCE_DIR}/include/PositionManager.h
    ${CMAKE_SOURCE_DIR}/include/StopLossCalculator.h
    ${CMAKE_SOURCE_DIR}/include/TakeProfitCalculator.h
    ${CMAKE_SOURCE_DIR}/include/PositionModel.h

    # Sources
    CsvLoader.cpp
    TimeframeAggregator.cpp
    ChartObjectModel.cpp
    LevelDetector.cpp
    TrendlineDetector.cpp
    EntryPointCalculator.cpp
    PositionManager.cpp
    StopLossCalculator.cpp
    TakeProfitCalculator.cpp
    PositionModel.cpp
)

target_link_libraries(forexanalyzer_lib PUBLIC Qt6::Core)
target_link_libraries(forexanalyzer_lib PRIVATE Qt6::Core)
target_link_libraries(forexanalyzer_lib PRIVATE Qt6::Core)
target_link_libraries(forexanalyzer_lib PRIVATE Qt6::Core)

target_include_directories(forexanalyzer_lib PUBLIC
    ${CMAKE_SOURCE_DIR}/include
)
