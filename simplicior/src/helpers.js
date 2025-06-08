// applyToNotesInSelection is a general purpose function that applies a
// function to every note in the current selection or to all notes in the
// score if there is no selection.  
function applyToNotesInSelection(func) {
    var selectionWasEmpty = (curScore.selection.elements.length == 0);
    if (selectionWasEmpty) {
        console.log("selectionWasEmpty");
        cmd("select-all");
    }
    curScore.startCmd();
    console.log("going through elements");
    for (var i in curScore.selection.elements)
        if (curScore.selection.elements[i].type == Element.NOTE)
            func(curScore.selection.elements[i]);
    curScore.endCmd();
    if (selectionWasEmpty) {
        console.log("selectionWasEmpty");
        cmd("escape");
    }
}
