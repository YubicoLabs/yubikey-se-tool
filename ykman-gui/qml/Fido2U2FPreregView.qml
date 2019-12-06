import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import Qt.labs.platform 1.0
import "slotutils.js" as SlotUtils
import QtQuick.Controls.Material 2.2

ColumnLayout {

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
        acceptLabel: "Export"
        defaultSuffix: ".tsv"
        fileMode: FileDialog.SaveFile
        options: FileDialog.DontConfirmOverwrite
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: setTsvFilePath(file.toString())
    }

    CustomContentColumn {

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
                toolTipText: qsTr("AppID must be a 32 byte hex value (SHA256 hash)")
            }
            Label { }

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
                toolTipText: qsTr("Challenge must be a 32 byte hex value (SHA256 hash)")
            }
            CustomButton {
                id: generateChallengeBtn
                text: qsTr("Generate")
                Layout.leftMargin: 10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
                onClicked: generateChallenge()
                toolTipText: qsTr("Generate a random challenge")
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

    Component {
        id: yubiOtpUploadView
        YubiOtpUploadView {}
    }
}
