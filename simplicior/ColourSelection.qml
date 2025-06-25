//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  A ColourSelection widget
//
//  Copyright (c) 2025 Peter Wurmsdobler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================
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
        onClicked: {
            colorPopup.open(); // Open the custom color selection popup
        }
    }

    Popup {
        id: colorPopup
        modal: true
        focus: true
        width: 200
        height: 200
        Rectangle {
            width: parent.width
            height: parent.height
            color: "white"
            ColumnLayout {
                spacing: 10
                Text {
                    text: qsTr("Select a Color")
                }
                Slider {
                    id: redSlider
                    from: 0
                    to: 255
                    value: Qt.rgba(colour.r, colour.g, colour.b, colour.a).r * 255
                    onValueChanged: {
                        colour = Qt.rgba(redSlider.value / 255, colour.g, colour.b, colour.a);
                    }
                }
                Slider {
                    id: greenSlider
                    from: 0
                    to: 255
                    value: Qt.rgba(colour.r, colour.g, colour.b, colour.a).g * 255
                    onValueChanged: {
                        colour = Qt.rgba(colour.r, greenSlider.value / 255, colour.b, colour.a);
                    }
                }
                Slider {
                    id: blueSlider
                    from: 0
                    to: 255
                    value: Qt.rgba(colour.r, colour.g, colour.b, colour.a).b * 255
                    onValueChanged: {
                        colour = Qt.rgba(colour.r, colour.g, blueSlider.value / 255, colour.a);
                    }
                }
                Rectangle {
                    id: resultField
                    width: 200
                    height: 20
                    color: colour
                }
                Button {
                    text: qsTr("Done")
                    onClicked: {
                        colorPopup.close(); // Close the popup
                        root.colourChanged(colour); // Emit the signal to notify the parent
                    }
                }
            }
        }
    }
}
