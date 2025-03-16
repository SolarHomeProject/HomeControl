import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: button

    property color bgColor: "#4891d9"
    property color bgColorPressed: "#3F7EBD"
    property url img
    property int bgRadius: 10

    background: Rectangle {
        color: (button.down) ? bgColorPressed : bgColor
        radius: bgRadius
    }

    Image {
        anchors.fill: parent
        source: img
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }
}
