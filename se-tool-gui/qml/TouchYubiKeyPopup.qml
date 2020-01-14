import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

InlinePopup {
    closePolicy: Popup.NoAutoClose
    RowLayout {
        anchors.fill: parent
        Heading2 {
            text: qsTr("Touch your YubiKey!")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.maximumWidth: parent.width
        }
        Image {
            fillMode: Image.PreserveAspectCrop
            source: "../images/touch.svg"
            sourceSize.width: 24
            sourceSize.height: 24
        }
    }
}
