import QtQuick
import Quickshell
import "."

ShellRoot {
    id: root

    ThemeSwitcher {
        id: switcher
    }

    Connections {
        target: Quickshell
        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }
    }
}
