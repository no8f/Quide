//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls.impl
import Quickshell.Services.SystemTray
import Quickshell.Wayland

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
                onRead: message => {
                    console.log(`read message from socket: ${message}`);
                    if (message == "lol")
                        powermenu.visible = true;
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
                x: bar.width - (width + 10)
                y: -(height + 10)
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

        visible: false
    }

    PanelWindow {
        id: systray_menu_popup

        property var menu_model: null
        property var menu_model_items: menu_opener.children

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors {
            right: true
            bottom: true
        }

        margins {
            bottom: 10
            right: 10
        }

        color: "transparent"

        width: 230
        height: 500
        visible: menu_model != null

        Pane {
            id: menu_content_frame
            anchors.fill: parent

            background: Pane {
                Material.roundedScale: Material.SmallScale
                opacity: 0.2
            }

            ListView {
                id: menu_list_view
                anchors.fill: parent

                model: systray_menu_popup.menu_model_items
                interactive: false

                onContentHeightChanged: {
                    systray_menu_popup.height = contentHeight + (menu_content_frame.padding * 2) + 1;

                    systray_menu_popup.visible = false;
                    if (systray_menu_popup.menu_model != null)
                        systray_menu_popup.visible = true;
                }

                Component {
                    id: menu_checkbox
                    CheckBox {
                        text: modelData.text
                        checkState: modelData.checkState
                        enabled: modelData.enabled
                    }
                }

                Component {
                    id: menu_radiobutton
                    RadioButton {
                        text: modelData.text
                        checked: modelData.checkState == Qt.Checked
                        enabled: modelData.enabled
                    }
                }

                Component {
                    id: menu_button
                    RowLayout {
                        enabled: modelData.enabled
                        Button {
                            visible: modelData.hasChildren
                            implicitWidth: implicitHeight / 1.5
                            Material.roundedScale: Material.ExtraSmallScale
                            icon.source: "icons/ChevronLeft.svg"
                            flat: true
                            onClicked: {
                                modelData.display(systray_menu_popup, 0, 0);
                            }
                        }
                        Button {
                            Layout.fillWidth: true
                            Material.roundedScale: Material.ExtraSmallScale
                            flat: true
                            text: modelData.text
                            icon.source: modelData.icon
                            onClicked: {
                                modelData.triggered();
                            }
                        }
                    }
                }

                Component {
                    id: menu_seperator
                    Rectangle {
                        height: 2
                        radius: height
                        width: parent.width
                        opacity: 0.1
                        color: Material.background
                    }
                }

                delegate: Loader {
                    required property var modelData

                    width: menu_list_view.width

                    sourceComponent: {
                        switch (modelData.buttonType) {
                        case QsMenuButtonType.CheckBox:
                            return menu_checkbox;
                            break;
                        case QsMenuButtonType.RadioButton:
                            return menu_radiobutton;
                            break;
                        case QsMenuButtonType.None:
                            {
                                if (modelData.isSeparator)
                                    return menu_seperator;
                                else
                                    return menu_button;
                                break;
                            }
                        }
                    }
                }
            }
        }

        QsMenuOpener {
            id: menu_opener
            menu: systray_menu_popup.menu_model
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
            anchors.fill: parent
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
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onTapped: (eventPoint, button) => {
                                    switch (button) {
                                    case Qt.LeftButton:
                                        {
                                            if (!modelData.onlyMenu) {
                                                systray_item_root.modelData.activate();
                                                break;
                                            }
                                            // fallthrough
                                        }
                                    case Qt.RightButton:
                                        {
                                            if (systray_menu_popup.menu_model == null || systray_menu_popup.menu_model != systray_item_root.modelData.menu)
                                                systray_menu_popup.menu_model = systray_item_root.modelData.menu;
                                            else
                                                systray_menu_popup.menu_model = null;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Modules.Clock {
                    TapHandler {
                        onTapped: {
                            calendar_widget.visible = !calendar_widget.visible;
                        }
                    }
                }
            }
        }
    }
}
