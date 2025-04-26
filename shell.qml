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
import QtQuick.Effects

import "modules" as Modules
import "components" as Components

ShellRoot {

    // SocketServer {
    //     active: true
    //     path: "/tmp/quickshell.sock"
    //     handler: Socket {
    //         onConnectedChanged: {
    //             console.log(connected ? "new connection!" : "connection dropped!");
    //         }
    //         parser: SplitParser {
    //             onRead: message => {
    //                 console.log(`read message from socket: ${message}`);
    //                 if (message == "lol")
    //                     powermenu.visible = true;
    //                 else if (message == "run")
    //                     app_launcher_panel.visible = !app_launcher_panel.visible;
    //             }
    //         }
    //     }
    // }

    IpcHandler {
        target: "shell_root"

        function toggleAppLauncher() {
            app_launcher_panel.visible = !app_launcher_panel.visible;
        }
        function showShutdownMenu() {
            powermenu.visible = true;
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
            anchors.margins: 5
            Material.elevation: 4

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

        height: 60
        color: "transparent"

        exclusiveZone: height - 25

        Components.RoundCorner {
            anchors.left: parent.left
            anchors.top: parent.top

            position: Components.RoundCorner.Position.BottomLeft
        }

        Pane {
            id: root_rect
            anchors.fill: parent
            anchors.topMargin: 25
            background: Rectangle {
                //opacity: 0.1
                color: Material.background
            }

            Modules.Workspace {}

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Modules.Battery {}

                RowLayout {
                    Layout.fillHeight: true
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

                Modules.WallpaperChanger {}

                Button {
                    flat: true
                    Material.roundedScale: Material.ExtraSmallScale
                    implicitHeight: 36
                    highlighted: true
                    implicitWidth: implicitHeight
                    icon.source: "icons/DarkTheme.svg"

                    Process {
                        id: switch_theme_process
                        command: ["sh", "-c", "$HOME/.config/scripts/switchtheme.sh"]
                    }

                    onClicked: {
                        switch_theme_process.startDetached();
                    }
                }

                Button {
                    icon.source: control_center.width === 25 ? "icons/PanelRightExpand.svg" : "icons/PanelRightContract.svg"
                    flat: true
                    Material.roundedScale: Material.ExtraSmallScale
                    implicitHeight: 36
                    highlighted: true
                    implicitWidth: implicitHeight
                    onClicked: {
                        if (control_center.width === 25)
                            control_center.width = 350;
                        else
                            control_center.width = 25;

                        control_center.visible = false;
                        control_center.visible = true;
                    }
                }
            }
        }
    }

    PanelWindow {
        id: control_center
        anchors {
            top: true
            right: true
            bottom: true
        }

        width: 25

        color: "transparent"
        exclusiveZone: width - 25

        Components.RoundCorner {
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            position: Components.RoundCorner.Position.BottomRight
        }

        Components.RoundCorner {
            anchors.top: parent.top
            anchors.left: parent.left

            position: Components.RoundCorner.Position.TopRight
            visible: control_center.width != 25
        }

        Pane {
            anchors.fill: parent
            anchors.leftMargin: 25
            visible: control_center.width == 350
            background: Rectangle {
                //opacity: 0.1
                color: Material.background
            }

            ToolButton {
                anchors.right: parent.right
                anchors.top: parent.top
                icon.source: "icons/ArrowCounterclockwise.svg"

                onClicked: {
                    Quickshell.reload(true);
                }
            }

            Modules.AudioPanel {
                id: ap
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }

            // ColorQuantizer {
            //     id: colorQuantizer
            //     property string homeDir: Quickshell.env("HOME")
            //     source: Qt.resolvedUrl(colorQuantizer.homeDir+"/Pictures/Wallpaper/wall.png")
            //     depth: 4 // Will produce 8 colors (2³)
            //     rescaleSize: 64 // Rescale to 64x64 for faster processing

            //     onColorsChanged: {
            //         Components.Colors.colors = colorQuantizer.colors
            //     }
            // }

            // ColumnLayout {
            //     anchors.bottom: ap.top
            //     Repeater {
            //         model: Components.Colors.colors
            //         Rectangle {
            //             width: 10
            //             height: 10
            //             color: modelData
            //         }
            //     }
            // }
        }
    }

    PanelWindow {
        id: app_launcher_panel
        color: "transparent"
        visible: false

        onVisibleChanged: {
            if ( visible ) {
            app_launcher.selectSearchText()
            }
        }

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        width: app_launcher.width
        height: app_launcher.height

        mask: Region {
            item: app_launcher
        }

        contentItem {
            focus: true
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Down)
                    app_launcher.nextItem();
                if (event.key == Qt.Key_Up)
                    app_launcher.prevItem();
                if (event.key == Qt.Key_Return)
                    app_launcher.launchCurrent();
                if (event.key == Qt.Key_Escape)
                    app_launcher_panel.visible = false
            }
        }

        Modules.AppLauncher {
            id: app_launcher
            anchors.centerIn: parent
            anchors.margins: 15
            width: 500

            onLaunched: {
                app_launcher_panel.visible = false
            }
        }
    }
}
