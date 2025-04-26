import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.impl
import QtQuick.Layouts

Pane {
    id: root_pane
    Material.elevation: 3
    padding: 0

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

    // Component.onCompleted: {
    //     state = "retracted"
    // }

}