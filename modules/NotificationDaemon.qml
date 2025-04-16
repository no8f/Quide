import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

PopupWindow {
    id: notification_list_root_window

    height: 1

    color: "transparent"

    ListModel {
        id: notification_test_model
        ListElement {
            text: "lol"
        }
        ListElement {
            text: "lol"
        }
        ListElement {
            text: "lol"
        }
    }

    visible: true

    NotificationServer {
        id: not_server
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true

        onNotification: notification => {
            notification.tracked = true;
        }
    }

    ListView {
        id: notification_list
        anchors.centerIn: parent

        width: notification_list_root_window.width
        height: parent.height

        verticalLayoutDirection: ListView.BottomToTop

        Timer {
            id: reset_size
            interval: 500
            onTriggered: {
                notification_list_root_window.height = 1;
            }
        }

        onContentHeightChanged: {
            if (notification_list_root_window.height < contentHeight && contentHeight < 600)
                notification_list_root_window.height = contentHeight + spacing + 2;
            if (notification_list.contentHeight == 0)
                reset_size.start();
        }

        model: not_server.trackedNotifications
        spacing: 10

        add: Transition {
            NumberAnimation {
                properties: "opacity"
                from: 0.0
                to: 1.0
                duration: 500
            }
        }

        remove: Transition {
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 500
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 300
                easing.type: Easing.InCubic
            }
        }

        delegate: Pane {
            id: delegate_root
            required property var modelData
            property double notifiedTime

            width: notification_list_root_window.width

            padding: 10

            background: Rectangle {
                id: background_pane
                radius: 7
            }

            Timer {
                id: expire_timer_progress_updater
                running: false
                repeat: true
                interval: 33 //roughly 30 fps
                onTriggered: {
                    expire_timer_progressbar.value = (new Date().getTime() - delegate_root.notifiedTime);
                }
            }

            Timer {
                id: expire_timer
                running: false
                onTriggered: {
                    delegate_root.modelData.expire();
                }
            }

            Component.onCompleted: {
                expire_timer.interval = delegate_root.modelData.expireTimeout;
                notifiedTime = new Date().getTime();
                if (expire_timer.interval > 0) {
                    expire_timer.start();
                    expire_timer_progress_updater.start();
                }

                switch (delegate_root.modelData.urgency) {
                case NotificationUrgency.Critical:
                    background_pane.color = Qt.darker(Material.accent, 1.8);
                    break;
                case NotificationUrgency.Normal:
                    background_pane.color = Material.background;
                    break;
                case NotificationUrgency.Low:
                    background_pane.color = Material.background;
                    background_pane.opacity = 0.6;
                }
            }

            contentItem: ColumnLayout {
                id: layout
                spacing: 8
                RowLayout {
                    RowLayout {
                        Layout.fillWidth: true
                        Image {
                            id: icon_image
                            source: delegate_root.modelData.appIcon
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32

                            visible: status == Image.Ready
                        }
                        Label {
                            Layout.fillWidth: true
                            text: delegate_root.modelData.summary
                            font.bold: true

                            wrapMode: Text.WordWrap
                        }
                    }
                    RoundButton {
                        icon.source: "../icons/DismissCircle.svg"
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: 32
                        padding: 8
                        flat: true

                        onClicked: {
                            delegate_root.modelData.dismiss();
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    IconImage {
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64

                        source: delegate_root.modelData.image
                        visible: status == Image.Ready
                    }
                    Label {
                        Layout.fillWidth: true

                        text: delegate_root.modelData.body
                        wrapMode: Text.WordWrap
                        visible: text != ""

                        textFormat: Text.RichText
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: delegate_root.modelData.actions
                        Button {
                            id: action_button
                            required property var modelData

                            Layout.fillWidth: true
                            Material.roundedScale: Material.ExtraSmallScale

                            flat: modelData.identifier != "default"
                            text: modelData.text
                            highlighted: true 

                            Component.onCompleted: {
                                if (delegate_root.modelData.hasActionIcons)
                                    icon.name = modelData.identifier;
                            }

                            onClicked: {
                                modelData.invoke();
                            }
                        }
                    }
                }

                ProgressBar {
                    id: expire_timer_progressbar
                    Layout.fillWidth: true
                    visible: value > 0
                    from: 0
                    to: expire_timer.interval
                }
            }
        }
    }
}
