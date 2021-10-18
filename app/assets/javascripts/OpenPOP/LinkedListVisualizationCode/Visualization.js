/**
 * create all step for the visualization
 * @param {TraceList} traces list of all traces
 */
class Visualization{
    constructor(traces, code) {
    this.steps = [];
    this.code = code;
    for (var i = 0; i < traces.size(); i++) {
        this.steps.push(new VisualizationStep(traces.getTraceItem(i)));
    }
    var linkedListForStep = new LinkedList(traces.getTraceItem(0).traceHeap);
    this.pointersForVisualization = new LinkedListPointersForStep(traces.getTraceItem(0).traceStack, linkedListForStep);
    this.currentStep = 0;
    this.visualizer = new JSAV($('.avcontainer'));
    this.codeObject = this.visualizer.code(code.getCode(), { top: 40, left: 50 });
    this.codeObject.show();
    this.drawInitialState();
    this.visualizeAllSteps();
    this.drawFinalState();
}
    /**
     * returns the current step
     */
    getCurrentStep() {
        return this.steps[this.currentStep];
    }
    getCurrentIndex() {
        return this.currentStep;
    }
    /**
     * 1- check change in the linked list number, values, order
        2- check change in pointers pointee (becomes null), position, add new pointer
        return the step with the next step with the change or the last step (return statement step)
     */
    getNextStep() {
        if (this.currentStep < this.size() - 1) {
            while (this.currentStep < this.size() - 1) {
                var nextStep = this.steps[this.currentStep + 1];
                var currentStep = this.steps[this.currentStep];
                this.currentStep++;
                if (!currentStep.equals(nextStep))
                    return nextStep;
            }
            if (this.currentStep == this.size() - 1) //return the last step (return statement step)
                if (!currentStep.equals(nextStep)) //if they are not equal then return the step
                    return nextStep;
                else
                    return null;
        } else
            window.alert("Steps Out of Bound");
    }
    /**
     * reset the current step value
     */
    resetSteps() {
        this.currentStep = 0;
    }
    /**
     * returns the total number of steps
     */
    size() {
        return this.steps.length;
    }
    /**
     * returns the specified step based on the given index
     * @param {Integer} index the step index
     */
    getStep(index) {
        if (index < this.size())
            return this.steps[index];
    }
    /**
     * use the diff to identify the changes. The changes are in the form of Json object string
     */
    determineTheChange(diff) {
        var listOfChanges = [];
        if (diff.hasOwnProperty('linkedListForStep')) { //this means there is a change in the linked lists
            if (diff.linkedListForStep.hasOwnProperty('size')) { //change in the list size means that a node added or deleted
                listOfChanges.push(diff.linkedListForStep.size);
            }
            if (diff.linkedListForStep.hasOwnProperty('node')) { //change in nodes
                listOfChanges.push(diff.linkedListForStep.node);
            }
        }
        if (diff.hasOwnProperty('pointerForStep')) { //this means there is a change in the pointers
            if (diff.pointerForStep.hasOwnProperty('size')) { //change in the number of pointers, means add new pointer or remove a pointer
                listOfChanges.push(diff.pointerForStep.size);
            }
            if (diff.pointerForStep.hasOwnProperty('pointer')) { //change in pointer it self, change its name, location, ...
                listOfChanges.push(diff.pointerForStep.pointer);
            }

        }
        return listOfChanges;
    }
    /**
     * Draws the initial configuration
     */
    drawInitialState() {
        this.JsavLinkedList = new JsavLinkedListObject(this.codeObject, this.visualizer);
        var initialLinkedList = this.steps[0].getLinkedListForStep();
        for (var i = 0; i < initialLinkedList.size(); i++) {
            this.JsavLinkedList.addLast(initialLinkedList.getNode(i).getData(), initialLinkedList.getNode(i).getReference());
        }
        if (initialLinkedList.isCircular())
            this.JsavLinkedList.circular = true;
        this.JsavLinkedList.layout();
        var initialPointers = this.pointersForVisualization;
        for (i = 0; i < initialPointers.size(); i++) {
            var pointer = initialPointers.getPointer(i);
            if (pointer.getPointeeReference() === null)
                this.nullifyPointer(i);
            else
                pointer.drawPointer(this.visualizer, this.JsavLinkedList.getJsavLinkedList());

        }
        this.visualizer.umsg("Initial Configuration");
        this.codeObject.setCurrentLine(0);
        this.visualizer.displayInit();
    }
    /**
     * Draws the final configuration
     */
    drawFinalState() {
        this.visualizer.umsg("Final Configuration");
        var lastStep = this.steps[this.size() - 1];
        this.codeObject.setCurrentLine(lastStep.getStepCodeLineNumber());
        this.visualizer.recorded();
    }
    /**
     * move a pointer based on its index inside the list of pointers for a step, to any position in the linked list
     * @param {Integer} pointerIndex pointer index inside the list of pointers for a step
     * @param {Integer} toIndex the index for a node in the Linked list to be pointed by the pointer
     */
    movePointer(pointerIndex, toIndex, toPointeeReference) {
        var pointer = this.pointersForVisualization.getPointer(pointerIndex);
        if (toIndex !== -1) {
            pointer.movePointerToNewNode(toIndex, toPointeeReference, this.JsavLinkedList.getJsavLinkedList(), this.visualizer, this.pointersForVisualization);
            this.visualizer.umsg('change pointer ' + pointer.getName(0) + ' pointee');
            //this.JsavLinkedList.layout();
        } else //make the pointer null
            pointer.makeNull(this.visualizer);
    }
    /**
     * function to make pointer pointes to a node that is not in the list
     */
    movePointerToSeparateNode(pointerIndex, node, nodeReference) {
        var pointer = this.pointersForVisualization.getPointer(pointerIndex);
        pointer.movePointerToSeparateNode(node, nodeReference, this.visualizer);
        this.visualizer.umsg('change pointer ' + pointer.getName(0) + ' pointee');
        this.JsavLinkedList.layout();
    }
    /**
     * Make the pointer value to null and visualize it appropriately
     * @param {Integer} pointerIndex the index of the pointer
     */
    nullifyPointer(pointerIndex) {
        var pointer = this.pointersForVisualization.getPointer(pointerIndex);
        this.visualizer.umsg("Pointer " + pointer.getName() + " points to NULL");
        pointer.makeNull(this.visualizer, this.JsavLinkedList.getJsavLinkedList());
        //if there is a node pointed only by this pointer, it should be removed from the list
    }
    /**
     * Visualizes all steps.
     */
    visualizeAllSteps() {
        while (this.currentStep < this.size() - 1) {
            var current = this.getCurrentStep();
            var index = this.getCurrentIndex();
            var next = this.getNextStep();
            if(next != null){
            this.visualizeChanges(current, next);
            //FIX ME temp solution to code line number issue
            var lineNumber = next.getStepCodeLineNumber();
            this.codeObject.setCurrentLine(lineNumber > 1 ? lineNumber - 1 : lineNumber);
            this.visualizer.step();
            }
        }
    }
    /**
     * Visualize the change from the current step to the next step
     * @param {VisualizationStep} current the current step
     * @param {VisualizationStep} next the next step
     */
    visualizeChanges(current, next) {
        var diff = current.difference(next);
        var str = this.determineTheChange(diff);
        var value = str[0];
        var changeObject = JSON.parse(value);
        if (changeObject.hasOwnProperty('pointerIndex') || changeObject.hasOwnProperty('addPointers'))
            this.visualizePointers(current, changeObject);
        else if (changeObject.hasOwnProperty('nodeIndex'))
            this.visualizeLinkedListNodes(current, next, changeObject);
        else if (changeObject.hasOwnProperty('removeNodes')) {
            if (str.length > 1) { //means that there is another change in the list
                for (var i = 1; i < str.length; i++) { //search for a pointer change
                    var anotherValue = str[i];
                    if (anotherValue !== "IGNORE") {
                        var anotherChange = JSON.parse(anotherValue);
                        if (anotherChange.hasOwnProperty('pointerIndex')) { //found
                            this.remove_nodesFromTheList(current, next, changeObject, anotherChange);
                        }
                    } else
                        this.remove_nodesFromTheList(current, next, changeObject, null);
                }
            } else
                this.remove_nodesFromTheList(current, next, changeObject, null);
        } else if (changeObject.hasOwnProperty('addNodes')) {
            if (str.length > 1)
                for (var i = 1; i < str.length; i++) { //search for a pointer change
                    var anotherValue = str[i];
                    var anotherChange = JSON.parse(anotherValue);
                    if (anotherChange.hasOwnProperty('pointerIndex')) { //found
                        this.add_nodesToTheList(current, next, changeObject, anotherChange);
                    }
                }
            else
                this.add_nodesToTheList(current, next, changeObject, null);
        } else
            window.alert("Other Type of Change");

    }
    /**
     * Visualizes the pointers based on the current visualization step
     * @param {VisualizationStep} current the current visualization step
     * @param {Hash} changeObject Hash table that contains the changes to be applied on pointers
     */
    visualizePointers(current, changeObject) {
        if (changeObject.hasOwnProperty('pointerIndex')) {
            if (changeObject.hasOwnProperty('reference')) {
                if (changeObject.To === null) {
                    this.nullifyPointer(changeObject.pointerIndex);
                } else {
                    var toReference = changeObject.To;
                    var node = current.getLinkedListForStep().getNodeByReference(toReference.toString());
                    var nodeLocation = current.getLinkedListForStep().getNodeLocation(toReference.toString());
                    var NodeIndex = this.JsavLinkedList.getNodeIndexByReference(node.getReference());
                    this.movePointer(changeObject.pointerIndex, NodeIndex, toReference.toString());
                }
            } else {
                var toIndex = changeObject.To;
                var pointerIndex = changeObject.pointerIndex;
                if (toIndex === -1)
                    this.nullifyPointer(pointerIndex);
                else {
                    var node = current.getLinkedListForStep().getNode(toIndex);
                    this.movePointer(pointerIndex, node.getReference(), toIndex);
                }
            }
        } else if (changeObject.hasOwnProperty('addPointers')) {
            this.addNewPointerAndVisualizeIt(changeObject);
        }
    }
    /**
     * Visualizes the change in the order of nodes (next values), or the values of nodes
     * @param {VisualizationStep} current the current visualization step
     * @param {VisualizationStep} next the next visualization step
     * @param {Hash} changeObject Hash table that contains the changes to be applied on list nodes
     */
    visualizeLinkedListNodes(current, next, changeObject) {
        if (changeObject.hasOwnProperty('data')) { //change of node data values
            var nodeIndex = changeObject.nodeIndex;
            var newData = changeObject.To;
            this.visualizer.umsg("Change the value of node number " + nodeIndex + " From: " + this.JsavLinkedList.get(nodeIndex).value() + " To: " + newData);
            this.JsavLinkedList.get(nodeIndex).value(newData);
        } else if (changeObject.hasOwnProperty('next')) {
            //first check if the node is part of the list or not
            var partOfTheList = false;
            var nodeIndex = changeObject.nodeIndex;
            var node = current.getLinkedListForStep().getNode(nodeIndex);
            for (var i = 0; i < current.getLinkedListForStep().size(); i++) {
                var listNode = current.getLinkedListForStep().getNode(i);
                if (listNode.getNext() !== null && listNode.getNext().toString() === node.getReference())
                    partOfTheList = true;
            }
            if (!partOfTheList) {
                var newNode = this.JsavLinkedList.getNodeNotPartOfTheListByData(current.getLinkedListForStep().getNode(nodeIndex).getData());
                var nextIndex = current.getLinkedListForStep().getNodeLocation(changeObject.To.toString());
                if (nextIndex == 0) { //add the new node at first
                    this.JsavLinkedList.addFirst(newNode, current.getLinkedListForStep().getNode(nodeIndex).getReference());
                    this.JsavLinkedList.layout();
                    this.visualizer.umsg("add the node with value " + current.getLinkedListForStep().getNode(nodeIndex).getData() + " at the first position in the list");
                    //correct all lists as the 
                } else
                    newNode.next(this.JsavLinkedList.get(nextIndex));

            } else if (!current.getLinkedListForStep().isCircular() && next.getLinkedListForStep().isCircular()) //make the linked list circular
            {
                this.JsavLinkedList.circular = true;
                this.JsavLinkedList.layout(changeObject.To.toString());
                this.visualizer.umsg("set the next link for the node with value " + current.getLinkedListForStep().getNode(changeObject.nodeIndex).getData() + " to the node with value " +
                    next.getLinkedListForStep().getNodeByReference(changeObject.To).getData());
            } else if (current.getLinkedListForStep().isCircular() && !next.getLinkedListForStep().isCircular()) { //remove the circular edge
                //implement me
                window.alert("implement Me");
            } else if (changeObject.To === null) { //remove the next link
                var jsavNode = this.JsavLinkedList.get(changeObject.nodeIndex);
                jsavNode.next(null);
                jsavNode.edgeToNext().hide();
                this.visualizer.umsg("set the next link for the node with value " + current.getLinkedListForStep().getNode(changeObject.nodeIndex).getData() + " to null");
            }
        }
    }
    /**
     * There is a change in the number of nodes inside the list. So, we need to detect, apply and visualize the change
     * @param {VisualizationStep} current the current visualization step
     * @param {VisualizationStep} next the next visualization step
     * @param {Hash} changeObject Hash table that contains the changes to be applied on list nodes
     * @param {Hash} pointerChange Hash table that contains the changes to be applied on pointers
     */
    remove_nodesFromTheList(current, next, changeObject, pointerChange) {
        var removedNodes = current.getLinkedListForStep().LinkedListNodes.
        filter(comparer(next.getLinkedListForStep().LinkedListNodes));
        if (changeObject.To === 0) //means that the list will be null
        {
            for (var i = 0; i < this.pointersForVisualization.size(); i++) //make all pointers to null
                this.nullifyPointer(i);
            for (i = current.getLinkedListForStep().size() - 1; i >= 0; i--) {
                this.JsavLinkedList.remove(i);
                //Update the current Linked List stpe nodes
                current.getLinkedListForStep().removeAt(i);
            }
            return;
        }
        //We need to determine if we should remove first or move the pointer first
        //if the pointer pointes to a node after a removed node so it is normal to see a change in the index of the node
        //if it points to a node before the removed one so we should apply the pointer change

        var after = false;
        if(pointerChange!== null){
        var oldPointerPointeeIndex = pointerChange.nodePosition;
        var differenceInIndices = pointerChange.nodePosition - pointerChange.To;
        for (var i = 0; i < removedNodes.length; i++) {
            var node = removedNodes[i];
            var nodeIndex = current.getLinkedListForStep().getNodeLocation(node.getReference());
            if (nodeIndex < oldPointerPointeeIndex)
                differenceInIndices--;
        }
    }
        if (pointerChange !== null && differenceInIndices !== 0) {
            var pointer = this.pointersForVisualization.getPointer(pointerChange.pointerIndex);
            var toIndex = -1;
            if (pointerChange.hasOwnProperty('nodeReference'))
                toIndex = current.getLinkedListForStep().getNodeLocation(pointerChange.To);
            else if (pointerChange.hasOwnProperty('nodePosition'))
                toIndex = current.getLinkedListForStep().getNode(pointerChange.To);
            this.movePointer(pointerChange.pointerIndex, toIndex, pointerChange.To);
            this.visualizer.step();
            pointerChange = null; //done
        }
        //remove every node from the linked list
        for (var i = 0; i < removedNodes.length; i++) {
            var node = removedNodes[i];
            var nodeIndex = current.getLinkedListForStep().getNodeLocation(node.getReference());
            if (nodeIndex != 0) { //means that the node is in the middle of the list. So, we need to visualize the remove
                var parentNode = this.JsavLinkedList.get(nodeIndex - 1);
                parentNode.edgeToNext().hide();
                var edge = this.JsavLinkedList.connection(parentNode.element, this.JsavLinkedList.get(nodeIndex + 1).element);
                edge.show();
                this.visualizer.umsg("change the next of the node with value " + current.getLinkedListForStep().getNode(nodeIndex - 1).getData() + " to point to the node with value " +
                    current.getLinkedListForStep().getNode(nodeIndex + 1).getData());
                this.visualizer.step();
                edge.hide();
            }
            this.visualizer.umsg('remove node with data equals ' + current.getLinkedListForStep().getNode(nodeIndex).getData());
            this.JsavLinkedList.remove(nodeIndex);
            //Update the current Linked List stpe nodes
            current.getLinkedListForStep().removeAt(nodeIndex);
            this.JsavLinkedList.layout();
            if (i !== removedNodes.length - 1)
                this.visualizer.step();
        }
        //correct the indices of pointers pointee location. The difference occurred due to deleted nodes
        this.correctPointersForVisualization(next);
    }
    /**
     * Adds a node the the current Visualized linked list and visualize the addition
     * @param {VisualizationStep} current the current visualization step
     * @param {VisualizationStep} next the next visualization step
     * @param {Hash} changeObject Hash table that contains the changes to be applied on list nodes
     * @param {Hash} pointerChange Hash table that contains the changes to be applied on pointers
     */
    add_nodesToTheList(current, next, changeObject, pointerChange) {
        var addedNodes = next.getLinkedListForStep().LinkedListNodes.filter(comparer(current.getLinkedListForStep().LinkedListNodes));
        for (var i = 0; i < addedNodes.length; i++) {
            var node = addedNodes[i];
            var nodeIndex = next.getLinkedListForStep().getNodeLocation(node.getReference());
            //if this new node is not pointed by any other node, so this node is not in the list
            var partOfTheList = false;
            if(current.getLinkedListForStep().size() > 0){
            var newNodeReference = node.getReference();
            for (var j = 0; j < next.getLinkedListForStep().size(); j++) {
                if (j !== nodeIndex) {
                    if (next.getLinkedListForStep().getNode(j).getNext() !== null &&
                        next.getLinkedListForStep().getNode(j).getNext().toString() === newNodeReference)
                        partOfTheList = true;
                }
            }
            
            if (!partOfTheList) { //means that the node is either will be added at the beginning of the list or the node is separate from the list
                //check to see if the node will be added in the beginning of the list
                var atBeginning = false;
                var node = addedNodes[i];
                if(node.getNext() !== null){
                for (var j = 0; j < next.getLinkedListForStep().size(); j++) {
                    if (j !== nodeIndex) {
                        if (next.getLinkedListForStep().getNode(j).getNext() !== null &&
                            next.getLinkedListForStep().getNode(j).getReference().toString() === node.getNext().toString())
                            atBeginning = true;
                    }
                }
                }
                if (atBeginning) {
                    this.JsavLinkedList.addFirst(node.getData(), node.getReference());

                    this.JsavLinkedList.layout();
                    this.visualizer.umsg("add new node with value " + node.getData() + " at the beginning of the list");
                } else { //means the node is separated from the list
                    var newNode = this.JsavLinkedList.newNode(node.getData());
                    newNode.css({
                        top: +100,
                        left: 0 //first
                    });
                }
                if (pointerChange.hasOwnProperty('reference') && pointerChange.To.toString() === newNodeReference) {
                    if (atBeginning) {
                        this.visualizer.step();
                        this.movePointer(pointerChange.pointerIndex, 0, node.getReference());
                    } else {
                        this.movePointerToSeparateNode(pointerChange.pointerIndex, newNode, newNodeReference);
                    }
                    this.visualizer.umsg("make pointer " + this.pointersForVisualization.getPointer(pointerChange.pointerIndex).getName() + " points to node with value " + node.getData());
                    pointerChange = null; //to prevent re-displaying the pointer latter in this function
                }
            } else {
                this.JsavLinkedList.add(nodeIndex, node.getData(), node.getReference());
                this.visualizer.umsg("Create new Node with data value " + node.getData() + ' and add it to the list at location ' + nodeIndex);
                this.JsavLinkedList.layout();
            }
        }
        else{
            this.JsavLinkedList.add(nodeIndex, node.getData(), node.getReference());
                this.visualizer.umsg("Create new Node with data value " + node.getData() + ' and add it to the list at location ' + nodeIndex);
                this.JsavLinkedList.layout();
        }
        }
        //now if there is a change in pointers we will visualize it
        if (pointerChange !== null) {
            if (pointerChange.hasOwnProperty('reference')) {
                var toIndex = next.getLinkedListForStep().getNodeLocation(pointerChange.To);
                this.visualizer.step();

                this.movePointer(pointerChange.pointerIndex, toIndex, pointerChange.To);
            }
        }
    }
    /**
     * modify the pointers references and pointee location for the next step
     * @param {VisualizationStep} nextStep the next step to be used to correct the pointers in the current visualized linked list
     */
    correctPointersForVisualization(nextStep) {
        for (var i = 0; i < this.pointersForVisualization.size(); i++) {
            var pointer = this.pointersForVisualization.getPointer(i);
            var nextStepPointer = nextStep.getPointersForStep().getPointer(i);
            if (pointer.getName() === nextStepPointer.getName()) {
                pointer.setPointeePosition(nextStepPointer.getPointeePosition());
                pointer.setPointeeReference(nextStepPointer.getPointeeReference());
            } else
                window.alert("LOOK AT ME");
        }
    }
    /**
     * Adds new pointer to the visualized linked list.
     * @param {Hash} changeObject Hash table that contains the changes to be applied on list nodes
     */
    addNewPointerAndVisualizeIt(changeObject) {
        var currentList = this.getCurrentStep().getPointersForStep();
        var newPointer = currentList.getPointer(changeObject.addPointers);
        newPointer = this.pointersForVisualization.addPointer(newPointer.getName(),
            newPointer.getPointeeReference(),
            newPointer.getPointeePosition());
        this.visualizer.umsg('add new pointer ' + newPointer.getName());
        newPointer.drawPointer(this.visualizer, this.JsavLinkedList.getJsavLinkedList(), this.pointersForVisualization);
    }
};