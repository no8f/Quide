import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Controls
import QtQuick.Controls.Material

Button {
    icon.source: "../icons/image_next.svg"
    highlighted: true
    flat: true
    implicitHeight: 36
    implicitWidth: implicitHeight
    Material.roundedScale: Material.ExtraSmallScale

    Process {
        id: changewallpaper_process
        command: ["sh", "-c", "$HOME/.config/scripts/changewallpaper.sh"]
    }

    TapHandler {
        onTapped: {
            changewallpaper_process.startDetached();
        }
    }
}
