pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Reads the persisted default-terminal state that launch-terminal.sh consumes
// and exposes the apply action that persists a new selection (no rebuild, next
// launch picks it up). Mirrors the themeswitcher's ThemeDb.
Singleton {
    id: root

    readonly property string statePath: "$HOME/.config/hypr/.default-terminal"
    readonly property string defaultTerminal: "ghostty"

    property var terminals: [
        { key: "ghostty", title: "Ghostty", desc: "Fast GPU-native terminal" },
        { key: "wezterm", title: "WezTerm", desc: "GPU terminal · tmux shell" },
        { key: "alacritty", title: "Alacritty", desc: "Lightweight GPU terminal" },
        { key: "kitty", title: "Kitty", desc: "GPU terminal" }
    ]
    property string current: root.defaultTerminal
    property bool loaded: false
    property bool applying: false

    function byKey(k) {
        const kl = (k ?? "").toLowerCase();
        return root.terminals.find(t => (t.key ?? "").toLowerCase() === kl) ?? null;
    }

    function apply(key) {
        const t = root.byKey(key);
        if (!t || root.applying)
            return;
        root.applying = true;
        applyProcess.command = [
            "sh", "-lc",
            `printf '%s\n' "${t.key}" > "${root.statePath}" && notify-send "Default terminal" "Set to ${t.title} (applies on next launch)"`
        ];
        applyProcess.running = true;
    }

    function reload() {
        loadState.running = true;
    }

    Process {
        id: loadState
        command: ["sh", "-lc", `cat "${root.statePath}" 2>/dev/null || true`]
        stdout: StdioCollector {
            id: stateCollector
            onStreamFinished: {
                const v = stateCollector.text.trim();
                root.current = root.byKey(v) ? root.byKey(v).key : root.defaultTerminal;
                root.loaded = true;
            }
        }
    }

    Process {
        id: applyProcess
        stdout: StdioCollector { }
        onRunningChanged: {
            if (!running) {
                root.applying = false;
                root.reload();
            }
        }
    }

    Component.onCompleted: {
        root.reload();
    }
}