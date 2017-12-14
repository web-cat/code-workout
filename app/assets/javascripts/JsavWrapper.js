"use strict";
var VisualizedLinkedList = new function (){
    this.objectConstructor = function (av) {
        this.av = av;
        this.linkedList = av.ds.list({nodegap: 30, top: 40, left: 400});
    };
    this.LinkedListSteps = [];
    this.linkedListItems = [];
    this.linkedListReferences = [];
    this.linkedItemsNext = [];
    this.circular = false;
    this.head = null;
    this.tail = null;
    this.circularEdge = false;
    this.size = function () {
        return this.linkedListItems.length;
    };
    this.createLinkedList = function () {
        for(var j=0; j<this.linkedListItems.length; j+=1)
        {
            this.linkedList.addFirst(this.linkedListItems[j]);
        }
        this.layout();
        this.head = this.av.pointer("p", this.linkedList.get(0));
        this.tail = this.av.pointer("r", this.linkedList.get(this.size() - 1),{left:35});
    };
    this.getListItemIndexByReference = function (REF) {
        for (var i = 0; i < this.linkedListReferences.length; i++)
        {
            if(this.linkedListReferences[i] == REF)
                return i;
        }
        return -1;
    };
    this.visualize = function ( ) {
        this.av.displayInit();
        this.linkedListItems = this.LinkedListSteps[0].listItems;
        this.linkedListReferences = this.LinkedListSteps[0].refs;
        this.createLinkedList();
        this.setHeadPointer(this.LinkedListSteps[0].pointers);
        this.setTailPointer(this.LinkedListSteps[0].pointers);
        this.av.step();
        for (var i = 1; i < this.LinkedListSteps.length; i++){
            this.linkedListReferences = this.LinkedListSteps[i].refs;
            this.setHeadPointer(this.LinkedListSteps[i].pointers);
            this.setTailPointer(this.LinkedListSteps[i].pointers);
            this.av.step();
        }
        this.av.recorded();
    };
    this.convertToCircularList = function () {
        this.circular = true;
        this.circularEdge = drawCircularArrow(this.linkedList.get(0), this.linkedList.get(2), this.av, this.linkedList.position());
        this.linkedList.last().next(this.linkedList.first());
        var edge = this.linkedList.get(this.linkedListItems.length - 1).edgeToNext();
        edge.hide();
        //window.alert(edge.g.rObj.attrs.path[0]);
        this.circularEdge.show();
    };
    this.layout = function () {
        if(!this.circular)
            this.linkedList.layout();
        else
        {
            this.circularEdge.hide();
            this.linkedList.last().next(null);
            this.linkedList.layout()();
            this.linkedList.last().next(this.linkedList.first());
            this.circularEdge.show();
        }
    };
    this.setHeadPointer = function (listOfVariableNames) {
        var index = -1;
        for(var i =0; i< listOfVariableNames.length; i++)
            if(listOfVariableNames[i].variable == "p")
            {
                index = i;
                window.alert(index);
                break;
            }
        var ref = listOfVariableNames[index].REF;
        var index2 = this.size() - 1 - this.getListItemIndexByReference(ref);
        this.head.target(this.linkedList.get(index2));
        //this.head.show();

    };
    this.setTailPointer = function (listOfVariableNames) {
        var index = -1;
        for(var i =0; i< listOfVariableNames.length; i++)
            if(listOfVariableNames[i].variable == "r")
            {
                index = i;
                break;
            }
        var ref = listOfVariableNames[index].REF;
        var index2 = this.size() - 1 - this.getListItemIndexByReference(ref);
        this.tail.target(this.linkedList.get(index2));
    };
    this.addNewListItems = function (listOfItems) {
        this.LinkedListSteps.push(listOfItems);
        //window.alert(this.LinkedListSteps.toSource());
    };
    this.getIndexOf = function (item) {

    }

};


function visualize(testvisualizerTrace) {
    function indexOf(ref, linkedListElements) {
        for (var i=0; i< linkedListElements.length; i++)
        {
            if(linkedListElements[i].address == ref)
                return i;
        }
    }
    function connection(obj1, obj2, jsav, position) {
    if (obj1 === obj2) { return; }
    var pos1 = obj1.offset() ;
    var pos2 = obj2.offset();
    var fx = pos1.left + obj1.outerWidth()/2.0 ;
    var tx = pos2.left - obj2.outerWidth()/2.0 ;
    var fy = position.top + obj1.outerHeight()/2.0;
    var ty = position.top + obj2.outerHeight();
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
      tx += 22;
      ty -= 15;
      fx1 = fx;
      fy1 = fy - dy;
      tx1 = tx - dx;
      ty1 = ty - dy;
    } else if (disx === 1) {
      tx += 22;
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

    return jsav.g.path(["M", fx, fy, "C", fx1, fy1, tx1, ty1, tx, ty].join(","),
                           {"arrow-end": "classic-wide-long", opacity: 0,
                            "stroke-width": 2});
  }
    function drawCircularArrow(last, first, av, top)
    {


      var longArrow = connection(first.element, last.element, av, top);
      longArrow.hide();
      return longArrow;
    }
    var av; // pseudocode display
    // Load the config object with interpreter and code created by odsaUtils.js
    var config = ODSA.UTILS.loadConfig();      // Settings for the AV
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
        while(codeLines[lineIndex-1]=="")
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
                if (value.constructor === Array) {
                    next = value[2];

                    if (next[1] != null) {
                        linkedListItems.push(value[3][1]);
                        linkedListReferences.push(ref);
                        linkedItemsNext.push(next[1][1]);
                    }
                    else {
                        linkedListItems.push(value[3][1]);
                        linkedListReferences.push(ref);
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
    }
    VisualizedLinkedList.visualize();
}
