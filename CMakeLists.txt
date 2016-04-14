## Project CSKMetadataViewer
project( CSKMetadataViewer )
cmake_minimum_required( VERSION 3.1.0 FATAL_ERROR)


# Add custom Cmake Modules
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMakeModules")

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)
# Instruct CMake to run uic automatically when needed.
set(CMAKE_AUTOUIC ON)

# Find OpenCV, GDAL, Qt:
find_package( GDAL REQUIRED )
find_package( OpenGL REQUIRED )

# This is works for Qt5 only 
set( QT_COMPONENT_LIST Widgets Qml Quick QuickWidgets XmlPatterns)
#set( QT_QML_PLUGINS_LIST XmlListModel)
message("QT_COMPONENT_LIST : ${QT_COMPONENT_LIST}")
message("QT_QML_PLUGINS_LIST : ${QT_QML_PLUGINS_LIST}")
find_package( Qt REQUIRED )


# add source and resources
## include & link to GDAL :
include_directories(${GDAL_INCLUDE_DIRS})
link_libraries(${GDAL_LIBRARY})

## include & link to Qt :
SET(INSTALL_QT_DLLS ON)
include(Qt)

## get files
file(GLOB SRC_FILES "Source/*.cpp")
file(GLOB INC_FILES "Source/*.h")
file(GLOB UI_FILES "Source/*.ui")
file(GLOB QML_FILES "Resources/*.qml")

## Use .qrc files:
file(GLOB QRC_FILES "Resources/*.qrc")
QT5_ADD_RESOURCES (ResourceSources ${QRC_FILES})

## create application
add_executable( ${PROJECT_NAME} ${SRC_FILES} ${INC_FILES} ${UI_FILES} ${QML_FILES} ${ResourceSources})
set_target_properties(${PROJECT_NAME} PROPERTIES DEBUG_POSTFIX ".d")

## install application
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)

## install attributes.xml configuration file
install(FILES Resources/attributes.xml DESTINATION bin)

if(WIN32)
    ## install gdal library dlls :
    get_filename_component(GDAL_BIN_DIR "${GDAL_INCLUDE_DIR}/../bin" ABSOLUTE)
    # message("GDAL_BIN_DIR : ${GDAL_BIN_DIR}")
    INSTALL(DIRECTORY ${GDAL_BIN_DIR}/ DESTINATION bin FILES_MATCHING PATTERN "*.dll" )
    INSTALL(DIRECTORY ${GDAL_BIN_DIR}/gdaldata DESTINATION bin PATTERN "*.png" EXCLUDE PATTERN "*.svg" EXCLUDE PATTERN "data/*")
    INSTALL(DIRECTORY ${GDAL_BIN_DIR}/gdalplugins DESTINATION bin PATTERN "*.dll")

    # QML Deployement on Windows
    # https://wiki.qt.io/Deploy_an_Application_on_Windows
    #
    # Copy folders from Qt distribution folder : (e.g. QT_DIR=C:/Qt/Qt5.6/msvc2013_64 )
    # 1) QT_DIR/plugins/platforms (select the library corresponding to your platform : e.g. qwindows.dll)
    # 2) QT_DIR/qml/QtQml
    # 3) QT_DIR/qml/QtQuick
    # 4) QT_DIR/qml/QtQuick.2
    # to the application install bin/ folder
    # Remove debug libraries to minimify package size

endif(WIN32)




