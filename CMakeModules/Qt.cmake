#############################################################
## Qt CMakeImport file
#############################################################


GET_TARGET_PROPERTY(res Qt5::Core IMPORTED_LOCATION_RELEASE)
get_filename_component(QT_BIN_DIR ${res} PATH)

if(WIN32)
    SET(DLL_LIST "")
endif()

foreach(component ${QT_COMPONENT_LIST})

    set(INCS Qt5${component}_INCLUDES)
    set(LIBS Qt5${component}_LIBRARIES)
    set(DEFS Qt5${component}_DEFINITIONS)
    set(FLAGS Qt5${component}_EXECUTABLE_COMPILE_FLAGS)

    include_directories(${${INCS}})
    link_libraries(${${LIBS}})
    ## We need add -DQT_WIDGETS_LIB when using QtWidgets in Qt 5.
    add_definitions(${${DEFS}})
    ## Executables fail to build with Qt 5 in the default configuration
    ## without -fPIE. We add that here.
    set(CMAKE_CXX_FLAGS "${${FLAGS}}")

    if(WIN32)
        GET_TARGET_PROPERTY(dependencies Qt5::${component} INTERFACE_LINK_LIBRARIES)
#        message("Qt5::${component} INTERFACE_LINK_LIBRARIES :  ${dependencies}")
        string(TOUPPER ${CMAKE_BUILD_TYPE} build_type)
#        message("build_type : ${build_type}")
        # Add dependencies
        foreach(d ${dependencies})
            GET_TARGET_PROPERTY(dll_name ${d} "IMPORTED_LOCATION_${build_type}")
#            message("dll_name :  ${dll_name}")
            list(APPEND DLL_LIST "${dll_name}")
        endforeach()
        # Add current component
        GET_TARGET_PROPERTY(dll_name Qt5::${component} "IMPORTED_LOCATION_${build_type}")
        list(APPEND DLL_LIST "${dll_name}")
    endif()

endforeach()


# Setting -fPIC globally even when building executables may also work sufficiently, but shouldn’t be the first option.
# For linux sustems
if(NOT WIN32)
set(CMAKE_CXX_FLAGS "-fPIC")
endif()

if(WIN32)
    list(REMOVE_DUPLICATES DLL_LIST)
#    message("DLL_LIST : ${DLL_LIST}")
endif()


if(WIN32 AND INSTALL_QT_DLLS)

    # Add & install qml plugins
    set(QT_QML_DIR "${QT_BIN_DIR}/../qml")
    foreach( plugin ${QT_QML_PLUGINS_LIST})
        string(TOLOWER Qml${plugin}Plugin${CMAKE_SHARED_LIBRARY_SUFFIX} plugin_name)
        find_path(plugin_loc ${plugin_name} PATHS
            ${QT_QML_DIR}/QtQuick
            ${QT_QML_DIR}/QtQuick.2
            ${QT_QML_DIR}/Qt
            ${QT_QML_DIR}/QtQml
            PATH_SUFFIXES ${plugin} NO_DEFAULT_PATH)
        if (NOT plugin_loc)
            message(WARNING "QML plugin ${plugin} is not found")
        endif()
        list(APPEND DLL_LIST "${plugin_loc}/${plugin_name}")
    endforeach()

#    foreach(it ${DLL_LIST})
#        message("dll_name : ${it}")
    INSTALL(FILES ${DLL_LIST} DESTINATION bin)
#    endforeach()
    # ICU for Qt5
    FILE(GLOB icu_dlls "${QT_BIN_DIR}/icu*.dll")
    INSTALL(FILES ${icu_dlls} DESTINATION bin )

endif()
