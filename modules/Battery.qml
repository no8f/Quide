import QtQuick // for Text
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts
import Quickshell.Services.UPower

Repeater {
    model: UPower.devices
    Layout.fillHeight: true

    RowLayout {
        id: battery_applet
        property int perc: Math.round(modelData.percentage * 100)
        property bool perc_visibel: false

        required property var modelData
        visible: perc != 0

        IconLabel {
            property int icon_state: Math.round(10 / (100 / battery_applet.perc))

            icon.source: "../icons/battery/Battery" + icon_state + ".svg"
            icon.color: palette.text

            TapHandler {
                onTapped: battery_applet.perc_visibel = !battery_applet.perc_visibel
            }

            IconLabel {
                visible: battery_applet.modelData.state === UPowerDeviceState.Charging
                anchors.left: parent.left
                anchors.leftMargin: -6
                anchors.top: parent.top

                icon.source: "../icons/lightning.svg"
                icon.color: Material.color(Material.Yellow, Material.Shade700)
                icon.width: 16

                z: 2
            }
        }

        Label {
            visible: battery_applet.perc_visibel
            text: battery_applet.perc + "%"
        }
    }
}
