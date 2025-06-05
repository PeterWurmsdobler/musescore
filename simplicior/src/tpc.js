// Musescore defines Tonal Pitch Class integers we can use to distinguish
// altered pitches.  The numbers are conveniently arranged in sequences of
// consecutive integers grouped by the number of semitones relative to the
// natural pitch.
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/tpc.html
// -1  F♭♭     6  F♭    13  F    20  F♯    27  F♯♯
//  0  C♭♭     7  C♭    14  C    21  C♯    28  C♯♯
//  1  G♭♭     8  G♭    15  G    22  G♯    29  G♯♯
//  2  D♭♭     9  D♭    16  D    23  D♯    30  D♯♯
//  3  A♭♭    10  A♭    17  A    24  A♯    31  A♯♯
//  4  E♭♭    11  E♭    18  E    25  E♯    32  E♯♯
//  5  B♭♭    12  B♭    19  B    26  B♯    33  B♯♯


function isFlat(note) {
    return (note.tpc >= 6) && (note.tpc <= 12)
}

function isSharp(note) {
    return (note.tpc >= 20) && (note.tpc <= 26)
}

// Map the note's tonal pitch class to names
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

// Map double sharps/flats to their simpler versions,e.g. F♭♭ -> E♭
// as well as map some sharps/flats to their base, e.g. F♭ -> E.
const simplificationMap = new Map([
    [-1, 11], // F♭♭ -> E♭
    [0, 12], // C♭♭ -> B♭
    [1, 13], // G♭♭ -> F
    [2, 14], // D♭♭ -> C
    [3, 15], // A♭♭ -> G
    [4, 16], // E♭♭ -> D
    [5, 17], // B♭♭ -> A
    [27, 15], // F♯♯ -> G
    [28, 16], // C♯♯ -> D
    [29, 17], // G♯♯ -> A
    [30, 18], // D♯♯ -> E
    [31, 19], // A♯♯ -> B
    [32, 20], // E♯♯ -> F♯
    [33, 21], // B♯♯ -> C♯
    [6, 18], // F♭ -> E
    [7, 19], // C♭ -> B
    [25, 13], // E♯ -> F
    [26, 14], // B♯ -> C
]);

// Map flats to their enharmonic sharp equivalents
const flatToSharpMap = new Map([
    [8, 20], // G♭ -> F♯
    [9, 21], // D♭ -> C♯
    [10, 22], // A♭ -> G♯
    [11, 23], // E♭ -> D♯
    [12, 24], // B♭ -> A♯
]);

// Map sharps to their enharmonic flat equivalents
const sharpToFlatMap = new Map([
    [20, 8], // F♯ -> G♭
    [21, 9], // C♯ -> D♭
    [22, 10], // G♯ -> A♭
    [23, 11], // D♯ -> E♭
    [24, 12], // A♯ -> B♭
]);

function applyMap(map, note) {
    var oldtpc = note.tpc;
    if (map.has(oldtpc)) {
        var newtpc = map.get(oldtpc)
        if (newtpc != oldtpc) {
            note.tpc = newtpc;
            console.log("Changed " + tpcNames.get(oldtpc) + " to " + tpcNames.get(newtpc))
        }
    }
}

// Replace TPC with enharmonically simpler TPC
function forceEnharmonic(note) {
    applyMap(simplificationMap, note)
}

// Replace TPC for flats with enharmonically equivalent TPC as sharp
function sharpen(note) {
    applyMap(flatToSharpMap, note)
}

// Replace TPC for sharps with enharmonically equivalent TPC as flats
function flatten(note) {
    applyMap(sharpToFlatMap, note)
}
