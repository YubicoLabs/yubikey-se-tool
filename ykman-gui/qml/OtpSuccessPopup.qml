import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import "slotutils.js" as SlotUtils

InlinePopup {
    property string message: qsTr("Success! " + SlotUtils.slotNameCapitalized(
                                      views.selectedSlot) + " is configured.")

    Heading2 {
        width: parent.width
        text: message
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    }

    standardButtons: Dialog.Ok
    onClosed: views.otp()
}