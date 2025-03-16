import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15
import "../Style"
import "../components"
import "../js/conversion.js" as Conversion

Item {
    Component.onCompleted: energybackend.active()
    Component.onDestruction: energybackend.inactive()

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
                    text: "Akt. Verbrauch"
                    font.pixelSize: 12
                }

                Text {
                    id: energyText
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
                    width: 230
                    height: 205
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Phase 1"
                        font.pixelSize: 12
                    }

                    Column {
                        anchors.centerIn: parent
                        width: 150
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
                                text: "Leistung"
                                font.pixelSize: 12
                            }

                            Text {
                                id: l1pText
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
                                text: "Strom"
                                font.pixelSize: 12
                            }

                            Text {
                                id: l1aText
                                anchors.centerIn: parent
                                color: "#c3cbdd"
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
                                text: "Spannung"
                                font.pixelSize: 12
                            }

                            Text {
                                id: l1vText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    width: 230
                    height: 205
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Phase 2"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 150
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
                                text: "Leistung"
                                font.pixelSize: 12
                            }

                            Text {
                                id: l2pText
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
                                text: "Strom"
                                font.pixelSize: 12
                            }

                            Text {
                                id: l2aText
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
                                text: "Spannung"
                                font.pixelSize: 12
                            }

                            Text {
                                id: l2vText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }
                    }

                }

                Rectangle {
                    width: 230
                    height: 205
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Phase 3"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 150
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
                                text: "Leistung"
                                font.pixelSize: 12
                            }

                            Text {
                                id: l3pText
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
                                text: "Strom"
                                font.pixelSize: 12
                            }

                            Text {
                                id: l3aText
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
                                text: "Spannung"
                                font.pixelSize: 12
                            }

                            Text {
                                id: l3vText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                    }

                }
            }

            TimeChartView {
                id: chart
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 410

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
            y: 291
            width: 140
            model: ["W Heute", "W Gestern"]
            onActivated: {
                let query = "today"
                if (charttimeComboBox.currentIndex == 0) {
                    query = "today"
                    chart.zoomReset();
                } else if (charttimeComboBox.currentIndex == 1) {
                    query = "yesterday"
                    chart.zoomReset();
                }
                energybackend.get_db_data(query)
            }
        }

    }

    Connections {
        target: energybackend

        function onData(l1p, l1a, l1v, l2p, l2a, l2v, l3p, l3a, l3v, total_power) {
            loadOverlay.visible = false
            l1pText.text = `${l1p} W`
            l1aText.text = `${l1a} A`
            l1vText.text = `${l1v} V`
            l2pText.text = `${l2p} W`
            l2aText.text = `${l2a} A`
            l2vText.text = `${l2v} V`
            l3pText.text = `${l3p} W`
            l3aText.text = `${l3a} A`
            l3vText.text = `${l3v} V`
            const conv = Conversion.wattsToKilowatts(total_power)
            energyText.text = `${conv.value} ${conv.unit}`
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
