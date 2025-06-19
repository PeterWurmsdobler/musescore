//=============================================================================
//  MuseScore
//  Music Composition & Notation
// 
//  Optimisation for choosing clefs for a score (for all staves)
//  
//  This algorithm does work out the optimal clef sequence and has two layers:
//  1. a dynamic programming algorithm takes the pitches per measure as an 
//     Array[Array[pitch]] and target reference pitches of possible clefs 
//     (the Bs for G clefs) as well as a factor to weigh clef transitions; 
//     it outputs a sequence of optimal reference pitches;
//  2. helper functions to collect the pitches in the score, build the sequence
//     of pitch groups as Array[Array[pitch]] per staff, call the optimiser, 
//     then try to set the clefs corresponding to the optimal pitches for each staff.
//
//  Copyright (c) 2025 Peter Wurmsdobler
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

// import { log } from "./src/helpers.js";
function log(nIndent, message) {
    var s = "\t".repeat(nIndent) + message;
    console.log(s);
}

const segmentTypeMap = Object.freeze({
    0: "Invalid",
    1: "BeginBarLine",
    2: "HeaderClef",
    4: "KeySig",
    16: "TimeSig",
    8192: "ChordRest",
    131072: "EndBarLine"
});

// Map Treble to their middle note pitch (octaves of B)
//  [23, 35, 47, 59, 71, 83, 95]
const gClefsToMiddlePitches = new Map([
    ["Clef.G15_MB", 47], // G m basso -> i.e. G2, middle is B2 = 47
    ["Clef.G8_VB", 59],  // G basso   -> i.e. G3, middle is B3 = 59
    ["Clef.G", 71],      //  G normal -> i.e. G4, middle is B4 = 71
    ["Clef.G_VA", 83],   // G alto    -> i.e. G5, middle is B5 = 83
    ["Clef.G_MA", 95],   // G m alto  -> i.e. G6, middle is B6 = 95
]);

// Invert the map
const middlePitchesToClefs = new Map(
    Array.from(gClefsToMiddlePitches.entries()).map(([key, value]) => [value, key])
);

function assignReferencePitches(pitchesInMeasures, referencePitches, transitionFactor = 10) {
    // Process the sequence of measures, each as a collection of pitches,
    // and the sequence of reference pitches as well as a transition cost factor.
    // pitchesInMeasures: Array<Array of pitches>
    // referencePitches: Array of reference pitches
    // transitionFactor: Cost factor for changing reference pitches
    // output: Array of reference pitches
    const numMeasures = pitchesInMeasures.length;
    const numReferences = referencePitches.length;

    // Initialize Synamic Programming (DP) table
    const dp = Array.from({ length: numMeasures }, () => Array(numReferences).fill(Infinity));
    const prevRef = Array.from({ length: numMeasures }, () => Array(numReferences).fill(-1));

    // Helper function to calculate the sum of distances
    function calculateDistanceSum(pitches, referencePitch) {
        return pitches.reduce((sum, pitch) => sum + Math.abs(pitch - referencePitch), 0);
    }

    // Initialize the first measure for all reference pitches
    for (let j = 0; j < numReferences; j++) {
        dp[0][j] = calculateDistanceSum(pitchesInMeasures[0], referencePitches[j]);
    }

    // Fill the DP table with cumulative costs measure by measure
    for (let i = 1; i < numMeasures; i++) {
        for (let j = 0; j < numReferences; j++) {
            const currentReference = referencePitches[j];

            // the distance for the current measure to the current reference pitch
            const currentDistance = calculateDistanceSum(pitchesInMeasures[i], currentReference);

            // Given the total accumulated cost per reference pitch in the previous measure,
            // calculate the total cost reaching each reference pitch in the current measure,
            // then work out the minimum cost and the corresponding previous reference pitch
            // and store it in the DP table as well as the previous reference index
            for (let k = 0; k < numReferences; k++) {
                const previousReference = referencePitches[k];
                const transitionCost = transitionFactor * Math.abs(currentReference - previousReference);

                const totalCost = dp[i - 1][k] + currentDistance + transitionCost;

                if (totalCost < dp[i][j]) {
                    dp[i][j] = totalCost;
                    prevRef[i][j] = k;
                }
            }
        }
    }

    // Find the minimum cost in the last measure, the end points for the graph
    let minCost = Infinity;
    let lastRefIndex = -1;
    for (let j = 0; j < numReferences; j++) {
        if (dp[numMeasures - 1][j] < minCost) {
            minCost = dp[numMeasures - 1][j];
            lastRefIndex = j;
        }
    }

    // Backtrack from the last reference to find the reference numbers up to the first measure
    const assignedReferences = [];
    let currentRefIndex = lastRefIndex;
    for (let i = numMeasures - 1; i >= 0; i--) {
        assignedReferences[i] = referencePitches[currentRefIndex];
        currentRefIndex = prevRef[i][currentRefIndex];
    }

    return assignedReferences;
}


function collectPitchesTally() {
    // Collect all note pitches in the current score and return a tally as:
    //   Map<staffIndex, Map<measureIndex, Array<pitches>>>
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
            log(2, "Add tally for staff " + staffIndex + " and measure " + measureIndex);
            var staffTally = pitchesTally.get(staffIndex)
            staffTally.set(measureIndex, []);
        }
        var segment = measure.firstSegment;
        while (segment) {
            log(2, "Segment @ t=" + segment.tick + ": " + segmentTypeMap[segment.segmentType]);
            for (var trackIndex = 0; trackIndex < curScore.ntracks; ++trackIndex) {
                var staffIndex = trackIndex / 4;
                var element = segment.elementAt(trackIndex);
                if (element) {
                    if (element.type === Element.CHORD) {
                        log(3, "Chord: duration: " + element.duration.numerator + "/" + element.duration.denominator + 
                            ", ticks: " + element.duration.ticks);
                        var staffTally = pitchesTally.get(staffIndex)
                        var measureTally = staffTally.get(measureIndex);
                        for (var noteIndex in element.notes) {
                            var note = element.notes[noteIndex];
                            var octave = Math.floor(note.pitch / 12) - 1;
                            measureTally.push(note.pitch);
                            log(4, "Note: " + Note.getTpcName(note.tpc) + octave + 
                                ", pitch: " + note.pitch + ", track: " + trackIndex + 
                                ", staff: " + staffIndex + ", voice: " + note.voice +
                                ", accidental: ", + Note.getAccidentalName(note.accidentalType));
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

function processPitchesTally(pitchesTally, transitionFactor = 2) {
    // Process the collected note pitches and return a Map of staff indices to
    // the sequence of ideal clefs per measure
    // pitchesTally:Map<staffIndex, Map<measureIndex, Array<pitches>>>
    // output: Map<staffIndex, Array<clef>>
    const referencePitches = Array.from(gClefsToMiddlePitches.values());
    var assignedClefsMap = new Map();
    for (const [staff, measures] of pitchesTally.entries()) {
        log(0, "Staff " + staff + ":");
        const measureList = Array.from(measures.values());
        const assignedReferences = assignReferencePitches(measureList, referencePitches, transitionFactor);
        const assignedClefs = assignedReferences.map(pitch => {
            return middlePitchesToClefs.get(pitch);
        });
        assignedClefsMap.set(staff, assignedClefs);
        log(0, "Assigned References:", assignedClefs);
    }

    return assignedClefsMap;
}

function applyAssignedClefs(assignedClefsMap) {
    // Apply the ideal sequence of clefs to the measures in the score
    // assignedClefsMap: Map<staffIndex, Array<clef>>
    for (const [staff, assignedClefs] of assignedClefsMap.entries()) {
        log(0, "Applying reference pitches for staff " + staff);
        var measureIndex = 0;
        var currentClef = ""; // Default clef
        var measure = curScore.firstMeasure;
        while (measure) {
            log(1, "Measure: " + measureIndex);
            var newClef = assignedClefs[measureIndex];
            if (newClef !== currentClef) {
                log(2, "New reference pitch for measure " + measureIndex + ": " + newClef);
                currentClef = newClef;
                var segment = measure.firstSegment;

                // Try to find the clef element in the segments of this measure
                var clef_present = false;
                while (segment) {
                    for (var trackIndex = 0; trackIndex < curScore.ntracks; ++trackIndex) {
                        var element = segment.elementAt(trackIndex);
                        if (element) {
                            if (element.type === Element.HEADERCLEF || element.type === Element.CLEF) {
                                log(3, "Clef " + element.clefType + " at staff " + trackIndex/4);
                                // clefElement.clefType = newClef;
                                // clef_present = true;
                            }
                        }
                    }
                    segment = segment.nextInMeasure;
                }
                if (!clef_present) {
                    // No clef found, create a new clef element
                    log(3, "Creating new clef element for staff " + staff + ": " + newClef);
                    var clefElement = newElement(Element.CLEF);
                    clefElement.clefType = newClef;
                    clefElement.track = staff * 4; // Assuming each staff has 4 tracks
                    // measure.addElement(clefElement);
                }
            }

            measure = measure.nextMeasure;
            ++measureIndex;
        }
    }
}
