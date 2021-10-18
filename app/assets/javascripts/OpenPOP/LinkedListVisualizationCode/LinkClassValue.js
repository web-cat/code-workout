/**
 * class to represent the heap for Link class only
 */
class LinkClassValue{
    /**
     * class constructor
     * @param {reference} next the reference for the next node in the list
     * @param {Object} data the value of the current node in the list
     */
    constructor(object1, object2) {
        var data, next;
        if(object1[0] == "data")
        {
            data = object1;
            next = object2;
        }
        else{
            data = object2;
            next = object1;
        }
    this.LinkNodeNext = null;
    if (next[1] !== null && next[1].constructor === Array)
        this.LinkNodeNext = next[1][1];
    this.LinkNodeData = null;
    if (data[1].constructor === Array)
        this.LinkNodeData = data[1][1];
    else
        this.LinkNodeData = data[1];
}
}