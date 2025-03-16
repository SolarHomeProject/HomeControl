import QtQuick 2.15
import QtQuick.Controls 2.15

ProgressBar {
    id: progressbar

    property color colorBackground: "#e6e6e6"
    property color colorBar: "#55aaff"

    to: 100
    padding: 2
    indeterminate: this.value === -1

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 6
        color: colorBackground
        radius: 3
    }

    contentItem: Item {
        implicitWidth: 200
        implicitHeight: 4

        Rectangle {
            width: progressbar.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: colorBar
        }

    }

    Text {
        y: -5
        anchors.left: progressbar.right
        anchors.leftMargin: 5
        color: "#c3cbdd"
        text: `${progressbar.value}%`
        visible: progressbar.value
    }

}
