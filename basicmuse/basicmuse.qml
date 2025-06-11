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
import MuseScore 3.0

MuseScore {
    version: "3.5"
    description: qsTr("Basic walk through a score.")
    title: "Basic Muse"
    categoryCode: "notation"
    thumbnailName: "basicmuse.png"
    requiresScore: true

    onRun: {
        var segmentTypeMap = Object.freeze({
         0: "Invalid",
         1: "BeginBarLine",
         2: "HeaderClef",
         4: "KeySig",
         16: "TimeSig",
         8192: "ChordRest",
        131072: "EndBarLine",
      });
        console.log("Iterating through all measures in score");

        curScore.startCmd();
        var measure = curScore.firstMeasure;
        var measureCount = 1;
        while (measure) {
            console.log("measure:");
            var segment = measure.firstSegment;
            while (segment) {
                console.log("S@" + segment.tick + ": " + segmentTypeMap[Number(segment.segmentType)]);

                segment = segment.nextInMeasure;
            }
            measure = measure.nextMeasure;
            ++measureCount;
        }
        curScore.endCmd();
    }
}
