cmake_minimum_required(VERSION 3.16)

project(QSExtensions VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core Network)
find_package(yaml-cpp REQUIRED)

# 1. Find the PAM library
find_package(PkgConfig REQUIRED)
pkg_check_modules(PAM REQUIRED pam)

qt_standard_project_setup()

qt_add_qml_module(QSExtensions
    URI "extensions.build"
    VERSION 1.0
    SOURCES
        AiPlugin.h AiPlugin.cpp
        # 2. Add the new authenticator source
        PamAuth.h PamAuth.cpp
)

# 3. Include PAM directories
target_include_directories(QSExtensions PRIVATE ${PAM_INCLUDE_DIRS})

target_link_libraries(QSExtensions
    PRIVATE
    Qt6::Quick
    Qt6::Core
    Qt6::Network
    yaml-cpp
    # 4. Link PAM
    ${PAM_LIBRARIES}
)
