import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "../components"

PanelWindow {
    id: powermenu
    anchors {
        right: true
        left: true
        top: true
        bottom: true
    }
    visible: false

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quidepowermenu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: {
        var color = Material.primary;
        color.a = 0.4;
        return color;
    }

    ListModel {
        id: powermenu_entries
        ListElement {
            display: "Lock"
            icon: "../icons/LockClosed.svg"
            command: "hyprlock"
        }
        ListElement {
            display: "Logout"
            icon: "../icons/PersonArrowRight.svg"
            command: "hyprctl dispatch exit"
        }
        ListElement {
            display: "Suspend"
            icon: "../icons/PauseCircle.svg"
            command: "systemctl suspend"
        }
        ListElement {
            display: "Reboot"
            icon: "../icons/ArrowCounterclockwise.svg"
            command: "systemctl reboot"
        }
    }

    // ListElement {
    //     id: poweroff
    //     display: "Shutdown"
    //         icon: "../icons/Power.svg"
    //         command: "systemctl poweroff"
    // }

    contentItem {
        focus: true
        Keys.onPressed: event => {
            if (event.key == Qt.Key_Escape)
                powermenu.visible = false;
        }
    }

    RoundButton {
        anchors.top: parent.top
        anchors.right: parent.right
        icon.source: "../icons/DismissCircle.svg"
        onClicked: powermenu.visible = false
        flat: true
    }

    Label {
        anchors.bottom: layout.top
        anchors.horizontalCenter: layout.horizontalCenter

        text: "Goodbye"
        font.pixelSize: 42
        font.bold: true
    }

    Component {
        id: menu_entry
        PowerMenuEntry {
            width: grid_view.cellWidth
            height: grid_view.cellHeight
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        width: powermenu.width * 0.5
        height: powermenu.height * 0.5
        spacing: 0

        PowerMenuEntry {
            modelData: {
                return {
                    display: "Shutdown",
                    icon: "../icons/Power.svg",
                    command: "systemctl poweroff"
                };
            }

            Layout.fillHeight: true
            Layout.preferredWidth: layout.width / 3
        }

        GridView {
            id: grid_view
            //anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true

            model: powermenu_entries

            cellWidth: width / 2
            cellHeight: height / 2

            delegate: menu_entry
        }
    }
}
