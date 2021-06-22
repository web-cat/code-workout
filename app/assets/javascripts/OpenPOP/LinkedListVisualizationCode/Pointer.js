/**
 * Class to represent any pointer that will be used in the visualizations
 */
class Pointer
{
/**
 * constructor to initialize a pointer to a linked list node
 * @param {String} pointerName pointer name
 * @param {reference} pointeeReference the reference for pointee node
 * @param {reference} linkedNodePosition pointee position
 */
    constructor(pointerName, pointeeReference /*, pointerPointee*/ , linkedNodePosition) {
    this.pointerName = pointerName;
    this.pointeeReference = pointeeReference;
    //this.pointerPointee = pointerPointee;
    this.LinkedNodePosition = linkedNodePosition;
    this.JsavPointer = null;
    }

    clone() {
        return new Pointer(this.pointerName, this.pointeeReference, this.linkedNodePosition);
    }
    /**
     * get pointer name
     */
    getName(){
        return this.pointerName;
    }
    /**
     * set pointer name
     * @param {String} value pointer name value
     */
    setName(value) {
        this.pointerName = value;
    }
    /**
     * get the pointer memory reference value
     */
    getPointeeReference() {
        return this.pointeeReference;
    }
    /**
     * set the pointer memory reference value
     * @param {reference} value pointer memory reference value
     */
    setPointeeReference(value) {
        this.pointeeReference = value;
    }
    /**
     * get the linked list node pointee index
     */
    getPointeePosition() {
        return this.LinkedNodePosition;
    }
    /**
     * set the linked list node pointee index
     * @param {Integer} value the linked list node pointee index
     */
    setPointeePosition(value) {
        this.LinkedNodePosition = value;
    }
    /**
     * checks if the current pointer is equal to the other pointer
     * @param {Pointer} OtherPointer the other pointer that will be compared to the current pointer
     */
    equals(OtherPointer) {
        return (this.pointerName === OtherPointer.pointerName &&
            this.pointeeReference === OtherPointer.pointeeReference &&
            /*            this.pointerPointee.equals(OtherPointer.pointerPointee) &&*/
            this.LinkedNodePosition === OtherPointer.LinkedNodePosition);
    }
    difference(OtherPointer, diff, index) {
        var str = null;
        if (this.pointerName !== OtherPointer.pointerName)
            str = { pointerIndex: index, name: this.pointerName, To: OtherPointer.pointerName };
        else if (this.pointeeReference !== OtherPointer.pointeeReference)
            str = { pointerIndex: index, reference: this.pointeeReference, To: OtherPointer.pointeeReference };
        //the below is commented as we do not need to check if the location is changed or not as if the reference changed then the location will change
        //and if the reference did not change this means that the list has some addition or deletion and the code will handel this change
        else if (this.LinkedNodePosition !== OtherPointer.LinkedNodePosition)
            str = { pointerIndex: index, nodePosition: this.LinkedNodePosition, To: OtherPointer.LinkedNodePosition };
        diff.pointerForStep.pointer = JSON.stringify(str);
        return diff;
    }
    drawPointer(av, JsavLinkedList, pointersForVisualization = null) {
        var left = 0;
        if(pointersForVisualization !== null)
        {
            for(var i = 0; i< pointersForVisualization.size(); i++)
            {
                if(pointersForVisualization.getPointer(i).getName() != this.getName() &&
                 pointersForVisualization.getPointer(i).getPointeePosition() === this.getPointeePosition())
                    left+=25;
            }
        }
        if (this.getPointeePosition() !== -1) {
            if (this.JsavPointer === null)
                this.JsavPointer = av.pointer(this.getName(), JsavLinkedList.get(this.getPointeePosition()), {left: left});
            else
                this.JsavPointer.target(JsavLinkedList.get(this.getPointeePosition()),{left: left});
        } else {//draw null pointer
            if (this.JsavPointer === null) {
                this.JsavPointer = av.pointer(this.getName(), JsavLinkedList, {anchor:"center bottom", myAnchor:"right top",top:0, left:-35, arrowAnchor: "center bottom"});
            }
            this.JsavPointer.target(null);
        }
    }
    movePointerToNewNode(nodeIndex, toPointeeReference, JsavLinkedList, av, pointersForVisualization) {
        this.setPointeePosition(nodeIndex);
        this.setPointeeReference(toPointeeReference);
        //pointer.setPointee(newNode);
        this.drawPointer(av, JsavLinkedList, pointersForVisualization);
    }
    movePointerToSeparateNode(node, reference, av) {
        this.setPointeePosition(-1); //we do not know the index of this node yet
        this.setPointeeReference(reference);
        if (this.JsavPointer === null)
            this.JsavPointer = av.pointer(this.getName(), node);
        else
            this.JsavPointer.target(node);
    }
    makeNull(av, JsavLinkedList) {
        this.setPointeePosition(-1);
        this.setPointeeReference(null);
        this.drawPointer(av, JsavLinkedList);
    }
};