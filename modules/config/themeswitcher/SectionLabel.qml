import QtQuick
import "."

// Small uppercase section header label (FLAVOUR / ACCENT).
Text {
    required property string label
    text: label
    font.family: "JetBrains Mono"
    font.pixelSize: 10
    font.letterSpacing: 1.5
    color: ThemePalette.onSurfaceVariant
}
