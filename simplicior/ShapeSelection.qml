//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  A hape Selection widget
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

import "./src/note.js" as Note

RowLayout {
    id: root
    property var shapes: Note.noteHeadShapes // List of shape names
    property string shape: Note.noteHeadShapes[0] // Default shape
    property string title: "Select Shape"

    spacing: 10 // Space between elements

    Text {
        text: title
    }

    ComboBox {
        id: shapeComboBox
        model: shapes // List of shape names
        currentIndex: model.indexOf(shape) // Set the current index based on the shape property
        onCurrentIndexChanged: {
            shape = model[currentIndex]; // Update the shape property when selection changes
            console.log("Selected shape:", shape);
        }
    }
}
