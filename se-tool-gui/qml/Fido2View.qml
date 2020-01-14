import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: fido2MainView

    property bool hasPin
    property bool pinBlocked
    property string pinMessage
    property int pinRetries
    property bool isBusy
    readonly property bool hasDevice: yubiKey.hasDevice
    property bool loadedReset
    onHasDeviceChanged: resetOnReInsert()

    StackView.onActivating: load()

    objectName: "fido2View"
    function load() {
        isBusy = true
        yubiKey.fidoHasPin(function (resp) {
            if (resp.success) {
                hasPin = resp.hasPin
                if (hasPin) {
                    yubiKey.fidoPinRetries(function (resp) {
                        if (resp.success) {
                            pinRetries = resp.retries
                        } else {
                            console.log(resp.error_id)
                            pinBlocked = (resp.error_id === 'PIN is blocked.')
                        }
                        isBusy = false
                    })
                } else {
                    pinBlocked = false
                    isBusy = false
                }
            } else {
                snackbarError.showResponseError(resp)
                views.home()
            }
        })
    }

    function getPinMessage() {
        if (pinBlocked) {
            return qsTr("PIN is blocked")
        }
        if (!hasPin) {
            return qsTr("No PIN is set")
        }
        if (hasPin && pinRetries) {
            return qsTr("A PIN is set, ") + pinRetries + qsTr(" retries left")
        }
    }

    function initiateReset() {
        confirmationPopup.show(
                    "Reset FIDO?",
                    "Are you sure you want to reset FIDO? This will delete all FIDO credentials, including FIDO U2F credentials, and remove the FIDO2 PIN.

This action cannot be undone!", function () {
    reInsertYubiKey.open()
})
    }

    function resetOnReInsert() {
        if (!hasDevice && reInsertYubiKey.visible) {
            loadedReset = true
        } else {
            if (loadedReset) {
                loadedReset = false
                touchYubiKey.open()
                yubiKey.fidoReset(function (resp) {
                    touchYubiKey.close()
                    if (resp.success) {
                        load()
                        snackbarSuccess.show(
                                    "FIDO applications have been reset")
                    } else {
                        if (resp.error_id === 'touch timeout') {
                            snackbarError.show(
                                        qsTr("A reset requires a touch on the YubiKey to be confirmed."))
                        } else if (resp.error_message) {
                            snackbarError.show(resp.error_message)
                        } else {
                            snackbarError.show(resp.error_id)
                        }
                    }
                })
            }
        }
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    CustomContentColumn {
        visible: !isBusy

        ViewHeader {
            breadcrumbs: [qsTr("FIDO2")]
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 30

            ColumnLayout {
                Heading2 {
                    text: qsTr("FIDO2 PIN")
                    font.pixelSize: constants.h2
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                Label {
                    text: getPinMessage() || ''
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CustomButton {
                    text: hasPin ? qsTr("Change PIN") : qsTr("Set PIN")
                    highlighted: true
                    onClicked: hasPin ? views.fido2ChangePin(
                                            ) : views.fido2SetPin()
                    toolTipText: hasPin ? qsTr("Change the FIDO2 PIN") : qsTr(
                                              "Configure a FIDO2 PIN")
                    iconSource: "../images/lock.svg"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
            }

            ColumnSeparator {
            }

            ColumnLayout {
                Heading2 {
                    text: qsTr("Reset")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                Label {
                    text: qsTr("Restore defaults")
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CustomButton {
                    text: qsTr("Reset FIDO")
                    highlighted: true
                    onClicked: initiateReset()
                    toolTipText: qsTr("Reset FIDO2 and FIDO U2F applications")
                    iconSource: "../images/reset.svg"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
            }

            ColumnSeparator {
            }

            ColumnLayout {
                Heading2 {
                    text: qsTr("U2F Prereg")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                Label {
                    text: qsTr("Preregister U2F credentials")
                    font.pixelSize: constants.h3
                    color: yubicoGrey
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                CustomButton {
                    text: qsTr("Preregister U2F credentials")
                    highlighted: true
                    onClicked: views.fido2U2FPrereg()
                    toolTipText: qsTr("Preregister U2F credentials")
                    iconSource: "../images/import.svg"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
            }
        }

        ButtonsBar {
        }
    }
}
