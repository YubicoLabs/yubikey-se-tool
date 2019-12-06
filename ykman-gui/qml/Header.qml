import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    spacing: 0
    function activeKeyLbl() {
        if (!yubiKey.hasDevice || views.isShowingHomeView) {
            return ""
        } else {
            if (yubiKey.serial) {
                return yubiKey.name + " (" + yubiKey.serial + ")"
            } else {
                return yubiKey.name
            }
        }
    }
    RowLayout {
        Layout.fillWidth: true

        RowLayout {
            Layout.leftMargin: 10
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Label {
                text: qsTr("U2F Preregistration Tool")
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                color: yubicoBlue
                font.pixelSize: constants.h2
                font.bold: true
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 10
            Layout.topMargin: 10
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                Label {
                    text: activeKeyLbl()
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    color: yubicoBlue
                    font.pixelSize: constants.h4
                }
                CustomButton {
                    flat: true
                    text: qsTr("About")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    iconSource: "../images/info.svg"
                    toolTipText: qsTr("About this tool")
                    onClicked: aboutPage.open()
                    font.pixelSize: constants.h4
                }
            }
        }
    }

    Rectangle {
        id: headerBorder
        Layout.minimumHeight: 4
        Layout.maximumHeight: 4
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: yubicoGrey
    }

    Rectangle {
        Layout.minimumHeight: 10
        Layout.maximumHeight: 10
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
