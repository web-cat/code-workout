/**
 * Class that creates a linked list for a single visualization step
 */
class LinkedList{
    /**
     * Class constructor
     * @param {Object} traceHeapForStep The trace heap for a single step
     */
constructor(traceHeapForStep) {
    this.LinkedListNodes = [];
    this.circularList = false;
    for (var i = 0; i < traceHeapForStep.length; i++) {
        var traceItem = traceHeapForStep[i];
        this.LinkedListNodes.push(new LinkedListNode(traceItem.value.LinkNodeData,
            traceItem.reference,
            traceItem.value.LinkNodeNext));
    }
    this.checkIfCircularList();
}
    /**
     * returns the number of nodes inside the linked list
     */
    size() {
        return this.LinkedListNodes.length;
    }
    /**
     * returns the node at the given index
     */
    getNode(index) {
        return this.LinkedListNodes[index]
    }
    /**
     * returns the reference of the node that has the given reference
     */
    getNodeByReference(reference) {
        var resultNode = null;
        this.LinkedListNodes.forEach(function(node, index) {
            if (node.getReference() === reference.toString())
                resultNode = node;
        });
        return resultNode;
    }
    /**
     * return the location of the node with the specified reference
     * @param {String} reference the node reference
     */
    getNodeLocation(reference) {
        var resultNode = null;
        this.LinkedListNodes.forEach(function(node, index) {
            if (node.getReference() === reference.toString())
                resultNode = index;
        });
        return resultNode;
    }
    /**
     * checks if the current linked list is equal to the other linked list
     * @param {LinkedList} OtherLinkedList the other linked list that will be compared to the current linked list
     */
    equals(OtherLinkedList) {
        if (this.size() !== OtherLinkedList.size())
            return false;
        for (var i = 0; i < this.size(); i++) {
            if (!this.getNode(i).equals(OtherLinkedList.getNode(i)))
                return false;
        }
        return true;
    }
    /**
     * Calculats the difference between this linked list and the other linkedlist
     * @param {LinkedList} OtherLinkedList The other linked list that will be compared with this linked list
     * @param {Hash} diff Hash table
     */
    difference(OtherLinkedList, diff) {
        if (this.size() !== OtherLinkedList.size()) { //determine if there is addition or deletion
            if (this.size() < OtherLinkedList.size())
                diff.linkedListForStep.size = JSON.stringify({ addNodes: this.size(), To: OtherLinkedList.size() });
            else {
                diff.linkedListForStep.size = JSON.stringify({ removeNodes: this.size(), To: OtherLinkedList.size() });
            }
        } else { //same size but different nodes
            for (var i = 0; i < this.size(); i++) {
                if (!this.getNode(i).equals(OtherLinkedList.getNode(i))) {
                    diff.linkedListForStep.node = {};
                    diff = this.getNode(i).difference(OtherLinkedList.getNode(i), diff, i);
                }
            }
        }
        return diff;
    }
    /**
     * Removes a node at the specified index
     * @param {Integer} index The index of the node that will be removed
     */
    removeAt(index) {
        this.LinkedListNodes.splice(index, 1);
    }
    /**
     * Check if the linked list is circular or not
     */
    checkIfCircularList() {
        var circular = true;
        if(this.size() > 0){
        if (this.getNode(this.size() - 1).getNext() === null)
            circular = false;
        this.circularList = circular;
        }
        else
            return false;
    }
    /**
     * returns the true if the list is circular, false otherwise
     */
    isCircular() {
        return this.circularList;
    }
};