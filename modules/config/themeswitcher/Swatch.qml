import QtQuick
import "."

// A color swatch chip showing an accent: a circular color dot + name capsule.
Item {
    id: swatch
    required property string key
    required property string hex
    property bool active: false
    signal clicked()

    width: swatchLabel.implicitWidth + 30
    height: 30

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: height / 2
        color: swatch.active ? ThemePalette.surfaceContainerHighest : ThemePalette.surface
        border.width: 1
        border.color: swatch.active
            ? Qt.rgba(accentC.r, accentC.g, accentC.b, 0.9)
            : Qt.rgba(ThemePalette.outline.r, ThemePalette.outline.g, ThemePalette.outline.b, 0.4)

        Behavior on color { ColorAnimation { duration: 120 } }

        Rectangle {
            id: colorDot
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            width: 14
            height: 14
            radius: 7
            color: accentC
            border.color: Qt.rgba(ThemePalette.outline.r, ThemePalette.outline.g, ThemePalette.outline.b, 0.5)
        }

        Text {
            id: swatchLabel
            anchors.left: colorDot.right
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: swatch.key
            font.family: "JetBrains Mono"
            font.pixelSize: 12
            color: swatch.active ? ThemePalette.onSurface : ThemePalette.onSurfaceVariant
            elide: Text.ElideRight
        }
    }

    readonly property color accentC: {
        try {
            const v = Qt.color(swatch.hex);
            if (v.a === 0 && swatch.hex.toLowerCase() !== "#00000000")
                return Qt.rgba(v.r, v.g, 0.0, 1.0);
            return v;
        } catch (e) {
            return "#888888";
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: swatch.clicked()
    }
}
