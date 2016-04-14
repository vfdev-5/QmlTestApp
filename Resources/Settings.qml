import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.XmlListModel 2.0

Item {
    id: settings

    property alias attributesView: attributesView
    property alias attributesModel: attributesModel

    ColumnLayout {
        id: layout
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.topMargin: 5
        anchors.rightMargin: 5
        anchors.fill: parent

        TableView {
            id: attributesView
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: attributesModel

            TableViewColumn {
                id: attributeName
                title: "Selection of attribute names from the configuration file \'attributes.xml\'"
                role: "name"
                resizable: false
                movable: false
                width: attributesView.viewport.width
            }
        }
    }

    XmlListModel {
        id: attributesModel
        source: attributesXmlUrl
        query: "/Attributes/name"

        XmlRole { name: "name"; query: "string()" }
    }




}
