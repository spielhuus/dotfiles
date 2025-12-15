# --- START OF FILE quickshell/extensions/CMakeLists.txt ---
cmake_minimum_required(VERSION 3.16)

# This project name is for the binary file, e.g., libQSExtensions.so
project(QSExtensions VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core)
find_package(yaml-cpp REQUIRED)

qt_standard_project_setup()

qt_add_qml_module(QSExtensions
    URI "extensions.build"
    VERSION 1.0
    SOURCES
        AiPlugin.h AiPlugin.cpp
)

target_link_libraries(QSExtensions
    PRIVATE
    Qt6::Quick
    Qt6::Core
    yaml-cpp
)
