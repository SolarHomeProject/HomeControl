import QtQuick 2.15
import QtCharts 2.15

ChartView {
    id: chartview

    property int maxValue
    property int minValue
    property int timeaxisfontsize: 6
    property color valuebarColor: "#000000"
    property variant time: []
    property variant value: []

    margins { top: 0; bottom: 0; left: 0; right: 0 }
    legend.visible: false
    antialiasing: true

    BarSeries {
        axisX: BarCategoryAxis {
            categories: time
            labelsFont: Qt.font({pointSize: timeaxisfontsize})
        }
        axisY: ValueAxis {
            max: maxValue
            min: minValue
        }

        BarSet {
            values: value
            color: valuebarColor
        }

    }

    PinchArea {
        anchors.fill: parent
        property real currentPinchScaleX: 1
        property real currentPinchScaleY: 1
        property real pinchStartX : 0
        property real pinchStartY : 0

        onPinchStarted: {
            // Pinching has started. Record the initial center of the pinch
            // so relative motions can be reversed in the pinchUpdated signal
            // handler
            pinchStartX = pinch.center.x
            pinchStartY = pinch.center.y
        }

        onPinchUpdated: {
            chartview.zoomReset();

            // Reverse pinch center motion direction
            var center_x = pinchStartX + (pinchStartX - pinch.center.x)
            var center_y = pinchStartY + (pinchStartY - pinch.center.y)

            // Compound pinch.scale with prior pinch scale level and apply
            // scale in the absolute direction of the pinch gesture
            var scaleX = currentPinchScaleX * (1 + (pinch.scale - 1) * Math.abs(Math.cos(pinch.angle * Math.PI / 180)))
            var scaleY = currentPinchScaleY * (1 + (pinch.scale - 1) * Math.abs(Math.sin(pinch.angle * Math.PI / 180)))

            // Apply scale to zoom levels according to pinch angle
            var width_zoom = height / scaleX
            var height_zoom = width / scaleY

            var r = Qt.rect(center_x - width_zoom / 2, center_y - height_zoom / 2, width_zoom, height_zoom)
            chartview.zoomIn(r)
        }

        onPinchFinished: {
            // Pinch finished. Record compounded pinch scale.
            currentPinchScaleX = currentPinchScaleX * (1 + (pinch.scale - 1) * Math.abs(Math.cos(pinch.angle * Math.PI / 180)))
            currentPinchScaleY = currentPinchScaleY * (1 + (pinch.scale - 1) * Math.abs(Math.sin(pinch.angle * Math.PI / 180)))
        }

        MouseArea {
            anchors.fill: parent
            drag.target: dragTarget
            drag.axis: Drag.XAndYAxis

            onClicked: chartview.zoomIn()

            onDoubleClicked: {
                chartview.zoomReset()
                parent.currentPinchScaleX = 1
                parent.currentPinchScaleY = 1
            }
        }

        Item {
            // A virtual item to receive drag signals from the MouseArea.
            // When x or y properties are changed by the MouseArea's
            // drag signals, the ChartView is scrolled accordingly.
            id: dragTarget

            property real oldX : x
            property real oldY : y

            onXChanged: {
                chartview.scrollLeft(x - oldX)
                oldX = x
            }
            onYChanged: {
                chartview.scrollUp(y - oldY)
                oldY = y
            }
        }

    }

}
