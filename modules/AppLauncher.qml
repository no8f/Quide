import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import Quickshell.Io

import "../components" as Components

Pane {
    id: root
    Material.elevation: 18

    Process {
        id: app_launcher
        property string app

        command: ["sh", "-c", app]
    }

    signal launched

    function nextItem() {
        if (app_list_view.currentIndex < app_list_view.count - 1)
            app_list_view.currentIndex++;
    }

    function prevItem() {
        if (app_list_view.currentIndex > 0)
            app_list_view.currentIndex--;
    }

    function launchCurrent() {
        if (app_list_view.currentItem.modelData.runInTerminal) {
            app_launcher.app = ("kitty zsh -ic '" + app_list_view.currentItem.modelData.execString + "; clear; exec zsh;'");
            app_launcher.startDetached();
        } else
            app_list_view.currentItem.modelData.execute();

        launched();
    }

    function selectSearchText() {
        searchField.forceActiveFocus();
        searchField.selectAll();
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    contentItem: ColumnLayout {
        TextField {
            id: searchField

            Layout.fillWidth: true
            Layout.preferredHeight: 40

            onTextChanged: {
                if (app_list_view.count != 0)
                    return;

                try {
                    let expr = text;
                    let result = (new Function("return " + expr))();
                    calc_display.text = result;
                } catch (e) {
                    calc_display.text = "Nothing here...";
                }
            }
        }

        Label {
            id: calc_display
            visible: app_list_view.count == 0
            Layout.fillWidth: true
            Layout.topMargin: 12
            horizontalAlignment: Qt.AlignHCenter

            font.pixelSize: 16
            font.bold: true
        }

        ListView {
            id: app_list_view
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumHeight: 500
            clip: true

            Layout.preferredHeight: childrenRect.height

            model: Components.FilterDelegateModel {
                id: filterDelegateModel
                model: DesktopEntries.applications
                filter: search ? model => (model.modelData.name.toLowerCase().indexOf(search) !== -1 || model.modelData.comment.toLowerCase().indexOf(search) !== -1) : null
                extraCondition: model => !model.modelData.noDisplay
                property string search: searchField.text.toLowerCase()
                onSearchChanged: Qt.callLater(update)

                delegate: Button {
                    id: delegate_root
                    required property var modelData
                    required property var index
                    width: app_list_view.width
                    flat: true
                    highlighted: ListView.isCurrentItem
                    Material.roundedScale: Material.ExtraSmallScale

                    onClicked: {
                        app_list_view.currentIndex = index;
                        root.launchCurrent();
                    }

                    contentItem: RowLayout {
                        spacing: 16
                        IconLabel {
                            id: app_icon
                            icon.name: delegate_root.modelData.icon
                            icon.width: 42
                            icon.height: 42
                        }
                        ColumnLayout {
                            Label {
                                id: app_name
                                Layout.fillWidth: true
                                text: delegate_root.modelData.name
                                horizontalAlignment: Qt.AlignHCenter
                            }
                            Label {
                                Layout.fillWidth: true
                                horizontalAlignment: Qt.AlignHCenter
                                text: delegate_root.modelData.comment
                                elide: Text.ElideRight
                                enabled: false
                            }
                        }
                        Item {
                            Layout.preferredWidth: app_icon.width
                        }
                    }
                }
            }
        }
    }
}
