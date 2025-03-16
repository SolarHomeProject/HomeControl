import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.VirtualKeyboard 2.15
import "Style"
import "components"

Window {
    id: mainWindow
    width: 1280
    height: 800
    visible: true

    Rectangle {
        id: dispsleepRect
        anchors.fill: parent
        color: "#000000"
        visible: false
        parent: Overlay.overlay

        MouseArea { anchors.fill: parent }

    }

    Rectangle {
        id: dispabouttosleepRect
        anchors.fill: parent
        color: "#80000000"
        visible: false
        parent: Overlay.overlay

        MouseArea {
            anchors.fill: parent
            onClicked: {
                dispabouttosleepRect.visible = false
                abouttosleepTimer.restart()
            }
        }

        Timer {
            id: abouttosleepTimer
            interval: mainbackend.get_display_timeout()
            repeat: true
            running: !dispsleepRect.visible
            onTriggered: mainbackend.get_disp_timeout_block() ? this.restart() : dispabouttosleepRect.visible = true
        }

        Timer {
            id: sleeptimeoutTimer
            interval: 10000
            repeat: true
            running: dispabouttosleepRect.visible
            onTriggered: {
                dispabouttosleepRect.visible = false
                mainbackend.disp_off_timeout()
                abouttosleepTimer.interval = mainbackend.get_display_timeout()
            }
        }

    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            mouse.accepted = false
            abouttosleepTimer.restart()
        }
    }

    InputPanel {
        y: Qt.inputMethod.visible ? this.height - parent.height / 2 : parent.height
        anchors.left: parent.left
        anchors.right: parent.right
        rotation: 180
        z: 999
    }

    Rectangle {
        id: failstoreView
        anchors.fill: parent
        color: "#80000000"
        visible: false
        parent: Overlay.overlay

        MouseArea { anchors.fill: parent }

        Rectangle {
            id: failstoreViewIR
            width: 1000
            height: 650
            anchors.centerIn: parent
            color: Style.innerrectBg
            border.width: 5
            border.color: Style.outerrectBg
            rotation: 180

            Column {
                anchors.fill: parent
                anchors.topMargin: parent.border.width
                spacing: 20

                Rectangle {
                    width: parent.width - failstoreViewIR.border.width * 2
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Style.outerrectBg

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                        color: Style.textColor
                        text: "Fehlerliste"
                        font.pointSize: 14
                    }

                    CustomImageButton {
                        width: 50
                        height: 50
                        anchors.right: parent.right
                        anchors.top: parent.top
                        onClicked: failstoreView.visible = false
                        bgColor: "#1c1d20"
                        bgColorPressed: "#00a1f1"
                        bgRadius: 0
                        img: "images/close_icon.svg"
                    }

                }

                Repeater {
                    model: ListModel {
                        id: fsModel
                    }

                    Rectangle {
                        width: parent.width - failstoreViewIR.border.width * 2
                        height: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#d61818"

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 10
                            verticalAlignment: Text.AlignVCenter
                            color: Style.textColor
                            text: model.type
                            font.pointSize: 12

                        }

                        Text {
                            anchors.centerIn: parent
                            color: Style.textColor
                            text: model.error
                            font.pointSize: 12
                        }

                        CustomButton {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            height: parent.height
                            width: 100
                            text: "Löschen"
                            onClicked: mainbackend.del_fs_entry(model.error)
                        }

                    }

                }

            }

        }

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

        Rectangle {
            id: appContainer
            anchors.fill: parent
            color: "#00000000"

            Rectangle {
                id: topBar
                height: 60
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                color: Style.outerrectBg

                ToggleButton {
                    onClicked: animationMenu.running = true
                }

                Rectangle {
                    id: titleBar
                    height: 35
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 70
                    color: "#00000000"

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                        color: Style.textColor
                        text: "HomeControl"
                        font.pointSize: 17
                    }

                    Row {
                        id: rowStatus
                        width: 285
                        height: 60
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: Style.spacing
                        Component.onCompleted: mainbackend.active()

                        Item {
                            width: 35
                            height: parent.height

                            MouseArea {
                                anchors.fill: parent
                                onClicked: failstoreView.visible = true
                                enabled: iconStatusColorWarning.visible || iconStatusColorError.visible
                            }

                            Image {
                                id: iconStatusWarning
                                source: "images/warning_icon.svg"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: parent.height
                                width: parent.width
                                visible: false
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }

                            ColorOverlay {
                                id: iconStatusColorWarning
                                source: iconStatusWarning
                                anchors.fill: iconStatusWarning
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: parent.height
                                color: "#fff000"
                                visible: false
                            }

                            ColorOverlay {
                                id: iconStatusColorError
                                source: iconStatusWarning
                                anchors.fill: iconStatusWarning
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: parent.height
                                color: "#ff0000"
                                visible: false
                            }

                        }

                        Item {
                            width: 35
                            height: parent.height

                            Image {
                                id: iconStatusHT
                                source: "images/network_icon.svg"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: parent.height
                                width: parent.width
                                visible: true
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }

                            ColorOverlay {
                                id: iconStatusHTColor
                                source: iconStatusHT
                                anchors.fill: iconStatusHT
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: parent.height
                                visible: false
                            }

                            ColorOverlay {
                                id: iconStatusHTColorWarning
                                source: iconStatusHT
                                anchors.fill: iconStatusHT
                                color: "#fff000"
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: parent.height
                                visible: false
                            }

                            ColorOverlay {
                                id: iconStatusHTColorError
                                source: iconStatusHT
                                anchors.fill: iconStatusHT
                                color: "#ff0000"
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: parent.height
                                visible: false
                            }

                        }

                        Item {
                            width: 35
                            height: parent.height

                            Image {
                                id: iconStatusInet
                                source: "images/web_icon.svg"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: parent.height
                                width: parent.width
                                visible: true
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }

                            ColorOverlay {
                                id: iconStatusInetColor
                                source: iconStatusInet
                                anchors.fill: iconStatusInet
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: parent.height
                                visible: false
                            }

                        }

                        Item {
                            width: 35
                            height: parent.height

                            Image {
                                id: iconStatusWIFI
                                source: "images/wifi_icon.svg"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: parent.height
                                width: parent.width
                                visible: true
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }

                            ColorOverlay {
                                id: iconStatusWIFIColor
                                source: iconStatusWIFI
                                anchors.fill: iconStatusWIFI
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: parent.height
                                visible: false
                            }

                            ColorOverlay {
                                id: iconStatusWIFIColorWarning
                                source: iconStatusWIFI
                                anchors.fill: iconStatusWIFI
                                color: "#fff000"
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: parent.height
                                visible: false
                            }

                            ColorOverlay {
                                id: iconStatusWIFIColorError
                                source: iconStatusWIFI
                                anchors.fill: iconStatusWIFI
                                color: "#ff0000"
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: parent.height
                                visible: false
                            }

                        }

                        Item {
                            width: 100
                            height: 60

                            Text {
                                id: labelTime
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: Style.textColor
                                font.pointSize: 17
                            }

                            Timer {
                                id: timerClock
                                repeat: true
                                running: true
                                onTriggered: labelTime.text = Qt.formatTime(new Date(),"hh:mm:ss")
                            }

                        }

                    }

                }


            }

            Rectangle {
                id: content
                color: "#00000000"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: topBar.bottom
                anchors.bottom: parent.bottom

                Rectangle {
                    id: leftMenu
                    width: 70
                    color: Style.outerrectBg
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    clip: true

                    PropertyAnimation {
                        id: animationMenu
                        target: leftMenu
                        property: "width"
                        to: leftMenu.width == 70 ? 250 : 70
                        duration: 500
                        easing.type: Easing.InOutQuint
                    }

                    Column {
                        id: columnMenus
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        clip: true

                        LeftMenuBtn {
                            id: btnHome
                            width: leftMenu.width
                            text: "Home"
                            isActiveMenu: stackView.currentItemPath === this.pagePath
                            property string pagePath: "pages/homePage.qml"
                            onClicked: {
                                stackView.replace(Qt.resolvedUrl(this.pagePath))
                                stackView.currentItemPath = this.pagePath
                            }
                        }

                        LeftMenuBtn {
                            id: btnEnergy
                            width: leftMenu.width
                            text: "Energie"
                            isActiveMenu: stackView.currentItemPath === this.pagePath
                            property string pagePath: "pages/energyPage.qml"
                            btnIconSource: "images/meter_icon.svg"
                            onClicked: {
                                stackView.replace(Qt.resolvedUrl(this.pagePath))
                                stackView.currentItemPath = this.pagePath
                            }
                        }

                        LeftMenuBtn {
                            id: btnSolar
                            width: leftMenu.width
                            text: "Solar"
                            isActiveMenu: stackView.currentItemPath === this.pagePath
                            property string pagePath: "pages/solarPage.qml"
                            btnIconSource: "images/solar_icon.svg"
                            onClicked: {
                                stackView.replace(Qt.resolvedUrl(this.pagePath))
                                stackView.currentItemPath = this.pagePath
                            }
                        }

                        LeftMenuBtn {
                            id: btnWater
                            width: leftMenu.width
                            text: "Boiler"
                            isActiveMenu: stackView.currentItemPath === this.pagePath
                            property string pagePath: "pages/boilerPage.qml"
                            btnIconSource: "images/water_icon.svg"
                            onClicked: {
                                stackView.replace(Qt.resolvedUrl(this.pagePath))
                                stackView.currentItemPath = this.pagePath
                            }
                        }

                        LeftMenuBtn {
                            id: btnIntercom
                            width: leftMenu.width
                            text: "Sprechanlage"
                            isActiveMenu: stackView.currentItemPath === this.pagePath
                            property string pagePath: "pages/intercomPage.qml"
                            btnIconSource: "images/intercom_icon.svg"
                            onClicked: {
                                stackView.replace(Qt.resolvedUrl(this.pagePath))
                                stackView.currentItemPath = this.pagePath
                            }
                        }

                        LeftMenuBtn {
                            id: btnCamera
                            width: leftMenu.width
                            text: "Kamera"
                            isActiveMenu: stackView.currentItemPath === this.pagePath
                            property string pagePath: "pages/cameraPage.qml"
                            btnIconSource: "images/camera_icon.svg"
                            onClicked: {
                                stackView.replace(Qt.resolvedUrl(this.pagePath))
                                stackView.currentItemPath = this.pagePath
                            }
                        }

                        LeftMenuBtn {
                            id: btnWeb
                            width: leftMenu.width
                            text: "Web"
                            isActiveMenu: stackView.currentItemPath === this.pagePath
                            property string pagePath: "pages/webbPage.qml"
                            btnIconSource: "images/web_icon.svg"
                            onClicked: {
                                stackView.replace(Qt.resolvedUrl(this.pagePath))
                                stackView.currentItemPath = this.pagePath
                            }
                        }

                    }

                    LeftMenuBtn {
                        id: btnSettings
                        anchors.bottom: parent.bottom
                        width: leftMenu.width
                        text: "Einstellungen"
                        isActiveMenu: stackView.currentItemPath === this.pagePath
                        property string pagePath: "pages/settingsPage.qml"
                        btnIconSource: "images/settings_icon.svg"
                        onClicked: {
                            stackView.replace(Qt.resolvedUrl(this.pagePath))
                            stackView.currentItemPath = this.pagePath
                        }
                    }

                }

                Rectangle {
                    id: contentPages
                    anchors.left: leftMenu.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: Style.pageBg
                    clip: true

                    StackView {
                        id: stackView
                        anchors.fill: parent
                        initialItem: Qt.resolvedUrl("pages/homePage.qml")
                        property string currentItemPath: "pages/homePage.qml"
                    }

                }

            }

        }

    }

    Connections {
        target: mainbackend

        function onNoerror() {
            iconStatusColorWarning.visible = false
            iconStatusColorError.visible = false
            fsModel.clear()
        }

        function onError() {
            iconStatusColorWarning.visible = false
            iconStatusColorError.visible = true
        }

        function onWarning() {
            iconStatusColorWarning.visible = true
            iconStatusColorError.visible = false
        }

        function onHtok() {
            iconStatusHTColor.visible = true
            iconStatusHTColorWarning.visible = false
            iconStatusHTColorError.visible = false
        }

        function onHterror() {
            iconStatusHTColor.visible = false
            iconStatusHTColorWarning.visible = false
            iconStatusHTColorError.visible = true
        }

        function onHtwarning() {
            iconStatusHTColor.visible = false
            iconStatusHTColorWarning.visible = true
            iconStatusHTColorError.visible = false
        }

        function onInetok() {
            iconStatusInet.visible = false
            iconStatusInetColor.visible = true
        }

        function onIneterror() {
            iconStatusInet.visible = true
            iconStatusInetColor.visible = false
        }

        function onWifiok() {
            iconStatusWIFI.visible = false
            iconStatusWIFIColor.visible = true
            iconStatusWIFIColorWarning.visible = false
            iconStatusWIFIColorError.visible = false
        }

        function onWifidisconnected() {
            iconStatusWIFI.visible = true
            iconStatusWIFIColor.visible = false
            iconStatusWIFIColorWarning.visible = false
            iconStatusWIFIColorError.visible = false
        }

        function onWifierror() {
            iconStatusWIFI.visible = false
            iconStatusWIFIColor.visible = false
            iconStatusWIFIColorWarning.visible = false
            iconStatusWIFIColorError.visible = true
        }

        function onWifiwarning() {
            iconStatusWIFI.visible = false
            iconStatusWIFIColor.visible = false
            iconStatusWIFIColorWarning.visible = true
            iconStatusWIFIColorError.visible = false
        }

        function onDispevt(intercom) {
            var active = !dispsleepRect.visible

            if (active) {
                dispabouttosleepRect.visible = false
                abouttosleepTimer.restart()
            }

            if (active && !intercom) {
                dispsleepRect.visible = true
                stackView.clear()
                stackView.currentItemPath = ""
            } else if (intercom && stackView.currentItemPath != "pages/intercomPage.qml") {
                dispsleepRect.visible = false
                stackView.push(Qt.resolvedUrl("pages/intercomPage.qml"))
                stackView.currentItemPath = "pages/intercomPage.qml"
            } else if (!active) {
                dispsleepRect.visible = false
                stackView.replace(Qt.resolvedUrl("pages/homePage.qml"))
                stackView.currentItemPath = "pages/homePage.qml"
            }
        }

        function onFsdata(data) {
            fsModel.clear()
            for (const [error, type] of Object.entries(data)) {
                fsModel.append({error: error, type: type})
            }
        }
    }

}
