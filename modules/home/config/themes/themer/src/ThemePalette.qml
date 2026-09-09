pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Reads the Noctalia theme-switcher palette (themeswapper.json) that
// scripts/theme rewrites on every hot-swap, and exposes the Noctalia design
// language tokens used by the widget — the same Material 3 role + layered
// surface system that Noctalia's own shell consumes (cf. Appearance.qml), plus
// the rounding / font scales and color-mix helpers. The popup therefore follows
// the current theme exactly like the rest of the Noctalia shell.
Singleton {
    id: root

    property bool loaded: false
    property string lastPayload: ""

    // --- Core Material 3 roles (from the Noctalia palette) ---
    property color primary: "#c6a0f6"
    property color secondary: "#8aadf4"
    property color tertiary: "#8bd5ca"
    property color surface: "#24273a"
    property color surfaceVariant: "#363a4f"
    property color outline: "#6e738d"
    property color outlineVariant: "#4c4f69"
    property color error: "#ed8796"
    property color shadow: "#181926"
    // Properties whose names begin with "on"+Capital are interpreted as signal
    // handlers, so they cannot carry a value initializer — leave them bare and
    // let the derived color tokens bind to whatever the palette loads.
    property color onPrimary
    property color onSecondary
    property color onTertiary
    property color onSurface
    property color onSurfaceVariant
    property color onErrorColor

    // --- Derived layered surfaces ---
    // Elevate "toward" onSurface by a small step while keeping the dominant
    // tone = surface, so dark themes stay dark and light themes stay light.
    // mix(c1, c2, p) = p*c1 + (1-p)*c2, so mixing onSurface into surface with
    // a small factor keeps the result ~surface (correct M3 elevation).
    readonly property color surfaceContainerLow: mix(onSurface, surface, 0.03)
    readonly property color surfaceContainer: mix(onSurface, surface, 0.08)
    readonly property color surfaceContainerHigh: mix(onSurface, surface, 0.14)
    readonly property color surfaceContainerHighest: mix(onSurface, surface, 0.22)

    // --- Noctalia design-language surface tokens (cf. Appearance.colors) ---
    readonly property color colLayer0: surface
    readonly property color colOnLayer0: onSurface
    readonly property color colLayer0Border: mix(outlineVariant, surface, 0.4)
    readonly property color colLayer1: surfaceContainerLow
    readonly property color colOnLayer1: onSurfaceVariant
    readonly property color colOnLayer1Inactive: mix(colOnLayer1, colLayer1, 0.45)
    readonly property color colLayer1Border: mix(outline, colLayer1, 0.55)
    readonly property color colLayer1Hover: mix(colLayer1, colOnLayer1, 0.92)
    readonly property color colLayer1Active: mix(colLayer1, colOnLayer1, 0.85)
    readonly property color colLayer2: surfaceContainer
    readonly property color colOnLayer2: onSurface
    readonly property color colLayer2Hover: mix(colLayer2, colOnLayer2, 0.90)
    readonly property color colLayer2Active: mix(colLayer2, colOnLayer2, 0.80)
    readonly property color colPrimary: primary
    readonly property color colOnPrimary: onPrimary
    readonly property color colPrimaryContainer: mix(surface, primary, 0.18)
    readonly property color colOnPrimaryContainer: bestOnColor(colPrimaryContainer)
    readonly property color colSecondary: secondary
    readonly property color colSecondaryContainer: mix(surface, secondary, 0.18)
    readonly property color colOnSecondaryContainer: bestOnColor(colSecondaryContainer)
    readonly property color colTooltip: onSurface
    readonly property color colOnTooltip: surface
    readonly property color colShadow: transparentize(shadow, 0.7)
    readonly property color colOutline: outline
    readonly property color colOutlineVariant: outlineVariant

    // --- Noctalia rounding scale (cf. Appearance.rounding) ---
    readonly property int roundingUnsharpen: 2
    readonly property int roundingVerysmall: 8
    readonly property int roundingSmall: 12
    readonly property int roundingNormal: 17
    readonly property int roundingLarge: 23
    readonly property int roundingFull: 9999
    readonly property int roundingWindow: 18

    // --- Noctalia font scale (cf. Appearance.font) ---
    readonly property string fontFamily: "JetBrains Mono"
    readonly property int fontSmaller: 12
    readonly property int fontSmall: 14
    readonly property int fontNormal: 15
    readonly property int fontLarger: 17
    readonly property int fontHuge: 20

    // --- Color helpers (mirror Noctalia's ColorUtils) ---
    function mix(c1, c2, percentage = 0.5) {
        const a = Qt.color(c1);
        const b = Qt.color(c2);
        return Qt.rgba(
            percentage * a.r + (1 - percentage) * b.r,
            percentage * a.g + (1 - percentage) * b.g,
            percentage * a.b + (1 - percentage) * b.b,
            percentage * a.a + (1 - percentage) * b.a
        );
    }

    function transparentize(color, percentage = 1) {
        const c = Qt.color(color);
        return Qt.rgba(c.r, c.g, c.b, c.a * (1 - percentage));
    }

    function applyAlpha(color, alpha) {
        const c = Qt.color(color);
        const a = Math.max(0, Math.min(1, alpha));
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function adaptToAccent(color1, color2) {
        const c1 = Qt.color(color1);
        const c2 = Qt.color(color2);
        return Qt.hsla(c2.hslHue, c2.hslSaturation, c1.hslLightness, c1.a);
    }

    function relativeLuminance(color) {
        const c = Qt.color(color);
        function channel(v) {
            return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
        }
        return (0.2126 * channel(c.r)) + (0.7152 * channel(c.g)) + (0.0722 * channel(c.b));
    }

    function bestOnColor(backgroundColor) {
        return relativeLuminance(backgroundColor) > 0.5 ? "#121212" : "#f5f5f5";
    }

    function reload() {
        loadPalette.running = true;
    }

    function applyPalette(obj) {
        root.primary = obj.mPrimary ?? root.primary;
        root.onPrimary = obj.mOnPrimary ?? root.onPrimary;
        root.secondary = obj.mSecondary ?? root.secondary;
        root.onSecondary = obj.mOnSecondary ?? root.onSecondary;
        root.tertiary = obj.mTertiary ?? root.tertiary;
        root.onTertiary = obj.mOnTertiary ?? root.onTertiary;
        root.surface = obj.mSurface ?? root.surface;
        root.surfaceVariant = obj.mSurfaceVariant ?? root.surfaceVariant;
        root.onSurface = obj.mOnSurface ?? root.onSurface;
        root.onSurfaceVariant = obj.mOnSurfaceVariant ?? root.onSurfaceVariant;
        root.outline = obj.mOutline ?? root.outline;
        root.error = obj.mError ?? root.error;
        root.onErrorColor = obj.mOnError ?? root.onErrorColor;
        root.shadow = obj.mShadow ?? root.shadow;
        root.outlineVariant = mix(root.onSurface, root.surface, 0.62);
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

    // Seed readable on-role defaults at construction so text tokens are never
    // undefined before the live palette finishes loading (the on* property
    // names cannot carry a value initializer in QML).
    function seedDefaults() {
        root.onPrimary = "#24273a";
        root.onSecondary = "#1e2030";
        root.onTertiary = "#1e2030";
        root.onSurface = "#cad3f5";
        root.onSurfaceVariant = "#a5adcb";
        root.onErrorColor = "#24273a";
    }

    Component.onCompleted: {
        root.seedDefaults();
        root.ensureLoaded();
    }
}
