//=============================================================================
//  MuseScore
//  Music Composition & Notation
// 
//  Helper functions for Notes
//
//  Copyright (c) 2025 Peter Wurmsdobler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

.import "helpers.js" as Helpers

function getAccidentalName(accidental) {
    // Return the name of the accidental, or "Unknown" if not found
    // Map the accidental to names
    const accidentalType = new Map([
        [Accidental.NONE, "None"],
        [Accidental.FLAT, "Flat"],
        [Accidental.NATURAL, "Natural"],
        [Accidental.SHARP, "Sharp"],
        [Accidental.SHARP2, "Double Sharp"],
        [Accidental.FLAT2, "Double Flat"],
    ]);
    return accidentalType.get(accidental) || "Unknown";
}

// Musescore defines Tonal Pitch Class integers we can use to distinguish
// altered pitches.  The numbers are conveniently arranged in sequences of
// consecutive integers grouped by the number of semitones relative to the
// natural pitch.
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/tpc.html
// -1  F♭♭     6  F♭    13  F    20  F♯    27  F♯♯
//  0  C♭♭     7  C♭    14  C    21  C♯    28  C♯♯
//  1  G♭♭     8  G♭    15  G    22  G♯    29  G♯♯
//  2  D♭♭     9  D♭    16  D    23  D♯    30  D♯♯
//  3  A♭♭    10  A♭    17  A    24  A♯    31  A♯♯
//  4  E♭♭    11  E♭    18  E    25  E♯    32  E♯♯
//  5  B♭♭    12  B♭    19  B    26  B♯    33  B♯♯


function isFlat(note) {
    return (note.tpc >= 6) && (note.tpc <= 12)
}

function isSharp(note) {
    return (note.tpc >= 20) && (note.tpc <= 26)
}


function getTpcName(tpc) {
    // Return the name of the TPC, or "Unknown" if not found
    // Map the note's tonal pitch class to names
    const tpcNames = new Map([
        [-1, "F♭♭"],
        [0, "C♭♭"],
        [1, "G♭♭"],
        [2, "D♭♭"],
        [3, "A♭♭"],
        [4, "E♭♭"],
        [5, "B♭♭"],
        [6, "F♭"],
        [7, "C♭"],
        [8, "G♭"],
        [9, "D♭"],
        [10, "A♭"],
        [11, "E♭"],
        [12, "B♭"],
        [13, "F"],
        [14, "C"],
        [15, "G"],
        [16, "D"],
        [17, "A"],
        [18, "E"],
        [19, "B"],
        [20, "F♯"],
        [21, "C♯"],
        [22, "G♯"],
        [23, "D♯"],
        [24, "A♯"],
        [25, "E♯"],
        [26, "B♯"],
        [27, "F♯♯"],
        [28, "C♯♯"],
        [29, "G♯♯"],
        [30, "D♯♯"],
        [31, "A♯♯"],
        [32, "E♯♯"],
        [33, "B♯♯"],
    ]);
    return tpcNames.get(tpc) || "Unknown";
}


function applyMap(map, note) {
    var oldtpc = note.tpc;
    if (map.has(oldtpc)) {
        var newtpc = map.get(oldtpc)
        if (newtpc != oldtpc) {
            note.tpc = newtpc;
            console.log("Changed " + getTpcName(oldtpc) + " to " + getTpcName(newtpc))
        }
    }
}

// Replace TPC with enharmonically simpler TPC
function forceEnharmonic(note) {
    // Map double sharps/flats to their simpler versions,e.g. F♭♭ -> E♭
    // as well as map some sharps/flats to their base, e.g. F♭ -> E.
    const simplificationMap = new Map([
        [-1, 11], // F♭♭ -> E♭
        [0, 12], // C♭♭ -> B♭
        [1, 13], // G♭♭ -> F
        [2, 14], // D♭♭ -> C
        [3, 15], // A♭♭ -> G
        [4, 16], // E♭♭ -> D
        [5, 17], // B♭♭ -> A
        [27, 15], // F♯♯ -> G
        [28, 16], // C♯♯ -> D
        [29, 17], // G♯♯ -> A
        [30, 18], // D♯♯ -> E
        [31, 19], // A♯♯ -> B
        [32, 20], // E♯♯ -> F♯
        [33, 21], // B♯♯ -> C♯
        [6, 18], // F♭ -> E
        [7, 19], // C♭ -> B
        [25, 13], // E♯ -> F
        [26, 14], // B♯ -> C
    ]);
    applyMap(simplificationMap, note)
}

// Replace TPC for flats with enharmonically equivalent TPC as sharp
function sharpen(note) {
    // Map flats to their enharmonic sharp equivalents
    const flatToSharpMap = new Map([
        [8, 20], // G♭ -> F♯
        [9, 21], // D♭ -> C♯
        [10, 22], // A♭ -> G♯
        [11, 23], // E♭ -> D♯
        [12, 24], // B♭ -> A♯
    ]);
    applyMap(flatToSharpMap, note)
}

// Replace TPC for sharps with enharmonically equivalent TPC as flats
function flatten(note) {
    // Map sharps to their enharmonic flat equivalents
    const sharpToFlatMap = new Map([
        [20, 8], // F♯ -> G♭
        [21, 9], // C♯ -> D♭
        [22, 10], // G♯ -> A♭
        [23, 11], // D♯ -> E♭
        [24, 12], // A♯ -> B♭
    ]);
    applyMap(sharpToFlatMap, note)
}

function setColour(note, newColour) {
    //set the note colour
    note.color = newColour;

    // colour the accidental, if any
    if (note.accidental) {
        note.accidental.color = newColour;
    }
    // colour the dots, if any
    if (note.dots) {
        for (var i = 0; i < note.dots.length; i++) {
            if (note.dots[i]) {
                note.dots[i].color = newColour;
            }
        }
    }
    console.log("setColour: " + newColour);
}

function setShape(note, newShape, vOffset) {
    //set the note shape
    // note.headScheme = NoteHead.Scheme.HEAD_SOLFEGE
    if (newShape === "▲") {
        note.headGroup = 5 //NoteHead.Group.??
    }
    else if (newShape === "▼") {
        note.headGroup = 6 //NoteHead.Group.??
    }
    else if (newShape === "◆") {
        note.headGroup = 9 //NoteHead.Group.??
    }
    else if (newShape === "▬") {
        note.headGroup = 18 //NoteHead.Group.HEAD_LA; // Square
    }
    note.offsetY = vOffset;
    console.log("setShape: " + newShape);
}

function setNoAccidentalSymbol(note) {
    //set the note accidental to none
    note.accidentalType = Accidental.NONE;
}

// Define a class with two fields
class NoteConfig {
    constructor(
        flatColour,
        sharpColour,
        flatShape,
        sharpShape,
        flatOffset,
        sharpOffset,
        enforceEnharmonic,
        noAccidentalSymbols) {
        this.flatColour = flatColour;
        this.sharpColour = sharpColour;
        this.flatShape = flatShape;
        this.sharpShape = sharpShape;
        this.flatOffset = flatOffset;
        this.sharpOffset = sharpOffset;
        this.enforceEnharmonic = enforceEnharmonic;
        this.noAccidentalSymbols = noAccidentalSymbols;
    }
}

function logNote(note, indent) {
    var octave = Math.floor(note.pitch / 12) - 1;
    var staffIndex = Math.floor(note.track / 4);
    Helpers.log(indent, "Note: " + getTpcName(note.tpc) + octave +
        ", pitch: " + note.pitch + ", track: " + note.track +
        ", staff: " + staffIndex + ", voice: " + note.voice +
        ", head Group: " + note.headGroup + ", headScheme: " + note.headScheme +
        ", accidental: ", + getAccidentalName(note.accidentalType));
}


function processNote(note, config) {
    if (config.enforceEnharmonic) {
        forceEnharmonic(note);
    }
    if (isFlat(note)) {
        if (config.flatColour)
            setColour(note, config.flatColour);
        if (config.flatShape)
            setShape(note, config.flatShape, config.flatOffset);
        if (config.noAccidentalSymbols && (config.sharpColour || config.sharpShape)) {
            setNoAccidentalSymbol(note);
        }
    } else if (isSharp(note)) {
        if (config.sharpColour)
            setColour(note, config.sharpColour);
        if (config.sharpShape)
            setShape(note, config.sharpShape, config.sharpOffset);
        if (config.noAccidentalSymbols && (config.sharpColour || config.sharpShape)) {
            setNoAccidentalSymbol(note);
        }
    }
}
