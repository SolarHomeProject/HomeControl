import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Style"
import "../components"
import "../js/swsc_state_translate.js" as Swsc_state_translate
import "../js/conversion.js" as Conversion

Item {
    Component.onCompleted: homebackend.active()
    Component.onDestruction: homebackend.inactive()

    Rectangle {
        color: Style.pageBg
        anchors.fill: parent

        Rectangle {
            id: loadOverlay
            color: parent.color
            anchors.fill: parent
            z: 1

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

        }

        Column {
            anchors.fill: parent
            spacing: 60

            Text {
                id: labelDate
                anchors.horizontalCenter: parent.horizontalCenter
                color: Style.textColor
                font.pointSize: 23

                Timer {
                    id: timerClock
                    repeat: true
                    running: true
                    onTriggered: labelDate.text = new Date().toLocaleDateString(Qt.locale("de_DE"))
                }

            }

            GridLayout {
                columns: 3
                anchors.horizontalCenter: parent.horizontalCenter
                columnSpacing: 40
                rowSpacing: 40

                Tile {
                    id: tileAVP
                    labelText: "Momentaner Solar-Ertrag"
                    unit: "W"
                }

                Tile {
                    id: tileDEC
                    labelText: "Solar-Ertrag (Tag)"
                    unit: "kW/h"
                }

                Tile {
                    id: tilePower
                    labelText: "Energieverbrauch"
                    unit: "W"
                }

                Tile {
                    id: tileBoilerstate
                    labelText: "Boiler-Status"
                }

                Tile {
                    id: tileBoilertemp
                    labelText: "Boiler-Temperatur"
                    unit: "°C"
                }

                Tile {
                    id: tileRoomtemp
                    labelText: "Raumtemperatur"
                    unit: "°C"
                }

            }

        }

    }

    Connections {
        target: homebackend

        function onData(inverterAVP, inverterDEC, total_power, boiler_status, boiler_temp, room_temp) {
            loadOverlay.visible = false
            tileAVP.value = inverterAVP
            tileDEC.value = inverterDEC
            const conv = Conversion.wattsToKilowatts(total_power)
            tilePower.value = conv.value
            tilePower.unit = conv.unit
            tileBoilerstate.valueString = Swsc_state_translate.translate(boiler_status)
            tileBoilertemp.value = boiler_temp
            tileRoomtemp.value = room_temp
        }

        function onError(errorString) {
            loadOverlay.visible = true
            busyIndicator.visible = false
            errorImg.visible = true
            errorText.text = errorString
        }
    }

}
