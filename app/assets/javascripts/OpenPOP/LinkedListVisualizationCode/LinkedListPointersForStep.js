/**
 * class to represent the pointers used to point at nodes in the linked list
 */
class LinkedListPointersForStep{
    /**
     * class constructor
     * @param {TraceStack} traceStackForStep Trace object that represent on step
     * @param {LinkedList} LinkedListForStep Linked List for the step
     */
    constructor(traceStackForStep, LinkedListForStep) {
    this.stepPointers = [];
    for (var i = 0; i < traceStackForStep.encodedLocals.length; i++) {
        var currentLocal = traceStackForStep.encodedLocals[i];
        if (currentLocal.referenceValue !== null)
            this.stepPointers.push(new Pointer(currentLocal.variableName,
                currentLocal.referenceValue,
                /*                LinkedListForStep.getNodeByReference(currentLocal.referenceValue),*/
                LinkedListForStep.getNodeLocation(currentLocal.referenceValue)));
        else
            this.stepPointers.push(new Pointer(currentLocal.variableName,
                currentLocal.referenceValue,
                /*                null, */
                -1));
        }
    }

    /**
     * returns the number of pointers in the list
     */
    size() {
        return this.stepPointers.length;
    }
    /**
     * return the pointer at the specified index
     */
    getPointer(index) {
        return this.stepPointers[index];
    }
    /**
     * checks if the current LinkedListPointersForStep is equal to the other LinkedListPointersForStep
     * @param {LinkedListPointersForStep} OtherLinkedListPointersForStep the other LinkedListPointersForStep that will be compared to the current LinkedListPointersForStep
     */
    equals(OtherLinkedListPointersForStep) {
        if (this.size() !== OtherLinkedListPointersForStep.size())
            return false;
        for (var i = 0; i < this.size(); i++) {
            if (!this.getPointer(i).equals(OtherLinkedListPointersForStep.getPointer(i)))
                return false;
        }
        return true;
    }
    /**
     * Calculats the difference between this linked list pointers and the other linkedlist pointers
     * @param {LinkedListPointersForStep} OtherLinkedListPointersForStep The other linked list pointers that will be compared with this linked list pointers
     * @param {Hash} diff Hash table
     */
    difference(OtherLinkedListPointersForStep, diff) {
        if (this.size() !== OtherLinkedListPointersForStep.size()) {
            if (this.size() < OtherLinkedListPointersForStep.size())
                diff.pointerForStep.size = JSON.stringify({ addPointers: this.size(), To: OtherLinkedListPointersForStep.size() });
            else
                diff.pointerForStep.size = JSON.stringify({ removePointers: this.size(), To: OtherLinkedListPointersForStep.size() });
        } else { //same size put change in pointers locations
            for (var i = 0; i < this.size(); i++) {
                if (!this.getPointer(i).equals(OtherLinkedListPointersForStep.getPointer(i))) {
                    diff.pointerForStep.pointer = {};
                    diff = this.getPointer(i).difference(OtherLinkedListPointersForStep.getPointer(i), diff, i);
                }
            }
        }
        return diff;
    }
    /**
     * creates a new pointer
     * @param {String} pointerName the pointer name
     * @param {String} pointeeReference the pointer reference value
     * @param {Object} LinkedListNodePosition Linked List pointee node poistion
     */
    addPointer(pointerName, pointeeReference, LinkedListNodePosition) {
        var newnode = new Pointer(pointerName, pointeeReference, LinkedListNodePosition);
        this.stepPointers.push(newnode);
        return newnode;
    }
};