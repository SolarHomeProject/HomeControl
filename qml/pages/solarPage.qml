import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Style"
import "../components"

Item {
    Component.onCompleted: solarbackend.active()
    Component.onDestruction: solarbackend.inactive()

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
                    text: "Akt. Ertrag"
                    font.pixelSize: 12
                }

                Text {
                    id: inverteravpText
                    anchors.centerIn: parent
                    color: Style.textColor
                    font.pixelSize: 24
                    font.bold: true
                }

            }

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 280
                    height: 390
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Inverter-Daten"
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
                                text: "Tagesertrag"
                                font.pixelSize: 12
                            }

                            Text {
                                id: inverterdecText
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
                                text: "Gesamt-Ertrag"
                                font.pixelSize: 12
                            }

                            Text {
                                id: invertertecText
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
                                text: "AC-Spannung"
                                font.pixelSize: 12
                            }

                            Text {
                                id: inverteracvText
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
                                color: Style.textColor
                                text: "DC-Spannung"
                                anchors.top: parent.top
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                id: inverterdcvText
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
                                text: "Inverter-Temperatur"
                                anchors.top: parent.top
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                id: invertertempText
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
                                text: "Inverter ID"
                                anchors.top: parent.top
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                id: inverteridText
                                color: Style.textColor
                                font.pixelSize: 14
                                anchors.centerIn: parent
                                font.bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    width: 300
                    height: 150
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Panel-Temperatur"
                        font.pixelSize: 12
                    }

                    Rectangle {
                        id: notempOverlay
                        width: parent.width
                        height: 120
                        color: parent.color
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: false
                        z: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Nicht verfügbar"
                            color: Style.textColor
                            font.pixelSize: 14
                        }

                    }

                    Image {
                        width: 280
                        height: 120
                        source: "../images/solararray_icon.svg"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        mipmap: true

                        Text {
                            x: 237
                            y: 1
                            color: Style.textColor
                            text: "P1"
                            font.pixelSize: 17
                        }

                        Text {
                            x: 167
                            y: 1
                            color: Style.textColor
                            text: "P2"
                            font.pixelSize: 17
                        }

                        Text {
                            x: 95
                            y: 1
                            color: Style.textColor
                            text: "P3"
                            font.pixelSize: 17
                        }

                        Text {
                            x: 25
                            y: 1
                            color: Style.textColor
                            text: "P4"
                            font.pixelSize: 17
                        }

                        Text {
                            id: p1sen1Text
                            x: 211
                            y: 60
                            width: 69
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            color: Style.textColor
                            font.pixelSize: 14
                        }

                        Text {
                            id: p2sen1Text
                            x: 141
                            y: 60
                            width: 70
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            color: Style.textColor
                            font.pixelSize: 14
                        }

                        Text {
                            id: p3sen1Text
                            x: 70
                            y: 60
                            width: 70
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            color: Style.textColor
                            font.pixelSize: 14
                        }

                        Text {
                            id: p4sen1Text
                            x: 0
                            y: 60
                            width: 69
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            color: Style.textColor
                            font.pixelSize: 14
                        }

                    }
                }

            }

            TimeChartView {
                id: chart
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 235

                Rectangle {
                    id: nodbdataOverlay
                    color: Style.innerrectBg
                    anchors.fill: parent
                    radius: 10
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
            y: 476
            model: ["W Heute", "W Gestern", "kW/h Jahresertrag"]
            onActivated: {
                let query = "today"
                if (charttimeComboBox.currentIndex == 0) {
                    query = "today"
                    chart.zoomReset();
                } else if (charttimeComboBox.currentIndex == 1) {
                    query = "yesterday"
                    chart.zoomReset();
                } else if (charttimeComboBox.currentIndex == 2) {
                    query = "year"
                    chart.zoomReset();
                }
                solarbackend.get_db_data(query)
            }
        }

    }

    Connections {
        target: solarbackend

        function onData(data) {
            if ("error" in data) {
                onError(data.error)
            } else {
                loadOverlay.visible = false
                if ([data.P1sen1, data.P2sen1, data.P3sen1, data.P4sen1].indexOf(solarbackend.get_temp_disconnected()) +1) {
                    notempOverlay.visible = true
                } else {
                    notempOverlay.visible = false
                }
                inverteravpText.text = `${data.inverterAVP} W`
                inverterdecText.text = `${data.inverterDEC} kW/h`
                invertertecText.text = `${data.inverterTEC} kW/h`
                inverteracvText.text = `${data.inverterACV} V`
                inverterdcvText.text = `${data.inverterDCV} V`
                invertertempText.text = `${data.chassisSen1} °C`
                inverteridText.text = data.inverterID
                p1sen1Text.text = `${data.P1sen1} °C`
                p2sen1Text.text = `${data.P2sen1} °C`
                p3sen1Text.text = `${data.P3sen1} °C`
                p4sen1Text.text = `${data.P4sen1} °C`
            }
        }

        function onError(errorString) {
            loadOverlay.visible = true
            busyIndicator.visible = false
            errorImg.visible = true
            errorText.text = errorString
        }

        function onDatadb(times, values) {
            if (!times.length & !values.length) {
                nodbdataOverlay.visible = true
                return
            } else {
                nodbdataOverlay.visible = false
            }

            chart.maxValue = Math.ceil(Math.max.apply(Math, values))
            chart.minValue = Math.min.apply(Math, values)
            chart.time = times
            chart.value = values
        }
    }

}
