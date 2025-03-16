import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15
import "../Style"
import "../components"
import "../js/swsc_state_translate.js" as Swsc_state_translate

Item {
    Component.onCompleted: boilerbackend.active()
    Component.onDestruction: boilerbackend.inactive()

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

        CustomDialog {
            id: edialog
            colorContent: "red"
            headerPic: "../images/warning_icon.svg"
            headerTitle: "Fehler"
            bodyText: "Einstellungen konnten nicht gesetzt werden!"
            acceptedButtonText: "OK"
            rejectedButtonText: ""
        }

        Column {
            anchors.fill: parent
            anchors.topMargin: 10
            spacing: Style.spacing

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 250
                height: 80
                color: Style.outerrectBg
                radius: Style.radius

                Text {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Style.textColor
                    text: "Boiler-Temperatur"
                    font.pixelSize: 12
                }

                Text {
                    id: boilertempText
                    anchors.centerIn: parent
                    color: Style.textColor
                    font.pixelSize: 24
                    font.bold: true
                }

            }

            Row {
                spacing: Style.spacing
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 270
                    height: 350
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Status"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 200
                        anchors.centerIn: parent
                        spacing: Style.spacing

                        Rectangle {
                            width: parent.width
                            height: 50
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                text: "Zustand"
                                font.pixelSize: 12
                            }

                            Text {
                                id: stateText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                        Rectangle {
                            width: parent.width
                            height: 50
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                text: "Momentane Leistung (Solar)"
                                font.pixelSize: 12
                            }

                            Text {
                                id: solarchargeText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                        Rectangle {
                            width: parent.width
                            height: 50
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                text: "Nachtstrom"
                                font.pixelSize: 12
                            }

                            Text {
                                id: nightstateText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                        Rectangle {
                            id: daystateRect
                            width: parent.width
                            height: 50
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                color: Style.textColor
                                text: "Tagstrom"
                                anchors.top: parent.top
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                id: daystateText
                                color: Style.textColor
                                font.pixelSize: 14
                                anchors.centerIn: parent
                                font.bold: true
                            }

                        }

                        Rectangle {
                            width: parent.width
                            height: 50
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                color: Style.textColor
                                text: "Überschreiben"
                                anchors.top: parent.top
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                id: overridestateText
                                color: Style.textColor
                                font.pixelSize: 14
                                anchors.centerIn: parent
                                font.bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    width: 270
                    height: 300
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Einstellungen"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 200
                        anchors.centerIn: parent
                        spacing: 30

                        Rectangle {
                            width: parent.width
                            height: 70
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                text: "Modus"
                                font.pixelSize: 12
                            }

                            CustomComboBox {
                                id: devicemodeComboBox
                                anchors.centerIn: parent
                                width: parent.width
                                model: ListModel {
                                    Component.onCompleted: {
                                        for (let element of boilerbackend.get_devicemodes()) {
                                            this.append({name: Swsc_state_translate.translate(element)})
                                        }
                                        devicemodeComboBox.currentIndex = boilerbackend.get_mode()
                                    }
                                }
                                onActivated: submitButton.enabled = true
                            }

                        }

                        Rectangle {
                            width: parent.width
                            height: 70
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                text: "Wasser-Zieltemperatur"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: waterttempSpinBox
                                anchors.centerIn: parent
                                to: 100
                                value: boilerbackend.get_waterttemp()
                                onValueModified: submitButton.enabled = true
                            }

                        }

                        CustomButton {
                            id: submitButton
                            width: parent.width
                            height: 70
                            text: "Einstellen"
                            enabled: false
                            onClicked: if (!boilerbackend.set_settings(devicemodeComboBox.currentIndex, waterttempSpinBox.value)) edialog.open()
                        }

                    }

                }

                Rectangle {
                    width: 270
                    height: 300
                    color: Style.outerrectBg
                    radius: Style.radius
                    visible: failstoreRpt.count

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Fehlerliste"
                        font.pixelSize: 12
                    }

                    Column {
                        anchors.centerIn: parent
                        width: parent.width
                        spacing: Style.spacing

                        Repeater {
                            id: failstoreRpt

                            Rectangle {
                                width: parent.width
                                height: 20
                                color: "#d61818"

                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    verticalAlignment: Text.AlignVCenter
                                    color: Style.textColor
                                    text: modelData
                                    font.pointSize: 12

                                }

                            }

                        }

                        CustomButton {
                            id: failstoreclearButton
                            width: parent.width
                            height: 20
                            text: "Löschen"
                            onClicked: boilerbackend.clear_failstore()
                        }

                    }

                }

            }

            TimeChartView {
                id: chart
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 270

                Rectangle {
                    id: nodbdataOverlay
                    color: Style.innerrectBg
                    anchors.fill: parent
                    radius: Style.radius
                    visible: false
                    z: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Keine Daten verfügbar"
                        color: Style.textColor
                        font.pixelSize: 14
                    }

                }

            }

        }

        CustomComboBox {
            id: charttimeComboBox
            anchors.right: parent.right
            anchors.rightMargin: 12
            y: 436
            width: 150
            model: ["°C Heute", "°C Gestern"]
            onActivated: {
                let query = "today"
                if (charttimeComboBox.currentIndex == 0) {
                    query = "today"
                    chart.zoomReset();
                } else if (charttimeComboBox.currentIndex == 1) {
                    query = "yesterday"
                    chart.zoomReset();
                }
                boilerbackend.get_db_data(query)
            }
        }

    }

    Connections {
        target: boilerbackend

        function onData(data) {
            loadOverlay.visible = false
            boilertempText.text = `${data.boilertemp} °C`
            solarchargeText.text = `${data.currentsolarcharge} W`
            nightstateText.text = data.nightstate ? "EIN" : "AUS"
            if ("daystate" in data) {
                daystateRect.visible = true
                daystateText.text = data.daystate ? "EIN" : "AUS"
            } else {
                daystateRect.visible = false
            }
            overridestateText.text = data.overridestate ? "EIN" : "AUS"
            stateText.text = Swsc_state_translate.translate(data.state)
            if (data.failstore) {
                failstoreRpt.model = data.failstore.slice(0, -1).split(";")
            } else {
                failstoreRpt.model = []
            }
        }

        function onError(errorString) {
            loadOverlay.visible = true
            busyIndicator.visible = false
            errorImg.visible = true
            errorText.text = errorString
        }

        function onDatadb(data) {
            if (Object.keys(data).length === 0) {
                nodbdataOverlay.visible = true
                return
            } else {
                nodbdataOverlay.visible = false
            }

            var timeArray = []
            var valueArray = []
            for (const [time, value] of Object.entries(data)) {
                timeArray.push(time)
                valueArray.push(value)
            }

            chart.maxValue = Math.ceil(Math.max.apply(Math, valueArray))
            chart.minValue = Math.min.apply(Math, valueArray)
            chart.time = timeArray
            chart.value = valueArray
        }
    }

}
