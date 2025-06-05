
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
    console.log("setNoteColour: " + note.tpc);
}
