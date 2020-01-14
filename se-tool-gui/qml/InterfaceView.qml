import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "utils.js" as Utils
import QtQuick.Controls.Material 2.2

ColumnLayout {
    objectName: "interfaces"

    property var newApplicationsEnabledOverUsb: []
    property var newApplicationsEnabledOverNfc: []

    readonly property var applications: [{
            id: "OTP",
            name: qsTr("OTP")
        }, {
            id: "FIDO2",
            name: qsTr("FIDO2")
        }, {
            id: "U2F",
            name: qsTr("FIDO U2F")
        }, {
            id: "OPGP",
            name: qsTr("OpenPGP")
        }, {
            id: "PIV",
            name: qsTr("PIV")
        }, {
            id: "OATH",
            name: qsTr("OATH")
        }]

    StackView.onActivating: load()

    function configureInterfaces() {
        if (yubiKey.configurationLocked) {
            lockCodePopup.getInputAndThen(writeInterfaces)
        } else {
            writeInterfaces()
        }
    }

    function writeInterfaces(lockCode) {
        views.lock()
        yubiKey.writeConfig(newApplicationsEnabledOverUsb,
                            newApplicationsEnabledOverNfc, lockCode,
                            function (resp) {
                                if (resp.success) {
                                    views.home()
                                    views.unlock()
                                    snackbarSuccess.show(
                                                qsTr("Configured interfaces"))
                                } else {
                                    views.unlock()
                                    snackbarError.showResponseError(resp)
                                }
                            })
    }

    function configurationHasChanged() {
        var enabledYubiKeyUsb = JSON.stringify(
                    yubiKey.applicationsEnabledOverUsb.sort())
        var enabledUiUsb = JSON.stringify(newApplicationsEnabledOverUsb.sort())
        var enabledYubiKeyNfc = JSON.stringify(
                    yubiKey.applicationsEnabledOverNfc.sort())
        var enabledUiNfc = JSON.stringify(newApplicationsEnabledOverNfc.sort())

        return enabledYubiKeyUsb !== enabledUiUsb
                || enabledYubiKeyNfc !== enabledUiNfc
    }

    function toggleEnabledOverUsb(applicationId, enabled) {
        if (enabled) {
            newApplicationsEnabledOverUsb = Utils.including(
                        newApplicationsEnabledOverUsb, applicationId)
        } else {
            newApplicationsEnabledOverUsb = Utils.without(
                        newApplicationsEnabledOverUsb, applicationId)
        }
    }

    function toggleEnabledOverNfc(applicationId, enabled) {
        if (enabled) {
            newApplicationsEnabledOverNfc = Utils.including(
                        newApplicationsEnabledOverNfc, applicationId)
        } else {
            newApplicationsEnabledOverNfc = Utils.without(
                        newApplicationsEnabledOverNfc, applicationId)
        }
    }

    function load() {
        // Populate initial state of checkboxes
        for (var i = 0; i < applications.length; i++) {
            usbCheckBoxes.itemAt(i).checked = yubiKey.isEnabledOverUsb(
                        applications[i].id) && yubiKey.isSupportedOverUSB(
                        applications[i].id)
            nfcCheckBoxes.itemAt(i).checked = yubiKey.isEnabledOverNfc(
                        applications[i].id) && yubiKey.isSupportedOverNfc(
                        applications[i].id)
        }
    }

    function validCombination() {
        return newApplicationsEnabledOverUsb.length >= 1
    }

    function toggleNfc() {
        if (newApplicationsEnabledOverNfc.length < 1) {
            for (var i = 0; i < nfcCheckBoxes.count; i++) {
                if (usbCheckBoxes.itemAt(i).enabled) {
                    nfcCheckBoxes.itemAt(i).checked = true
                }
            }
        } else {
            for (var j = 0; j < nfcCheckBoxes.count; j++) {
                nfcCheckBoxes.itemAt(j).checked = false
            }
        }
    }

    function toggleUsb() {
        if (newApplicationsEnabledOverUsb.length < 2) {
            for (var i = 0; i < usbCheckBoxes.count; i++) {
                if (usbCheckBoxes.itemAt(i).enabled) {
                    usbCheckBoxes.itemAt(i).checked = true
                }
            }
        } else {
            for (var j = 0; j < usbCheckBoxes.count; j++) {
                // Leave OTP by default, not allowed to have 0 USB enabled.
                if (usbCheckBoxes.itemAt(j).text !== 'OTP') {
                    usbCheckBoxes.itemAt(j).checked = false
                }
            }
        }
    }

    CustomContentColumn {

        ViewHeader {
            breadcrumbs: [qsTr("Interfaces")]
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 60

            GridLayout {
                visible: yubiKey.supportsUsbConfiguration()
                columns: 2
                RowLayout {
                    spacing: 8
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/usb.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                    }
                    Label {
                        text: qsTr("USB")
                        color: yubicoBlue
                        font.pixelSize: constants.h2
                    }
                }
                CustomButton {
                    text: newApplicationsEnabledOverUsb.length < 2 ? qsTr("Enable all") : qsTr(
                                                                         "Disable all")
                    flat: true
                    onClicked: toggleUsb()
                    toolTipText: qsTr("Toggle all availability over USB (at least one USB application is required)")
                }

                Repeater {
                    id: usbCheckBoxes
                    model: applications
                    CheckBox {
                        enabled: yubiKey.isSupportedOverUSB(modelData.id)
                        visible: yubiKey.isSupportedOverUSB(modelData.id)
                        Layout.bottomMargin: -20
                        onCheckedChanged: toggleEnabledOverUsb(modelData.id,
                                                               checked)
                        text: modelData.name || modelData.id
                        font.pixelSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle %1 availability over USB").arg(
                                          modelData.name || modelData.id)
                        Material.foreground: yubicoBlue
                    }
                }
            }

            ColumnSeparator {
                visible: yubiKey.supportsNfcConfiguration()
                         && yubiKey.supportsUsbConfiguration()
            }

            GridLayout {
                visible: yubiKey.supportsNfcConfiguration()
                columns: 2
                RowLayout {
                    spacing: 8
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: "../images/contactless.svg"
                        sourceSize.width: 18
                        sourceSize.height: 18
                    }
                    Label {
                        text: qsTr("NFC")
                        font.pixelSize: constants.h2
                        color: yubicoBlue
                    }
                }
                CustomButton {
                    text: newApplicationsEnabledOverNfc.length < 1 ? qsTr("Enable all") : qsTr(
                                                                         "Disable all")
                    flat: true
                    onClicked: toggleNfc()
                    toolTipText: qsTr("Toggle all availability over NFC")
                }

                Repeater {
                    id: nfcCheckBoxes
                    model: applications
                    CheckBox {
                        visible: yubiKey.isSupportedOverNfc(modelData.id)
                        enabled: yubiKey.isSupportedOverNfc(modelData.id)
                        Layout.bottomMargin: -20
                        onCheckedChanged: toggleEnabledOverNfc(modelData.id,
                                                               checked)
                        text: modelData.name || modelData.id
                        font.pixelSize: constants.h3
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Toggle %1 availability over NFC").arg(
                                          modelData.name || modelData.id)
                        Material.foreground: yubicoBlue
                    }
                }
            }
        }

        ButtonsBar {
            finishCallback: configureInterfaces
            finishEnabled: configurationHasChanged() && validCombination()
            finishText: qsTr("Save Interfaces")
            finishTooltip: qsTr("Finish and save interfaces configuration to YubiKey")
        }
    }
}
