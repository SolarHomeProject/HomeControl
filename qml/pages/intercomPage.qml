import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.4
import "../Style"
import "../components"

Item {
    Component.onCompleted: intercombackend.active()
    Component.onDestruction: intercombackend.inactive()

    Rectangle {
        color: Style.pageBg
        anchors.fill: parent

        BusyIndicator {
            id: busyIndicator
            height: 100
            width: 100
            palette.dark: "black"
            anchors.centerIn: parent
        }

        Image {
            id: errorImg
            source: "../images/warning_icon.svg"
            height: 100
            width: 100
            anchors.centerIn: parent
            visible: false
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

        VideoOutput {
            width: parent.width
            height: 680
            source: Camera {
                viewfinder.maximumFrameRate: 10
                onError: {
                    busyIndicator.visible = false
                    errorImg.visible = true
                    errorText.text = errorString
                    this.start()
                }
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.spacing

            CustomImageButton {
                width: 60
                height: 60
                anchors.bottom: parent.bottom
                img: "../images/handset_speak_inc_icon.svg"
                onClicked: intercombackend.step_vol_handset("+")
            }

            CustomImageButton {
                width: 60
                height: 60
                anchors.bottom: parent.bottom
                img: "../images/handset_speak_dec_icon.svg"
                onClicked: intercombackend.step_vol_handset("-")
            }

            CustomImageButton {
                width: 60
                height: 60
                anchors.bottom: parent.bottom
                img: "../images/intercom_speak_inc_icon.svg"
                onClicked: intercombackend.step_vol_intercom("+")
            }

            CustomImageButton {
                width: 60
                height: 60
                anchors.bottom: parent.bottom
                img: "../images/intercom_speak_dec_icon.svg"
                onClicked: intercombackend.step_vol_intercom("-")
            }

        }

        CustomImageButton {
            width: 60
            height: 60
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            img: "../images/key_icon.svg"
            onPressed: intercombackend.door_open(true)
            onReleased: intercombackend.door_open(false)
            onCanceled: intercombackend.door_open(false)
        }

    }

    Connections {
        target: intercombackend
    }

}
