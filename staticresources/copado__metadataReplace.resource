//Namespaces
var metadataReplace = metadataReplace || {};
metadataReplace.bindings = metadataReplace.bindings || {};
metadataReplace.template = metadataReplace.template || {};
metadataReplace.findReplace = metadataReplace.findReplace || {};

//Properties
metadataReplace.findReplaceArray = [];

/*
 *  This method will create the rows for the find replace array.
 *  return {[]}
*/
metadataReplace.createChildRows = function(array){
    if(typeof array == 'undefined')return false;
    var parentId = 'findReplaceArrayPlaceholder';
    var parent = document.getElementById(parentId);
    while (parent.firstChild) {
        parent.removeChild(parent.firstChild);
    }
    for(var i=0; i<array.length; i++){
        var wrapper = metadataReplace.template.findReplaceRow(i, array[i]);
        $copado(wrapper).appendTo('#'+parentId);
    }
};
/*
 *  The object of the field that cause this method to be triggered is called.
 *  $obj = jQuery object for field
 *  return {[]} nothing
*/
metadataReplace.setFindReplaceArrayProperty = function($obj){
    var al = $obj?$obj.data('al'):0;
    var at = $obj?$obj.data('type'):'';
    if($obj)metadataReplace.findReplaceArray[al] = [(at=='name')?$obj.val():metadataReplace.findReplaceArray[al][0], (at=='value')?$obj.val():metadataReplace.findReplaceArray[al][1]];
};


/* BINDINGS METHODS */
metadataReplace.bindings.headerKeyUp = function(){
    $copado('#findReplaceArrayPlaceholder').unbind('keyup');// to prevent multiple bindings
    $copado('#findReplaceArrayPlaceholder').on('keyup', '.js-findReplace', function(event){
        if((event.which>=16&&event.which<=20)||(event.which>=36&&event.which<=40))return;
        metadataReplace.setFindReplaceArrayProperty($copado(this)); 
    });
};
metadataReplace.bindings.bindActions = function(){
    metadataReplace.bindings.headerKeyUp();
};

/* HEADER METHODS */
metadataReplace.findReplace.addRow = function(){
    var me = metadataReplace;
    var wrapper;
    var parentId = 'findReplaceArrayPlaceholder';
    wrapper = me.template.findReplaceRow(me.findReplaceArray.length, null);
    me.findReplaceArray.push(['','']);
    $copado(wrapper).appendTo('#'+parentId);
    me.bindings.bindActions();
};
metadataReplace.findReplace.deleteRow = function(i){
    var me = metadataReplace;
    me.findReplaceArray.splice(i,1);
    me.createChildRows(me.findReplaceArray);
    me.bindings.bindActions();    
};
metadataReplace.findReplace.decode = function(){
    var me = metadataReplace;
    for(var i=0; i<me.findReplaceArray.length; i++){
        me.findReplaceArray[i][0] = decodeURIComponent(me.findReplaceArray[i][0]);
        me.findReplaceArray[i][1] = decodeURIComponent(me.findReplaceArray[i][1]);
    }
};
metadataReplace.findReplace.encode = function(){
    var me = metadataReplace;
    for(var i=0; i<me.findReplaceArray.length; i++){
        me.findReplaceArray[i][0] = encodeURIComponent(me.findReplaceArray[i][0]);
        me.findReplaceArray[i][1] = encodeURIComponent(me.findReplaceArray[i][1]);
    }
};
/*
    Pre-save validation method to ensure we don't have empty header params.
*/
metadataReplace.findReplace.validate = function(){
    var isValid = true;
    var params = metadataReplace.findReplaceArray;
    for(var i=0; i<params.length; i++){
        if(isValid==false)break;
        isValid = (params[i][0].length>0 && params[i][1].length>0);
    }
    return isValid;
};

metadataReplace.template.findReplaceRow = function(rowNumber, keyPair){
    var n = keyPair?keyPair[0]:'';
    var v = keyPair?keyPair[1]:'';
    //replaces quotes and double quotes with their HTML decimal codes to prevent hmtl break on html append
    n = n.replace(/"/g,'&#34;').replace(/'/g,"&#39");
    v = v.replace(/"/g,'&#34;').replace(/'/g,"&#39");
    var btn = `<button id="del-findReplace-${rowNumber}" onclick="metadataReplace.findReplace.deleteRow(${rowNumber}); return false;" class="btn copado-lightning">Delete</button`;
    var nameField =   `<input type="text" class="js-findReplace" id="findReplace-${rowNumber}-name" data-type="name" data-al="${rowNumber}" value="${n}" style="width:40%;min-width:300px;" placeholder="Find"/>`;
    var valueField = `<input type="text" class="js-findReplace" id="findReplace-${rowNumber}-value" data-type="value" data-al="${rowNumber}" value="${v}" style="width:40%;min-width:300px;" placeholder="Replace with"/>`;
    var wrapper = `<div id="findReplaceWrapper-${rowNumber}" style="clear:both;">${nameField}${valueField}${btn}</div>`;
    return wrapper;
};


