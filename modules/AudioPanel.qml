import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../components" as Components

Pane {
    id: root_pane
    Material.elevation: 3
    //Material.background: Material.primary
    padding: 0

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    Behavior on height {
        NumberAnimation{
            easing.type: Easing.OutCubic
            duration: 300
        }
    }

    property int collapsedHeight: 40
    height: state === "retracted" ? collapsedHeight : contentItem.implicitHeight

    states: [
        State {
            name: "retracted"
        }
    ]

    Component.onCompleted: {
        state = "retracted"
    }

    contentItem: ColumnLayout {
        clip: true
        spacing: 0

        Pane {
            id: nav_pane
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            implicitHeight: 40
            padding: 0
            Material.roundedScale: Material.ExtraSmallScale
            Material.background: Material.primary
            ButtonGroup {
                id: nav_btn_group
                buttons: nav_btns.children
            }
            ToolButton {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                icon.source: root_pane.state == "retracted" ? "../icons/ChevronUp.svg" : "../icons/ChevronDown.svg"
                flat: true
                highlighted: true

                onClicked: {
                    if (root_pane.state == "retracted")
                        root_pane.state = "";
                    else
                        root_pane.state = "retracted";
                }
            }

            Row {
                id: nav_btns
                anchors.centerIn: parent
                visible: root_pane.state != "retracted"
                TabButton {
                    height: nav_pane.implicitHeight
                    text: "Out"
                    checked: true
                }
                TabButton {
                    height: nav_pane.implicitHeight
                    text: "In"
                }
            }

            Label {
                text: "Volume"
                anchors.centerIn: parent
                visible: !nav_btns.visible
            }
        }
        SwipeView {
            id: splitview
            clip: true
            interactive: false
            Layout.fillWidth: true
            Layout.margins: 8
            Layout.maximumHeight: 400

            currentIndex: nav_btns.children.indexOf(nav_btn_group.checkedButton)

            Flickable {
                implicitHeight: contentHeight
                contentHeight: lay.implicitHeight
                ColumnLayout {
                    id: lay
                    anchors.fill: parent
                    
                    Repeater {
                        model: Pipewire.nodes
                        Components.AudioNode {
                            Layout.fillWidth: true
                            Layout.margins: 5
                            visible: modelData.audio && modelData.properties["port.group"] != "capture"
                        }
                    }
                }
            }

            Flickable {
                implicitHeight: contentHeight
                contentHeight: lay2.implicitHeight
                ColumnLayout {
                    id: lay2
                    anchors.fill: parent
                    Repeater {
                        model: Pipewire.nodes
                        Components.AudioNode {
                            Layout.fillWidth: true
                            Layout.margins: 5
                            visible: modelData.audio && modelData.properties["port.group"] == "capture"
                            isSource: true
                        }
                    }
                }
            }
        }
    }
}
