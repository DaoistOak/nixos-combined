pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Reads the Noctalia theme-switcher palette (themeswapper.json) that
// scripts/theme rewrites on every hot-swap, and maps its Material roles to
// the layered color set used by the widget — so the popup follows the current
// theme just like the Noctalia shell does.
Singleton {
    id: root

    property bool loaded: false
    property string lastPayload: ""

    // --- Core Material roles (from the Noctalia palette) ---
    property color primary
    property color onPrimary
    property color secondary
    property color onSecondary
    property color surface
    property color surfaceVariant
    property color onSurface
    property color onSurfaceVariant
    property color outline
    property color error
    property color shadow
    property color tertiary

    // --- Derived layered surfaces (mix surface toward onSurface) ---
    readonly property color surfaceContainerLow: mix(surface, onSurface, 0.06)
    readonly property color surfaceContainer: mix(surface, onSurface, 0.10)
    readonly property color surfaceContainerHigh: mix(surface, onSurface, 0.14)
    readonly property color surfaceContainerHighest: mix(surface, onSurface, 0.18)

    function mix(c1, c2, p) {
        const a = Qt.color(c1);
        const b = Qt.color(c2);
        return Qt.rgba(
            p * a.r + (1 - p) * b.r,
            p * a.g + (1 - p) * b.g,
            p * a.b + (1 - p) * b.b,
            p * a.a + (1 - p) * b.a
        );
    }

    function transparentize(color, p) {
        const c = Qt.color(color);
        return Qt.rgba(c.r, c.g, c.b, c.a * (1 - p));
    }

    function reload() {
        loadPalette.running = true;
    }

    function applyPalette(obj) {
        root.primary = obj.mPrimary ?? root.primary;
        root.onPrimary = obj.mOnPrimary ?? root.onPrimary;
        root.secondary = obj.mSecondary ?? root.secondary;
        root.onSecondary = obj.mOnSecondary ?? root.onSecondary;
        root.surface = obj.mSurface ?? root.surface;
        root.surfaceVariant = obj.mSurfaceVariant ?? root.surfaceVariant;
        root.onSurface = obj.mOnSurface ?? root.onSurface;
        root.onSurfaceVariant = obj.mOnSurfaceVariant ?? root.onSurfaceVariant;
        root.outline = obj.mOutline ?? root.outline;
        root.error = obj.mError ?? root.error;
        root.shadow = obj.mShadow ?? root.shadow;
        root.tertiary = obj.mTertiary ?? root.tertiary;
        root.loaded = true;
    }

    function ensureLoaded() {
        if (!root.loaded)
            root.reload();
    }

    Process {
        id: loadPalette
        command: ["sh", "-lc",
            "cfg=\"$HOME/.config/noctalia/palettes/themeswapper.json\"; [ -r \"$cfg\" ] && cat \"$cfg\""]
        stdout: StdioCollector {
            id: collector
            onStreamFinished: {
                const text = collector.text.trim();
                if (!text) {
                    root.loaded = false;
                    return;
                }
                try {
                    const parsed = JSON.parse(text);
                    // The profile is keyed by polarity: { "dark": {...} } | { "light": {...} }
                    const obj = parsed?.dark ?? parsed?.light ?? parsed;
                    if (obj && typeof obj === "object") {
                        const payload = JSON.stringify(obj);
                        if (payload !== root.lastPayload) {
                            root.lastPayload = payload;
                            applyPalette(obj);
                        }
                    } else {
                        root.loaded = false;
                    }
                } catch (e) {
                    console.warn("themeswitcher palette: parse error", e);
                    root.loaded = false;
                }
            }
        }
    }

    Component.onCompleted: {
        root.ensureLoaded();
    }
}
