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

RowLayout {
    id: root
    property var shapes // List of shape names
    property string shape // Default shape
    property string title

    spacing: 10 // Space between elements

    Text {
        text: title
    }

    ComboBox {
        id: shapeComboBox
        model: shapes // List of shape names
        currentIndex: shapes.indexOf(shape) // Set the current index based on the shape property

        onCurrentIndexChanged: {
            if (shape !== shapes[currentIndex]) { // Prevent unnecessary updates
                shape = shapes[currentIndex]; // Update the shape property
                console.log("Selected shape:", shape);
                root.shapeChanged(); // Emit the signal to notify the parent
            }
        }

        Component.onCompleted: {
            currentIndex = shapes.indexOf(shape); // Initialize currentIndex when the component is loaded
        }
    }
}
