import Quickshell.Hyprland
import QtQuick // for Text
import QtQuick.Controls.Material

ListView {
    id: workspace_list
    property int indecatorSize: 18

    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter

    height: workspace_list.indecatorSize
    width: contentItem.width

    orientation: Qt.Horizontal
    spacing: 5
    model: Hyprland.workspaces

    delegate: Rectangle {
        id: delegate_root
        required property var modelData
        property bool active: delegate_root.modelData.active

        width: active ? workspace_list.indecatorSize * 2.5 : workspace_list.indecatorSize
        height: workspace_list.indecatorSize
        color: Material.accent
        opacity: active ? 1.0 : 0.2
        onActiveChanged: {
            opacity = active ? 1.0 : 0.2
        }

        radius: 3

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                Hyprland.dispatch("workspace " + delegate_root.modelData.id);
            }
            onContainsMouseChanged: {
                if (containsMouse && !delegate_root.active) {
                    delegate_root.width = workspace_list.indecatorSize * 1.5;
                    delegate_root.opacity = 0.6
                } else if (!delegate_root.active) {
                    delegate_root.width = workspace_list.indecatorSize;
                    delegate_root.opacity = 0.2
                }
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutQuint
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }
}
