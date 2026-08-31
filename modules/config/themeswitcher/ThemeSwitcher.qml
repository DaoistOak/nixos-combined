import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "."

// Centered floating capsule panel matching the Noctalia shell design language:
// Material layered colors pulled live from the theme-switcher palette, rounded
// capsules for chips, JetBrains Mono, subtle backdrop. Shows Scheme -> Flavour
// -> Accent; picking a selection hot-swaps via the theme CLI.
//
// Uses a full-screen overlay PanelWindow (proofed pattern from the overview
// reference) so it can grab keyboard + dismiss on any outside click while the
// capsule stays centered — same tradeoff as a launcher overlay.
Item {
    id: root

    property bool open: false
    property string selectedThemeKey: ""
    property string selectedVariantKey: ""
    property string selectedAccentKey: ""
    property var selectedThemeObj: null
    property var selectedVariantObj: null

    PanelWindow {
        id: win
        visible: root.open
        color: "transparent"

        WlrLayershell.namespace: "quickshell:themeswitcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        implicitWidth: win.screen?.width ?? 1920
        implicitHeight: win.screen?.height ?? 1080

        // Track the focused monitor so the capsule centers on the active screen.
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

        // Full-window key handler (Keys must attach to an Item, not the window).
        Item {
            id: keyHandler
            anchors.fill: parent
            visible: root.open
            focus: root.open
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return) {
                    root.open = false;
                    event.accepted = true;
                }
            }
        }

        // Subtle Noctalia-style backdrop to separate the panel from the screen.
        Rectangle {
            id: backdrop
            anchors.fill: parent
            visible: root.open
            color: "#000000"
            opacity: 0.22
        }

        // --- Reset + reload selection each time the panel opens ---
        Connections {
            target: root
            function onOpenChanged() {
                if (root.open) {
                    root.selectedThemeKey = "";
                    root.selectedVariantKey = "";
                    root.selectedAccentKey = "";
                    root.selectedThemeObj = null;
                    root.selectedVariantObj = null;
                    ThemePalette.reload();
                    ThemeDb.reload();
                    root.syncSelection();
                }
            }
        }

        // Dismiss on any outside click (below the panel)
        MouseArea {
            id: outsideCatcher
            anchors.fill: parent
            z: 0
            visible: root.open
            onPressed: event => {
                root.open = false;
                event.accepted = true;
            }
        }

        Item {
            id: capsule
            anchors.centerIn: parent
            width: 480
            height: panelBody.implicitHeight + 56
            z: 1

            // Capsule background (swallows clicks so the outside catcher below
            // never fires while interacting inside the panel).
            Rectangle {
                id: panel
                anchors.fill: parent
                radius: 18
                color: Qt.rgba(ThemePalette.surfaceContainerHigh.r, ThemePalette.surfaceContainerHigh.g, ThemePalette.surfaceContainerHigh.b, 0.96)
                border.color: Qt.rgba(ThemePalette.outline.r, ThemePalette.outline.g, ThemePalette.outline.b, 0.35)
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    onPressed: event => {
                        event.accepted = true;
                    }
                }

                ColumnLayout {
                    id: panelBody
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    // ---- Header ----
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Text {
                            text: "Theme"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 18
                            font.bold: true
                            color: ThemePalette.onSurface
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: ThemeDb.loaded ? `${cap(ThemeDb.currentTheme)} · ${cap(ThemeDb.currentVariant)}${ThemeDb.currentAccent ? " · " + cap(ThemeDb.currentAccent) : ""}` : ""
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                            color: ThemePalette.onSurfaceVariant
                            elide: Text.ElideRight
                        }
                    }

                    // ---- Scheme row ----
                    SectionLabel { label: "SCHEME" }
                    Flow {
                        Layout.fillWidth: true
                        spacing: 6
                        Variants {
                            model: ThemeDb.themes
                            Chip {
                                required property var modelData
                                text: modelData.title
                                active: modelData.key.toLowerCase() === ThemeDb.currentTheme.toLowerCase()
                                    || modelData.key === root.selectedThemeKey
                                onClicked: {
                                    root.selectedThemeKey = modelData.key;
                                    root.selectedThemeObj = modelData;
                                    root.selectedVariantKey = "";
                                    root.selectedVariantKey = "";
                                    root.selectedAccentKey = "";
                                    root.selectedVariantObj = null;
                                    const vs = modelData.variants ?? [];
                                    if (vs.length > 0) {
                                        root.selectedVariantKey = vs[0].key;
                                        root.selectedVariantObj = vs[0];
                                        const acs = vs[0].accents ?? [];
                                        if (acs.length > 0) {
                                            root.selectedAccentKey = acs[0].key;
                                            ThemeDb.apply(modelData.key, vs[0].key, acs[0].key);
                                        } else {
                                            ThemeDb.apply(modelData.key, vs[0].key, "");
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ---- Flavour row ----
                    SectionLabel {
                        visible: root.selectedThemeKey !== ""
                        label: "FLAVOUR"
                    }
                    Flow {
                        Layout.fillWidth: true
                        visible: root.selectedThemeKey !== ""
                        spacing: 6
                        Variants {
                            model: root.selectedThemeObj?.variants ?? []
                            Chip {
                                required property var modelData
                                text: (modelData.polarity === "light" ? "☀ " : "☾ ") + modelData.title
                                active: modelData.key === root.selectedVariantKey
                                onClicked: {
                                    root.selectedVariantKey = modelData.key;
                                    root.selectedVariantObj = modelData;
                                    root.selectedAccentKey = "";
                                    const acs = modelData.accents ?? [];
                                    if (acs.length > 0) {
                                        root.selectedAccentKey = acs[0].key;
                                        ThemeDb.apply(root.selectedThemeKey, modelData.key, acs[0].key);
                                    } else {
                                        ThemeDb.apply(root.selectedThemeKey, modelData.key, "");
                                    }
                                }
                            }
                        }
                    }

                    // ---- Accent row ----
                    SectionLabel {
                        visible: root.selectedVariantKey !== "" && (root.selectedVariantObj?.accents?.length ?? 0) > 0
                        label: "ACCENT"
                    }
                    Flow {
                        Layout.fillWidth: true
                        visible: root.selectedVariantKey !== "" && (root.selectedVariantObj?.accents?.length ?? 0) > 0
                        spacing: 6
                        Variants {
                            model: root.selectedVariantObj?.accents ?? []
                            Swatch {
                                required property var modelData
                                key: modelData.key
                                hex: modelData.hex
                                active: modelData.key === root.selectedAccentKey
                                onClicked: {
                                    root.selectedAccentKey = modelData.key;
                                    ThemeDb.apply(root.selectedThemeKey, root.selectedVariantKey, modelData.key);
                                }
                            }
                        }
                    }

                    // ---- Footer status ----
                    RowLayout {
                        Layout.fillWidth: true
                        visible: ThemeDb.applying
                        Text {
                            text: "Applying…"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            color: ThemePalette.onSurfaceVariant
                        }
                    }
                }
            }
        }
    }

    // Align the selection with the persisted "current" theme.
    function syncSelection() {
        if (!ThemeDb.loaded) return;
        for (const th of ThemeDb.themes) {
            if (th.key.toLowerCase() === ThemeDb.currentTheme.toLowerCase()) {
                root.selectedThemeKey = th.key;
                root.selectedThemeObj = th;
                for (const v of th.variants ?? []) {
                    if (v.key.toLowerCase() === ThemeDb.currentVariant.toLowerCase()) {
                        root.selectedVariantKey = v.key;
                        root.selectedVariantObj = v;
                        for (const a of v.accents ?? []) {
                            if (a.key.toLowerCase() === ThemeDb.currentAccent.toLowerCase()) {
                                root.selectedAccentKey = a.key;
                                return;
                            }
                        }
                        return;
                    }
                }
                return;
            }
        }
        // Fallback: first theme, first variant, first accent.
        if (ThemeDb.themes.length > 0) {
            const th = ThemeDb.themes[0];
            root.selectedThemeKey = th.key;
            root.selectedThemeObj = th;
            if ((th.variants ?? []).length > 0) {
                const v = th.variants[0];
                root.selectedVariantKey = v.key;
                root.selectedVariantObj = v;
                if ((v.accents ?? []).length > 0)
                    root.selectedAccentKey = v.accents[0].key;
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
