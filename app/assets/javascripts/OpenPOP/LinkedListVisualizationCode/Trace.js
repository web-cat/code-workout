/**
 * class to represent a single trace item
 */
class Trace{
    /**
     * class constructor
     * @param {Object} trace trace item
     */
    constructor(trace) {
    this.trace = trace;
    this.traceCode = trace.code;
    this.traceCodeLineNumber = trace.lineNumber;
    this.traceStack = new TraceStack(trace.stack);
    this.traceHeap = [];
    for (var key in trace.heap)
        this.traceHeap.push(new TraceHeap(key, trace.heap[key]));
}
}