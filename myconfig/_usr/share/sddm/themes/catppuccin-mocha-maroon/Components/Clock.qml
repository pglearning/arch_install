// import QtQuick 2.15
// import SddmComponents 2.0
//
// Clock {
//     id: time
//     color: "#CDD6F4"
//     timeFont.family: config.Font
//     dateFont.family: config.Font
//
//     anchors {
//         margins: 10
//         top: parent.top
//         right: parent.right
//     }
// }

import QtQuick 2.15
import SddmComponents 2.0

Item {
    id: clockItem

    property color color: "#CDD6F4"
    property font timeFont: Qt.font({family: config.Font})
    property font dateFont: Qt.font({family: config.Font})

    anchors {
        margins: 20
        top: parent.top
        right: parent.right
    }

    Text {
        id: timeText
        anchors.fill: parent
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        color: clockItem.color
        font.family: clockItem.timeFont.family
        font.pixelSize: 32
        text: Qt.formatDateTime(new Date(), config.DateTimeFormat)
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = Qt.formatDateTime(new Date(), config.DateTimeFormat)
        }
    }
}
