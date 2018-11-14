import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "utils.js" as Utils

InlinePopup {

    property var doneCallback

    closePolicy: Popup.NoAutoClose
    standardButtons: Dialog.Cancel | Dialog.Ok

    onAccepted: doneCallback(pinInput.text)
    onVisibleChanged: pinInput.clear()

    function getPinAndThen(cb) {
        doneCallback = cb
        open()
    }

    ColumnLayout {
        anchors.fill: parent
        Heading2 {
            text: qsTr("Please enter the PIN.")
            color: yubicoBlue
            font.pixelSize: constants.h3
        }

        RowLayout {
            Heading2 {
                text: qsTr("PIN:")
                color: yubicoBlue
                font.pixelSize: constants.h3
            }
            TextField {
                id: pinInput
                Layout.fillWidth: true
                echoMode: TextInput.Password
                selectionColor: yubicoGreen
            }
        }
    }

}