import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    width: 350
    height: 450

    color: "transparent"

    property int currentYear
    property int currentMonth

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Pane {
        anchors.fill: parent
        anchors.margins: 5
        Material.elevation: 3

        ColumnLayout {
            anchors.fill: parent

            Clock {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 36
                font.bold: true
                format: "hh:mm:ss"
            }

            Pane {
                Layout.fillWidth: true

                Material.elevation: 4
                Material.roundedScale: Material.LargeScale
                Material.background: Material.primary

                topPadding: 6
                bottomPadding: topPadding

                contentItem: RowLayout {
                    Label {
                        Layout.fillWidth: true
                        text: grid.title

                        font.bold: true
                        font.pixelSize: 19

                        TapHandler {
                            acceptedButtons: Qt.RightButton
                            onTapped: (mouse, button) => {
                                grid.year = root.currentYear;
                                grid.month = root.currentMonth;
                            }
                        }
                    }

                    Button {
                        icon.source: "../icons/ChevronLeft.svg"
                        flat: true
                        highlighted: true
                        Layout.preferredWidth: implicitHeight
                        Material.roundedScale: Material.SmallScale
                        onClicked: {
                            if (grid.month > 0)
                                grid.month--;
                            else {
                                grid.year--;
                                grid.month = Calendar.December;
                            }
                        }
                    }

                    Button {
                        icon.source: "../icons/ChevronRight.svg"
                        flat: true
                        highlighted: true
                        Layout.preferredWidth: implicitHeight
                        Material.roundedScale: Material.SmallScale
                        onClicked: {
                            if (grid.month < 11)
                                grid.month++;
                            else {
                                grid.year++;
                                grid.month = Calendar.January;
                            }
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true

                columns: 2

                DayOfWeekRow {
                    locale: grid.locale

                    Layout.column: 1
                    Layout.fillWidth: true
                    delegate: Label {
                        required property var model

                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: model.shortName
                        font.bold: true
                    }
                }

                WeekNumberColumn {
                    month: grid.month
                    year: grid.year
                    locale: grid.locale

                    Layout.fillHeight: true

                    delegate: Label {
                        required property var model

                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: model.weekNumber
                        font.bold: true
                    }
                }

                MonthGrid {
                    id: grid
                    locale: Qt.locale("de_DE")

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Component.onCompleted: {
                        root.currentYear = year;
                        root.currentMonth = month;
                    }

                    delegate: Button {
                        opacity: model.month === grid.month ? 1 : 0.3
                        text: grid.locale.toString(model.date, "d")
                        font: grid.font

                        flat: true
                        highlighted: model.today

                        Material.roundedScale: Material.SmallScale

                        required property var model
                    }
                }
            }
        }
    }
}
