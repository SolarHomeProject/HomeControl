import QtQuick 2.15
import QtQuick.Window 2.15
import "Style"
import "components"

Window {
    id: mainWindow
    width: 1280
    height: 800
    visible: true
    Component.onCompleted: backend.printError()

    Rectangle {
        id: bg
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Style.pageBg
        z: 1
        transform: Rotation {
            angle: 180
            origin.x: mainWindow.width / 2
            origin.y: mainWindow.height / 2
        }

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 20
            color: Style.textColor
            text: "HomeControl konnte nicht gestartet werden."
            font.pixelSize: 32
        }

        Image {
            id: errorImg
            source: "images/warning_icon.svg"
            height: 100
            width: 100
            anchors.centerIn: parent
        }

        Text {
            id: errorText
            width: parent.width
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "red"
            wrapMode: Text.Wrap
        }

        CustomButton {
            id: rebootButton
            width: 200
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            text: "Neustarten"
            onClicked: backend.reboot()
        }

    }

    Connections {
        target: backend

        function onError(errormsg) {
            errorText.text = errormsg
        }
    }

}
