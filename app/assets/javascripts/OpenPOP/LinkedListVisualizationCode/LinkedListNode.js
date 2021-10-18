/**
 * class to initialize a linked list node
 */
class LinkedListNode{
    /**
     * Class constructor
     * @param {Object} nodeData the data value for the node
     * @param {reference} nodeReference The reference value for the pointer
     * @param {reference} nodeNext The reference value for the next node in the chain
     */
    constructor(nodeData, nodeReference, nodeNext) {
    this.nodeData = nodeData;
    this.nodeReference = nodeReference;
    this.nodeNext = nodeNext;
    }
    /**
     * get the node value
     */
    getData() {
        return this.nodeData;
    }
    /**
     * set the value of the node
     * @param {Object} value the node value
     */
    setData(value) {
        this.nodeData = value;
    }
    /**
     * get the reference value for the node
     */
    getReference() {
        return this.nodeReference;
    }
    /**
     * set the reference value for the node
     * @param {reference} value the reference value for the node
     */
    setReference(value) {
        this.nodeReference = value;
    }
    /**
     * get the reference for the next node in the chain
     */
    getNext() {
        return this.nodeNext;
    }
    /**
     * set the reference for the next node in the chain
     * @param {reference} value the reference value for the next node in the chain
     */
    setNext(value) {
        this.nodeNext = value;
    }
    /**
     * checks if the current node is equal to the other node
     * @param {LinkedListNode} OtherNode the other node that will be compared to the current node
     */
    equals(OtherNode) {
        return (this.nodeData === OtherNode.nodeData && this.nodeReference === OtherNode.nodeReference &&
            this.nodeNext === OtherNode.nodeNext);
    }
    /**
     * 
     * Calculats the difference between this linkedlist node and the other linkedlist node
     * @param {LinkedListNode} OtherNode The other linked list that will be compared with this linked list
     * @param {Hash} diff Hash table
     * @param {Integer} index the node index
     */
    difference(OtherNode, diff, index) {
        var str = null;
        if (this.nodeData !== OtherNode.nodeData)
            str = { nodeIndex: index, data: this.getData(), To: OtherNode.getData() };
        /*if (this.nodeReference !== OtherNode.nodeReference)
            str += '"reference": ' + this.nodeReference + ', "To": ' + OtherNode.nodeReference + '}';*/
        if (this.nodeNext !== OtherNode.nodeNext)
            str = { nodeIndex: index, next: this.getNext(), To: OtherNode.getNext() };
        diff.linkedListForStep.node = JSON.stringify(str);
        return diff;
    }
};