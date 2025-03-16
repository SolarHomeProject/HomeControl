import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Style"
import "../components"
import "../js/validate.js" as Validate

Item {
    Component.onCompleted: settingsbackend.active()

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
            bodyText: "IP-Address Eingaben überprüfen!"
            acceptedButtonText: "OK"
            rejectedButtonText: ""
        }

        CustomDialog {
            id: qdialog
            property string action
            onAcceptedButtonClicked: settingsbackend.system_action(this.action)
        }

        TabBar {
            id: tabBar
            width: parent.width

            TabButton {
                text: "Bildschirm"
            }

            TabButton {
                text: "Audio"
            }

            TabButton {
                text: "Netzwerk"
            }

            TabButton {
                text: "Daten-APIs"
            }

            TabButton {
                text: "Update"
            }

            TabButton {
                text: "System"
            }

            TabButton {
                text: "Info"
            }

        }

        StackLayout {
            width: parent.width
            currentIndex: tabBar.currentIndex

            Item {
                id: displayTab

                Rectangle {
                    x: 470
                    y: 220
                    width: 270
                    height: 300
                    color: Style.outerrectBg
                    radius: Style.radius

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
                                text: "Timeout (s)"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: displaytimeoutSpinbox
                                anchors.centerIn: parent
                                from: 10
                                to: 120
                                onValueModified: dsubmitButton.enabled = true
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
                                text: "Helligkeit (%)"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: displaybrightnessSpinbox
                                anchors.centerIn: parent
                                to: 100
                                onValueModified: dsubmitButton.enabled = true
                            }

                        }

                        CustomButton {
                            id: dsubmitButton
                            width: parent.width
                            height: 70
                            text: "Einstellen"
                            enabled: false
                            onClicked: settingsbackend.set_display(displaytimeoutSpinbox.value, displaybrightnessSpinbox.value)
                        }

                    }

                }

            }

            Item {
                id: audioTab

                Rectangle {
                    x: 470
                    y: 70
                    width: 270
                    height: 600
                    color: Style.outerrectBg
                    radius: Style.radius

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
                                text: "Lautstärke Hörer LP (%)"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: hsspeakervolSpinbox
                                anchors.centerIn: parent
                                to: 100
                                onValueModified: asubmitButton.enabled = true
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
                                text: "Lautstärke Hörer Mic (%)"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: hsmicvolSpinbox
                                anchors.centerIn: parent
                                to: 100
                                onValueModified: asubmitButton.enabled = true
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
                                text: "Lautstärke Türstation LP (%)"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: dsspeakervolSpinbox
                                anchors.centerIn: parent
                                to: 100
                                onValueModified: asubmitButton.enabled = true
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
                                text: "Lautstärke Türstation Mic (%)"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: dsmicvolSpinbox
                                anchors.centerIn: parent
                                to: 100
                                onValueModified: asubmitButton.enabled = true
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
                                text: "Lautstärke Intern (%)"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: intspeakervolSpinbox
                                anchors.centerIn: parent
                                to: 100
                                onValueModified: asubmitButton.enabled = true
                            }

                        }

                        CustomButton {
                            id: asubmitButton
                            width: parent.width
                            height: 70
                            text: "Einstellen"
                            enabled: false
                            onClicked: settingsbackend.set_audio(hsspeakervolSpinbox.value, hsmicvolSpinbox.value, dsspeakervolSpinbox.value, dsmicvolSpinbox.value, intspeakervolSpinbox.value)
                        }

                    }

                }

            }

            Item {
                id: networkTab

                QtObject {
                    id: submit_netset

                    function validset() {
                        if (wifidhcpCheckbox.checked && Validate.ip_address(lanipTextField.text) && Validate.ip_address(lansmTextField.text)) {
                            settingsbackend.set_network_wifidhcp(lanipTextField.text, lansmTextField.text)
                        } else if (!wifidhcpCheckbox.checked && Validate.ip_address(lanipTextField.text) && Validate.ip_address(lansmTextField.text) && Validate.ip_address(wifiipTextField.text) && Validate.ip_address(wifismTextField.text) && Validate.ip_address(wifigwTextField.text) && Validate.ip_address(wifidnsTextField.text)) {
                            settingsbackend.set_network(lanipTextField.text, lansmTextField.text, wifiipTextField.text, wifismTextField.text, wifigwTextField.text, wifidnsTextField.text)
                        } else {
                            edialog.bodyText = "IP-Address Eingaben überprüfen!"
                            edialog.open()
                        }
                    }

                }

                Rectangle {
                    x: 200
                    y: 220
                    width: 250
                    height: 300
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "HT-LAN"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 180
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
                                text: "IP"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: lanipTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "x.x.x.x"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/
                                }
                                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                                onTextEdited: nlansubmitButton.enabled = true
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
                                text: "SM"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: lansmTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "x.x.x.x"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/
                                }
                                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                                onTextEdited: nlansubmitButton.enabled = true
                            }

                        }

                        CustomButton {
                            id: nlansubmitButton
                            width: parent.width
                            height: 70
                            text: "Einstellen"
                            enabled: false
                            onClicked: submit_netset.validset()
                        }

                    }

                }

                Rectangle {
                    x: 760
                    y: 70
                    width: 250
                    height: 600
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "WIFI"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 180
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

                            CheckBox {
                                id: wifidhcpCheckbox
                                anchors.centerIn: parent
                                text: "DHCP"
                                onClicked: nwifisubmitButton.enabled = true
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
                                text: "IP"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: wifiipTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "x.x.x.x"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/
                                }
                                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                                onTextEdited: nwifisubmitButton.enabled = true
                                enabled: !wifidhcpCheckbox.checked
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
                                text: "SM"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: wifismTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "x.x.x.x"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/
                                }
                                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                                onTextEdited: nwifisubmitButton.enabled = true
                                enabled: !wifidhcpCheckbox.checked
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
                                text: "GW"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: wifigwTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "x.x.x.x"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/
                                }
                                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                                onTextEdited: nwifisubmitButton.enabled = true
                                enabled: !wifidhcpCheckbox.checked
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
                                text: "DNS"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: wifidnsTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "x.x.x.x"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/
                                }
                                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                                onTextEdited: nwifisubmitButton.enabled = true
                                enabled: !wifidhcpCheckbox.checked
                            }

                        }

                        CustomButton {
                            id: nwifisubmitButton
                            width: parent.width
                            height: 70
                            text: "Einstellen"
                            enabled: false
                            onClicked: submit_netset.validset()
                        }

                    }

                }

                Rectangle {
                    x: 470
                    y: 70
                    width: 270
                    height: 600
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "WIFI-Verbindung"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 200
                        anchors.centerIn: parent
                        spacing: 30

                        Rectangle {
                            width: parent.width
                            height: 260
                            color: Style.innerrectBg
                            radius: Style.radius
                            clip: true

                            Column {
                                anchors.fill: parent
                                spacing: Style.spacing

                                Repeater {
                                    model: ListModel {
                                        id: wifiscanModel
                                    }

                                    Rectangle {
                                        height: 20
                                        width: parent.width
                                        color: model.security ? "red" : "green"

                                        Text {
                                            text: model.ssid
                                            width: parent.width
                                            height: parent.height
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                            elide: Text.ElideRight
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                wifissidTextField.text = model.ssid
                                                pwRect.visible = model.security
                                                wifipwTextField.text = ""
                                            }
                                        }

                                    }

                                }

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
                                text: "SSID"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: wifissidTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: ""
                                inputMethodHints: Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
                                onTextChanged: connwifisubmitButton.enabled = true
                            }

                        }

                        Rectangle {
                            id: pwRect
                            width: parent.width
                            height: 70
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                text: "PW"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: wifipwTextField
                                anchors.centerIn: parent
                                width: parent.width
                                echoMode: TextInput.Password
                                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                                placeholderText: ""
                                onTextChanged: connwifisubmitButton.enabled = true
                            }

                        }

                        CustomButton {
                            id: connwifisubmitButton
                            width: parent.width
                            height: 70
                            text: "Verbinden"
                            enabled: false
                            onClicked: {
                                if ((wifissidTextField.length > 0) && ((pwRect.visible && wifipwTextField.length >= 8) || (!pwRect.visible))) {
                                    settingsbackend.wifi_connect(wifissidTextField.text, wifipwTextField.text)
                                } else {
                                    edialog.bodyText = "WIFI-Verbindung überprüfen!"
                                    edialog.open()
                                }
                            }
                        }

                    }

                }

            }

            Item {
                id: apiTab

                Rectangle {
                    x: 455
                    y: 120
                    width: 300
                    height: 500
                    color: Style.outerrectBg
                    radius: Style.radius

                    Column {
                        width: 230
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
                                text: "Shelly API-Host"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: shellyhostTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "x.x.x.x"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/
                                }
                                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                                onTextEdited: apisubmitButton.enabled = true
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
                                text: "SolarDataCollector API-Host"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: sdchostTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "x.x.x.x"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/
                                }
                                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                                onTextEdited: apisubmitButton.enabled = true
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
                                text: "SolarWaterStorageController API-Host"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: swschostTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "x.x.x.x"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/
                                }
                                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                                onTextEdited: apisubmitButton.enabled = true
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
                                text: "Kamera URL (rtsp)"
                                font.pixelSize: 12
                            }

                            CustomTextField {
                                id: cameraurlTextField
                                anchors.centerIn: parent
                                width: parent.width
                                placeholderText: "URL"
                                validator: RegularExpressionValidator {
                                    regularExpression: /^rtsp:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/
                                }
                                inputMethodHints: Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
                                onTextEdited: apisubmitButton.enabled = true
                            }

                        }

                        CustomButton {
                            id: apisubmitButton
                            width: parent.width
                            height: 70
                            text: "Speichern"
                            enabled: false
                            onClicked: {
                                if (Validate.ip_address(shellyhostTextField.text) && Validate.ip_address(sdchostTextField.text) && Validate.ip_address(swschostTextField.text) && Validate.rtsp_addr(cameraurlTextField.text)) {
                                    settingsbackend.set_api(shellyhostTextField.text, sdchostTextField.text, swschostTextField.text, cameraurlTextField.text)
                                    qdialog.headerTitle = "Neustart erf."
                                    qdialog.bodyText = "Neustarten für Änderungen"
                                    qdialog.action = "reboot"
                                    qdialog.open()
                                } else {
                                    edialog.bodyText = "API Eingaben überprüfen!"
                                    edialog.open()
                                }
                            }
                        }

                    }

                }

            }

            Item {
                id: updateTab

                Rectangle {
                    x: 355
                    y: 120
                    width: 500
                    height: 500
                    color: Style.outerrectBg
                    radius: Style.radius

                    Column {
                        width: 430
                        anchors.centerIn: parent
                        spacing: Style.spacing

                        CustomButton {
                            id: updatesystemButton
                            width: parent.width
                            height: 70
                            text: "System aktualisieren"
                            onClicked: {
                                settingsbackend.run_systemupd()
                                this.enabled = false
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 170
                            color: Style.innerrectBg
                            radius: Style.radius

                            Column {
                                spacing: Style.spacing
                                anchors.topMargin: 10
                                anchors.fill: parent

                                Text {
                                    id: aptomText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: Style.textColor
                                }

                                CustomProgressBar {
                                    id: aptomProgress
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 320
                                    visible: this.value !== 0
                                }

                                Text {
                                    id: aptpgText
                                    horizontalAlignment: Text.AlignHCenter
                                    width: parent.width
                                    color: Style.textColor
                                    wrapMode: Text.Wrap
                                }

                                CustomProgressBar {
                                    id: aptpgProgress
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 320
                                    visible: this.value !== 0
                                }

                                Text {
                                    id: aptimText
                                    horizontalAlignment: Text.AlignHCenter
                                    width: parent.width
                                    color: Style.textColor
                                    wrapMode: Text.Wrap
                                }

                                CustomProgressBar {
                                    id: aptimProgress
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 320
                                    visible: this.value !== 0
                                }

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
                                text: "HomeControl Version"
                                font.pixelSize: 12
                            }

                            Text {
                                id: appverText
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
                                text: "HomeControl-OS Version"
                                font.pixelSize: 12
                            }

                            Text {
                                id: hcosverText
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
                                text: "Kernel-Version"
                                font.pixelSize: 12
                            }

                            Text {
                                id: kernelverText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                    }

                }
            }

            Item {
                id: systemTab

                Rectangle {
                    x: 405
                    y: 70
                    width: 400
                    height: 600
                    color: Style.outerrectBg
                    radius: Style.radius

                    Column {
                        width: 330
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
                                text: "Daten Aktualisierungsrate (s)"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: datarefreshrateSpinbox
                                anchors.centerIn: parent
                                from: 1
                                to: 60
                                onValueModified: ssubmitButton.enabled = true
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
                                text: "Datenbank Aktualisierungsrate (s)"
                                font.pixelSize: 12
                            }

                            SpinBox {
                                id: dbrefreshrateSpinbox
                                anchors.centerIn: parent
                                from: 10
                                to: 120
                                onValueModified: ssubmitButton.enabled = true
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
                                text: "Nachtzeit (h)"
                                font.pixelSize: 12
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: Style.spacing

                                SpinBox {
                                    id: nighttimefromSpinbox
                                    from: 16
                                    to: 20
                                    onValueModified: ssubmitButton.enabled = true
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: Style.textColor
                                    font.pixelSize: 16
                                    text: "bis"
                                }

                                SpinBox {
                                    id: nighttimetoSpinbox
                                    from: 5
                                    to: 8
                                    onValueModified: ssubmitButton.enabled = true
                                }

                            }

                        }

                        CustomButton {
                            id: ssubmitButton
                            width: parent.width
                            height: 70
                            text: "Einstellen"
                            enabled: false
                            onClicked: settingsbackend.set_system(datarefreshrateSpinbox.value, dbrefreshrateSpinbox.value, nighttimefromSpinbox.value, nighttimetoSpinbox.value)
                        }

                        CustomButton {
                            id: shutdownButton
                            width: parent.width
                            height: 70
                            text: "System herunterfahren"
                            onClicked: {
                                qdialog.headerTitle = "Herunterfahren"
                                qdialog.bodyText = "Wirklich herunterfahren?"
                                qdialog.action = "shutdown"
                                qdialog.open()
                            }
                        }

                        CustomButton {
                            id: rebootButton
                            width: parent.width
                            height: 70
                            text: "System neustarten"
                            onClicked: {
                                qdialog.headerTitle = "Neustarten"
                                qdialog.bodyText = "Wirklich neustarten?"
                                qdialog.action = "reboot"
                                qdialog.open()
                            }
                            onPressAndHold: {
                                qdialog.headerTitle = "System zurücksetzen"
                                qdialog.bodyText = "System wird zurückgesetzt und neugestartet. Fortfahren?"
                                qdialog.action = "sysreset"
                                qdialog.open()
                            }
                        }

                    }

                }

                Rectangle {
                    x: 102
                    y: 80
                    width: 250
                    height: 580
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Dienste"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 180
                        spacing: 30
                        anchors.centerIn: parent

                        Rectangle {
                            width: parent.width
                            height: 180
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                text: "FTP Kamerabild Server"
                                font.pixelSize: 12
                            }

                            Column {
                                spacing: 1
                                anchors.topMargin: 10
                                anchors.fill: parent

                                CheckBox {
                                    id: ftpactiveCheckbox
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Aktiv"
                                    onClicked: sservicesubmitButton.enabled = true
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: Style.textColor
                                    text: "User"
                                    font.pixelSize: 12
                                    visible: ftpactiveCheckbox.checked
                                }

                                CustomTextField {
                                    id: ftpuserTextField
                                    width: parent.width
                                    placeholderText: ""
                                    onTextEdited: sservicesubmitButton.enabled = true
                                    visible: ftpactiveCheckbox.checked
                                    inputMethodHints: Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: Style.textColor
                                    text: "PW"
                                    font.pixelSize: 12
                                    visible: ftpactiveCheckbox.checked
                                }

                                CustomTextField {
                                    id: ftppwTextField
                                    width: parent.width
                                    placeholderText: ""
                                    onTextEdited: sservicesubmitButton.enabled = true
                                    echoMode: TextInput.Password
                                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                                    visible: ftpactiveCheckbox.checked
                                }

                            }

                        }

                        Rectangle {
                            width: parent.width
                            height: 110
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                text: "HomeControl WebApp"
                                font.pixelSize: 12
                            }

                            Column {
                                spacing: 1
                                anchors.topMargin: 10
                                anchors.fill: parent

                                CheckBox {
                                    id: webappactiveCheckbox
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Aktiv"
                                    onClicked: sservicesubmitButton.enabled = true
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: Style.textColor
                                    text: "WebApp PW"
                                    font.pixelSize: 12
                                    visible: webappactiveCheckbox.checked
                                }

                                CustomTextField {
                                    id: webapppwTextField
                                    width: parent.width
                                    placeholderText: ""
                                    onTextEdited: sservicesubmitButton.enabled = true
                                    echoMode: TextInput.Password
                                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                                    visible: webappactiveCheckbox.checked
                                }

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
                                text: "NTP Zeitserver"
                                font.pixelSize: 12
                            }

                            CheckBox {
                                id: ntpactiveCheckbox
                                anchors.centerIn: parent
                                text: "Aktiv"
                                onClicked: sservicesubmitButton.enabled = true
                            }

                        }

                        CustomButton {
                            id: sservicesubmitButton
                            width: parent.width
                            height: 70
                            text: "Anwenden"
                            enabled: false
                            onClicked: {
                                if ( ((ftpactiveCheckbox.checked && ftpuserTextField.text && ftppwTextField.text) || (!ftpactiveCheckbox.checked)) && ((webappactiveCheckbox.checked && webapppwTextField.text) || (!webappactiveCheckbox.checked)) ) {
                                    settingsbackend.set_system_services(ftpactiveCheckbox.checked, ftpuserTextField.text, ftppwTextField.text, webappactiveCheckbox.checked, webapppwTextField.text, ntpactiveCheckbox.checked)
                                } else {
                                    edialog.bodyText = "Dienste aut. Eingaben überprüfen!"
                                    edialog.open()
                                }
                            }
                        }

                    }

                }

            }

            Item {
                id: infoTab

                Rectangle {
                    x: 465
                    y: 45
                    width: 280
                    height: 220
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Thermischer Zustand"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 210
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
                                text: "Hardware Temperaturstatus"
                                font.pixelSize: 12
                            }

                            Text {
                                id: hwtempstateText
                                width: parent.width
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                                wrapMode: Text.Wrap
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
                                text: "Interne Temperatur"
                                font.pixelSize: 12
                            }

                            Text {
                                id: inttempText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    x: 197
                    y: 145
                    width: 250
                    height: 450
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Netzwerk"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 170
                        anchors.centerIn: parent
                        spacing: Style.radius

                        Rectangle {
                            width: parent.width
                            height: 50
                            color: Style.innerrectBg
                            radius: Style.radius

                            Text {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                text: "LAN-Interface Status"
                                font.pixelSize: 12
                            }

                            Text {
                                id: laninterfacestatusText
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
                                text: "WIFI-Interface Status"
                                font.pixelSize: 12
                            }

                            Text {
                                id: wifiinterfacestatusText
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
                                text: "LAN-Interface Aktiv"
                                font.pixelSize: 12
                            }

                            Text {
                                id: laninterfaceactiveText
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
                                text: "WIFI-Interface Aktiv"
                                anchors.top: parent.top
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                id: wifiinterfaceactiveText
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
                                text: "LAN-Interface OK"
                                anchors.top: parent.top
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                id: laninterfaceokText
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
                                text: "WIFI-Interface OK"
                                anchors.top: parent.top
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                id: wifiinterfaceokText
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
                                text: "Internetzugriff"
                                anchors.top: parent.top
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                id: inetaccessText
                                color: Style.textColor
                                font.pixelSize: 14
                                anchors.centerIn: parent
                                font.bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    x: 762
                    y: 145
                    width: 280
                    height: 450
                    color: Style.outerrectBg
                    radius: Style.radius
                    clip: true

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Speicher"
                        font.pixelSize: 12
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: Style.radius

                        Repeater {
                            model: ListModel {
                                id: storageModel
                            }

                            Rectangle {
                                width: 250
                                height: 100
                                color: Style.innerrectBg
                                radius: Style.radius

                                Text {
                                    color: Style.textColor
                                    text: model.disk
                                    anchors.top: parent.top
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Column {
                                    anchors.centerIn: parent
                                    width: parent.width
                                    spacing: 5

                                    Text {
                                        width: parent.width
                                        color: Style.textColor
                                        text: `- Partitionen: ${model.parts ? model.parts : "Keine Partitionen vorhanden"}`
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        color: Style.textColor
                                        text: `- Größe ${model.size} GB`
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        color: Style.textColor
                                        text: "(Interner Speicher)"
                                        font.pixelSize: 12
                                        font.bold: true
                                        visible: model.internal
                                    }

                                }

                            }

                        }

                    }

                }

                Rectangle {
                    x: 465
                    y: 270
                    width: 280
                    height: 220
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Zeit/Datum"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 210
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
                                text: "Akt. Zeit/Datum RTC"
                                font.pixelSize: 12
                            }

                            Text {
                                id: rtctimeText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
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
                                text: "Akt. Zeit/Datum System"
                                font.pixelSize: 12
                            }

                            Text {
                                id: localtimeText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    x: 465
                    y: 494
                    width: 280
                    height: 220
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Auslastung"
                        font.pixelSize: 12
                    }

                    Column {
                        width: 210
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
                                text: "CPU"
                                font.pixelSize: 12
                            }

                            Text {
                                id: cpupercText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
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
                                text: "RAM"
                                font.pixelSize: 12
                            }

                            Text {
                                id: mempercText
                                anchors.centerIn: parent
                                color: Style.textColor
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                    }

                }

            }

        }

    }

    Connections {
        target: settingsbackend

        function onDatadisplay(timeout, brightness_level, speaker_vol) {
            displaytimeoutSpinbox.value = timeout
            displaybrightnessSpinbox.value = brightness_level
        }

        function onDataaudio(handset_speaker_vol, handset_mic_vol, doorstation_speaker_vol, doorstation_mic_vol, internal_vol) {
            hsspeakervolSpinbox.value = handset_speaker_vol
            hsmicvolSpinbox.value = handset_mic_vol
            dsspeakervolSpinbox.value = doorstation_speaker_vol
            dsmicvolSpinbox.value = doorstation_mic_vol
            intspeakervolSpinbox.value = internal_vol
        }

        function onDatastorage(disk_data) {
            for (const [disk, info] of Object.entries(disk_data)) {
                storageModel.append({"disk": disk, parts: info.parts.toString(), size: info.size, internal: info.internal})
            }
        }

        function onDatanetwork(ethup, wifiup, ethactive, wifiactive, ethok, wifiok, ethparams, wifiparams, inetok) {
            laninterfacestatusText.text = ethup ? "Operativ" : "Aus"
            wifiinterfacestatusText.text = wifiup ? "Operativ" : "Aus"
            laninterfaceactiveText.text = ethactive ? "Aktiv" : "Inaktiv"
            wifiinterfaceactiveText.text = wifiactive ? "Aktiv" : "Inaktiv"
            laninterfaceokText.text = ethok ? "Ja" : "Nein"
            wifiinterfaceokText.text = wifiok ? "Ja" : "Nein"
            lanipTextField.text = ethparams.addr
            lansmTextField.text = ethparams.netmask
            wifidhcpCheckbox.checked = wifiparams.dhcp
            wifiipTextField.text = wifiparams.addr
            wifismTextField.text = wifiparams.netmask
            wifigwTextField.text = wifiparams.gw
            wifidnsTextField.text = wifiparams.dns
            inetaccessText.text = inetok ? "Ja" : "Nein"
        }

        function onDataapi(SHELLY_HOST, SDC_HOST, SWSC_HOST, CAMERA_URL) {
            shellyhostTextField.text = SHELLY_HOST
            sdchostTextField.text = SDC_HOST
            swschostTextField.text = SWSC_HOST
            cameraurlTextField.text = CAMERA_URL
        }

        function onAutoconfig_api_status(data) {
        }

        function onDataupdate (app_ver, hcos_ver, kernel_ver) {
            appverText.text = app_ver
            hcosverText.text = hcos_ver
            kernelverText.text = kernel_ver
        }

        function onDatasystem(DATA_REFRESH_RATE, DB_DATA_INSERT_RATE, NIGHT_TIME_RANGE, FTP_ENABLED, FTP_USER, FTP_PW, WEB_ENABLED, WEB_PW, NTP_ENABLED) {
            datarefreshrateSpinbox.value = DATA_REFRESH_RATE
            dbrefreshrateSpinbox.value = DB_DATA_INSERT_RATE
            nighttimefromSpinbox.value = NIGHT_TIME_RANGE[1]
            nighttimetoSpinbox.value = NIGHT_TIME_RANGE[0]
            ftpactiveCheckbox.checked = FTP_ENABLED
            ftpuserTextField.text = FTP_USER
            ftppwTextField.text = FTP_PW
            webappactiveCheckbox.checked = WEB_ENABLED
            webapppwTextField.text = WEB_PW
            ntpactiveCheckbox.checked = NTP_ENABLED
        }

        function onDatainfo(throttled_state, int_temp, rtc_time, local_time, cpu_percent, mem_percent) {
            hwtempstateText.text = throttled_state ? throttled_state : "Keine Meldung vorhanden"
            inttempText.text = int_temp
            rtctimeText.text = rtc_time
            localtimeText.text = local_time
            cpupercText.text = `${cpu_percent} %`
            mempercText.text = `${mem_percent} %`
            loadOverlay.visible = false
        }

        function onError(errorString) {
            busyIndicator.visible = false
            errorImg.visible = true
            errorText.text = errorString
        }

        function onWifiscanresult(ssid, rsnflags) {
            wifiscanModel.append({ssid: ssid, security: rsnflags})
        }

        function onAptprogress(status, progress_val) {
            aptpgProgress.value = progress_val
            if (status.startsWith("DL_RUNNING")) {
                aptpgText.text = `Herunterladen... (${status.split(" ")[1]}/${status.split(" ")[2]})`
            } else if (status.startsWith("FETCHFAIL")) {
                aptpgText.text = `${status.split(" ")[1]} konnte nicht geholt werden. Fehler: ${status.split(" ")[2]}`
            } else if (status === "DL_COMPLETE") {
                aptpgText.text = "Download beendet"
            } else if (status.startsWith("ITEMFETCH")) {
                aptpgText.text = `Hole ${status.split(" ")[1]}`
            } else if (status === "DL_STOP") {
                aptpgText.text = "Download abgeschlossen"
            } else if (status === "DL_START") {
                aptpgText.text = "Download gestartet"
            } else {
                aptpgText.text = status
            }
        }

        function onAptinstall(status, progress_val) {
            aptimProgress.value = progress_val
            if (status === "UPD_START") {
                aptimText.text = "Update gestartet"
            } else if (status === "UPD_FIN") {
                aptimText.text = "Update abgeschlossen"
            } else if (status.startsWith("INSTALLFAIL")) {
                aptimText.text = `Paket ${status.split(" ")[1]} konnte nicht installiert werden. Fehler: ${status.split(" ")[2]}`
            } else if (status.startsWith("STATECHANGE")) {
                aptimText.text = `${status.split(" ")[1]} status: ${status.split(" ")[2]}`
            } else if (status.startsWith("PKG_PROCESS")) {
                aptimText.text = `Verarbeite ${status.split(" ")[1]} für ${status.split(" ")[2]}`
            } else {
                aptimText.text = status
            }
        }

        function onAptop(status, progress_val) {
            aptomProgress.value = progress_val
            if (status === "CACHE_INS") {
                aptomText.text = "Cache Instanz"
            } else if (status === "CACHE_UPDATE") {
                aptomText.text = "Cache Update"
            } else if (status === "CACHE_OPEN") {
                aptomText.text = "Cache öffnen"
            } else if (status === "CACHE_UPGRADE") {
                aptomText.text = "Cache Upgrade"
            } else if (status === "CACHE_COMMIT") {
                aptomText.text = "Cache übernehmen"
            } else if (status.startsWith("STATECHANGE")) {
                aptomText.text = status.split(" ")[1]
            } else if (status === "DONE") {
                aptomText.text = "Abgeschlossen"
            } else {
                aptomText.text = status
            }
        }

        property var apterr

        function onUpdatedone() {
            updatesystemButton.enabled = true
            if (!apterr) {
                qdialog.headerTitle = "Update beendet"
                qdialog.bodyText = "Neustarten um Update anzuwenden?"
                qdialog.action = "reboot"
                qdialog.open()
            }
            apterr = false
            aptpgText.text = ""
            aptpgProgress.value = 0
            aptimText.text = ""
            aptimProgress.value = 0
            aptomText.text = ""
            aptomProgress.value = 0
        }

        function onApterr(errstr) {
            apterr = true
            edialog.bodyText = errstr
            edialog.open()
        }
    }

}
