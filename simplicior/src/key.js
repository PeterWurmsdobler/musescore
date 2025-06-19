// import { log } from "./src/helpers.js";

function log(nIndent, message) {
    var s = "\t".repeat(nIndent) + message;
    console.log(s);
}

function setAtonalKeySignature()
{
    log(0, "Setting atonal key signature");
    var measureIndex = 0;
    var measure = curScore.firstMeasure;
    while (measure) {
        log(1, "Measure: " + measureIndex);
        var segment = measure.firstSegment;
        while (segment) {
            for (var trackIndex = 0; trackIndex < curScore.ntracks; ++trackIndex) {
                var element = segment.elementAt(trackIndex);
                if (element) {
                    if (element.type === Element.KEYSIG) {
                        log(2, "Key " + element.key + " at measure " + measureIndex + " at staff " + trackIndex/4);
                        if (element.key !== 12) {
                            log(3, "Setting atonal key signature");
                            element.key = 12;
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