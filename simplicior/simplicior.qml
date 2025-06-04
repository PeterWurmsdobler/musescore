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

    // The onRun action for this plugin.
    onRun: {
        console.log("Hello Simplicior");
        Helpers.applyToNotesInSelection(NoteColour.noteColour);
    }
}
