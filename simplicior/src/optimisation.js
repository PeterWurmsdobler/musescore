function assignReferencePitches(measures, referencePitches, transitionFactor = 10) {
    // Process the sequence of measures, each as a collection of pitches,
    // and the sequence of reference pitches and a transition cost factor.
    // measures: Array<Array of pitches>
    // referencePitches: Array of reference pitches
    // transitionFactor: Cost factor for changing reference pitches
    // output: Map<staffIndex, Array of reference pitches>
    const numMeasures = measures.length;
    const numReferencePitches = referencePitches.length;

    // Initialize DP table
    const dp = Array.from({ length: numMeasures }, () => Array(numReferencePitches).fill(Infinity));
    const prevRef = Array.from({ length: numMeasures }, () => Array(numReferencePitches).fill(-1));

    // Helper function to calculate the sum of distances
    function calculateDistanceSum(measure, referencePitch) {
        return measure.reduce((sum, notePitch) => sum + Math.abs(notePitch - referencePitch), 0);
    }

    // Initialize the first group
    for (let j = 0; j < numReferencePitches; j++) {
        dp[0][j] = calculateDistanceSum(measures[0], referencePitches[j]);
    }

    // Fill the DP table
    for (let i = 1; i < numMeasures; i++) {
        for (let j = 0; j < numReferencePitches; j++) {
            const currentReference = referencePitches[j];
            const currentDistance = calculateDistanceSum(measures[i], currentReference);

            for (let k = 0; k < numReferencePitches; k++) {
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

    // Find the minimum cost in the last group
    let minCost = Infinity;
    let lastRefIndex = -1;
    for (let j = 0; j < numReferencePitches; j++) {
        if (dp[numMeasures - 1][j] < minCost) {
            minCost = dp[numMeasures - 1][j];
            lastRefIndex = j;
        }
    }

    // Backtrack to find the reference numbers
    const assignedReferences = [];
    let currentRefIndex = lastRefIndex;
    for (let i = numMeasures - 1; i >= 0; i--) {
        assignedReferences[i] = referencePitches[currentRefIndex];
        currentRefIndex = prevRef[i][currentRefIndex];
    }

    return assignedReferences;
}