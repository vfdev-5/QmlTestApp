import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Item {
    id: panel
    property alias filterCheckBox: filterCheckBox
    property alias searchField: searchField

    signal clear()
    signal settings()
    signal filterStateChanged()

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.bottomMargin: 5
        anchors.topMargin: 5
        anchors.rightMargin: 2


        CheckBox {
            id: filterCheckBox
            text: qsTr("Selection from Settings")
            onClicked: panel.filterStateChanged()
        }

        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: qsTr("Search...")
            inputMethodHints: Qt.ImhNoPredictiveText

        }


        Button {
            id: settingsButton
            iconSource: "settings"
            checkable: true
            onClicked: panel.settings()
        }

        ToolButton {
            id: clearButton
            iconSource: "clear"
            onClicked: panel.clear()
        }


    }




}
