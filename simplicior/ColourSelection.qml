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
import QtQuick.Dialogs // Import for ColorDialog

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
            colorDialog.open(); // Open the color dialog when the button is clicked
        }       
    }

    ColorDialog {
        id: colorDialog
        title: qsTr("Select a Colour")
        onAccepted: {
            colour = colorDialog.color; // Update the colour property with the selected color
        }
    }
}
