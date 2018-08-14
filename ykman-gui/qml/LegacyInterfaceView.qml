import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "utils.js" as Utils

ColumnLayout {
    objectName: "interfaces"
    Component.onCompleted: load()
    function load() {
        otp.checked = Utils.includes(yubiKey.enabledUsbInterfaces, 'OTP')
        fido.checked = Utils.includes(yubiKey.enabledUsbInterfaces, 'FIDO')
        ccid.checked = Utils.includes(yubiKey.enabledUsbInterfaces, 'CCID')
    }

    function getEnabledInterfaces() {
        var interfaces = []
        if (otp.checked) {
            interfaces.push('OTP')
        }
        if (fido.checked) {
            interfaces.push('FIDO')
        }
        if (ccid.checked) {
            interfaces.push('CCID')
        }
        return interfaces
    }

    function configureInterfaces() {
        yubiKey.set_mode(getEnabledInterfaces(), function (error) {
            if (error) {
                console.log(error)
            } else {
                if (!yubiKey.canWriteConfig) {
                    reInsertYubiKey.open()
                } else {
                    views.pop()
                }
            }
        })
    }

    function validCombination() {
        return otp.checked || fido.checked || ccid.checked
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Heading1 {
            text: qsTr("Interfaces")
        }

        RowLayout {

            Label {
                text: qsTr("Home")
                color: yubicoGreen
            }

            BreadCrumbSeparator {
            }

            Label {
                text: qsTr("Interfaces")
                color: yubicoGrey
            }
        }

        RowLayout {
            Layout.fillWidth: true

            CheckBox {
                id: otp
                enabled: yubiKey.otpInterfaceSupported()
                text: "OTP"
                checkable: true
            }
            CheckBox {
                id: fido
                enabled: yubiKey.fidoInterfaceSupported()
                text: "FIDO"
                checkable: true
            }
            CheckBox {
                id: ccid
                enabled: yubiKey.ccidInterfaceSupported()
                text: "CCID (Smart Card)"
                checkable: true
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Button {
                enabled: validCombination()
                text: qsTr("Save Configuration")
                highlighted: true
                onClicked: configureInterfaces()
            }
        }
    }
}
