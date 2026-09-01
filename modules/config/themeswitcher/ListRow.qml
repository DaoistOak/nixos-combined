import QtQuick
import QtQuick.Layouts
import "."

// A full-width selectable row in the fuzzy-find list. Pure anchor-based layout:
// the check and swatch cells are always reserved (fixed width, children hidden
// when inactive), so the title starts at a constant x on every row and every
// glyph is pinned to the row's vertical center.
Item {
    id: row
    required property string title
    property bool selected: false
    property bool active: false
    property bool custom: false
    property string hex: ""
    property string sub: ""
    signal clicked()

    width: parent.width
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
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        radius: 1.5
        color: ThemePalette.colPrimary
    }

    // Check cell (always reserved so the title never shifts).
    Item {
        id: checkCell
        width: 18
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        Text {
            anchors.centerIn: parent
            visible: row.selected
            text: "✓"
            font.family: ThemePalette.fontFamily
            font.pixelSize: ThemePalette.fontSmall
            color: ThemePalette.colPrimary
        }
    }

    // Swatch cell (always reserved).
    Item {
        id: swatchCell
        width: 18
        anchors.left: checkCell.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        Rectangle {
            anchors.centerIn: parent
            visible: row.hex !== ""
            width: 14
            height: 14
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
    }

    // Sub text cell (always reserved; marker shown only when present).
    Item {
        id: subCell
        width: 24
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        Text {
            anchors.centerIn: parent
            visible: row.sub !== ""
            text: row.sub
            font.family: ThemePalette.fontFamily
            font.pixelSize: ThemePalette.fontSmaller
            horizontalAlignment: Text.AlignHCenter
            color: row.active ? ThemePalette.colOnPrimaryContainer : ThemePalette.colOnLayer1
        }
    }

    // Title (fills between the cells and the sub cell).
    Text {
        text: row.title
        font.family: ThemePalette.fontFamily
        font.pixelSize: ThemePalette.fontSmall
        elide: Text.ElideRight
        anchors.left: swatchCell.right
        anchors.right: subCell.left
        anchors.verticalCenter: parent.verticalCenter
        color: row.custom
            ? ThemePalette.colPrimary
            : row.active ? ThemePalette.colOnPrimaryContainer : ThemePalette.colOnLayer2
        opacity: row.active ? 1 : (row.selected ? 0.95 : 0.8)
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: row.clicked()
    }
}