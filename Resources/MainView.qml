// Qt
import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

// Project
import App.CSKMetadataViewer 1.0


Item {
    id: view

    property alias filePath: filePath
    property alias dropArea: dropArea
    property alias metadataView: metadataView
    property alias proxyModel: proxyModel

    ColumnLayout {
        id: layout
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.topMargin: 5
        anchors.rightMargin: 5
        anchors.fill: parent

        TextField {
            id: filePath
            text: ""
            readOnly: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            visible: !dropArea.visible
        }

        DropArea {
            id: dropArea
            Layout.fillHeight: true
            Layout.fillWidth: true
            keys: ['text/uri-list']

            onDropped: {
                if (drop.hasUrls) {
                    if (drop.proposedAction == Qt.CopyAction ||
                            drop.proposedAction == Qt.MoveAction ) {
                        console.log("urls : " + drop.urls[0])
                        drop.acceptProposedAction()

                        // call reader
                        if (metadataModel.read(drop.urls[0])) {

                            // setup filePath
                            filePath.text = QtCoreHelper.absoluteFilePathFromUrl(drop.urls[0])
                            mainWindow.state = "hasData"
                        }
                        else
                        {
                            errorDialog.title = qsTr("Failed to open the file")
                            errorDialog.text = qsTr("Application failed to open the dropped file")
                            errorDialog.detailedText = metadataModel.errorMessage()
                            errorDialog.open()
                        }
                    }
                }
            }

            MessageDialog {
                id: errorDialog
                modality: Qt.WindowModal
                icon: StandardIcon.Critical
            }

            Text {
                id: dropFileLabel
                text: qsTr("Drop a CSK file here")
                style: Text.Normal
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 24
            }
        }

        TableView {
            id: metadataView

            model: SortFilterProxyModel {
                id: proxyModel
                filterRole: "name"
                //filterString: "*" + controls.searchField.text + "*"
                //filterSyntax: SortFilterProxyModel.Wildcard
                filterString: controls.searchField.text
                filterSyntax: SortFilterProxyModel.RegExp
                filterCaseSensitivity: Qt.CaseInsensitive
            }

            selectionMode: SelectionMode.ExtendedSelection
            visible: !dropArea.visible
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

            TableViewColumn {
                id: attributeName
                title: "Attribute name"
                role: "name"
                resizable: true
                movable: false
                width: metadataView.viewport.width / 3
            }

            TableViewColumn {
                id: attributeValue
                title: "Value"
                role: "value"
                movable: false
                resizable: true
                width: metadataView.viewport.width - attributeName.width
            }
        }
    }
}
