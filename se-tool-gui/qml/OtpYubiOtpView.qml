import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {

    property string uploadUrl

    function useSerial() {
        if (useSerialCb.checked) {
            yubiKey.serialModhex(function (res) {
                publicIdInput.text = res
            })
        }
    }

    function generatePrivateId() {
        yubiKey.randomUid(function (res) {
            privateIdInput.text = res
        })
    }

    function generateKey() {
        yubiKey.randomKey(16, function (res) {
            secretKeyInput.text = res
        })
    }

    function finish() {
        if (views.selectedSlotConfigured()) {
            otpConfirmOverwrite(programYubiOtp)
        } else {
            programYubiOtp()
        }
    }

    function programYubiOtp() {
        yubiKey.programOtp(views.selectedSlot, publicIdInput.text,
                           privateIdInput.text, secretKeyInput.text,
                           enableUpload.checked, function (resp) {
                               if (resp.success) {
                                   snackbarSuccess.show(
                                               qsTr("Configured Yubico OTP credential"))

                                   if (resp.upload_url) {
                                       uploadUrl = resp.upload_url
                                       views.push(yubiOtpUploadView)
                                   } else {
                                       views.otp()
                                   }
                               } else {
                                   if (resp.error_id === 'write error') {
                                       views.otpWriteError()
                                   } else if (resp.error_id === 'upload_failed') {
                                       snackbarError.show(
                                                   qsTr(
                                                       "Upload failed: %1").arg(
                                                       getUploadErrorMessage(
                                                           resp.upload_errors[0])))
                                   } else {
                                       views.otpFailedToConfigureErrorPopup(
                                                   resp.error_id)
                                   }
                               }
                           })
    }

    function getUploadErrorMessage(uploadErrorId) {
        // Keys defined in ykman library
        switch (uploadErrorId) {
        case 'CONNECTION_FAILED':
            return qsTr('Failed to open HTTPS connection.')
        case 'NOT_FOUND':
            return qsTr('Upload request not recognized by server.')
        case 'PUBLIC_ID_NOT_VV':
            return qsTr('Public ID must begin with "vv".')
        case 'PUBLIC_ID_OCCUPIED':
            return qsTr('Public ID is already in use.')
        case 'SERVICE_UNAVAILABLE':
            return qsTr('Service temporarily unavailable, please try again later.')
        }
    }

    CustomContentColumn {

        ViewHeader {
            breadcrumbs: [qsTr("OTP"), SlotUtils.slotNameCapitalized(
                    views.selectedSlot), qsTr("Yubico OTP")]
        }

        GridLayout {
            columns: 3
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            Label {
                text: qsTr("Public ID")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pixelSize: constants.h3
                color: yubicoBlue
            }
            CustomTextField {
                id: publicIdInput
                Layout.fillWidth: true
                enabled: !useSerialCb.checked
                validator: RegExpValidator {
                    regExp: /[cbdefghijklnrtuv]{12}$/
                }
                toolTipText: qsTr("Public ID must be a 12 characters (6 bytes) modhex value")
            }
            CheckBox {
                id: useSerialCb
                enabled: yubiKey.serial
                text: qsTr("Use serial")
                onCheckedChanged: useSerial()
                ToolTip.delay: 1000
                font.pixelSize: constants.h3
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Use the encoded serial number of the YubiKey as Public ID")
                Material.foreground: yubicoBlue
            }

            Label {
                text: qsTr("Private ID")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pixelSize: constants.h3
                color: yubicoBlue
            }
            CustomTextField {
                id: privateIdInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /[0-9a-fA-F]{12}$/
                }
                toolTipText: qsTr("Private ID must be a 12 characters (6 bytes) hex value")
            }
            CustomButton {
                id: generatePrivateIdBtn
                text: qsTr("Generate")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                onClicked: generatePrivateId()
                toolTipText: qsTr("Generate a random Private ID")
            }

            Label {
                text: qsTr("Secret key")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pixelSize: constants.h3
                color: yubicoBlue
            }
            CustomTextField {
                id: secretKeyInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /[0-9a-fA-F]{32}$/
                }
                toolTipText: qsTr("Secret key must be a 32 characters (16 bytes) hex value")
            }
            CustomButton {
                id: generateSecretKeyBtn
                text: qsTr("Generate")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                onClicked: generateKey()
                toolTipText: qsTr("Generate a random Secret Key")
            }

            Label {}
            CheckBox {
                id: enableUpload
                text: qsTr("Upload to YubiCloud")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                ToolTip.delay: 1000
                font.pixelSize: constants.h3
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Upload key and ID to YubiCloud (required for most 3rd party services)")
                Material.foreground: yubicoBlue
            }
            Label {}
        }

        ButtonsBar {
            finishCallback: finish
            finishEnabled: publicIdInput.acceptableInput
                           && privateIdInput.acceptableInput
                           && secretKeyInput.acceptableInput
            finishTooltip: qsTr("Finish and write the configuration to the YubiKey")
        }
    }

    Component {
        id: yubiOtpUploadView
        YubiOtpUploadView {}
    }
}
