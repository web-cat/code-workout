"use strict";
function drawCircularArrow(last, first, av, top)
{
    var longArrow = connection(first.element, last.element, av, top);
    longArrow.hide();
    return longArrow;
}

function connection(obj1, obj2, jsav, position) {
    if (obj1 === obj2) { return; }
    var pos1 = obj1.offset();
    var pos2 = obj2.offset();
    var fx = pos1.left + obj1.outerWidth()/2.0 ;
    var tx = pos2.left - obj2.outerWidth()/2.0 ;
    var fy = position.top + obj1.outerHeight();///2.0
    /*var ty = position.top + obj2.outerHeight();
    var fx1 = fx,
        fy1 = fy,
        tx1 = tx,
        ty1 = ty;
    var disx = ((fx - tx - 22) > 0) ? 1 : ((fx - tx - 22) === 0) ? 0 : -1;
    var disy = ((fy - ty) > 0) ? 1 : ((fy - ty) === 0) ? 0 : -1;

    var dx = Math.max(Math.abs(fx - tx) / 2, 35);
    var dy = Math.max(Math.abs(fy - ty) / 2, 35);

    if ((fy - ty > -25) && (fy - ty < 25) && ((tx - fx < 36) || (tx - fx > 38))) {
        dx = Math.min(Math.abs(fx - tx), 20);
        dy = Math.min(Math.abs(fx - tx) / 3, 50);

        ty -= 15;
        fx1 = fx;
        fy1 = fy - dy;
        tx1 = tx - dx;
        ty1 = ty - dy;
    } else if (disx === 1) {
    */
        tx += 22;
        /*
        ty += 15 * disy;
        fx1 = fx + dx;
        fy1 = fy - dy * disy;
        tx1 = tx;
        ty1 = ty + dy * disy;
    } else if (disx === -1) {
        fx1 = fx + dx;
        fy1 = fy;
        tx1 = tx - dx;
        ty1 = ty;
    }
*/
    return jsav.g.path(["M", fx, fy, "h", 20, "v", 30, "h", (tx - fx - 30 - 20), "v", -30, "h", 20].join(","),
        {"arrow-end": "classic-wide-long", opacity: 0,
            "stroke-width": 2});/*jsav.g.path(["M", fx, fy, "C", -fx1, -fy1, -tx1, -ty1, tx, ty].join(","),
        {"arrow-end": "classic-wide-long", opacity: 0,
            "stroke-width": 2});*/
}
var VisualizedLinkedList = new function (){
    this.objectConstructor = function (av) {
        this.av = av;
        this.linkedList = av.ds.list({nodegap: 30, top: 40, left: 400});
    };
    this.ListOfRedLabels = [];
    this.LinkedListSteps = [];
    this.linkedListItems = [];
    this.linkedListReferences = [];
    this.linkedItemsNext = [];
    this.circular = false;
    this.head = null;
    this.tail = null;
    this.circularEdge = false;
    this.blackifyAll = function (listOfObjects) {
        for (var obj in listOfObjects){
            if(typeof(obj.css) !== 'undefined')
                obj.css({"stroke" : "black"});
            else
                if(obj < this.listOfOtherLinks.length)
                    this.listOfOtherLinks[parseInt(obj)].arrow.css({"stroke" : "black"});
        }
    };
    this.size = function () {
        return this.linkedListItems.length;
    };
    this.createLinkedList = function () {
        //window.alert(this.LinkedListSteps.toSource());
        for(var j=0; j<this.linkedListItems.length; j+=1)
        {
            this.linkedList.addFirst(this.linkedListItems[j]);
        }
        this.layout();
        this.head = this.av.pointer("p", this.linkedList.get(0));
        this.setTailPointer(this.LinkedListSteps[0].pointers, 0);
        this.drawOtherLinks(0);
    };
    this.getListItemIndexByReference = function (REF) {
        for (var i = 0; i < this.linkedListReferences.length; i++)
        {
            if(this.linkedListReferences[i] == REF)
                return i;
        }
        return -1;
    };
    this.moveHead = function(index){
        var i = index;
        window.alert("here");
        if(this.headPointerPositionChanged(i))
        {

            if(!this.circular){ //if no one else is pointing to the first node
                var node = this.linkedList.get(this.findHeadPosition(this.LinkedListSteps[i - 1].pointers));
                node.highlight();
                this.av.step();
                this.setHeadPointer(this.LinkedListSteps[i].pointers);
                //this.head.css("color", "red");
                this.head.arrow.css({"stroke" : "red"});
                this.ListOfRedLabels.push(this.head.arrow);
                //this.av.step();
                //this.head.arrow.css({"stroke" : "black"});
                node.hide();
                node.edgeToNext().hide();
            }
            else
                this.setHeadPointer(this.LinkedListSteps[i].pointers);
        }
    };
    this.showEmptyLinkedList = function (index) {
      if(this.LinkedListSteps[index].listItems.length === 0){

          return true;
      }
      else
          return false;
    };
    this.visualize = function ( ) {
        this.av.displayInit();
        var startIteration = 0;
        while(this.showEmptyLinkedList(startIteration)){
            startIteration += 1;
        }
        //window.alert(startIteration);
        this.linkedListItems = this.LinkedListSteps[startIteration].listItems;
        this.linkedListReferences = this.LinkedListSteps[startIteration].refs;
        this.linkedItemsNext = this.LinkedListSteps[startIteration].nexts;
        this.createLinkedList();
        this.setHeadPointer(this.LinkedListSteps[startIteration].pointers);
        this.setTailPointer(this.LinkedListSteps[startIteration].pointers, startIteration);
        this.av.step();
        for (this.i = startIteration+1; this.i < this.LinkedListSteps.length; this.i++){
            if(this.ListOfRedLabels.length >0){
                this.blackifyAll(this.ListOfRedLabels);
            }
            this.linkedListItems = this.LinkedListSteps[this.i].listItems;
            this.linkedListReferences = this.LinkedListSteps[this.i].refs;
            this.linkedItemsNext = this.LinkedListSteps[this.i].nexts;
            this.linkedListReferences = this.LinkedListSteps[this.i].refs;
            //determine the change and visualize it
            if(this.determineTheChange(this.i))
            //next slide
                this.av.step();
        }
        this.av.recorded();
    };
    this.determineTheChange = function (index) {
        var currentListItems = this.LinkedListSteps[index].listItems;
        var previousListItems = this.LinkedListSteps[index - 1].listItems;
        var currentListOfRefs = this.LinkedListSteps[index].nexts;
        var previousListOfRefs = this.LinkedListSteps[index - 1].nexts;
        var change = false;
        if(!this.circular) {
            this.checkIfCircularList(index);
            if (this.circular && this.linkedList.get(0).edgeToNext() !== null) {
                this.convertToCircularList();
                change = true;
            }
        }
        if(currentListItems.length > previousListItems.length){
            change = change | this.insertNewItemsToList(index);
        }
        if(currentListOfRefs.length < previousListOfRefs.length){
            change = change | this.changeListNexts(index);
        }
        if(this.LinkedListSteps[index-1].listItems.length === this.LinkedListSteps[index].listItems.length){
            change = change | this.changeListValues(index);
        }
        if(this.headPointerPositionChanged(index)) {
            if (currentListItems === previousListItems) {
                change = change | this.moveHead(index);
            }
            else {
                this.head.arrow.css({"stroke": "red"});
                this.ListOfRedLabels.push(this.head.arrow);
                this.setHeadPointer(this.LinkedListSteps[index].pointers);
                this.av.step();
            }
        }
        if(currentListItems.length === previousListItems.length){
            change = change | this.changeListNodesOrder(index);
        }
        change = change | this.drawOtherLinks(index);
        change = change | this.setTailPointer(this.LinkedListSteps[index].pointers, index);

        return change;
    };
    this.insertNewItemsToList = function(index){
        var currentListItems = this.LinkedListSteps[index].listItems;
        var previousListItems = this.LinkedListSteps[index - 1].listItems;
        if(currentListItems.length > previousListItems.length) //there is new item added to the list
        {
            var newNodeValue = this.linkedListItems[this.linkedListItems.length - 1];
            var newNodeRef = this.linkedListReferences[this.linkedListReferences.length - 1];
            var newNodeNext = this.LinkedListSteps[index].nexts[this.LinkedListSteps[index].nexts.length - 1];
            //window.alert(this.linkedItemsNext.indexOf(parseInt(newNodeRef)));
            if(newNodeNext != null || newNodeNext === null && this.linkedItemsNext.indexOf(parseInt(newNodeRef)) >= 0) {//the new node added directly to the list
                if (this.linkedItemsNext.indexOf(parseInt(newNodeRef)) < 0) {//if not found means that this node is in the head
                    this.linkedList.addFirst(newNodeValue);
                    if(this.headPointerPositionChanged(index)) {//the the new item is the new head of the list
                        this.setHeadPointer(this.LinkedListSteps[index].pointers);
                        this.head.arrow.css({"stroke" : "red"});
                        this.ListOfRedLabels.push(this.head.arrow);
                    }
                }
                else {
                    this.linkedList.addLast(newNodeValue);
                    this.linkedList.get(this.linkedListItems.length - 1).highlight();
                    if(this.linkedList.get(this.linkedListItems.length - 2).highlight())
                        this.linkedList.get(this.linkedListItems.length - 2).unhighlight();
                }
                this.layout();
                return true;

            }
            else{//new node added first then linked to the list
                //first we need to look ahead and see it it will be in the head ot the tail of the list
                var newNodeNextInNextStep = this.LinkedListSteps[index + 1].nexts[this.LinkedListSteps[index + 1].nexts.length - 1];
                var pointers = this.LinkedListSteps[index].pointers;
                if(newNodeNextInNextStep == pointers[0].REF) {//points to the head
                    for(var j = 0; j< pointers.length; j++){
                        if(pointers[j].REF == newNodeRef){
                            var p = pointers[j];
                            var newNode = this.linkedList.newNode(newNodeValue);
                            newNode.css({
                                top: 0,
                                left: -80//first
                            });
                            var newLink = this.av.pointer(p.variable, newNode,{anchor:"center bottom", myAnchor:"right top",top:-5, left:-35, arrowAnchor: "center bottom"});
                            newNode.highlight();
                            newLink.arrow.css({"stroke": "red"});
                            this.ListOfRedLabels.push(newLink.arrow);
                            this.av.step();
                            this.linkedList.addFirst(newNode);
                            this.layout();
                            this.av.step();
                            this.i++;
                            this.head.target(newNode);
                            this.head.arrow.css({"stroke": "red"});
                            this.ListOfRedLabels.push(this.head.arrow);
                            this.layout();
                            newNode.unhighlight();
                            newLink.hide();
                        }
                    }
                }
                return true;
            }
        }
        return false;
    };
    this.changeListNodesOrder = function (index) {//the same number of nodes but with different nexts
        var currentListItems = this.LinkedListSteps[index].listItems;
        var previousListItems = this.LinkedListSteps[index - 1].listItems;
        if(currentListItems.length === previousListItems.length){
            var currentListNexts = this.LinkedListSteps[index].nexts;
            var previoustListNexts = this.LinkedListSteps[index - 1].nexts;
            var changed = -1;
            for(var j = 0; j< currentListNexts.length; j++){
                if(currentListNexts[j] != previoustListNexts[j]){
                    changed = j;
                    break;
                }
            }
            if(changed === -1)
                return false;//no changes
            else{
                if(currentListNexts[changed] === null) {//remove the next arrow
                    var ref = this.LinkedListSteps[index].refs[changed];
                    var index2 = this.size() - 1 - this.getListItemIndexByReference(ref);
                    this.linkedList.get(index2).edgeToNext().hide();
                    //this.layout();
                    return true;
                }
                else if(previoustListNexts[changed] === null){//it was null but now points to a new node
                    var next = currentListNexts[changed];
                    var indexOfNewNext =  this.size() - 1 - this.getListItemIndexByReference(next);
                    var refOfChangedNode = this.LinkedListSteps[index].refs[changed];
                    var indexOfChangedNode = this.size() - 1 - this.getListItemIndexByReference(refOfChangedNode);
                    //this.linkedList.get(indexOfChangedNode).next(this.linkedList.get(indexOfNewNext));

                    if(!this.circular)
                    {
                        var circularEdge = drawCircularArrow(this.linkedList.get(indexOfNewNext), this.linkedList.get(indexOfChangedNode),
                            this.av, this.linkedList.position());
                        circularEdge.show();
                        circularEdge.css({stroke: "red"});
                        this.ListOfRedLabels.push(circularEdge);
                        this.linkedList.get(indexOfChangedNode).next(this.linkedList.get(indexOfNewNext));
                        this.linkedList.get(indexOfChangedNode).edgeToNext().hide();
                        return true;
                    }
                    else
                        return false;

                }
                else
                    window.alert("Another Case");

            }

        }
        return false;
    };
    this.changeListNexts = function(index){
        var currentListOfRefs = this.LinkedListSteps[index].nexts;
        var previousListOfRefs = this.LinkedListSteps[index - 1].nexts;
        var length  = previousListOfRefs.length;
        var chaged = false;
        if(currentListOfRefs.length < previousListOfRefs.length) //there is a delete in nexts
        {
            chaged = true;
            var i = length - 1;
            while (currentListOfRefs.indexOf(previousListOfRefs[i]) >= 0) //found so not this item
                i--;
            //now i - 1 is removed
            i = i - 1;

            var nodeFrom = this.linkedList.get(i-1);
            var nodeTo = this.linkedList.get(i);
            nodeTo.highlight();
            this.av.step();
            var pos1 = nodeFrom.element.offset();
            var pos2 = nodeTo.element.offset();
            var fx = pos1.left + nodeFrom.element.outerWidth()/2.0 ;
            var tx = pos2.left - nodeTo.element.outerWidth()/2.0 ;
            var fy = this.linkedList.position().top + nodeFrom.element.outerHeight();
            var ty = this.linkedList.position().top + nodeTo.element.outerHeight();
            var leftMargin = fx,
                topMargin = fy;
            var dashline = this.av.g.polyline([[leftMargin, topMargin],
                    [leftMargin + 15, topMargin],
                    [leftMargin + 15, topMargin + 45],
                    [leftMargin + 90, topMargin + 45],
                    [leftMargin + 90, topMargin],
                    [leftMargin + 105, topMargin]],
                {"arrow-end": "classic-wide-long",
                    opacity: 0, "stroke-width": 2,
                    "stroke-dasharray": "-", stroke: "red"});
            dashline.show();
            nodeFrom.edgeToNext().hide();
            this.av.step();
            dashline.css({"stroke" : "black"});
            nodeTo.unhighlight();
            nodeTo.edgeToNext().hide();
            nodeTo.hide();
            this.av.step();
            dashline.hide();
            this.linkedList.remove(i);
            nodeFrom.edgeToNext().css({"stroke" : "red"});
            this.ListOfRedLabels.push(nodeFrom.edgeToNext());
            this.layout();
        }

        return chaged;
    };
    this.checkIfCircularList = function(index){
          var currentListOfRefs = this.LinkedListSteps[index].nexts;
          var circular = true;
          for(var i = 0; i< currentListOfRefs.length; i++){
              if(currentListOfRefs[i] == null) {
                  circular = false;
                  break;
              }
          }
          if(circular)
              this.circular = true;
    };
    this.changeListValues = function (index) {
        var changed = false;
        if(this.LinkedListSteps[index-1].listItems.length === this.LinkedListSteps[index].listItems.length) {
            var length = this.LinkedListSteps[index - 1].listItems.length;
            for (var i = 0; i < length; i++) {

                var previous = this.LinkedListSteps[index - 1].listItems[i];
                var current = this.LinkedListSteps[index].listItems[i];
                if (previous != current) {
                    this.linkedList.get(length - i - 1).highlight();
                    this.av.step();
                    this.linkedList.get(length - i - 1).value(current);
                    this.linkedList.get(length - i - 1).css({"color":"red"});
                    this.ListOfRedLabels.push(this.linkedList.get(length - i - 1));
                    this.linkedList.get(length - i - 1).unhighlight();
                    //this.av.step();
                    //this.linkedList.get(length - i - 1).css({"color":"black"});
                    changed = true;
                }
            }
        }
        return changed;
    };
    this.convertToCircularList = function () {
        this.circular = true;
        this.circularEdge = drawCircularArrow(this.linkedList.get(0), this.linkedList.get(2), this.av, this.linkedList.position());
        this.circularEdge.css({"stroke" : "red"});
        this.ListOfRedLabels.push(this.circularEdge);
        this.circularEdge.show();
        //these lines are required to show problem 7 correctly
        this.linkedList.last().next(this.linkedList.first());
        var edge = this.linkedList.get(this.linkedListItems.length - 1).edgeToNext();
        edge.hide();
        this.layout();
        ////this.av.step();
        //this.circularEdge = null;
        //this.circularEdge = drawCircularArrow(this.linkedList.get(0), this.linkedList.get(2), this.av, this.linkedList.position(), "black");;
        ////this.circularEdge.css({"stroke" : "black"});
        ////this.circularEdge.show();
        return true;

    };
    this.layout = function () {
        if(!this.circular)
            this.linkedList.layout();
        else
        {
            this.circularEdge.hide();
            //this.linkedList.last().next(null);
            var target = this.linkedList.get(this.linkedListItems.length -1).next();
            this.linkedList.get(this.linkedListItems.length -1).next(null);
            this.linkedList.layout();
            this.linkedList.get(this.linkedListItems.length -1).next(target);
            this.linkedList.get(this.linkedListItems.length -1).edgeToNext().hide();
            this.circularEdge.show();
        }
    };
    this.removeNodeFromList = function (index, currentNodeRef, currentNodeIndex) {
        var i;
      for ( i= 0;  i< this.LinkedListSteps[index].nexts.length; i++){
          if(this.LinkedListSteps[index].nexts[i] === currentNodeRef){
              return;//will not be removed
          }
      }
      //No other link points to the node. So it should be removed
        //1- hide it
        this.av.step();
        this.linkedList.get(currentNodeIndex).edgeToNext().hide();
        this.linkedList.get(currentNodeIndex).hide();
        this.av.step();
        this.linkedList.remove(currentNodeIndex);
        this.layout();
    };
    this.setHeadPointer = function (listOfVariableNames) {

        var index = this.findHeadPosition(listOfVariableNames);

        this.head.target(this.linkedList.get(index));
        if(this.i >0) {
            var nodeRef = this.LinkedListSteps[this.i - 1].pointers[0].REF;
            this.removeNodeFromList(this.i, nodeRef, 0);
            //this.head.show();
        }
    };
    this.setTailPointer = function (listOfVariableNames, iterationIndex) {
        var index = -1;
        for(var i =0; i< listOfVariableNames.length; i++)
            if(listOfVariableNames[i].variable === "r")
            {
                index = i;
                break;
            }
        if(index === -1)
            return;
        var ref = listOfVariableNames[index].REF;
        var index2 = this.size() - 1 - this.getListItemIndexByReference(ref);
        if(this.tail == null)
            this.tail = this.av.pointer("r", this.linkedList.get(index2),{left:35});
        else if(this.tailPointerPositionChanged(iterationIndex)){
            this.tail.target(this.linkedList.get(index2));
            this.tail.arrow.css({"stroke" : "red"});
            this.ListOfRedLabels.push(this.tail.arrow);
            //this.av.step();
            //this.tail.arrow.css({"stroke" : "black"});
        }
    };
    this.addNewListItems = function (listOfItems) {
        this.LinkedListSteps.push(listOfItems);
        //window.alert(this.LinkedListSteps.toSource());
    };
    this.getIndexOf = function (item) {

    };
    this.headPointerPositionChanged = function(index)
    {
        if(index == 0)
            return false;
        if(this.findHeadPosition(this.LinkedListSteps[index].pointers) !== this.findHeadPosition(this.LinkedListSteps[index - 1].pointers))
            return true;
        else
            return false;
    };
    this.tailPointerPositionChanged = function(index)
    {
        if(index == 0)
            return false;
        if(this.findTailPosition(this.LinkedListSteps[index].pointers) !==
            this.findTailPosition(this.LinkedListSteps[index - 1].pointers))
            return true;
        else
            return false;
    };
    this.findHeadPosition = function(listOfVariableNames){
        var index = -1;
        //window.alert(listOfVariableNames.toSource());
        for(var i =0; i< listOfVariableNames.length; i++) {
            if (listOfVariableNames[i].variable === "p") {
                index = i;
                //window.alert(index);
                break;
            }
        }
        var ref = listOfVariableNames[index].REF;
        var index2 = this.size() - 1 - this.getListItemIndexByReference(ref);
        //window.alert(index2);
        return index2;
    };
    this.findTailPosition = function(listOfVariableNames){
        var index = -1;
        //window.alert(listOfVariableNames.toSource());
        for(var i =0; i< listOfVariableNames.length; i++) {
            if (listOfVariableNames[i].variable === "r") {
                index = i;
                //window.alert(index);
                break;
            }
        }
        var ref = listOfVariableNames[index].REF;
        var index2 = this.size() - 1 - this.getListItemIndexByReference(ref);
        //window.alert(index2);
        return index2;
    };
    this.findLinkPosition = function(listOfVariableNames, linkName){
        var index = -1;
        //window.alert(listOfVariableNames.toSource());
        for(var i =0; i< listOfVariableNames.length; i++) {
            if (listOfVariableNames[i].variable === linkName) {
                index = i;
                //window.alert(index);
                break;
            }
        }
        var ref = listOfVariableNames[index].REF;
        var index2 = this.size() - 1 - this.getListItemIndexByReference(ref);
        //window.alert(index2);
        return index2;
    };
    this.linkPointerPositionChanged = function(index, linkName)
    {
        if(index == 0)
            return false;
        if(this.findLinkPosition(this.LinkedListSteps[index].pointers, linkName) !==
            this.findLinkPosition(this.LinkedListSteps[index - 1].pointers, linkName))
            return true;
        else
            return false;
    };
    this.drawOtherLinks = function(index){
        var changed = false;
        for( var i = 0; i< this.LinkedListSteps[index].pointers.length; i++)
        {
            var link = this.LinkedListSteps[index].pointers[i];
            if(link.variable !== "p" && link.variable !== "r") {
                var ref = link.REF;
                if (ref != null) {
                    var index2 = this.size() - 1 - this.getListItemIndexByReference(ref);
                    var indexOfPointerInListOfLinks = this.listOfOtherLinksNames.indexOf(link.variable);
                    if (indexOfPointerInListOfLinks >= 0) {//link already exist
                        if(this.linkPointerPositionChanged(index, link.variable)) {//position changed
                            var l = this.listOfOtherLinks[indexOfPointerInListOfLinks];
                            l.target(this.linkedList.get(index2));
                            l.arrow.css({"stroke": "red"});
                            this.ListOfRedLabels.push(indexOfPointerInListOfLinks);
                            //this.av.step();
                            //l.arrow.css({"stroke": "black"});
                            changed = true;
                        }
                    }
                    else {//create new link
                        var other;
                        if (this.tail != null)// tail
                            other = this.av.pointer(link.variable, this.linkedList.get(index2), {
                                left: +15
                            });

                        else//there no tail
                            other = this.av.pointer(link.variable, this.linkedList.get(index2), {left: 35});
                        this.listOfOtherLinks.push(other);
                        this.listOfOtherLinksNames.push(link.variable);
                        changed = true;
                    }
                }
            }
        }
        return changed;
    };
    this.listOfOtherLinks = [];
    this.listOfOtherLinksNames = [];
};


function visualize(testvisualizerTrace) {
    function indexOf(ref, linkedListElements) {
        for (var i=0; i< linkedListElements.length; i++)
        {
            if(linkedListElements[i].address === ref)
                return i;
        }
    }


    var av; // pseudocode display
    // Settings for the AV
    av = new JSAV($('.avcontainer'));
    VisualizedLinkedList.objectConstructor(av);

    var removed = [],
        visualizationCode = testvisualizerTrace.code,
        pseudo = av.code(visualizationCode, {top:40, left: 50}),
        visualizationTrace = testvisualizerTrace.trace,
        codeLines = visualizationCode.replace(/(\r\n|\n|\r)/gm, "<br>").split("<br>"),
        traceObject,
        traceStack,
        traceHeap,
        listOfVariableNames,
        Heap,
        leftMargin = 400,
        topMargin = 40,
        linkedList = av.ds.list({nodegap: 30, top: topMargin, left: leftMargin}),
        i,
        j,
        k,
        ref,
        maxi,
        maxk,
        maxj,
        nodeGap = 30,
        notCircular = false;
    var lineIndex = 1;
    for(i =0, maxi = visualizationTrace.length; i<maxi; i+=1) {
        var linkedListItems = [],
            linkedListReferences = [],
            linkedItemsNext = [];

        notCircular = false;
        linkedList = av.ds.list({nodegap: nodeGap, top: topMargin, left: leftMargin});
        while(codeLines[lineIndex-1]==="")
            lineIndex++;
        if(i != 0) {
            pseudo.setCurrentLine(lineIndex++);
        }
        for(k = 0, maxk = removed.length; k<maxk; k+=1)
            removed[k].hide();
        traceObject = visualizationTrace[i];
        traceStack = traceObject.stack_to_render[0];
        traceHeap = traceObject.heap;
        listOfVariableNames=[];
        //load the variables from ordered_varnames to array listOfVariableNames
        for(j = 0, maxj = traceObject.stack_to_render[0].ordered_varnames.length; j<maxj; j+=1){
            var variable = traceObject.stack_to_render[0].ordered_varnames[j];
            if(traceObject.stack_to_render[0].encoded_locals[variable] != null) {
                var REF = traceObject.stack_to_render[0].encoded_locals[variable][1];
                listOfVariableNames.push({variable: variable, REF: REF});


            }
            else {
                listOfVariableNames.push({variable: variable, REF: null});

            }
        }
        //load heap part
        Heap = traceObject.heap;
        for(ref in Heap)
        {
            var value,
                next;
            if(Heap.hasOwnProperty(ref)) {
                value = Heap[ref];
                if (value.constructor === Array && value.length === 4) {
                    //window.alert(value[3][1].toSource());
                    next = value[2];
                    var storedValue;
                    if (value[3][1].constructor === Array) {//The Array contains the data and its type so take the data only
                        storedValue = value[3][1][1];
                    }
                    else {
                        storedValue = value[3][1];
                    }
                    if(typeof storedValue === 'number' && storedValue > 9 )//it should be a letter
                    {
                        storedValue = String.fromCharCode(storedValue);
                    }
                    linkedListItems.push(storedValue);
                    linkedListReferences.push(ref);
                    if (next[1] != null) {
                        linkedItemsNext.push(next[1][1]);
                    }
                    else {
                        linkedItemsNext.push(null);
                    }
                }
            }
        }
        var object = {
            listItems : linkedListItems,
            refs: linkedListReferences,
            nexts: linkedItemsNext,
            pointers: listOfVariableNames
        };
        VisualizedLinkedList.addNewListItems(object);
        //window.alert(object.toSource());
    }
    //window.alert(VisualizedLinkedList.LinkedListSteps.toSource());
    VisualizedLinkedList.visualize();
}