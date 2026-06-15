cmake_minimum_required(VERSION 3.16)
project(ForexAnalyzer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core QuickControls2 Charts)
qt_standard_project_setup(REQUIRES 6.8)

enable_testing()

# Library of all your business logic
add_subdirectory(src)

add_subdirectory(tests)

qt_standard_project_setup()

# App target stays in root — QML paths are clean
qt_add_executable(appForexAnalyzer src/main.cpp)

qt_add_qml_module(appForexAnalyzer
    URI ForexAnalyzer
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/ChartPage.qml
        qml/LeftBar.qml
        qml/ResultPage.qml
        qml/components/CustomButton.qml
        qml/components/CandleChart.qml
        qml/components/CustomToggle.qml
        qml/components/AccordionItem.qml
        qml/InfographyPage.qml
        qml/components/CircularGauge.qml
        QML_FILES qml/components/OutcomeChart.qml
)

target_link_libraries(appForexAnalyzer PRIVATE
    forexanalyzer_lib       # your classes
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Charts
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
