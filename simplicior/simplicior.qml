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

import MuseScore 3.0
import Muse.Ui
import Muse.UiComponents

import "./src/tpc.js" as Tpc
import "./src/note.js" as Note
import "./src/helpers.js" as Helpers

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

    function processNote(note) {
        if (enharmonic) {
            Tpc.forceEnharmonic(note);
        }
        if (Tpc.isFlat(note)) {
            if (colourCodedNonNaturals)
                Note.setColour(note, flatColour);
            if (shapeCodedNonNaturals)
                Note.setShape(note, "flat");
        } else if (Tpc.isSharp(note)) {
            if (colourCodedNonNaturals)
                Note.setColour(note, sharpColour);
            if (shapeCodedNonNaturals)
                Note.setShape(note, "sharp");
        }
    }

    function doApply() {
        console.log("Hello Simplicior");
        Helpers.applyToNotesInSelection(processNote);
    }

    function listNotesInAllMeasures() {
        if (!curScore) {
            console.log("No score is open.");
            return;
        }

        console.log("Iterating through all measures in all staves...");

        // Iterate through all staves in the score
        for (let staffIndex = 0; staffIndex < curScore.staves.length; staffIndex++) {
            let staff = curScore.staves[staffIndex];
            console.log("Staff " + (staffIndex + 1) + ":");

            // Iterate through all measures in the staff
            for (let measureIndex = 0; measureIndex < staff.measures.length; measureIndex++) {
                let measure = staff.measures[measureIndex];
                console.log("  Measure " + (measureIndex + 1) + ":");

                // Iterate through all elements in the measure
                for (let elementIndex = 0; elementIndex < measure.elements.length; elementIndex++) {
                    let element = measure.elements[elementIndex];

                    // Check if the element is a note
                    if (element.type === Element.Note) {
                        console.log("    Note: pitch=" + element.pitch + ", duration=" + element.duration);
                    }
                }
            }
        }
    }


    ColumnLayout {
        id: main
        spacing: 2

        Button {
            text: qsTr("List Notes in All Measures")
            onClicked: listNotesInAllMeasures()
        }
        CheckBox {
            id: enharmonicCheck
            checked: enharmonic
            text: qsTr("Enforce Enharmonics")
            onClicked: {enharmonicCheck.checked = !enharmonicCheck.checked}
            onCheckedChanged: enharmonic = checked
        }
        CheckBox {
            id: trebleClefOnlyCheck
            checked: trebleClefOnly
            text: qsTr("Treble Clef Only")
            onClicked: {trebleClefOnlyCheck.checked = !trebleClefOnlyCheck.checked}
            onCheckedChanged: trebleClefOnly = checked
        }
        CheckBox {
            id: colourCodedNonNaturalsCheck
            checked: colourCodedNonNaturals
            text: qsTr("Colour code non-naturals")
            onClicked: {colourCodedNonNaturalsCheck.checked = !colourCodedNonNaturalsCheck.checked}
            onCheckedChanged: colourCodedNonNaturals = checked
        }
        ColourSelection {
            id: selectionFlat
            title: qsTr("Flats:")
            colour: flatColour
            enabled: colourCodedNonNaturals
        }
        ColourSelection {
            id: selectionSharp
            title: qsTr("Sharps:")
            colour: sharpColour
            enabled: colourCodedNonNaturals
        }
        CheckBox {
            id: shapeCodedNonNaturalsCheck
            checked: shapeCodedNonNaturals
            text: qsTr("Shape code non-naturals")
            onClicked: {shapeCodedNonNaturalsCheck.checked = !shapeCodedNonNaturalsCheck.checked}
            onCheckedChanged: shapeCodedNonNaturals = checked
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
        property alias flatColour: selectionFlat.colour
        property alias sharpColour: selectionSharp.colour
    }
}
