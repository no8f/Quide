import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell

Pane {
    id: audio_node
    required property var modelData
    property bool isSource: false
    padding: 8
    rightPadding: 12
    bottomPadding: 0
    Material.elevation: 3
    Material.background: Material.primary
    Layout.fillWidth: true

    contentItem: ColumnLayout {
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            IconLabel {
                property string appName: audio_node.modelData.properties["application.name"]

                icon.name: DesktopEntries.byId(appName).icon
                Layout.preferredHeight: 42
                Layout.preferredWidth: 42
                visible: icon.name
            }
            ColumnLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: audio_node.modelData.nickname != "" ? audio_node.modelData.nickname : audio_node.modelData.name
                    elide: Text.ElideRight
                }
                Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    enabled: false
                    text: audio_node.modelData.properties["media.name"]
                    visible: text
                }
            }
        }
        RowLayout {
            id: la
            ToolButton {
                property int stage: 3 / (1 / (vol_slider.value - 0.1))
                icon.source: {
                    if (audio_node.modelData.audio.muted || vol_slider.value == 0) {
                        if (audio_node.isSource)
                            return "../icons/audio/MicOff.svg";
                        else
                            return "../icons/audio/SpeakerMute.svg";
                    } else {
                        if (audio_node.isSource)
                            return "../icons/audio/MicOn.svg";
                        else
                            return "../icons/audio/Speaker" + stage + ".svg";
                    }
                }
                icon.color: palette.text

                onClicked: {
                    audio_node.modelData.audio.muted = !audio_node.modelData.audio.muted;
                }
            }
            Slider {
                id: vol_slider
                from: 0
                to: 1
                padding: 0
                Layout.fillWidth: true

                value: audio_node.modelData.audio.volume
                onMoved: {
                    audio_node.modelData.audio.volume = value;
                }
            }
            Label {
                text: Math.round(vol_slider.value * 100)
            }
        }
    }
}
