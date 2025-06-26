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

.import "note.js" as Note
.import "helpers.js" as Helpers
.import "segment.js" as Segment
.import "clef.js" as Clef

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
    var pitchesTally = new Map();
    var measureIndex = 0;
    var measure = curScore.firstMeasure;
    while (measure) {
        Helpers.log(1, "Measure: " + measureIndex);
        var segment = measure.firstSegment;
        while (segment) {
            Helpers.log(2, "Segment @ t=" + segment.tick + ": " + Segment.segmentTypeMap[segment.segmentType]);
            for (var trackIndex = 0; trackIndex < curScore.ntracks; ++trackIndex) {
                var staffIndex = Math.floor(trackIndex / 4);
                // Ensure the inner map exists
                if (!pitchesTally.has(staffIndex)) {
                    pitchesTally.set(staffIndex, new Map());
                }
                var element = segment.elementAt(trackIndex);
                if (element) {
                    if (element.type === Element.CHORD) {
                        Helpers.log(3, "Chord: duration: " + element.duration.numerator + "/" + element.duration.denominator +
                            ", ticks: " + element.duration.ticks);
                        // Ensure the array exists for the measure
                        const staffTally = pitchesTally.get(staffIndex);
                        if (!staffTally.has(measureIndex)) {
                            staffTally.set(measureIndex, []);
                        }
                        for (var noteIndex in element.notes) {
                            var note = element.notes[noteIndex];
                            staffTally.get(measureIndex).push(note.pitch);
                            Note.logNote(note, 4);
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
    // output: Map<staffIndex, Map<measureIndex,clef>>
    const referencePitches = Array.from(Clef.gClefsToMiddlePitches.values());
    var assignedClefsMap = new Map();
    for (const [staff, measures] of pitchesTally.entries()) {
        Helpers.log(0, "Staff " + staff + ":");
        const measureList = Array.from(measures.values());
        const assignedReferences = assignReferencePitches(measureList, referencePitches, transitionFactor);
        const assignedClefsList = assignedReferences.map(pitch => {
            return Clef.middlePitchesToClefs.get(pitch);
        });
        const measureIndices = Array.from(measures.keys());
        const assignedClefs = new Map(measureIndices.map((key, index) => [key, assignedClefsList[index]]));

        assignedClefsMap.set(staff, assignedClefs);
        Helpers.log(0, "Assigned References:", assignedClefs);
    }

    return assignedClefsMap;
}

function _findClefElementInMeasure(measure, staffIndex) {
    // Find the clef element in the measure for the given staff index
    var segment = measure.firstSegment;
    while (segment) {
        for (var trackIndex = 0; trackIndex < curScore.ntracks; ++trackIndex) {
            var currentStaffIndex = Math.floor(trackIndex / 4);
            if (currentStaffIndex === staffIndex) {
                var element = segment.elementAt(trackIndex);
                if (element) {
                    if (element.type == Element.HEADERCLEF || element.type == Element.CLEF) {
                        Helpers.log(2, "Clef " + element.clefType + " found");
                        return element
                    }
                }
            }
        }
        segment = segment.nextInMeasure;
    }
    return null;
}

function applyAssignedClefs(assignedClefsMap) {
    // Apply the ideal sequence of clefs to the measures in the score
    // assignedClefsMap: Map<staffIndex, Map<measureIndex,clef>>
    for (const [staff, assignedClefs] of assignedClefsMap.entries()) {
        Helpers.log(0, "Applying reference pitches for staff " + staff);
        var measureIndex = 0;
        var currentClef = ""; // Default clef
        var measure = curScore.firstMeasure;
        while (measure) {
            Helpers.log(1, "Measure: " + measureIndex);

            // Try to find the clef element in the measure
            var clef_element = _findClefElementInMeasure(measure, staff);
            
            // If there is a new clef assigned for this measure, update or create the clef element
            if (assignedClefs.has(measureIndex)) {
                var newClef = assignedClefs.get(measureIndex);
                if (newClef !== currentClef) {
                    Helpers.log(2, "New clef at measure " + measureIndex + ": " + newClef);
                    currentClef = newClef;
                    if (clef_element == null) {
                        // No clef found, create a new clef element
                        Helpers.log(3, "Creating new clef element: " + newClef);
                        // var clefElement = newElement(Element.CLEF);
                        // clefElement.clefType = newClef;
                        // TODO: add once API permitts
                        // measure.addElement(clefElement);
                    }
                    else {
                        Helpers.log(3, "Assigning clef element to: " + newClef);
                        // TODO: assign once API permitts
                        // clef_element.clefType = newClef;
                    }
                }
            } else {
                // If there is no new clef assigned for this measure and the clef element exists:
                if (clef_element != null) {
                    if (clef_element.type == Element.HEADERCLEF) {
                        Helpers.log(3, "Assigning clef element to: " + currentClef);
                        // TODO: assign once API permitts
                        // clef_element.clefType = currentClef;
                    }
                    else {
                        Helpers.log(3, "Removing clef element: " + clef_element.clefType);
                        // TODO: remove the clef element if it exists
                    }
                }
            }

            measure = measure.nextMeasure;
            ++measureIndex;
        }
    }
}
