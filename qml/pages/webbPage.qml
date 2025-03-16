import QtQuick 2.15
import QtQuick.Controls 1.4
import QtWebView 1.15
import "../Style"
import "../components"
import "../js/validate.js" as Validate

Item {

    Rectangle {
        color: Style.pageBg
        anchors.fill: parent

        CustomDialog {
            id: edialog
            colorContent: "red"
            headerPic: "../images/warning_icon.svg"
            headerTitle: "Fehler"
            bodyText: "Eingaben überprüfen!"
            acceptedButtonText: "OK"
            rejectedButtonText: ""
        }

        TabView {
            anchors.fill: parent

            Repeater {
                model: ListModel {
                    id: tabsModel
                    Component.onCompleted: {
                        for (const [name, url] of Object.entries(webbbackend.get_webb_tabs())) {
                            this.append({name: name, url: url})
                        }
                    }
                }

                Tab {
                    title: model.name

                    WebView {
                        anchors.fill: parent
                        url: model.url
                    }

                }

            }

            Tab {
                title: "Bearbeiten"

                Rectangle {
                    anchors.fill: parent
                    color: "#2c313e"

                    Column {
                        spacing: Style.spacing
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 20

                        Repeater {
                            model: tabsModel

                            Rectangle {
                                radius: Style.radius
                                color: Style.innerrectBg
                                height: 50
                                width: 600

                                Rectangle {
                                    id: updsuccessOverlay
                                    anchors.fill: parent
                                    color: parent.color
                                    radius: parent.radius
                                    visible: false
                                    z: 1

                                    Text {
                                        anchors.centerIn: parent
                                        color: Style.textColor
                                        text: "Seite neu laden"
                                    }

                                }

                                Row {
                                    anchors.fill: parent
                                    spacing: Style.spacing

                                    Text {
                                        color: Style.textColor
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 100
                                        text: model.name
                                    }

                                    CustomTextField {
                                        id: newurlField
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 270
                                        validator: RegularExpressionValidator {
                                            regularExpression: /^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/
                                        }
                                        text: model.url
                                        placeholderText: "URL"
                                        inputMethodHints: Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
                                    }

                                    CustomButton {
                                        height: parent.height
                                        width: 100
                                        text: "Speichern"
                                        onClicked: {
                                            if (Validate.http_addr(newurlField.text) && webbbackend.update_webb_tab(model.name, newurlField.text)) {
                                                updsuccessOverlay.visible = true
                                            } else {
                                                edialog.open()
                                            }
                                        }
                                    }

                                    CustomButton {
                                        height: parent.height
                                        width: 100
                                        colorDefault: "#d61818"
                                        colorPressed: "#911616"
                                        text: "Löschen"
                                        onClicked: if (webbbackend.del_webb_tab(model.name)) updsuccessOverlay.visible = true
                                    }

                                }

                            }

                        }

                        Rectangle {
                            radius: Style.radius
                            color: Style.innerrectBg
                            height: 50
                            width: 490
                            visible: tabsModel.count <= 10

                            Rectangle {
                                id: addsuccessOverlay
                                anchors.fill: parent
                                color: parent.color
                                radius: parent.radius
                                visible: false
                                z: 1

                                Text {
                                    anchors.centerIn: parent
                                    color: Style.textColor
                                    text: "Seite neu laden"
                                }

                            }

                            Row {
                                anchors.fill: parent
                                spacing: Style.spacing

                                CustomTextField {
                                    id: nameField
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 100
                                    maximumLength: 10
                                    placeholderText: "Name"
                                }

                                CustomTextField {
                                    id: urlField
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 270
                                    validator: RegularExpressionValidator {
                                        regularExpression: /^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/
                                    }
                                    placeholderText: "URL"
                                    inputMethodHints: Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
                                }

                                CustomButton {
                                    height: parent.height
                                    width: 100
                                    text: "Hinzufügen"
                                    onClicked: {
                                        if (nameField.text && Validate.http_addr(urlField.text) && webbbackend.add_webb_tab(nameField.text, urlField.text)) {
                                            addsuccessOverlay.visible = true
                                        } else {
                                            edialog.open()
                                        }
                                    }
                                }

                            }

                        }

                    }
                }
            }

        }

    }

}
