
function setColour(note, newColour) {
    //set the note colour
    note.color = newColour;

    // colour the accidental, if any
    if (note.accidental) {
        note.accidental.color = newColour;
    }
    // colour the dots, if any
    if (note.dots) {
        for (var i = 0; i < note.dots.length; i++) {
            if (note.dots[i]) {
                note.dots[i].color = newColour;
            }
        }
    }
    console.log("setColour: " + newColour);
}

function setShape(note, newShape) {
    //set the note shape
    if (newShape === "sharp") {
        // note.headScheme = NoteHead.Scheme.HEAD_SOLFEGE
        note.headGroup = 18//NoteHead.Group.HEAD_LA; // Square
        note.offsetY = -0.25; // Sharp notes are drawn higher
    }
    else if (newShape === "flat") {
        // note.headScheme = NoteHead.Scheme.HEAD_SOLFEGE
        note.headGroup = 18//NoteHead.Group.HEAD_LA; // Square
        note.offsetY = 0.25; // Flat notes are drawn lower
    }
    console.log("setShape: " + newShape);
}
