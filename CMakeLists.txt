cmake_minimum_required(VERSION 3.16)
project(ForexAnalyzer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core QuickControls2 Charts Concurrent Network WebSockets)
qt_standard_project_setup(REQUIRES 6.8)

enable_testing()

add_subdirectory(src)

add_subdirectory(tests)

qt_standard_project_setup()

qt_add_executable(appForexAnalyzer src/main.cpp)

qt_add_qml_module(appForexAnalyzer
    URI ForexAnalyzer
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/ChartPage.qml
        qml/LeftBar.qml
        qml/ResultPage.qml
        qml/TitleBar.qml
        qml/ChartTools.qml
        qml/InfographyPage.qml
        qml/APIPage.qml
        qml/CurrencyModel.qml
        qml/components/CustomButton.qml
        qml/components/CandleChart.qml
        qml/components/CustomToggle.qml
        qml/components/CircularGauge.qml
        qml/components/OutcomeChart.qml
        qml/components/CustomProgressBar.qml
        qml/components/CustomRoundButton.qml
        qml/components/CustomComboBox.qml
        qml/components/GUIParameters.qml
        qml/components/CustomToolTip.qml
        qml/components/CustomSlider.qml
        qml/components/CustomTextField.qml
        qml/components/qmldir
        qml/popups/StrategyPopup.qml
        qml/popups/LoadChartPopup.qml
        RESOURCES assets/chart.jpg
        assets/slider-black-small.svg
        assets/slider-grey-small.svg
        assets/slider-white-small.svg
        assets/candle-black-small.svg
        assets/candle-grey-small.svg
        assets/candle-white-small.svg
        assets/chart-line-black.svg
        assets/chart-line-grey.svg
        assets/chart-line-white.svg
        assets/play-green.svg
        assets/play-grey.svg
        assets/table-black.svg
        assets/table-grey.svg
        assets/table-white.svg
        assets/position-black.svg
        assets/position-grey.svg
        assets/position-white.svg
        assets/left-arrow-black.svg
        assets/left-arrow-grey.svg
        assets/left-arrow-white.svg
        assets/right-arrow-black.svg
        assets/right-arrow-grey.svg
        assets/right-arrow-white.svg
        assets/tools-black.svg
        assets/tools-grey.svg
        assets/tools-white.svg
        assets/crosshair-black.svg
        assets/crosshair-grey.svg
        assets/crosshair-white.svg
        assets/dollar-black.svg
        assets/dollar-grey.svg
        assets/dollar-white.svg
        assets/moon-black.svg
        assets/moon-grey.svg
        assets/moon-white.svg
        assets/sun-black.svg
        assets/sun-grey.svg
        assets/sun-white.svg
        assets/api-black.svg
        assets/api-grey.svg
        assets/api-white.svg
        assets/load-black.svg
        assets/load-grey.svg
        assets/load-white.svg
        assets/flags/aud.svg
        assets/flags/cad.svg
        assets/flags/chf.svg
        assets/flags/eur.svg
        assets/flags/gbp.svg
        assets/flags/jpy.svg
        assets/flags/nzd.svg
        assets/flags/usd.svg
)

target_link_libraries(appForexAnalyzer PRIVATE
    forexanalyzer_lib
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Charts
    Qt6::Concurrent
    Qt6::Network
    Qt6::WebSockets
)

set_target_properties(appForexAnalyzer PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS appForexAnalyzer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
