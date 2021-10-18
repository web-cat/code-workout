/**
 * class that represents the OpenPOP trace
 */
class TraceList{
    /**
     * Class constructor
     * @param {Object} traceList Object that represents the OpenPOP trace
     */
constructor(traceList) {
    this.listOfTraces = [];
    for (var i = 0;  i<traceList[0].length; i++) {
        var trace = traceList[0][i];
        this.listOfTraces.push(new Trace(trace));
    }
    }

    /**
     * get the number of traces
     */
    size() {
        return this.listOfTraces.length;
    }
    /**
     * get the trace item at the specified index
     */
    getTraceItem(index) {
        if (index < this.size())
            return this.listOfTraces[index];
    }
    /**
     * get the code for the trace item at the specified index
     */
    getTraceCode(index) {
        if (index < this.size())
            return this.listOfTraces[index].traceCode;
    }
    /**
     * get the stack for the trace at the specified index
     */
    getTraceStack(index) {
        if (index < this.size())
            return this.listOfTraces[index].traceStack;
    }
    /**
     * get the heap for the  trace at the specified index
     */
    getTraceHeap(index) {
        if (index < this.size())
            return this.listOfTraces[index].traceHeap;
    }
};