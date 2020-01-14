import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import Qt.labs.platform 1.0
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {
    Component.onCompleted:generateChallenge()

    function generatePrivateId() {
        yubiKey.randomUid(function (res) {
            privateIdInput.text = res
        })
    }

    function generateChallenge() {
        yubiKey.randomKey(32, function (res) {
            challengeInput.text = res
        })
    }

    function browseTsvFileBtn() {

    }

    function openCalculatePopup() {
        fidoU2FPreregPopup.getInputAndThen(function (effectiveDomain) {
            yubiKey.fidoGetAppIDFromDomain(effectiveDomain, function (resp) {
                if (resp.success) {
                    appIDInput.text = resp.appid
                } else {
                    snackbarError.showResponseError(resp)
                }
            })
        })
    }



    function finish() {
        touchYubiKey.open()
        yubiKey.fidoU2FPrereg(challengeInput.text, appIDInput.text, "file://"+tsvFileInput.text,
                                function (resp) {
                                    touchYubiKey.close()
                                    if (resp.success) {
                                        snackbarSuccess.show(qsTr("Successfully preregistered and saved output to file."))
                                        //views.fido2U2FPrereg()
                                    } else {
                                        snackbarError.showResponseError(resp)
                                        //snackbarError.show(qsTr("Error exporting"))
                                    }
                                })
    }

    function setTsvFilePath(tsvFileUrl) {
        tsvFileInput.text = tsvFileUrl.replace("file://","")
    }

    FileDialog {
        id: exportTSVDialog
        title: "Export prereg data to TSV file..."
        acceptLabel: "Select"
        defaultSuffix: ".tsv"
        fileMode: FileDialog.SaveFile
        options: FileDialog.DontConfirmOverwrite
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: setTsvFilePath(file.toString())
    }

    CustomContentColumn {

        Label {
            text: "Preregister U2F credentials, and output a TSV with preregistration data in the standard format. If the TSV file already exists, each new preregistration will be appended as a new row."
            wrapMode: Text.WordWrap
            font.pixelSize: constants.h3
            color: yubicoBlue
            Layout.maximumWidth: parent.width
            width: parent.width
        }

        GridLayout {
            columns: 3
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            Label {
                text: qsTr("App ID")
                Layout.rightMargin: 5
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pixelSize: constants.h3
                color: yubicoBlue
            }
            CustomTextField {
                id: appIDInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /[0123456789abcdef]{64}$/
                }
                toolTipText: qsTr("AppID is the SHA256 hash of the origin URL.")
            }
            CustomButton {
                text: qsTr("Calculate")
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
                onClicked: openCalculatePopup()
                toolTipText: qsTr("Calculate the App ID from the effective domain.")
            }

            Label {
                text: qsTr("Challenge")
                Layout.rightMargin: 5
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pixelSize: constants.h3
                color: yubicoBlue
            }
            CustomTextField {
                id: challengeInput
                Layout.fillWidth: true
                validator: RegExpValidator {
                    regExp: /[0123456789abcdef]{64}$/
                }
                toolTipText: qsTr("Challenge should be a random 32 byte hex value.")
            }
            CustomButton {
                id: generateChallengeBtn
                text: qsTr("Generate")
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
                onClicked: generateChallenge()
                toolTipText: qsTr("Generate a random challenge.")
            }

            Label {
                text: qsTr("TSV output file")
                Layout.rightMargin: 5
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pixelSize: constants.h3
                color: yubicoBlue
            }
            CustomTextField {
                id: tsvFileInput
                Layout.fillWidth: true
                readOnly: true
                toolTipText: qsTr("New TSV filename or append to an existing file")
                selectByMouse: false
            }
            CustomButton {
                id: browseTsvFileBtn
                text: qsTr("Browse")
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
                onClicked: exportTSVDialog.open()
            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.preferredWidth: constants.contentWidth

            CustomButton {
                highlighted: true
                iconSource: "../images/import.svg"
                onClicked: finish()
                text: "Preregister"
                toolTipText: "Preregister credential on YubiKey"
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            }
        }
    }
}
