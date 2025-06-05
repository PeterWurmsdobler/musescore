import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property color theColour
    property string theText
    Text {
        text: theText
    }
    Rectangle {
        id: colourField
        width: 50
        height: 20
        color: theColour
    }
    Button {
        id: selectButton
        width: 10
        height: 20
        text: "V"
    }
}
