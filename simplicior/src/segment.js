//=============================================================================
//  MuseScore
//  Music Composition & Notation
// 
//  Helper functions for Segments
//
//  Copyright (c) 2025 Peter Wurmsdobler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================
export const segmentTypeMap = Object.freeze({
    0: "Invalid",
    1: "BeginBarLine",
    2: "HeaderClef",
    4: "KeySig",
    16: "TimeSig",
    8192: "ChordRest",
    131072: "EndBarLine"
});
