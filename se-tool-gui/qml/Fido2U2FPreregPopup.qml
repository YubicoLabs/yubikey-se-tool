import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

AuthenticationPopup {

    ColumnLayout {
        width: parent.width
        spacing: 10

        Heading2 {
            text: "Compute the App ID"
            width: parent.width
            Layout.maximumWidth: parent.width
        }
        Text {
            text: "Input the origin's effective domain ('acme.org' if the origin will be 'https://acme.org:8443'). It should NOT include the scheme or port. See w3.org/TR/webauthn/#relying-party-identifier for more details. This will compute the SHA256 hash of the effective domain and set the app ID to it."
            wrapMode: Text.WordWrap
            width: parent.width
            Layout.maximumWidth: parent.width
        }

        RowLayout {
            Heading2 {
                text: qsTr("Effective domain")
                color: yubicoBlue
                font.pixelSize: constants.h3
                Layout.rightMargin: 5
            }
            CustomTextField {
                Component.onCompleted: keyInput.text = "localhost"
                id: keyInput
                Layout.fillWidth: true
                onAccepted: accept()
                validator: RegExpValidator {
                    regExp: /[^:]+\.[^:]+/
                }
            }
        }
    }
}
