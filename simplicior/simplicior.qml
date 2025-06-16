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
import "./src/clef.js" as Clef
import "./src/helpers.js" as Helpers
import "./src/segment.js" as Segment
import "./src/optimisation.js" as Optimisation

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

    property bool enforceEnharmonic: true
    property bool trebleClefOnly: true
    property bool colourCodedNonNaturals: true
    property bool shapeCodedNonNaturals: true
    property color flatColour: "red"
    property color sharpColour: "blue"

    function log(nIndent, message) {
        var s = "\t".repeat(nIndent) + message;
        console.log(s);
    }

    function collectPitchesTally() {
        // Collect all note pitches in the current score and return a tally as:
        //   Map<staffIndex, Map<measureIndex, Array of pitches>>
        var nStaves = curScore.ntracks / 4;
        var pitchesTally = new Map();
        for (var staffIndex = 0; staffIndex < nStaves; ++staffIndex) {
            pitchesTally.set(staffIndex, new Map());
        }
        var measureIndex = 0;
        var measure = curScore.firstMeasure;
        while (measure) {
            log(1, "Measure: " + measureIndex);
            for (var staffIndex = 0; staffIndex < nStaves; ++staffIndex) {
                pitchesTally.get(staffIndex).set(measureIndex, []);
            }
            var segment = measure.firstSegment;
            while (segment) {
                log(2, "Segment @ t=" + segment.tick + ": " + Segment.segmentTypeMap[segment.segmentType]);
                for (var trackIndex = 0; trackIndex < curScore.ntracks; ++trackIndex) {
                    var staffIndex = trackIndex / 4;
                    var element = segment.elementAt(trackIndex);
                    if (element) {
                        if (element.type === Element.CHORD) {
                            log(3, "Chord: duration: " + element.duration.numerator + "/" + element.duration.denominator + ", ticks: " + element.duration.ticks);
                            for (var noteIndex in element.notes) {
                                var note = element.notes[noteIndex];
                                var octave = Math.floor(note.pitch / 12) - 1;
                                pitchesTally.get(staffIndex).get(measureIndex).push(note.pitch);
                                log(4, "Note: " + Tpc.tpcNames.get(note.tpc) + octave + ", pitch: " + note.pitch + ", track: " + trackIndex + ", staff: " + staffIndex + ", voice: " + note.voice);
                            }
                        }
                    }
                }

                segment = segment.nextInMeasure;
            }
            measure = measure.nextMeasure;
            ++measureIndex;
        }
        return pitchesTally;
    }

    function processPitchesTally(pitchesTally) {
        // Process the collected note pitches and return a Map of staff indices to
        // the sequence of ideal clefs per measure
        // pitchesTally: Map<staffIndex, Map<measureIndex, Array of pitches>>
        // output: Map<staffIndex, Array of clefs>
        const referencePitches = Array.from(Clef.gClefsToMiddlePitches.values());
        var assignedClefsMap = new Map();
        for (const [staff, measures] of pitchesTally.entries()) {
            console.log("Staff " + staff + ":");
            const measureList = Array.from(measures.values());
            const transitionFactor = 2;//; // Factor to determine how strong a transition should be penalised
            const assignedReferences = Optimisation.assignReferencePitches(measureList, referencePitches, transitionFactor);
            const assignedClefs = assignedReferences.map(pitch => {
                return Clef.middlePitchesToClefs.get(pitch);
            });
            assignedClefsMap.set(staff, assignedClefs);
            console.log("Assigned References:", assignedClefs);
        }

        return assignedClefsMap;
    }

    function applyAssignedClefs(assignedClefsMap) {
        // Apply the ideal sequenc of clefs to the measures in the score
        // assignedClefsMap: Map<staffIndex, Array of clefs>
        for (const [staff, assignedClefs] of assignedClefsMap.entries()) {
            console.log("Applying reference pitches for staff " + staff);
            var measureIndex = 0;
            var currentClef = ""; // Default clef
            var measure = curScore.firstMeasure;
            while (measure) {
                log(1, "Measure: " + measureIndex);
                var newClef = assignedClefs[measureIndex];
                if (newClef !== currentClef) {
                    log(2, "New reference pitch for measure " + measureIndex + ": " + newClef);
                    currentClef = newClef;
                    // TODO: apply clef to measure
                }

                measure = measure.nextMeasure;
                ++measureIndex;
            }
        }
    }

    function processNote(note) {
        if (enforceEnharmonic) {
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
        if (trebleClefOnly) {
            var pitchesTally = collectPitchesTally();
            var assignedClefsMap = processPitchesTally(pitchesTally);
            applyAssignedClefs(assignedClefsMap);
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
            }
        }
        CheckBox {
            id: colourCodedNonNaturalsCheck
            checked: colourCodedNonNaturals
            text: qsTr("Colour code non-naturals")
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
            text: qsTr("Shape code non-naturals")
            onClicked: {
                shapeCodedNonNaturals = !shapeCodedNonNaturals;
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
        property alias flatColour: selectionFlat.colour
        property alias sharpColour: selectionSharp.colour
    }
}
