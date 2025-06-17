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
import FileIO
import MuseScore

MuseScore {
    version: "3.5"
    description: qsTr("Basic walk through a score.")
    title: "Basic Muse"
    categoryCode: "notation"
    thumbnailName: "basicmuse.png"
    requiresScore: true
    
    property string outputBuffer: ""

    FileIO {
       id: outfile
       source: tempPath() + "/result.csv"
       onError: console.log("FileIO Error")
    }

    function log(nIndent, message) {
        var s = "\t".repeat(nIndent) + message
        console.log(s);
        outputBuffer += s + "\n";
    }

    onRun: {
        const segmentTypeMap = Object.freeze({
            0: "Invalid",
            1: "BeginBarLine",
            2: "HeaderClef",
            4: "KeySig",
            16: "TimeSig",
            8192: "ChordRest",
            131072: "EndBarLine"
        });

        const accidentalType = new Map([
            [Accidental.NONE, "None"],
            [Accidental.FLAT, "Flat"],
            [Accidental.NATURAL, "Natural"],
            [Accidental.SHARP, "Sharp"],
            [Accidental.SHARP2, "Double Sharp"],
            [Accidental.FLAT2, "Double Flat"],
        ]);

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

        log(0, "Iterating through all measures in score");

        curScore.startCmd();
        var measure = curScore.firstMeasure;
        var measureCount = 0;
        while (measure) {
            log(1, "Measure: " + measureCount);
            var segment = measure.firstSegment;
            while (segment) {
                log(2, "Segment @ t=" + segment.tick + ": " + segmentTypeMap[segment.segmentType]);
                for (var trackIndex = 0; trackIndex < curScore.ntracks; ++trackIndex) {
                    var element = segment.elementAt(trackIndex);
                    if (element) {
                        if (element.type === Element.CHORD) {
                            log(3, "Chord: duration: " 
                                + element.duration.numerator + "/" + element.duration.denominator 
                                + ", ticks: " + element.duration.ticks);
                            for (var noteIndex in element.notes) {
                                var note = element.notes[noteIndex]
                        		var octave = Math.floor(note.pitch / 12) - 1;
                                log(4, "Note: " + tpcNames.get(note.tpc) + octave 
                                    + ", pitch: " + note.pitch  + ", track: " + trackIndex
                                    + ", staff: " + (trackIndex / 4) + ", voice: " + note.voice
                                    + ", accidentalType: " + accidentalType.get(note.accidentalType));
                            }
                        } else if (element.type === Element.REST) {
                            log(3, "Rest: duration: " 
                                + element.duration.numerator + "/" + element.duration.denominator 
                                + ", ticks:," + element.duration.ticks);
                        } else if (element.type === Element.TIMESIG) {
                            log(3, "Timing: " + measure.timesigActual.ticks + ", " 
                                + measure.timesigActual.numerator + "/" + measure.timesigActual.denominator);
                        } else if (element.type === Element.HEADERCLEF) {
                            log(3, "Header clef " + element.clefType + " at staff " + trackIndex/4);
                        } else if (element.type === Element.CLEF) {
                            log(3, "Clef " + element.clefType + " at staff " + trackIndex/4);
                        }
                    }
                }

                segment = segment.nextInMeasure;
            }
            measure = measure.nextMeasure;
            ++measureCount;
        }
        curScore.endCmd();
        outfile.write(outputBuffer);
    }
}
