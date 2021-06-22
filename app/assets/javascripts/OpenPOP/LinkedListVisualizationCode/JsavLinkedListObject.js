/**
 * This class represents the JSAV linked list object thea will be used in the visualization
 */
class JsavLinkedListObject{
    /**
     * Class constructor
     * @param {JSAVpesudocodeobject} codeObject This object is used to show the student code in the slide show
     * @param {JSAV} av the JSAV object that is used to draw the visualizations
     */
    constructor(codeObject, av) {
    this.JsavLinkedList = av.ds.list({ nodegap: 30, top: 40, left: codeObject.element.outerWidth() + 100 });
    this.circular = false;
    this.size = 0;
    this.av = av;
    this.listOfNewNodesNotPartOfTheList = [];
    this.listOfNodesReferences = [];
    }
    /**
     * Create new node in the JSAV linked list. This node is not part of the list yet.
     * @param {Object} data the linked list node data
     * @returns the new JSAV linked list node
     */
    newNode(data) {
        var newnode = this.JsavLinkedList.newNode(data);
        this.listOfNewNodesNotPartOfTheList.push(newnode);
        return newnode;
    }
    /**
     * Search for a node that is not in the linked list. 
     * @param {Object} data The data will be used to find the requested node
     * @returns the linked list node
     */
    getNodeNotPartOfTheListByData(data) {
        for (var i = 0; i < this.listOfNewNodesNotPartOfTheList.length; i++)
            if (this.listOfNewNodesNotPartOfTheList[i].value() === data)
                return this.listOfNewNodesNotPartOfTheList[i];
    }
    /**
     * Creates and adds a new node at the first of the list.
     * @param {Object} data The created node data
     * @param {String} ref The created node memory reference.
     */
    addFirst(data, ref) {
        this.JsavLinkedList.addFirst(data);
        this.listOfNodesReferences.splice(0, 0, ref.toString());
        this.size++;
    }
    /**
     * Creates and adds a new node at the end on the list.
     * @param {Object} data The created node data
     * @param {String} ref The created node memory reference.
     */
    addLast(data, ref) {
        this.JsavLinkedList.addLast(data);
        this.listOfNodesReferences.push(ref.toString());
        this.size++;
    }
    /**
     * Creates and adds a new node at the specified index of the list.
     * @param {Integer} index  The specified index on the list
     * @param {Object} data The created node data
     * @param {String} ref The created node memory reference.
     */
    add(index, data, ref) {
        this.JsavLinkedList.add(index, data);
        this.listOfNodesReferences.splice(index, 0, ref.toString());
        this.size++;
    }
    /**
     * returns the JSAV Linked list object.
     */
    getJsavLinkedList() {
        return this.JsavLinkedList;
    }
    /**
     * returns the node at the specified index on the list.
     * @param {Integer} index  The specified index of the list
     */
    get(index) {
        return this.JsavLinkedList.get(index);
    }
    /**
     * removes the node at the specified index on the list.
     * @param {Integer} index  The specified index of the list
     */
    remove(index) {
        this.size--;
        return this.JsavLinkedList.remove(index);
        this.listOfNodesReferences.splice(index, 1);
    }
    /**
     * connects the last node with the first node
     * @param {JSAVNode} last 
     * @param {JSAVNode} first 
     */
    CreateCircularArrow(last, first) {
        this.circularEdge = this.connection(last.element, first.element);
        this.circularEdge.hide();
    }
    /**
     * Draws a link from obj1 to obj2
     * @param {JSAVNode} obj1 
     * @param {JSAVNode} obj2 
     * @returns the new link
     */
    connection(obj1, obj2) {
        var position = this.position();
        //if (obj1 === obj2) { return; }
        var pos1 = obj1.offset();
        var pos2 = obj2.offset();
        var fx = pos1.left + obj1.outerWidth() / 2.0;
        var tx = pos2.left - obj2.outerWidth() / 2.0;
        var fy = position.top + obj1.outerHeight(); ///2.0
        tx += 22;
        return this.av.g.path(["M", fx, fy, "h", 20, "v", 30, "h", (tx - fx - 30 - 20), "v", -30, "h", 20].join(","), {
            "arrow-end": "classic-wide-long",
            opacity: 0,
            "stroke-width": 2
        });
    }
    /**
     * Converts the list to Circular linked list
     */
    convertToCircularList(toRef) {
        if(toRef === null){
        this.CreateCircularArrow(this.get(this.size - 1), this.get(0));
        
        }
        else{
            var index = this.getNodeIndexByReference(toRef)
            this.CreateCircularArrow(this.get(this.size - 1), this.get(index));
        }
        this.circularEdge.show();
        this.last().next(this.first());
        var edge = this.get(this.size - 1).edgeToNext();
        edge.hide();
        return true;
    }
    /**
     * redraw the JSAV linked list
     */
    layout(toRef = null) {
        this.JsavLinkedList.layout();
        if (this.circular)
            this.convertToCircularList(toRef);
    }
    /**
     * returns the size of the linked list
     */
    size() {
        return this.JsavLinkedList.size();
    }
    /**
     * returns the position of the JSAV linked list object
     */
    position() {
        return this.JsavLinkedList.position();
    }
    /**
     * returns the last JSAV node in the list
     */
    last() {
        return this.JsavLinkedList.last();
    }
    /**
     * returns the first JSAV node in the list
     */
    first() {
        return this.JsavLinkedList.first();
    }
    /**
     * Returns the index of the node with the given value
     * @param {Object} value the value that used to find the node index
     */
    getNodeIndexByValue(value) {
        for (var i = 0; i < this.JsavLinkedList.size(); i++)
            if (this.JsavLinkedList.get(i).value() === value)
                return i;
    }
    /**
     * Returns the index of the node with the given reference
     * @param {String} reference the reference value that used to find the node index
     */
    getNodeIndexByReference(reference) {
        for (var i = 0; i < this.listOfNodesReferences.length; i++)
            if (this.listOfNodesReferences[i] === reference.toString())
                return i;
    }
};