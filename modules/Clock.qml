import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Quickshell

Label {
    id: timeText
    property string format: "hh:mm"
    font.pixelSize: 16
    text: Qt.formatDateTime(clock.date, format)

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
