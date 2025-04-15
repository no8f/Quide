//@ pragma UseQApplication

import Quickshell // for ShellRoot and PanelWindow
import Quickshell.Io
import QtQuick // for Text
import QtQuick.Controls // for Text
import QtQuick.Controls.Material // for Text
import QtQuick.Layouts
import QtQuick.Controls.impl
import Quickshell.Services.SystemTray

import "modules" as Modules

ShellRoot {

    SocketServer {
        active: true
        path: "/tmp/quickshell.sock"
        handler: Socket {
            onConnectedChanged: {
                console.log(connected ? "new connection!" : "connection dropped!");
            }
            parser: SplitParser {
                onRead: (message) => {
                    console.log(`read message from socket: ${message}`);
                    if (message == "lol")
                        powermenu.visible = true
                }
            }
        }
    }

    Modules.Powermenu {
        id: powermenu
    }

    Modules.NotificationDaemon {
        anchor {
            window: bar
            rect {
                x: bar.width - ( width + 10 )
                y:  - ( height + 10 )
            }
        }

        width: 300
    }

    Modules.Calendar {
        id: calendar_widget

        anchors {
            right: true
            bottom: true
        }

        margins {
            right: 10
            bottom: 10
        }

        visible: true
    }

    PanelWindow {
        id: systray_menu_popup

        property var menu_model
        property var menu_model_items

        anchors {
            right: true
            bottom: true
        }

        margins {
            bottom: 10
            right: 10
        }

        color: "transparent"

        //height: 10
        width: 200
        height: 300
        // width: 200
        // height: 300
        visible: false

        Pane {
            anchors.fill: parent

            background: Pane {
                Material.roundedScale: Material.MediumScale
                opacity: 0.5
            }

            // Label {
            //     anchors.centerIn: parent
            //     text: "test"
            // }

            ListView {
                anchors.fill: parent

                width: contentItem.width
                height: contentItem.height

                model: systray_menu_popup.menu_model_items

                delegate: Rectangle {
                    width: 50
                    height: 50
                    color: "red"
                }
            }
        }

        QsMenuOpener {
            menu: systray_menu_popup.menu_model
            onMenuChanged: {
                systray_menu_popup.menu_model_items = children;
            }
        }
    }

    PanelWindow {
        id: bar
        anchors {
            //top: true
            left: true
            right: true
            bottom: true
        }

        height: 35
        color: "transparent"

        Pane {
            id: root_rect
            // center the bar in its parent component (the window)
            anchors.fill: parent
            //radius: 14

            //color: "transparent"//palette.window
            background: Rectangle {
                opacity: 0.1
                color: Material.background
            }

            Modules.Workspace {}

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 6

                Modules.WallpaperChanger {}

                Modules.Battery {}

                RowLayout {
                    Repeater {
                        model: SystemTray.items
                        IconImage {
                            id: systray_item_root
                            required property var modelData
                            source: modelData.icon

                            Layout.preferredWidth: modelData.title === "Network" ? 24 : 35 / 2

                            TapHandler {
                                onTapped: {
                                    //systray_item_root.modelData.activate();
                                    //systray_menu_popup.menu_model = systray_item_root.modelData.menu;
                                    systray_item_root.modelData.activate();
                                }
                                onLongPressed: {
                                    systray_item_root.modelData.display(bar, bar.width, -5);
                                }
                            }
                        }
                    }
                }

                Modules.Clock {
                    TapHandler {
                        onTapped: {
                            //systray_menu_popup.visible = !systray_menu_popup.visible;
                            calendar_widget.visible = !calendar_widget.visible
                        }
                    }
                }
            }
        }
    }
}
