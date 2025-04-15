import QtQuick // for Text
import QtQuick.Controls
import QtQuick.Controls.Material

Label {
    id: timeText
    font.pixelSize: 16
    text: Qt.formatTime(new Date(), "hh:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = Qt.formatTime(new Date(), "hh:mm");
        }
    }
}
