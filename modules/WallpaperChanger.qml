import Quickshell.Io
import QtQuick // for Text
import QtQuick.Layouts
import QtQuick.Controls.impl

IconLabel {
    Layout.fillHeight: true

    icon.width: 35 / 2
    icon.source: "../icons/image_next.svg"
    icon.color: palette.text

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
