pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Reads the machine-readable theme DB (themes.json) that scripts/theme (and the
// declarative modules/config/colors) consume, plus the persisted current
// selection, and exposes the apply action that triggers a full hot-swap via the
// theme CLI.
Singleton {
    id: root

    readonly property string dbPath: "$HOME/.local/share/theme-switcher/themes.json"
    readonly property string statePath: "$HOME/.local/share/theme-switcher/current"
    readonly property string scriptPath: "/home/zeph/.config/nixos/scripts/theme"

    property var themes: []
    property string currentTheme: ""
    property string currentVariant: ""
    property string currentAccent: ""
    property bool loaded: false
    property bool applying: false
    property bool loadQueued: false
    property var loadErrors: []

    // Emitted after every finished load attempt. `loaded` only flips on the first
    // successful parse, so listeners that rebuild a model must watch this instead:
    // a reload that only adds themes leaves `loaded` at true and never signals.
    signal reloaded

    // Index helpers for the UI model (themes = [{ key, title, variants:[{ key, title, polarity, accents:[{key,hex}] }] }])
    function variants(themeIdx) {
        return themes[themeIdx]?.variants ?? [];
    }
    function variantAccents(themeIdx, vIdx) {
        return variants(themeIdx)[vIdx]?.accents ?? [];
    }
    function themeTitle(themeIdx) {
        return themes[themeIdx]?.title ?? "";
    }
    function themeKey(themeIdx) {
        return themes[themeIdx]?.key ?? "";
    }
    function variantKey(themeIdx, vIdx) {
        return variants(themeIdx)[vIdx]?.key ?? "";
    }
    function variantTitle(themeIdx, vIdx) {
        return variants(themeIdx)[vIdx]?.title ?? "";
    }
    function accentHex(themeIdx, vIdx, aIdx) {
        return variantAccents(themeIdx, vIdx)[aIdx]?.hex ?? "#888888";
    }

    // Key-based lookups for the fuzzy-finder.
    function themeByKey(k) {
        const kl = (k ?? "").toLowerCase();
        return themes.find(t => (t.key ?? "").toLowerCase() === kl) ?? null;
    }
    function variantByKey(themeKey, vKey) {
        const th = themeByKey(themeKey);
        const kl = (vKey ?? "").toLowerCase();
        return (th?.variants ?? []).find(v => (v.key ?? "").toLowerCase() === kl) ?? null;
    }
    // Accent objects with a stable { key, hex, title } shape (hex prefixed with #).
    // Also offers the "Default" accent: the theme's primary text color.
    function accentsOf(themeKey, vKey) {
        const v = variantByKey(themeKey, vKey);
        const list = (v?.accents ?? [])
            .map(a => ({ key: a.key, hex: a.hex, title: a.key }));
        list.unshift({ key: "default", hex: v?.text ?? "", title: "Default" });
        return list;
    }

    // Case-insensitive current-selection matches for highlighting.
    function isCurrentTheme(themeIdx) {
        if (!root.loaded || !root.currentTheme) return false;
        return root.currentTheme.toLowerCase() === (themes[themeIdx]?.key ?? "").toLowerCase();
    }
    function isCurrentVariant(themeIdx, vIdx) {
        if (!isCurrentTheme(themeIdx)) return false;
        return root.currentVariant.toLowerCase() === (variants(themeIdx)[vIdx]?.key ?? "").toLowerCase();
    }
    function isCurrentAccent(themeIdx, vIdx, acIdx) {
        if (!isCurrentVariant(themeIdx, vIdx)) return false;
        const ac = variants(themeIdx)[vIdx]?.accents?.[acIdx]?.key ?? "";
        return root.currentAccent.toLowerCase() === ac.toLowerCase();
    }

    function reload() {
        // Quickshell ignores `running = true` while the process is live, which
        // would silently drop the reload; queue it for the next free run.
        if (loadDb.running) {
            root.loadQueued = true;
            return;
        }
        loadDb.running = true;
    }

    function apply(themeKey, variantKey, accentKey) {
        if (!themeKey || !variantKey)
            return;
        const a = accentKey || "";
        applyProcess.command = [
            "bash", "-lc",
            `"${root.scriptPath}" set '${themeKey}' '${variantKey}' '${a}'`
        ];
        applyProcess.running = true;
    }

    Process {
        id: loadDb
        command: ["sh", "-lc",
            `cat "${root.dbPath}" 2>/dev/null; echo; echo "--STATE--"; cat "${root.statePath}" 2>/dev/null || true`
        ]
        onRunningChanged: {
            // Drain reloads that arrived while the process was live.
            if (!running && root.loadQueued) {
                root.loadQueued = false;
                loadDb.running = true;
            }
        }
        stdout: StdioCollector {
            id: dbCollector
            onStreamFinished: {
                const raw = dbCollector.text;
                const sep = raw.indexOf("--STATE--");
                const jsonText = raw.slice(0, sep).trim();
                const stateText = raw.slice(sep + "--STATE--".length).trim();

                try {
                    const db = JSON.parse(jsonText);
                    const built = [];
                    for (const key of Object.keys(db)) {
                        const th = db[key];
                        const variants = [];
                        for (const vkey of Object.keys(th.flavors ?? {})) {
                            const f = th.flavors[vkey];
                            const accents = Object.keys(f.accents ?? {})
                                .filter(a => a !== "default")
                                .map(a => ({ key: a, hex: "#" + (f.accents[a] ?? "#888888") }));
                            variants.push({
                                key: vkey,
                                title: f.title ?? vkey,
                                polarity: f.polarity ?? "dark",
                                text: f.text ?? "",
                                accents
                            });
                        }
                        built.push({ key, title: th.title ?? key, variants });
                    }

                    const parts = stateText.split(/\s+/).filter(Boolean);
                    if (parts.length >= 2) {
                        root.currentTheme = parts[0];
                        root.currentVariant = parts[1].toLowerCase();
                        root.currentAccent = parts[2] ? parts[2].toLowerCase() : "";
                    } else {
                        root.currentTheme = "catppuccin";
                        root.currentVariant = "macchiato";
                        root.currentAccent = "mauve";
                    }

                    // Assign the model last so `themesChanged` observers see a
                    // fully populated selection state.
                    root.themes = built;
                    root.loaded = built.length > 0;
                    root.loadErrors = [];
                } catch (e) {
                    console.warn("themeswitcher db: parse error", e);
                    root.loadErrors = [String(e)];
                    root.loaded = false;
                }
                root.reloaded();
            }
        }
    }

    Process {
        id: applyProcess
        stdout: StdioCollector { }
        onRunningChanged: {
            if (!running) {
                // After applying, refresh state so highlights move to the new pick.
                root.reload();
            }
        }
    }

    Component.onCompleted: {
        root.reload();
    }
}
