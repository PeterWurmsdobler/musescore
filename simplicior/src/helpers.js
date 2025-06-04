// applyToNotesInSelection is a general purpose function that applies a
// function to every note in the current selection or to all notes in the
// score if there is no selection.  
function applyToNotesInSelection(func) {
    var fullScore = !curScore.selection.elements.length;
    if (fullScore) {
        cmd("select-all");
    }
    curScore.startCmd();
    for (var i in curScore.selection.elements)
        if (curScore.selection.elements[i].pitch)
            func(curScore.selection.elements[i]);
    curScore.endCmd();
    if (fullScore) {
        cmd("escape");
    }
}
