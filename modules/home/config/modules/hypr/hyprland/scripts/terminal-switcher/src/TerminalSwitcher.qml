import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "."

// Default-terminal switcher as a CLI-style fuzzy finder, mirrored from the
// themeswitcher utility. Single level: type to filter, Enter applies.
// Presented as a compact, centered layer-shell capsule (above windows, no
// exclusive keyboard grab).
Item {
    id: root

    property bool open: false

    property string query: ""
    property int selIndex: 0
    property var filtered: []

    function matches(item, q) {
        const needle = q.trim().toLowerCase();
        if (!needle) return true;
        const hay = ((item.title ?? "") + " " + (item.key ?? "") + " " + (item.desc ?? "")).toLowerCase();
        return hay.includes(needle);
    }

    function pick(item) {
        if (!item) return;
        TermDb.apply(item.key);
        root.open = false;
    }

    function refresh() {
        const list = TermDb.terminals.filter(i => root.matches(i, root.query));
        filtered = list;
        root.selIndex = Math.min(root.selIndex, list.length - 1);
        if (root.selIndex < 0) root.selIndex = list.length ? 0 : -1;
    }

    function moveSel(delta) {
        const n = filtered.length;
        if (n === 0) return;
        root.selIndex = (root.selIndex + delta + n) % n;
    }

    function isSelected(item) {
        return (item.key ?? "").toLowerCase() === TermDb.current.toLowerCase();
    }

    function syncCurrent() {
        const idx = TermDb.terminals.findIndex(t =>
            (t.key ?? "").toLowerCase() === TermDb.current.toLowerCase());
        root.selIndex = Math.max(0, idx);
        root.refresh();
    }

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) { root.open = false; return true; }
        if (event.key === Qt.Key_Down)   { root.moveSel(1); return true; }
        if (event.key === Qt.Key_Up)     { root.moveSel(-1); return true; }
        if (event.key === Qt.Key_Return) {
            const item = filtered[root.selIndex];
            if (item) root.pick(item);
            return true;
        }
        if (event.key === Qt.Key_Backspace && root.query === "") {
            root.open = false; return true;
        }
        return false;
    }

    PanelWindow {
        id: win
        visible: root.open
        color: "transparent"
        // No anchors -> wlr-layer-shell centers the surface on its output.
        screen: Hyprland.focusedMonitor?.screen ?? null
        exclusiveZone: 0
        focusable: true

        implicitWidth: 640
        implicitHeight: Math.min(560, panelBody.implicitHeight + 32)

        Rectangle {
            id: panel
            anchors.fill: parent
            radius: ThemePalette.roundingLarge
            color: ThemePalette.colLayer1
            border.color: ThemePalette.colLayer1Border
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onPressed: event => { event.accepted = true; }
            }

            ColumnLayout {
                id: panelBody
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // ---- Header ----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "Terminal"
                        font.family: ThemePalette.fontFamily
                        font.pixelSize: ThemePalette.fontLarger
                        font.bold: true
                        color: ThemePalette.colOnLayer2
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: TermDb.loaded
                            ? "current · " + cap(TermDb.current)
                            : ""
                        font.family: ThemePalette.fontFamily
                        font.pixelSize: ThemePalette.fontSmaller
                        color: ThemePalette.colOnLayer1
                        elide: Text.ElideRight
                    }
                }

                // ---- Input bar ----
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: ThemePalette.roundingSmall
                    color: ThemePalette.colLayer2
                    border.width: 1
                    border.color: root.query !== "" || input.activeFocus
                        ? ThemePalette.colPrimary
                        : ThemePalette.colLayer1Border

                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: "TERMINAL >"
                            font.family: ThemePalette.fontFamily
                            font.pixelSize: ThemePalette.fontSmall
                            font.bold: true
                            color: ThemePalette.colPrimary
                        }

                        TextInput {
                            id: input
                            Layout.fillWidth: true
                            verticalAlignment: TextInput.AlignVCenter
                            text: root.query
                            font.family: ThemePalette.fontFamily
                            font.pixelSize: ThemePalette.fontNormal
                            color: ThemePalette.colOnLayer2
                            selectByMouse: true
                            activeFocusOnPress: true
                            cursorDelegate: Rectangle {
                                width: 1
                                color: ThemePalette.colPrimary
                            }
                            onTextChanged: {
                                root.query = text;
                                root.refresh();
                            }
                            Keys.onPressed: event => {
                                if (!root.handleKey(event))
                                    event.accepted = false;
                                else
                                    event.accepted = true;
                            }
                        }

                        Text {
                            text: TermDb.applying ? "…" : ""
                            font.family: ThemePalette.fontFamily
                            font.pixelSize: ThemePalette.fontSmall
                            color: ThemePalette.colPrimary
                        }
                    }
                }

                // ---- Result list ----
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 240
                    color: ThemePalette.colLayer2
                    radius: ThemePalette.roundingSmall
                    clip: true

                    ListView {
                        anchors.fill: parent
                        anchors.margins: 12
                        clip: true
                        model: root.filtered
                        currentIndex: root.selIndex
                        boundsBehavior: Flickable.StopAtBounds
                        highlightMoveDuration: 0
                        spacing: 2

                        delegate: ListRow {
                            required property var modelData
                            required property int index
                            title: modelData.title
                            sub: ""
                            hex: ""
                            custom: false
                            selected: root.isSelected(modelData)
                            active: index === root.selIndex
                            onClicked: {
                                root.selIndex = index;
                                root.pick(modelData);
                            }
                        }
                    }

                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        visible: root.filtered.length === 0
                        text: !TermDb.loaded
                            ? "Loading terminals…"
                            : `No terminal matches "${root.query}"`
                        font.family: ThemePalette.fontFamily
                        font.pixelSize: ThemePalette.fontSmall
                        color: ThemePalette.colOnLayer1
                    }
                }

                // ---- Footer ----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        text: "↑↓ select   ⏎ apply   esc close"
                        font.family: ThemePalette.fontFamily
                        font.pixelSize: ThemePalette.fontSmaller
                        color: ThemePalette.colOnLayer2
                        opacity: 0.7
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "applies on next launch"
                        font.family: ThemePalette.fontFamily
                        font.pixelSize: ThemePalette.fontSmaller
                        color: ThemePalette.colPrimary
                    }
                }
            }
        }
    }

    Connections {
        target: root
        function onOpenChanged() {
            if (root.open) {
                root.syncCurrent();
                TermDb.reload();
                input.forceActiveFocus();
            }
        }
    }

    Connections {
        target: TermDb
        function onLoadedChanged() {
            if (root.open) {
                root.syncCurrent();
                root.refresh();
            }
        }
    }

    Component.onCompleted: {
        if (root.open) {
            root.syncCurrent();
            TermDb.reload();
            input.forceActiveFocus();
        }
    }

    function cap(s) {
        if (!s) return "";
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    IpcHandler {
        target: "terminal-switcher"
        function toggle() { root.open = !root.open; }
        function open() { root.open = true; }
        function close() { root.open = false; }
    }
}