//=============================================================================
//  MuseScore
//  Music Composition & Notation
// 
//  Helper functions for Clefs
//
//  Copyright (c) 2025 Peter Wurmsdobler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

// Map Treble to their middle note pitch (octaves of B)
//  [23, 35, 47, 59, 71, 83, 95]
export const gClefsToMiddlePitches = new Map([
    ["Clef.G15_MB", 47], // G m basso -> i.e. G2, middle is B2 = 47
    ["Clef.G8_VB", 59],  // G basso   -> i.e. G3, middle is B3 = 59
    ["Clef.G", 71],      //  G normal -> i.e. G4, middle is B4 = 71
    ["Clef.G_VA", 83],   // G alto    -> i.e. G5, middle is B5 = 83
    ["Clef.G_MA", 95],   // G m alto  -> i.e. G6, middle is B6 = 95
]);

// Invert the map
export const middlePitchesToClefs = new Map(
    Array.from(gClefsToMiddlePitches.entries()).map(([key, value]) => [value, key])
);