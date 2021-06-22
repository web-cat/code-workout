'use strict';
/**
 * Function that compares this list of nodes with the otherArray
 * @param {*} otherArray 
 */
function comparer(otherArray) {
    return function(current) {
        return otherArray.filter(function(other) {
            return other.getData() === current.getData() && other.getReference() === current.getReference()
                //no compare for the next to enable detecting the deleted nodes only
        }).length == 0;
    }
}

/**
 * function to create a linked list for each trace
 * @param {List} trace the complete trace
 */
function CreateListOfLinkedLists(trace) {
    var linkLists = [];
    for (var i = 0; i < trace.size(); i++)
        linkLists.push(new LinkedList(trace.getTraceHeap(i)));
    return linkLists;
}

/**
 * Code for the main function
 */
function visualize(testVisualizerTrace) {
    var traces = new TraceList(testVisualizerTrace.trace);
    var code = new StudentCode(testVisualizerTrace.code);
    var vis = new Visualization(traces, code);
}
