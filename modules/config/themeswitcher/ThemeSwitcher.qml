import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "."

// Runtime theme switcher as a CLI-style fuzzy finder, styled after Noctalia.
// Three levels walked by Enter: Scheme -> Flavour -> Accent -> apply.
// - Header always shows the current Scheme / Flavour / Accent.
// - Input bar filters the list (case-insensitive substring) and doubles as the
//   custom-hex entry at the Accent level.
// - Arrow Up/Down move selection, Enter advances/applies, Backspace (empty
//   input) steps back a level, Esc closes. Clicking a row also advances.
//
// Hot-swaps run through: /home/zeph/.config/nixos/scripts/theme set <t> <v> <a>
Item {
    id: root

    property bool open: false

    readonly property string lvlScheme: "scheme"
    readonly property string lvlFlavour: "flavour"
    readonly property string lvlAccent: "accent"

    property string level: lvlScheme
    property string query: ""
    property int selIndex: 0
    property var filtered: []

    // Locked context as you descend the levels.
    property var themeObj: null
    property var variantObj: null

    // ---- filtering ----
    function matches(item, q) {
        const needle = q.trim().toLowerCase();
        if (!needle) return true;
        const hay = ((item.title ?? "") + " " + (item.key ?? "") + " " + (item.hex ?? "")).toLowerCase();
        return hay.includes(needle);
    }

    function isHex(v) {
        return /^#?[0-9a-f]{6}$/i.test(v.trim());
    }
    function normHex(v) {
        let s = v.trim();
        if (s.charAt(0) === "#") s = s.slice(1);
        return "#" + s.toLowerCase();
    }

    // Build the accent list for the current variant, plus the custom-hex row.
    function accentItems() {
        const list = ThemeDb.accentsOf(themeObj?.key ?? "", variantObj?.key ?? "");
        const custom = {
            key: "__custom__",
            title: isHex(query) ? `Custom: ${normHex(query)}` : "Custom hex…",
            hex: isHex(query) ? normHex(query) : "",
            custom: true
        };
        list.push(custom);
        return list;
    }

    function baseList() {
        if (level === lvlScheme) return ThemeDb.themes;
        if (level === lvlFlavour) return themeObj?.variants ?? [];
        if (level === lvlAccent) return accentItems();
        return [];
    }

    // Picked -> descends a level or applies.
    function pick(item) {
        if (level === lvlScheme) {
            themeObj = item;
            level = lvlFlavour;
            query = "";
            refresh();
        } else if (level === lvlFlavour) {
            variantObj = item;
            level = lvlAccent;
            query = "";
            refresh();
        } else if (level === lvlAccent) {
            root.applySelected(item);
        }
    }

    function applySelected(item) {
        if (!item) item = filtered[selIndex];
        if (!item) return;
        const t = themeObj?.key ?? "";
        const v = variantObj?.key ?? "";
        if (!t || !v) return;
        if (item.custom) {
            if (!isHex(query)) {
                root.open = false;
                return;
            }
            ThemeDb.apply(t, v, normHex(query).slice(1));
        } else {
            ThemeDb.apply(t, v, item.key);
        }
        root.open = false;
    }

    function goBack() {
        if (level === lvlAccent) {
            level = lvlFlavour;
            variantObj = null;
            query = "";
            refresh();
        } else if (level === lvlFlavour) {
            level = lvlScheme;
            themeObj = null;
            query = "";
            refresh();
        } else {
            root.open = false;
        }
    }

    function refresh() {
        const list = baseList().filter(i => root.matches(i, root.query));
        filtered = list;
        root.selIndex = Math.min(root.selIndex, list.length - 1);
        if (root.selIndex < 0) root.selIndex = list.length ? 0 : -1;
        // If a valid hex is typed, snap selection onto the custom row.
        if (level === lvlAccent && root.isHex(root.query)) {
            const ci = list.findIndex(i => i.custom);
            if (ci >= 0) root.selIndex = ci;
        }
    }

    function moveSel(delta) {
        const n = filtered.length;
        if (n === 0) return;
        root.selIndex = (root.selIndex + delta + n) % n;
    }

    // Model object => row "selected"/"current" state.
    function isSelected(item) {
        if (level === lvlScheme)
            return (item.key ?? "").toLowerCase() === ThemeDb.currentTheme.toLowerCase();
        if (level === lvlFlavour)
            return item === ThemeDb.variantByKey(themeObj?.key ?? "", ThemeDb.currentVariant);
        if (level === lvlAccent)
            return item.custom ? false : item.key.toLowerCase() === ThemeDb.currentAccent.toLowerCase();
        return false;
    }

    // Keep selection aligned with the persisted "current" theme on open.
    function syncCurrent() {
        root.themeObj = ThemeDb.themeByKey(ThemeDb.currentTheme);
        root.variantObj = ThemeDb.variantByKey(ThemeDb.currentTheme, ThemeDb.currentVariant);
        root.level = lvlScheme;
        root.query = "";
        root.refresh();
    }

    // Key handling (focused inner Item).
    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            root.open = false;
            return true;
        }
        if (event.key === Qt.Key_Down) {
            root.moveSel(1);
            return true;
        }
        if (event.key === Qt.Key_Up) {
            root.moveSel(-1);
            return true;
        }
        if (event.key === Qt.Key_Return) {
            const item = filtered[root.selIndex];
            if (item) root.pick(item);
            return true;
        }
        if (event.key === Qt.Key_Backspace) {
            if (root.query === "") {
                root.goBack();
                return true;
            }
            return false; // let the input eat it
        }
        return false;
    }

    function labelTitle() {
        if (level === lvlScheme) return "Scheme";
        if (level === lvlFlavour) return "Flavour";
        return "Accent";
    }

    PanelWindow {
        id: win
        visible: root.open
        color: "transparent"

        WlrLayershell.namespace: "quickshell:themeswitcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors { top: true; bottom: true; left: true; right: true }

        implicitWidth: win.screen?.width ?? 1920
        implicitHeight: win.screen?.height ?? 1080

        function updateScreen() {
            const s = Hyprland.focusedMonitor?.screen
                ?? (Quickshell.screens?.length ? Quickshell.screens[0] : null);
            if (s)
                win.screen = s;
        }
        Component.onCompleted: win.updateScreen()
        Connections {
            target: Hyprland
            function onFocusedMonitorChanged() { win.updateScreen() }
        }

        // Backdrop
        Rectangle {
            id: backdrop
            anchors.fill: parent
            visible: root.open
            color: ThemePalette.shadow
            opacity: 0.35
        }

        // Dismiss on outside click
        MouseArea {
            id: outsideCatcher
            anchors.fill: parent
            z: 0
            visible: root.open
            onPressed: event => { root.open = false; event.accepted = true; }
        }

        // Centered panel
        Item {
            id: capsule
            anchors.centerIn: parent
            width: 640
            height: Math.min(560, panelBody.implicitHeight + 40)
            z: 1

            Rectangle {
                id: panel
                anchors.fill: parent
                radius: ThemePalette.roundingLarge
                // Solid opaque card so the desktop/terminal never bleeds through
                // the dialog body (only the outer backdrop is translucent).
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
                    spacing: 10

                    // ---- Header: current scheme / flavour / accent ----
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Text {
                            text: "Theme"
                            font.family: ThemePalette.fontFamily
                            font.pixelSize: ThemePalette.fontLarger
                            font.bold: true
                            color: ThemePalette.colOnLayer2
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: ThemeDb.loaded
                                ? `${cap(ThemeDb.currentTheme)}${ThemeDb.currentVariant ? " · " + cap(ThemeDb.currentVariant) : ""}${ThemeDb.currentAccent ? " · " + ThemeDb.currentAccent : ""}`
                                : ""
                            font.family: ThemePalette.fontFamily
                            font.pixelSize: ThemePalette.fontSmaller
                            color: ThemePalette.colOnLayer1
                            elide: Text.ElideRight
                        }
                    }

                    // ---- Input / fuzzy bar ----
                    Rectangle {
                        Layout.fillWidth: true
                        height: 42
                        radius: ThemePalette.roundingSmall
                        color: ThemePalette.colLayer2
                        border.width: 1
                        border.color: root.query !== "" || input.activeFocus
                            ? ThemePalette.colPrimary
                            : ThemePalette.colLayer1Border

                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            // level prompt (e.g. "SCHEME >")
                            Text {
                                text: root.labelTitle().toUpperCase() + " >"
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
                                text: ThemeDb.applying ? "…" : ""
                                font.family: ThemePalette.fontFamily
                                font.pixelSize: ThemePalette.fontSmall
                                color: ThemePalette.colPrimary
                            }
                        }
                    }

                    // ---- Result list (scrollable) ----
                    Rectangle {
                        id: listFrame
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 60
                        color: ThemePalette.colLayer2
                        radius: ThemePalette.roundingSmall
                        border.width: 2
                        border.color: ThemePalette.colPrimary
                        clip: true

                        ListView {
                            id: flic
                            anchors.fill: parent
                            anchors.margins: 1
                            clip: true
                            model: root.filtered
                            currentIndex: root.selIndex
                            boundsBehavior: Flickable.StopAtBounds
                            highlightMoveDuration: 0
                            spacing: 2

                            delegate: ListRow {
                                required property var modelData
                                required property int index
                                title: modelData?.custom
                                    ? modelData.title
                                    : (root.level === root.lvlFlavour ? "☾ " + modelData.title : modelData.title)
                                sub: modelData?.polarity === "light" ? "light" : ""
                                hex: modelData?.hex ?? ""
                                custom: modelData?.custom ?? false
                                selected: root.isSelected(modelData)
                                active: index === root.selIndex
                                onClicked: {
                                    root.selIndex = index;
                                    root.pick(modelData);
                                }
                            }
                        }

                        // Empty / not-yet-loaded state so the list region is never blank.
                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            visible: root.filtered.length === 0
                            text: !ThemeDb.loaded
                                ? "Loading themes…"
                                : `No ${root.labelTitle().toLowerCase()} match "` + root.query + '"'
                            font.family: ThemePalette.fontFamily
                            font.pixelSize: ThemePalette.fontSmall
                            color: ThemePalette.colOnLayer1
                        }
                    }

                    // ---- Footer hints ----
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14
                        Text {
                            text: "↑↓ select   ⏎ " + (root.level === root.lvlAccent ? "apply" : "next") + "   ⌫ back   esc close"
                            font.family: ThemePalette.fontFamily
                            font.pixelSize: ThemePalette.fontSmaller
                            font.bold: false
                            color: ThemePalette.colOnLayer2
                            opacity: 0.85
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.level === root.lvlAccent ? "type a hex for Custom" : ""
                            font.family: ThemePalette.fontFamily
                            font.pixelSize: ThemePalette.fontSmaller
                            color: ThemePalette.colPrimary
                        }
                    }
                }
            }
        }
    }

    // ---- open/close lifecycle ----
    Connections {
        target: root
        function onOpenChanged() {
            if (root.open) {
                root.syncCurrent();
                ThemePalette.reload();
                ThemeDb.reload();
                root.refresh();
                input.forceActiveFocus();
                Qt.callLater(function() {
                    console.log("DIAG themeswitcher:",
                        "filtered:", root.filtered.length,
                        "capsule.h:", capsule.height,
                        "panelBody.ih:", panelBody.implicitHeight,
                        "listFrame.h:", listFrame.height,
                        "flic.h:", flic.height,
                        "flic.contentH:", flic.contentHeight,
                        "flic.count:", flic.count);
                });
            }
        }
    }

    function cap(s) {
        if (!s) return "";
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    IpcHandler {
        target: "themeswitcher"
        function toggle() { root.open = !root.open; }
        function open() { root.open = true; }
        function close() { root.open = false; }
    }
}
