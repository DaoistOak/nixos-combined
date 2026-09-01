import QtQuick
import QtQuick.Layouts
import "."

// A full-width selectable row in the fuzzy-find list, styled with the Noctalia
// design language: layered surface highlight on hover, primary-tinted active
// (arrow-key) row, a "current" check accent, and a swatch dot for accent rows.
Item {
    id: row
    required property string title
    property bool selected: false
    property bool active: false
    property bool custom: false
    property string hex: ""
    property string sub: ""
    signal clicked()

    height: 40

    Rectangle {
        id: highlight
        anchors.fill: parent
        radius: ThemePalette.roundingVerysmall
        color: row.active
            ? ThemePalette.colPrimaryContainer
            : (hover.hovered ? ThemePalette.colLayer2Hover : "transparent")
        Behavior on color { ColorAnimation { duration: 90 } }
    }

    Rectangle {
        visible: row.active
        width: 3
        Layout.fillHeight: true
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        radius: 1.5
        color: ThemePalette.colPrimary
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        spacing: 8

        // Accent swatch dot (accent/custom rows only).
        Rectangle {
            visible: row.hex !== ""
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            radius: 7
            color: row.hex
            border.color: ThemePalette.applyAlpha(ThemePalette.colOutline, 0.5)
            Rectangle {
                visible: row.custom
                anchors.centerIn: parent
                width: parent.width - 7
                height: 2
                radius: 1
                color: row.active ? ThemePalette.colOnPrimaryContainer : ThemePalette.colPrimary
                rotation: 45
            }
        }

        // Title
        Text {
            Layout.fillWidth: true
            text: row.title
            font.family: ThemePalette.fontFamily
            font.pixelSize: ThemePalette.fontSmall
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            color: row.custom
                ? ThemePalette.colPrimary
                : row.active ? ThemePalette.colOnPrimaryContainer : ThemePalette.colOnLayer2
            opacity: row.active ? 1 : (row.selected ? 0.95 : 0.8)
        }

        // Sub text (e.g. polarity marker)
        Text {
            visible: row.sub !== ""
            text: row.sub
            font.family: ThemePalette.fontFamily
            font.pixelSize: ThemePalette.fontSmaller
            Layout.leftMargin: 6
            color: row.active ? ThemePalette.colOnPrimaryContainer : ThemePalette.colOnLayer1
        }

        // Current check
        Text {
            visible: row.selected
            text: "✓"
            font.family: ThemePalette.fontFamily
            font.pixelSize: ThemePalette.fontSmall
            Layout.leftMargin: 4
            color: ThemePalette.colPrimary
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: row.clicked()
    }
}
