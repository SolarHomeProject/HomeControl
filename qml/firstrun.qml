import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.VirtualKeyboard 2.15
import "Style"
import "components"
import "js/validate.js" as Validate

Window {
    id: mainWindow
    width: 1280
    height: 800
    visible: true

    InputPanel {
        y: Qt.inputMethod.visible ? this.height - parent.height / 2 : parent.height
        anchors.left: parent.left
        anchors.right: parent.right
        rotation: 180
        z: 999
    }

    CustomDialog {
        id: edialog
        colorContent: "red"
        headerPic: "images/warning_icon.svg"
        headerTitle: "Fehler"
        bodyText: "Eingaben überprüfen!"
        acceptedButtonText: "OK"
        rejectedButtonText: ""
    }

    Rectangle {
        id: bg
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Style.pageBg
        z: 1
        transform: Rotation {
            angle: 180
            origin.x: mainWindow.width / 2
            origin.y: mainWindow.height / 2
        }

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 20
            color: Style.textColor
            text: "HomeControl Einrichtung"
            font.pixelSize: 24
        }

        Rectangle {
            width: parent.width
            height: 50
            anchors.top: parent.top
            anchors.topMargin: 60
            color: Style.outerrectBg
        }

        StackLayout {
            id: stackLayout
            width: parent.width

            Item {
                id: networkTab

                QtObject {
                    id: submit_netset

                    function validset() {
                        if (wifidhcpCheckbox.checked && Validate.ip_address(lanipTextField.text) && Validate.ip_address(lansmTextField.text)) {
                            settingsbackend.set_network_wifidhcp(lanipTextField.text, lansmTextField.text)
                            return true
                        } else if (!wifidhcpCheckbox.checked && Validate.ip_address(lanipTextField.text) && Validate.ip_address(lansmTextField.text) && Validate.ip_address(wifiipTextField.text) && Validate.ip_address(wifismTextField.text) && Validate.ip_address(wifigwTextField.text) && Validate.ip_address(wifidnsTextField.text)) {
                            settingsbackend.set_network(lanipTextField.text, lansmTextField.text, wifiipTextField.text, wifismTextField.text, wifigwTextField.text, wifidnsTextField.text)
                            return true
                        } else {
                            edialog.bodyText = "IP-Address Eingaben überprüfen!"
                            edialog.open()
                            return false
                        }
                    }

                }

                Rectangle {
                    x: 335
                    y: 15
                    width: 150
                    height: 150
                    color: "dodgerblue"
                    radius: 180

                    Text {
                        anchors.centerIn: parent
                        color: Style.textColor
                        text: stackLayout.currentIndex +1
                        font.pixelSize: 48
                    }

                }

                Rectangle {
                    x: 185
                    y: 337
                    width: 250
                    height: 250
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
                            }

                        }

                    }

                }

                Rectangle {
                    x: 757
                    y: 187
                    width: 250
                    height: 550
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
                                checked: true
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
                                enabled: !wifidhcpCheckbox.checked
                            }

                        }

                    }

                }

                Rectangle {
                    x: 462
                    y: 187
                    width: 270
                    height: 550
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

                        CustomButton {
                            id: scanwifiButton
                            width: parent.width
                            height: 70
                            text: "Scan"
                            onClicked: {
                                wifiscanModel.clear()
                                settingsbackend.wifi_scan()
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 170
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
                                            anchors.left: parent.left
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
                            }

                        }

                    }

                }

            }

            Item {
                id: apiTab

                Rectangle {
                    id: autosetupView
                    anchors.fill: parent
                    color: "#80000000"
                    visible: false
                    parent: Overlay.overlay

                    Rectangle {
                        id: autosetupViewIR
                        width: 700
                        height: 350
                        anchors.centerIn: parent
                        color: Style.innerrectBg
                        border.color: Style.outerrectBg
                        rotation: 180

                        Column {
                            anchors.fill: parent
                            anchors.topMargin: parent.border.width

                            Rectangle {
                                width: parent.width - autosetupView.border.width * 2
                                height: 50
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.outerrectBg

                                Text {
                                    id: autosetupstateText
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    verticalAlignment: Text.AlignVCenter
                                    color: Style.textColor
                                    text: "AutoSetup läuft..."
                                    font.pointSize: 14
                                }

                                CustomImageButton {
                                    id: autosetupviewButton
                                    width: 50
                                    height: 50
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    bgColor: "#1c1d20"
                                    bgColorPressed: "#00a1f1"
                                    bgRadius: 0
                                    img: "images/close_icon.svg"
                                    visible: false
                                    onClicked: autosetupView.visible = false
                                }

                            }

                            Repeater {
                                model: ListModel {
                                    id: autosetupModel
                                }

                                Rectangle {
                                    width: parent.width - autosetupViewIR.border.width * 2
                                    height: 100
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: Style.outerrectBg

                                    Text {
                                        color: Style.textColor
                                        text: model.Device_Name
                                        font.pointSize: 12

                                    }

                                    Text {
                                        x: 1
                                        y: 28
                                        color: Style.textColor
                                        text: "IP-Adresse"
                                        font.pointSize: 10
                                    }

                                    Text {
                                        x: 160
                                        y: 25
                                        color: Style.textColor
                                        text: model.IP
                                        font.pointSize: 12
                                    }

                                    Text {
                                        x: 1
                                        y: 52
                                        color: Style.textColor
                                        text: "Firmware-Version"
                                        font.pointSize: 10
                                    }

                                    Text {
                                        x: 160
                                        y: 49
                                        color: Style.textColor
                                        text: model.FW_VERSION
                                        font.pointSize: 12
                                    }

                                    Text {
                                        x: 1
                                        y: 76
                                        color: Style.textColor
                                        text: "Laufzeit"
                                        font.pointSize: 10
                                    }

                                    Text {
                                        x: 160
                                        y: 73
                                        color: Style.textColor
                                        text: model.Uptime
                                        font.pointSize: 12
                                    }

                                }

                            }

                        }

                    }

                }

                Rectangle {
                    x: 568
                    y: 15
                    width: 150
                    height: 150
                    color: "dodgerblue"
                    radius: 180

                    Text {
                        anchors.centerIn: parent
                        color: Style.textColor
                        text: stackLayout.currentIndex +1
                        font.pixelSize: 48
                    }

                }

                Rectangle {
                    x: 490
                    y: 230
                    width: 300
                    height: 530
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "API-Verbindungen"
                        font.pixelSize: 12
                    }

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
                            }

                        }

                        CustomButton {
                            id: autosetupButton
                            width: parent.width
                            height: 70
                            text: "AutoSetup ausführen"
                            onClicked: {
                                autosetupModel.clear()
                                autosetupView.visible = true
                                settingsbackend.autoconfig_api()
                            }
                        }

                    }

                }

            }

            Item {
                id: servicesTab

                Rectangle {
                    x: 1008
                    y: 15
                    width: 150
                    height: 150
                    color: "dodgerblue"
                    radius: 180

                    Text {
                        anchors.centerIn: parent
                        color: Style.textColor
                        text: stackLayout.currentIndex +1
                        font.pixelSize: 48
                    }

                }

                Rectangle {
                    x: 515
                    y: 241
                    width: 250
                    height: 500
                    color: Style.outerrectBg
                    radius: Style.radius

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Style.textColor
                        text: "Dienste"
                        font.pixelSize: 12
                    }

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
                            }

                        }

                    }

                }

            }

        }

        CustomButton {
            width: 200
            height: 50
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            text: stackLayout.currentIndex == stackLayout.count -1 ? "Abschließen" : "Weiter"
            onClicked: {
                switch (stackLayout.currentIndex) {
                    case 0:
                        if (submit_netset.validset()) {
                            if ((wifissidTextField.length > 0) && ((pwRect.visible && wifipwTextField.length >= 8) || (!pwRect.visible))) {
                                settingsbackend.wifi_connect(wifissidTextField.text, wifipwTextField.text)
                                stackLayout.currentIndex++
                            } else {
                                edialog.bodyText = "Netzwerk-Eingaben überprüfen!"
                                edialog.open()
                            }
                        } else {
                            edialog.bodyText = "Netzwerk-Eingaben überprüfen!"
                            edialog.open()
                        }
                        break
                    case 1:
                        if (Validate.ip_address(shellyhostTextField.text) && Validate.ip_address(sdchostTextField.text) && Validate.ip_address(swschostTextField.text) && Validate.rtsp_addr(cameraurlTextField.text)) {
                            settingsbackend.set_api(shellyhostTextField.text, sdchostTextField.text, swschostTextField.text, cameraurlTextField.text)
                            stackLayout.currentIndex++
                        } else {
                            edialog.bodyText = "API Eingaben überprüfen!"
                            edialog.open()
                        }
                        break
                    case 2:
                        if ( ((ftpactiveCheckbox.checked && ftpuserTextField.text && ftppwTextField.text) || (!ftpactiveCheckbox.checked)) && ((webappactiveCheckbox.checked && webapppwTextField.text) || (!webappactiveCheckbox.checked)) ) {
                            settingsbackend.set_system_services(ftpactiveCheckbox.checked, ftpuserTextField.text, ftppwTextField.text, webappactiveCheckbox.checked, webapppwTextField.text, ntpactiveCheckbox.checked)
                            settingsbackend.setup_done()
                        } else {
                            edialog.bodyText = "Dienste aut. Eingaben überprüfen!"
                            edialog.open()
                        }
                        break
                }

            }
        }

    }

    Connections {
        target: settingsbackend

        function onDataapi(SHELLY_HOST, SDC_HOST, SWSC_HOST, CAMERA_URL) {
            shellyhostTextField.text = SHELLY_HOST
            sdchostTextField.text = SDC_HOST
            swschostTextField.text = SWSC_HOST
            cameraurlTextField.text = CAMERA_URL
            autosetupstateText.text = "AutoSetup beendet."
            autosetupviewButton.visible = true
        }

        function onWifiscanresult(ssid, rsnflags) {
            wifiscanModel.append({ssid: ssid, security: rsnflags})
        }

        function onAutoconfig_api_status(data) {
            autosetupModel.append(data)
        }
    }

}
