// Qt
import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

// Project
import App.CSKMetadataViewer 1.0


Rectangle {

    id: mainWindow
    visible: true
    width: 600
    height: 400
    color: "lightgray"
    state: "empty"

    property string settingsFilterRegExp: ""

    // ******************************************************************************

    ColumnLayout {
        id: layout
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.topMargin: 5
        anchors.rightMargin: 5
        anchors.fill: parent

        Controls {
            id: controls
            height: 40
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            visible: !mainView.dropArea.visible

            onClear: {
                infoDialog.text = qsTr("Please, press 'Yes' if you want to clear current info")
                infoDialog.standardButtons = StandardButton.Yes | StandardButton.No
                infoDialog.onYes.connect( function(){
                    return function() {
                        metadataModel.clear();
                        mainWindow.state = "empty"
                    };
                }())
                infoDialog.open()
            }

            onSettings: {
                if (mainWindow.state == "settings")
                    mainWindow.state = "hasData"
                else
                    mainWindow.state = "settings"
            }

            onFilterStateChanged: {
                setupMetadataFilter(controls.filterCheckBox.checked)
            }

        }

        MainView {
            id: mainView
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Settings {
            id: settings
            visible: !mainView.visible
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }

    // ******************************************************************************

    MessageDialog {
        id: infoDialog
        modality: Qt.WindowModal
        icon: StandardIcon.Question
    }

    // ******************************************************************************

    Shortcut {
        id: clipboardCopy
        sequence: "Ctrl+C"
        property var view: null
        property var model: null
        onActivated: {
            if (view && model) {
                var clipboardData = "";
                view.selection.forEach(function(rowIndex){
                    var row = model.get(rowIndex);
                    clipboardData += row.name + "=" + row.value + " ";
                });
                console.log("Copy to clipboard : " + clipboardData);
                if (!QtCoreHelper.clipboardCopy(clipboardData)) {
                    console.err("Clipboard is not available");
                }
            }
        }
    }

    // ******************************************************************************

    states: [

        State {
            name: "empty"
            PropertyChanges { target: mainView.dropArea; visible: true }
            PropertyChanges { target: mainView.proxyModel; source: null }
            PropertyChanges { target: clipboardCopy; view: null; model: null }
        },
        State {
            name: "hasData"
            PropertyChanges { target: mainView.dropArea; visible: false }
            PropertyChanges { target: controls.filterCheckBox; checked: true; enabled: true }
            PropertyChanges { target: controls.searchField; enabled: true }
            PropertyChanges { target: mainView.proxyModel; source: metadataModel }
            StateChangeScript { name: "setupSettingsFilterRegExp"; script: setupSettingsFilterRegExp() }
            StateChangeScript { name: "setupMetadataFilter"; script: setupMetadataFilter(controls.filterCheckBox.checked) }
            PropertyChanges { target: clipboardCopy; view: mainView.metadataView; model: mainView.proxyModel }
        },
        State {
            name: "settings"
            PropertyChanges { target: mainView; visible: false }
            PropertyChanges { target: controls.filterCheckBox; enabled: false }
            PropertyChanges { target: controls.searchField; enabled: false }
        }
    ]


    // ******************************************************************************

    function setupSettingsFilterRegExp() {

        if (mainWindow.settingsFilterRegExp.length == 0) {
            var size = settings.attributesModel.count;
            var filterStr = "(";
            for (var i=0; i<size-1; i++) {
                filterStr += settings.attributesModel.get(i).name + "|"
            }
            filterStr +=settings.attributesModel.get(size-1).name + ")";
            mainWindow.settingsFilterRegExp = filterStr;
        }
    }

    // ******************************************************************************

    function setupMetadataFilter(isFiltered) {
        mainView.proxyModel.filterString = Qt.binding(function(){
            if (isFiltered && controls.searchField.text.length == 0) {
                return mainWindow.settingsFilterRegExp;
            } else {
                return controls.searchField.text;
            }
        });
    }

    // ******************************************************************************

}
