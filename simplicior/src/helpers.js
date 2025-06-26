//=============================================================================
//  MuseScore
//  Music Composition & Notation
// 
//  General helper functions
//
//  Copyright (c) 2025 Peter Wurmsdobler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

// applyToNotesInSelection is a general purpose function that applies a
// function to every note in the current selection or to all notes in the
// score if there is no selection.  
function applyToNotesInSelection(func, arg) {
    curScore.startCmd();
    
    var selectionWasEmpty = (curScore.selection.elements.length == 0);
    if (selectionWasEmpty) {
        console.log("selectionWasEmpty, selecting all notes");
        curScore.selection.selectRange(0, curScore.lastSegment.tick + 1, 0, curScore.nstaves);
    }
    console.log("Applying function to all elements");
    for (var i in curScore.selection.elements)
        if (curScore.selection.elements[i].type == Element.NOTE)
            func(curScore.selection.elements[i], arg);

    if (selectionWasEmpty) {
        console.log("selectionWasEmpty, clearing selection");
        curScore.selection.clear(); // Clear the selection after applying the function
    }
    curScore.endCmd();
}

function log(nIndent, message) {
    var s = "\t".repeat(nIndent) + message;
    console.log(s);
}
