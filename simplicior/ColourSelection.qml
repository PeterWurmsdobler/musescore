import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property color colour
    property string title
    Text {
        text: title
    }
    Rectangle {
        id: colourField
        width: 50
        height: 20
        color: colour
    }
    Button {
        id: selectButton
        width: 10
        height: 20
        text: "V"
    }
}
