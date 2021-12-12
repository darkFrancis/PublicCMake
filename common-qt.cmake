# Author : Dark Francis
# Date : 13.11.2021

# Common CMake Qt script

# C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Autobuild Qt
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Shared libs
option(BUILD_SHARED_LIBS "Build using shared libraries" ON)

# CCache
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
endif()

### Fonctions

### set_qt5_modules [modules...]
# Add modules to _QT5_MODULES_ list for further use and find packages
macro(set_qt5_modules)
    foreach(module IN ITEMS ${ARGN})
        find_package(Qt5${module} REQUIRED)
        list(APPEND _QT5_MODULES_ Qt5::${module})
    endforeach()
    message(STATUS "_QT5_MODULES_ = ${_QT5_MODULES_}")
endmacro(set_qt5_modules)

### set_ui_paths [paths...]
# Add paths for ui file search
macro(set_ui_paths)
    set(CMAKE_AUTOUIC_SEARCH_PATHS ${ARGN})
endmacro(set_ui_paths)

### set_common_defines
macro(set_common_defines)
    if(NOT DEFINED _DEFINED_VERSION)
        target_compile_definitions(${PROJECT_NAME} PUBLIC _DEFINED_VERSION="${PROJECT_VERSION}")
    endif()
    if(NOT DEFINED _DEFINED_APPNAME)
        target_compile_definitions(${PROJECT_NAME} PUBLIC _DEFINED_APPNAME="${PROJECT_NAME}")
    endif()
endmacro(set_common_defines)

### add_qt_bin [LIB|SHARED|STATIC]    | option for static or dynamic library
#              NAME binName           | binary name
#              SOURCES sources...     | sources (.c ou .cpp) 
#              [LIBS libs...]         | libraries to link to the binary
#              [INCLUDES incDirs...]  | dirs to includes during compilation
# Add the binary
function(add_qt_bin)
    set(options LIB SHARED STATIC)
    set(oneValueArgs NAME)
    set(multiValueArgs SOURCES LIBS INCLUDES)
    cmake_parse_arguments(BIN "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Check bin
    if(NOT DEFINED BIN_NAME)
        message(FATAL_ERROR "Missing NAME in call for add_bin")
    endif()
    if(NOT DEFINED BIN_SOURCES)
        message(FATAL_ERROR "Missing SOURCES in call for add_bin")
    endif()

    # Add bin
    if(${BIN_LIB})
        if(${BIN_SHARED} OR ${BIN_STATIC})
            message(FATAL_ERROR "Multiple definitions of library types !")
        endif()
        message(STATUS "Add lib : ${BIN_NAME}")
        add_library(${BIN_NAME} ${BIN_SOURCES})
    elseif(${BIN_SHARED})
        if(${BIN_LIB} OR ${BIN_STATIC})
            message(FATAL_ERROR "Multiple definitions of library types !")
        endif()
        message(STATUS "Add shared lib : ${BIN_NAME}")
        add_library(${BIN_NAME} SHARED ${BIN_SOURCES})
    elseif(${BIN_STATIC})
        if(${BIN_LIB} OR ${BIN_SHARED})
            message(FATAL_ERROR "Multiple definitions of library types !")
        endif()
        message(STATUS "Add static lib : ${BIN_NAME}")
        add_library(${BIN_NAME} STATIC ${BIN_SOURCES})
    else() # EXE
        message(STATUS "Add executable : ${BIN_NAME}")
        add_executable(${BIN_NAME} ${BIN_SOURCES})
    endif()

    # Config bin
    if(DEFINED BIN_LIBS)
        target_link_libraries(${BIN_NAME} ${BIN_LIBS})
    else()
        target_link_libraries(${BIN_NAME})
    endif()
    if(DEFINED BIN_INCLUDES)
        target_include_directories(${BIN_NAME} PUBLIC ${BIN_INCLUDES})
    endif()
    
    # Config Qt
    if(DEFINED _QT5_MODULES_)
        target_link_libraries(${BIN_NAME} ${_QT5_MODULES_})
    endif()

    install(TARGETS ${BIN_NAME})

endfunction(add_qt_bin)
