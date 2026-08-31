import QtQuick
import "."

// A Noctalia-style capsule chip (rounded, elevated, layered Material colors).
Item {
    id: chip
    required property string text
    property bool active: false
    signal clicked()

    width: chipLabel.implicitWidth + 24
    height: 30
    property color base: active ? ThemePalette.primary : ThemePalette.surfaceVariant

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: height / 2
        color: chip.base
        border.width: 1
        border.color: chip.active
            ? ThemePalette.primary
            : Qt.rgba(ThemePalette.outline.r, ThemePalette.outline.g, ThemePalette.outline.b, 0.4)

        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        id: chipLabel
        anchors.centerIn: parent
        text: chip.text
        font.family: "JetBrains Mono"
        font.pixelSize: 13
        color: chip.active ? ThemePalette.onPrimary : ThemePalette.onSurface
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: pill.color = Qt.lighter(chip.base, 1.15)
        onExited: pill.color = chip.base
        onClicked: chip.clicked()
    }
}
