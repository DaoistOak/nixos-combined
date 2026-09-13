import QtQuick
import Quickshell
import "."

ShellRoot {
    id: root

    TerminalSwitcher {
        id: switcher
    }

    Connections {
        target: Quickshell
        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }
    }
}