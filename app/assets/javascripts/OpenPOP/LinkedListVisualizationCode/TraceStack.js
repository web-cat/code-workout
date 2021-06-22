/**
 * class to represent the trace stack
 */
class TraceStack{
    /**
     * class constructor
     * @param {Object} traceStack the trace stack value
     */
    constructor(traceStack) {
    this.orderedVariableNames = traceStack.ordered_variable_names;
    this.encodedLocals = [];
    for (var key in traceStack.encoded_locals) {
        this.encodedLocals.push(new EncodedLocal(key, traceStack.encoded_locals[key]));
    }
}
    /**
     * returns the specified encoded local at the given index
     */
    getEncodedLocals(index) {
        return this.encodedLocals[index];
    }
};