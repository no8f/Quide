import QtQuick // for Text
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts
import Quickshell.Services.UPower
import Quickshell // for ShellRoot and PanelWindow
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Effects

Item {
    id: powermenu_entry

    property bool fill_height
    required property var modelData

    Pane {
        //Layout.alignment: Qt.AlignCenter
        id: powermenu_pane
        anchors.centerIn: parent

        implicitWidth: powermenu_entry.width * 0.75
        implicitHeight: powermenu_entry.height * 0.75

        Behavior on width {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutInQuad
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutInQuad
            }
        }

        background: Rectangle {
            id: background
            color: mouse_area.containsMouse ? Material.accent : Material.background
            opacity: 0.5
            radius: 7

            RectangularShadow {
                anchors.fill: parent
                radius: background.radius
                blur: 8
                offset.y: 3
                spread: 3
                color: Qt.darker(background.color, 1.6)
            }

            Behavior on color {
                ColorAnimation {
                    target: background
                    duration: 150
                }
            }
        }

        MouseArea {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                power_process.startDetached();
                powermenu.visible = false;
            }
            onContainsMouseChanged: {
                if (containsMouse) {
                    powermenu_pane.width = powermenu_entry.width * 0.85;
                    powermenu_pane.height = powermenu_entry.height * 0.85;

                    text.opacity = 1;
                } else {
                    powermenu_pane.height = powermenu_entry.height * 0.75;
                    powermenu_pane.width = powermenu_entry.width * 0.75;

                    text.opacity = 0.0;
                }
            }
        }

        Process {
            id: power_process
            command: ["sh", "-c", powermenu_entry.modelData.command]
        }

        IconLabel {
            anchors.centerIn: parent

            icon.source: "../"+powermenu_entry.modelData.icon
            icon.color: palette.text
            icon.width: 64
        }
        Label {
            id: text
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            text: powermenu_entry.modelData.display
            font.bold: true

            opacity: 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutInQuad
                }
            }
        }
    }
}
