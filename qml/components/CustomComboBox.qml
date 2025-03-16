import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    width: 210
    height: 33

    popup.contentItem {
     transform: [ Rotation { angle: 180 } ]
     transformOrigin: Item.TopLeft
    }

    popup.background {
     transform: [ Rotation { angle: 180 } ]
     transformOrigin: Item.TopLeft
   }

}
