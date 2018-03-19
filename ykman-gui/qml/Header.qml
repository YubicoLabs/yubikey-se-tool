import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

ColumnLayout {
    id: header
    spacing: 0
    height: 63
    Rectangle {
        id: background
        Layout.minimumHeight: 60
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#ffffff"
        Image {
            id: logo
            width: 100
            height: 28
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.bottomMargin: 5
            anchors.bottom: parent.bottom
            source: "../images/logo-header.png"
        }
    }
    Rectangle {
        id: headerBorder
        Layout.minimumHeight: 3
        Layout.maximumHeight: 3
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#9aca3c"
    }
}