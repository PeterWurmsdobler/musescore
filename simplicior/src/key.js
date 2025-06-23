//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Helper functions for Keys
//
//  Copyright (c) 2025 Peter Wurmsdobler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

.import "helpers.js" as Helpers

function setAtonalKeySignature() {
    Helpers.log(0, "Setting atonal key signature");
    var measureIndex = 0;
    var measure = curScore.firstMeasure;
    while (measure) {
        Helpers.log(1, "Measure: " + measureIndex);
        var segment = measure.firstSegment;
        while (segment) {
            for (var trackIndex = 0; trackIndex < curScore.ntracks; ++trackIndex) {
                var element = segment.elementAt(trackIndex);
                if (element) {
                    if (element.type === Element.KEYSIG) {
                        Helpers.log(2, "Key " + element.key + " at measure " + measureIndex + " at staff " + trackIndex / 4);
                        if (element.key !== 12) {
                            Helpers.log(3, "Setting atonal key signature");
                            // TODO: assign once API permitts
                            //element.key = 12;
                        }
                    }
                }
            }

            segment = segment.nextInMeasure;
        }
        measure = measure.nextMeasure;
        ++measureIndex;
    }
}