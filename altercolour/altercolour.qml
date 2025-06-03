//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Copyright (c) 2025 Peter Wurmsdobler
//
//  Derived from altercolour.qml which is Copyright (c):
//      2022 Michael Ellis
//  and in turn derived from colournotes.qml which is Copyright (c):
//      2012 Werner Schweer
//      2013-2017 Nicolas Froment, Joachim Schmitz
//      2014 Jörn Eichler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick 2.2
import MuseScore 3.0

MuseScore {
    version: "3.5"
    description: qsTr("colours notes in the selection that are sharped (blue), double-sharped (cyan), flatted (red) or double-flatted (magenta).")
    title: "Colour Alter Notes"
    categoryCode: "colour-notes"
    thumbnailName: "altercolour.png"

    // Define the colours we'll use for various alterations in rrggbb format.
    property string natural: "#000000" // black
    property string doublesharp: "#00ffff" // cyan
    property string sharp: "#0080ff" // blue
    property string flat: "#ff0000" // red
    property string doubleflat: "#ff0080" // magenta

    function getAlterColour(note) {
        // pick a colour based on the tpc value

        // Musescore defines Tonal Pitch Class integers we can use to distinguish
        // altered pitches.  The numbers are conveniently arranged in sequences of
        // consecutive integers grouped by the number of semitones relative to the
        // natural pitch.
        // Here are the values from  https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/tpc.html

        // -1	F♭♭	6	F♭	13	F	20	F♯	27	F♯♯
        // 0	C♭♭	7	C♭	14	C	21	C♯	28	C♯♯
        // 1	G♭♭	8	G♭	15	G	22	G♯	29	G♯♯
        // 2	D♭♭	9	D♭	16	D	23	D♯	30	D♯♯
        // 3	A♭♭	10	A♭	17	A	24	A♯	31	A♯♯
        // 4	E♭♭	11	E♭	18	E	25	E♯	32	E♯♯
        // 5	B♭♭	12	B♭	19	B	26	B♯	33	B♯♯

        var altercolour;
        var n = note.tpc;
        // console.log("note.tpc is " + n)
        if (n < 7)
            altercolour = doubleflat;
        else if (n < 13)
            altercolour = flat;
        else if (n < 20)
            altercolour = natural;
        else if (n < 27)
            altercolour = sharp;
        else if (n < 34)
            altercolour = doublesharp;
        else {
            console.log("ignoring unknown tonal pitch class: " + note.tpc);
            altercolour = natural;
        }
        return altercolour;
    }

    function setNoteColour(note, newColour) {
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
    }

    function applyNoteColour(note) {
        var alterColour = getAlterColour(note);
        console.log("alterColour: " + alterColour);
        setNoteColour(note, alterColour);
    }

    // applyToNotesInSelection is a general purpose function that applies a
    // function to every note in the current selection or to all notes in the
    // score if there is no selection.  In this plugin, we use it to apply the
    // colourNotes function (defined in this file).
    function applyToNotesInSelection(func) {
        var fullScore = !curScore.selection.elements.length;
        if (fullScore) {
            cmd("select-all");
        }
        curScore.startCmd();
        for (var i in curScore.selection.elements)
            if (curScore.selection.elements[i].pitch)
                func(curScore.selection.elements[i]);
        curScore.endCmd();
        if (fullScore) {
            cmd("escape");
        }
    }

    // The onRun action for this plugin.
    onRun: {
        console.log("Hello ColourNonNaturals");
        applyToNotesInSelection(applyNoteColour);
    }
}
