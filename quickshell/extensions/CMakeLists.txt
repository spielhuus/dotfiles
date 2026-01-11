cmake_minimum_required(VERSION 3.16)

# Enable C language support (required for the generated Wayland code)
project(QSExtensions VERSION 0.1 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core Network)
find_package(yaml-cpp REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(PAM REQUIRED pam)
find_package(Wayland REQUIRED COMPONENTS Client)

find_program(WAYLAND_SCANNER_EXECUTABLE NAMES wayland-scanner)

# --- Define Protocol Paths ---
set(PROTOCOL_XML ${CMAKE_CURRENT_SOURCE_DIR}/wlr-output-power-management-unstable-v1.xml)
set(PROTOCOL_HEADER ${CMAKE_CURRENT_BINARY_DIR}/wlr-output-power-management-unstable-v1-client-protocol.h)
set(PROTOCOL_CODE ${CMAKE_CURRENT_BINARY_DIR}/wlr-output-power-management-unstable-v1-protocol.c)

# --- Generate Protocol Files ---
add_custom_command(
    OUTPUT ${PROTOCOL_HEADER}
    COMMAND ${WAYLAND_SCANNER_EXECUTABLE} client-header ${PROTOCOL_XML} ${PROTOCOL_HEADER}
    DEPENDS ${PROTOCOL_XML}
)

add_custom_command(
    OUTPUT ${PROTOCOL_CODE}
    COMMAND ${WAYLAND_SCANNER_EXECUTABLE} private-code ${PROTOCOL_XML} ${PROTOCOL_CODE}
    DEPENDS ${PROTOCOL_XML}
)

qt_standard_project_setup()

# --- Build the QML Module ---
qt_add_qml_module(QSExtensions
    URI "extensions.build"
    VERSION 1.0
    SOURCES
        AiPlugin.h AiPlugin.cpp
        PamAuth.h PamAuth.cpp
        WaylandPower.h WaylandPower.cpp
        
        # Explicitly include the generated protocol files here
        ${PROTOCOL_HEADER}
        ${PROTOCOL_CODE}
)

# Allow #include <wlr-...-protocol.h> to work
target_include_directories(QSExtensions PRIVATE 
    ${PAM_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(QSExtensions
    PRIVATE
    Qt6::Quick
    Qt6::Core
    Qt6::Network
    Wayland::Client
    yaml-cpp
    ${PAM_LIBRARIES}
)
