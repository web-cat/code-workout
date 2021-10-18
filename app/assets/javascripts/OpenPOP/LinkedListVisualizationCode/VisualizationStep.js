/**
 * classes for the visualization steps
 * @param {Trace} traceForStep the trace object correspond to a single step
 */
class VisualizationStep{
constructor(traceForStep) {
    this.traceForStep = traceForStep;
    this.linkedListForStep = new LinkedList(traceForStep.traceHeap);
    this.pointerForStep = new LinkedListPointersForStep(traceForStep.traceStack, this.linkedListForStep);
    this.stepCodeLine = traceForStep.traceCode;
    this.stepCodeLineNumber = traceForStep.traceCodeLineNumber;
    }
     /**
     * gets the linked list for this step
     */
    getLinkedListForStep() {
        return this.linkedListForStep;
    }
    /**
     * gets the pointers for this step
     */
    getPointersForStep() {
        return this.pointerForStep;
    }
    /**
     * gets the code for this step
     */
    getStepCode() {
        return this.stepCodeLine;
    }
    /**
     * checks if the current VisualizationStep is equal to the other VisualizationStep
     * @param {VisualizationStep} OtherVisualizationStep the other VisualizationStep that will be compared to the current VisualizationStep
     */
    equals(OtherVisualizationStep) {
        return (this.linkedListForStep.equals(OtherVisualizationStep.linkedListForStep) &&
            this.pointerForStep.equals(OtherVisualizationStep.pointerForStep));
    }
    /**
     * calculate the difference between the current step and the next step
     * @param {VisualizationStep} next the next step
     */
    difference(next) {
        var diff = {};
        if (!this.linkedListForStep.equals(next.linkedListForStep)) {
            diff.linkedListForStep = {};
            diff = this.linkedListForStep.difference(next.linkedListForStep, diff);
        }
        if (!this.pointerForStep.equals(next.pointerForStep)) {
            diff.pointerForStep = {};
            diff = this.pointerForStep.difference(next.pointerForStep, diff);
        }
        return diff;
    }
    /**
     * returns the current step code line number
     */
    getStepCodeLineNumber() {
        return this.stepCodeLineNumber;
    }
};