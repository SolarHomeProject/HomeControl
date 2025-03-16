import QtQuick 2.15

Rectangle {
    radius: 10
    width: 200
    height: 200

    property color bg: "lightblue"
    property string labelText
    property real value
    property string valueString
    property string unit

    color: bg

    Text {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: labelText
        font.pixelSize: 15
    }

    Text {
        id: valueText
        anchors.centerIn: parent
        text: (valueString) ? "" : value
        font.pixelSize: 35
    }

    Text {
        anchors.centerIn: parent
        text: valueString
        font.pixelSize: 25
    }

    Text {
        anchors.top: valueText.top
        anchors.left: valueText.right
        anchors.leftMargin: 8
        anchors.topMargin: 5
        text: unit
        font.pixelSize: 20
    }

}
