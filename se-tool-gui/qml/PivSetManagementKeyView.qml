import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property bool isBusy: false

    readonly property bool hasCurrentManagementKeyInput: !hasProtectedKey
    readonly property bool hasNewManagementKeyInput: true
    readonly property bool hasPinInput: hasProtectedKey || storeManagementKey
    readonly property bool hasProtectedKey: yubiKey.piv.has_protected_key
                                            || false
    readonly property bool storeManagementKey: storeManagementKeyCheckbox.checked
    readonly property bool validCurrentManagementKey: (!hasCurrentManagementKeyInput
                                                       || currentManagementKey.text.length
                                                       === constants.pivManagementKeyHexLength)
    readonly property bool validNewManagementKey: (!hasNewManagementKeyInput
                                                   || newManagementKey.text.length
                                                   === constants.pivManagementKeyHexLength)

    function clearDefaultManagementKey() {
        if (useDefaultCurrentManagementKeyCheckbox.checked) {
            currentManagementKey.clear()
            useDefaultCurrentManagementKeyCheckbox.checked = false
        }
    }

    function generateManagementKey() {
        yubiKey.pivGenerateRandomMgmKey(function (key) {
            newManagementKey.text = key
        })
    }

    function toggleUseDefaultCurrentManagementKey() {
        if (useDefaultCurrentManagementKeyCheckbox.checked) {
            currentManagementKey.text = constants.pivDefaultManagementKey
        } else {
            currentManagementKey.clear()
        }
    }

    function finish() {
        if (hasProtectedKey || storeManagementKey) {
            pivPinPopup.getInputAndThen(_finish)
        } else {
            _finish()
        }

        function _finish(pin) {
            isBusy = true
            yubiKey.pivChangeMgmKey(function (resp) {
                isBusy = false

                if (resp.success) {
                    views.pivPinManagement()
                    snackbarSuccess.show(qsTr("Changed the Management Key"))
                } else {
                    snackbarError.showResponseError(resp, {
                                                        mgm_key_bad_format: qsTr("Current management key must be exactly %1 hexadecimal characters").arg(constants.pivManagementKeyHexLength),
                                                        mgm_key_required: qsTr("Please enter the current management key"),
                                                        pin_required: qsTr("Please enter the PIN"),
                                                        wrong_mgm_key: qsTr("Wrong current management key")
                                                    })

                    if (resp.error_id === 'wrong_mgm_key') {
                        clearDefaultManagementKey()
                    } else if (resp.error_id === 'pin_blocked') {
                        if (hasProtectedKey) {
                            views.pivPinManagement()
                        } else {
                            views.pop()
                        }
                    }
                }
            }, pin, currentManagementKey.text, newManagementKey.text,
            storeManagementKey)
        }
    }

    CustomContentColumn {

        ViewHeader {
            breadcrumbs: [qsTr("PIV"), qsTr("Configure PINs"), qsTr(
                    "Change Management Key")]
        }

        ColumnLayout {
            width: parent.width

            GridLayout {
                columns: 3

                Label {
                    text: qsTr("Current Management Key")
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: hasCurrentManagementKeyInput
                }
                PivManagementKeyTextField {
                    id: currentManagementKey
                    Layout.fillWidth: true
                    background.width: width
                    visible: hasCurrentManagementKeyInput
                    enabled: !useDefaultCurrentManagementKeyCheckbox.checked
                }
                CheckBox {
                    id: useDefaultCurrentManagementKeyCheckbox
                    text: qsTr("Use default")
                    onCheckedChanged: toggleUseDefaultCurrentManagementKey()
                    font.pixelSize: constants.h3
                    Material.foreground: yubicoBlue
                    visible: hasCurrentManagementKeyInput
                }
                Label {
                    text: qsTr("New Management Key")
                    font.pixelSize: constants.h3
                    color: yubicoBlue
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
                PivManagementKeyTextField {
                    id: newManagementKey
                    Layout.fillWidth: true
                    background.width: width
                }
                CustomButton {
                    id: randomManagementKeyBtn
                    text: qsTr("Generate")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    onClicked: generateManagementKey()
                }
            }

            CheckBox {
                id: storeManagementKeyCheckbox
                checked: false
                text: qsTr("Protect with PIN")
                font.pixelSize: constants.h3
                Material.foreground: yubicoBlue
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Store the management key on the YubiKey, protected by PIN.")
            }
        }

        ButtonsBar {
            finishCallback: finish
            finishEnabled: validCurrentManagementKey && validNewManagementKey
            finishTooltip: qsTr("Finish and change the management key")
        }
    }
}
