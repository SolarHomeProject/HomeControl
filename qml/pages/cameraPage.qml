import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import QtMultimedia 5.4
import "../Style"
import "../components"

Item {

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
            anchors.fill: parent
            source: MediaPlayer {
                source: camerabackend.get_cameraurl()
                autoPlay: true
                muted: true
                onError: {
                    busyIndicator.visible = false
                    errorImg.visible = true
                    errorText.text = errorString
                }
            }
        }

        SwipeView {
            id: imageSlider
            anchors.fill: parent
            clip: true
            visible: false
            z: 1

            Repeater {
                model: FolderListModel {
                    id: imagesModel
                    folder: camerabackend.get_ftpimgpath()
                }

                Image {
                    source: `${imagesModel.folder}/${fileName}`
                    fillMode: Image.PreserveAspectFit

                    CustomImageButton {
                        width: 50
                        height: 50
                        anchors.right: parent.right
                        anchors.top: parent.top
                        onClicked: imageSlider.visible = false
                        bgColor: "#1c1d20"
                        bgColorPressed: "#00a1f1"
                        bgRadius: 0
                        img: "../images/close_icon.svg"
                    }

                }

            }

        }

        MouseArea {
            anchors.fill: parent
            onClicked: imageSlider.visible = true
        }

    }

}
