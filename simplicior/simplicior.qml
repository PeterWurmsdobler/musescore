//=============================================================================
//  MuseScore
//  Music Composition & Notation
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
import QtQuick.Dialogs

import MuseScore 3.0
import Muse.Ui
import Muse.UiComponents

import "./src/helpers.js" as Helpers
import "./src/notecolour.js" as NoteColour

MuseScore {
    version: "3.5"
    description: qsTr("A collection of measures to simplify traditional notation.")
    title: "Simplicior Notation"
    categoryCode: "notation"
    thumbnailName: "simplicior.png"
    pluginType: "dialog"
    requiresScore: true
    width: 200
    height: 200

    onRun: {}

    property bool enharmonic: true
    property bool trebleClefOnly: true
    property bool colourCodedNonNaturals: true
    property bool shapeCodedNonNaturals: true
    property color flatColour: "red"
    property color sharpColour: "blue"

    function doApply() {
        console.log("Hello Simplicior");
    // Helpers.applyToNotesInSelection(NoteColour.noteColour);
    }

    ColumnLayout {
        id: main
        spacing: 2

        CheckBox {
            id: enharmonicCheck
            checked: enharmonic
            text: qsTr("Enforce Enharmonics")
        }
        CheckBox {
            id: trebleClefOnlyCheck
            checked: trebleClefOnly
            text: qsTr("Treble Clef Conly")
        }
        CheckBox {
            id: colourCodedNonNaturalsCheck
            checked: colourCodedNonNaturals
            text: qsTr("Colour code non-naturals")
        }
        ColourSelection {
            id: selectionFlat
            theText: qsTr("Flats:")
            theColour: flatColour
        }
        ColourSelection {
            id: selectionSharp
            theText: qsTr("Sharps:")
            theColour: sharpColour
        }
        CheckBox {
            id: shapeCodedNonNaturalsCheck
            checked: shapeCodedNonNaturals
            text: qsTr("Shape code non-naturals")
        }

        FlatButton {
            id: applyButton
            width: 60
            text: qsTr("Apply")
            toolTipTitle: qsTr("Apply simplification")
            onClicked: doApply()
        }
    }
    Settings {
        id: settings
        category: "PluginSimplicior"
        property alias enharmonic: enharmonicCheck.checked
        property alias trebleClefOnly: trebleClefOnlyCheck.checked
        property alias colourCodedNonNaturals: colourCodedNonNaturalsCheck.checked
        property alias shapeCodedNonNaturals: shapeCodedNonNaturalsCheck.checked
        property alias flatColour: selectionFlat.theColour
        property alias sharpColour: selectionSharp.theColour
    }
}
