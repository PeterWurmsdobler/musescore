//=============================================================================
//  MuseScore
//  Music Composition & Notation
// 
//  The simplicior plugin that allows simplification of a score
//  - only use one clef class per staff
//  - enforce enharmonic spelling
//  - colour encode non-naturals
//  - shape encode non-naturals
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

import "./src/key.js" as Key
import "./src/note.js" as Note
import "./src/helpers.js" as Helpers
import "./src/clef_optimisation.js" as ClefOptimisation


MuseScore {
    version: "3.5"
    description: qsTr("A collection of measures to simplify traditional notation.")
    title: "Simplicior Notation"
    categoryCode: "notation"
    thumbnailName: "simplicior.png"
    pluginType: "dialog"
    requiresScore: true
    width: 300
    height: 300

    onRun: {}

    property bool enforceEnharmonic: true
    property bool trebleClefOnly: true
    property bool colourCodedNonNaturals: true
    property bool shapeCodedNonNaturals: true
    property bool noAccidentalSymbols: false
    property color flatColour: "red"
    property color sharpColour: "blue"


    function doApply() {
        console.log("Hello Simplicior");
        if (noAccidentalSymbols) {
            Key.setAtonalKeySignature()
        }   
        const settings = new Note.NoteConfig(
            flatColour,
            sharpColour,
            enforceEnharmonic,
            trebleClefOnly,
            colourCodedNonNaturals,
            shapeCodedNonNaturals,
            noAccidentalSymbols,
        );
        Helpers.applyToNotesInSelection(Note.processNote, settings);
        if (trebleClefOnly) {
            var pitchesTally = ClefOptimisation.collectPitchesTally();
            const transitionFactor = trebleClefSlider.value;
            var assignedClefsMap = ClefOptimisation.processPitchesTally(pitchesTally, transitionFactor);
            ClefOptimisation.applyAssignedClefs(assignedClefsMap);
        }
    }

    ColumnLayout {
        id: main
        spacing: 2

        CheckBox {
            id: enforceEnharmonicCheck
            checked: enforceEnharmonic
            text: qsTr("Enforce Enharmonics")
            onClicked: {
                enforceEnharmonic = !enforceEnharmonic;
            }
        }
        CheckBox {
            id: trebleClefOnlyCheck
            checked: trebleClefOnly
            text: qsTr("Treble Clef Only")
            onClicked: {
                trebleClefOnly = !trebleClefOnly;
                trebleClefSlider.enabled = trebleClefOnly
            }
        }
        Text {
            text: qsTr("Cost of clef transitions") 
        }
        RowLayout {
            spacing: 10
            Text {
                text: qsTr("No cost") 
            }
            Slider {
                id: trebleClefSlider
                from: 0
                to: 10
                value: 5 // Default value
                stepSize: 0.1 
                onValueChanged: {
                    console.log("Slider value:", value);
                }
            }
            Text {
                text: qsTr("Max cost") 
            }
        }        
        CheckBox {
            id: colourCodedNonNaturalsCheck
            checked: colourCodedNonNaturals
            text: qsTr("Colour coded non-naturals")
            onClicked: {
                colourCodedNonNaturals = !colourCodedNonNaturals;
            }
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
            text: qsTr("Shape coded non-naturals")
            onClicked: {
                shapeCodedNonNaturals = !shapeCodedNonNaturals;
                noAccidentalSymbolsCheck.enabled = shapeCodedNonNaturals
                noAccidentalSymbols = shapeCodedNonNaturals && noAccidentalSymbols;
            }
        }
        CheckBox {
            id: noAccidentalSymbolsCheck
            checked: noAccidentalSymbols
            text: qsTr("No accidental symbols")
            onClicked: {
                noAccidentalSymbols = !noAccidentalSymbols;
            }
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
        property alias enforceEnharmonic: enforceEnharmonicCheck.checked
        property alias trebleClefOnly: trebleClefOnlyCheck.checked
        property alias colourCodedNonNaturals: colourCodedNonNaturalsCheck.checked
        property alias shapeCodedNonNaturals: shapeCodedNonNaturalsCheck.checked
        property alias noAccidentalSymbols: noAccidentalSymbolsCheck.checked
        property alias flatColour: selectionFlat.colour
        property alias sharpColour: selectionSharp.colour
    }
}
