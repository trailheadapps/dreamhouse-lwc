/**
 * Backend code. No UI should be used here ( except for simple UI.show*() messages )
 * User-triggered methods should be named .do*() and have a callback(response, exception)
 * Exceptions visible to the user are handled in the UI, so every .do*() method should have a try/catch
 * All UI data should be handled via CopadoKanban.getUIData()
 * User messages go to UI.msg.LABEL = TEXT
 */
var NS = '';
var CopadoKanban = {};

CopadoKanban.boardData = {
    items: [],
    statusList: [],
    JSON_Settings: {states: [], fieldNamesLabels: {}},
    itemObjectName: null, // name of the object that represents an item. E.G. User_Story__c
    itemFieldName: null // name of the field that represents an item status. E.G. Status__c
};
CopadoKanban.itemIdxMap = {};


// String formatting
// formatString("{0} is dead, but {1} is alive! {0} {2}", "ASP", "ASP.NET")
function formatString() {
    var args = [];
    Array.prototype.push.apply(args, arguments);
    return args.shift().replace(/{(\d+)}/g, function (match, number) {
        return typeof args[number] != 'undefined' ? args[number] : match;
    });
}

// Polyfill for IE
if (!String.prototype.startsWith) {
    String.prototype.startsWith = function(searchString, position){
      position = position || 0;
      return this.substr(position, searchString.length) === searchString;
  };
}

function CopadoException(message) {
    this.message = message;
}
CopadoException.prototype = Object.create(Error.prototype);
CopadoException.prototype.message = "";
CopadoException.prototype.constructor = CopadoException;
CopadoException.prototype.toString = function () {
    return this.message;
};


function isEmptyString(s) {
    return !(s && s.trim && s.trim());
}

function assert(s, e) {
    if (!s) throw new CopadoException(e);
}

function assertNotEmptyString(s, e) {
    if (typeof s !== 'string') throw e;
    if (isEmptyString(s)) throw new CopadoException(e);
}

function sobjectsAddNamespace(sobjects, ns) {
    if (!ns) return;
    for (var i = 0; i < sobjects.length; i++) {
        var item = sobjects[i];
        for (var k in item) {
            if (item.hasOwnProperty(k) && k !== 'Id' && k !== 'Name' && k !== 'type') {
                item[ns + k] = item[k];
                delete item[k];
            }
        }
    }
}

function sobjectsRemoveNamespace(sobjects, ns) {
    if (!ns) return;

    for (var i = 0; i < sobjects.length; i++) {
        var item = sobjects[i];
        for (var k in item) {
            if (item.hasOwnProperty(k) && k.startsWith(ns)) {
                item[k.substr(ns.length, k.length)] = item[k];
                delete item[k];
            }
        }
    }
}

/**
 * Validate/Parse the values when creating/updating the fields.
 * No required field validation takes place here, since it must work on creation as well, with all fields empty
 *
 * @param rec
 */
CopadoKanban.validateStatusList = function (rec) {
    var t;

    var ckb = CopadoKanban.boardData;

    // Validate Field_to_read_update__c
    if (!isEmptyString(rec.Field_to_read_update__c)) {
        t = rec.Field_to_read_update__c.trim().split('.');
        assert(t.length === 2 && t[0] && t[1] && t[0].trim() && t[1].trim(), formatString(CopadoKanban.UI.msg.INVALID_VALUE, "Field_to_read_update__c ( OBJECT.FIELD )"));
        ckb.itemObjectName = t[0];
        ckb.itemFieldName = t[1];
    }

    // Validate Columns_SOQL__c
    if (!isEmptyString(rec.Columns_SOQL__c)) {
        assertNotEmptyString(rec.Columns_SOQL__c, formatString(CopadoKanban.UI.msg.INVALID_VALUE, "Columns_SOQL__c ( SELECT ... )"));
        assert(rec.Columns_SOQL__c.trim().toLowerCase().startsWith('select'),
            formatString(CopadoKanban.UI.msg.INVALID_VALUE, "Columns_SOQL__c ( SELECT ... )"))
    }

    // try to parse the JSON that hold the states, and check that it's a non-empty set
    if (rec.JSON_Settings__c) {
        try {
            rec.JSON_Settings = JSON.parse(rec.JSON_Settings__c || '{}');
            for (var k in rec.JSON_Settings) {
                if (rec.JSON_Settings.hasOwnProperty(k)) {
                    ckb.JSON_Settings[k] = rec.JSON_Settings[k];
                }
            }
        } catch (e) {
            console.error(e);
            assert(false, formatString(CopadoKanban.UI.msg.INVALID_VALUE, "JSON_Settings__c ( JSON value expected )"));
        }
    }
};

CopadoKanban.validateForm = function (rec) {
    var ckb = CopadoKanban.boardData;

    assertNotEmptyString(rec.Field_to_read_update__c, formatString(CopadoKanban.UI.msg.REQUIRED_VALUE, "Field_to_read_update__c"));
    CopadoKanban.validateStatusList(rec);

    assert(ckb.JSON_Settings.states && ckb.JSON_Settings.states.length,
        formatString(CopadoKanban.UI.msg.INVALID_VALUE, "States list needs at least an element"));

    // Validate SOQL_Query__c
    if (!isEmptyString(rec.SOQL_Query__c)) {
        assertNotEmptyString(rec.SOQL_Query__c, formatString(CopadoKanban.UI.msg.INVALID_VALUE, "SOQL_Query__c ( SELECT ... )"));
        assert(rec.SOQL_Query__c.trim().toLowerCase().startsWith('select'),
            formatString(CopadoKanban.UI.msg.INVALID_VALUE, "SOQL_Query__c ( SELECT ... )"))
    }

    // refresh the describe cache, which in turns fills out JSON_Settings.fieldNamesLabels
    CopadoKanban.fetchDescribeSobject();
};

/**
 * Load & validate the data coming from SF.
 *
 * @param callback
 */
CopadoKanban.fetchSFData = function (callback) {
    CopadoKanban.boardData.items = [];

    // validate and parse the status list json data.
    CopadoKanban.validateStatusList(CopadoKanban.boardData);

    try {
        var result = sforce.connection.query(CopadoKanban.boardData.SOQL_Query__c);
        var it = new sforce.QueryResultIterator(result);
        var rec_count = 0;
        while (it.hasNext()) {
            var rec = it.next();

            // join every additional field in item using a newline
            // so the text of each item is: value1; value2; ...
            // including sub-fields, such as Owner.Name
            var fields = JSON.parse(JSON.stringify(rec));
            delete fields.type;
            delete fields.attributes;
            delete fields.Id;
            delete fields[CopadoKanban.boardData.itemFieldName];
            var buf = [], textParts = [];
            for (var k in fields) {
                if (fields.hasOwnProperty(k)) {
                    if (fields[k] && typeof fields[k] === 'object') {
                        delete fields[k].Id;
                        delete fields[k].type;
                        delete fields[k].attributes;
                        for (var k1 in fields[k]) {
                            if (fields[k].hasOwnProperty(k1) && fields[k][k1]) {
                                buf.push(fields[k][k1]);
                                textParts[k + '.' + k1] = fields[k][k1];
                            }
                        }
                        continue;
                    }
                    buf.push(fields[k]);
                    textParts[k] = fields[k];
                }
            }

            // Pick the first TEXT field as the item title.
            // NOTE: it used to be the Name field exclusively, but we changed it.
            var itemTitle = undefined;
            for (var k in textParts) {
                if (textParts.hasOwnProperty(k)) {
                    console.warn(k, textParts[k],rec);
                    itemTitle = textParts[k];
                    delete textParts[k]; // remove it to avoid duplication.
                    break;
                }
            }

            // Validate each item as it is being loaded.
            assert(itemTitle !== undefined,
                formatString(CopadoKanban.UI.msg.INVALID_VALUE, "SOQL record #" + rec_count + " does not have a single text field. " + JSON.stringify(rec)));
            assert(rec.hasOwnProperty(CopadoKanban.boardData.itemFieldName),
                formatString(CopadoKanban.UI.msg.INVALID_VALUE, "SOQL record #" + rec_count + " does not have field " +
                    CopadoKanban.boardData.itemFieldName + ". " + JSON.stringify(rec)));


            var item = {
                id: rec.Id,
                name: itemTitle,
                status: rec[CopadoKanban.boardData.itemFieldName] || '',
                text: buf.join('; '),
                textParts: textParts
            };
            CopadoKanban.boardData.items.push(item);
            CopadoKanban.itemIdxMap[rec.Id] = item;

            rec_count++;
        }
    } catch (e) {
        e.prevStack = e.stack; // chrome workaround
        console.warn(e.stack);
        e.message = formatString(CopadoKanban.UI.msg.SALESFORCE_ERROR, "SOQL_Query__c", e.faultstring ? e.faultstring : String(e));
        throw e;
    }

    callback ? callback() : null;
};

CopadoKanban.fetchDescribeSobject = function () {
    var ckb = CopadoKanban.boardData;
    if (ckb.cachedDescribe) {
        return ckb.cachedDescribe;
    }
    var describe = sforce.connection.describeSObject(ckb.itemObjectName);
    // find the field matching name == ckb.itemFieldName
    ckb.JSON_Settings.fieldNamesLabels = ckb.JSON_Settings.fieldNamesLabels || {};
    for (var i = 0; i < describe.fields.length; i++) {
        ckb.JSON_Settings.fieldNamesLabels[describe.fields[i].name] = describe.fields[i].label;
    }
    ckb.cachedDescribe = describe;
    return describe;
};

/**
 * Returns the array needed to render the information
 * see CopadoKanban.boardData for details
 */
CopadoKanban.getUIData = function () {
    return CopadoKanban.boardData;
};

/**
 * Fill the list fo states with values on salesforce
 *
 * @param fromSource where to fill the values from, Field_to_read_update__c or Columns_SOQL__c
 * @param rec hash with the fields .statusList .Field_to_read_update__c, .Columns_SOQL__c
 * @param callback
 */
CopadoKanban.doGenerateStatusList = function (rec, fromSource, callback) {
    var i;
    assert(rec, "General error");
    console.debug("CopadoKanban.doGenerateStatusList", fromSource, rec);

    var ckb = CopadoKanban.boardData;

    CopadoKanban.validateStatusList(rec);

    // set the existing values JSON_Settings into newValues.
    // new values from a picklist or a SOQL will be appended.
    var newValues = ckb.JSON_Settings.states, valuesMap = {};
    for (i = 0; i < newValues.length; i++) {
        valuesMap[newValues[i].value] = newValues[i];
    }

    // helper function to accumulate every value in newValues list and valuesMap hash
    var setValue = function (id, label, checked) {
        checked = (checked === false) ? false: true;
        if (!valuesMap[id]) {
            var t = {value: id, label: label, checked: checked};
            newValues.push(t);
            valuesMap[id] = t;
        }
    };

    // If we need to retrieve the statuses from a picklist...
    if (fromSource === 'Field_to_read_update__c') {
        console.debug("SF.describe for ", ckb.itemObjectName, ckb.itemFieldName);
        try {
            var field = null;
            var describe = CopadoKanban.fetchDescribeSobject();
            // find the field matching name == ckb.itemFieldName
            for (i = 0; i < describe.fields.length; i++) {
                if (describe.fields[i].name === ckb.itemFieldName) {
                    field = describe.fields[i];
                    break;
                }
            }
            if (field && field.picklistValues && field.picklistValues.length) {
                // retrieve every picklist value
                for (i = 0; i < field.picklistValues.length; i++) {
                    setValue(field.picklistValues[i].value, field.picklistValues[i].label);
                }
                setValue("", "(empty)", false);
                console.log(field.name + " : " + field.label + " : " + field.length + " : ", newValues);
            } else {
                throw new Error(formatString("Field not found {0}.{1}", ckb.itemObjectName, ckb.itemFieldName));
            }
        } catch (e) {
            console.warn(e, e.stack);
            e.prevStack = e.stack; // chrome workaround
            e.message = formatString(CopadoKanban.UI.msg.SALESFORCE_ERROR, "Field_to_read_update__c", e.faultstring ? e.faultstring : String(e));
            throw e;
        }
    }

    // If we need to retrieve the statuses from a SOQL query...
    if (fromSource === 'Columns_SOQL__c') {
        try {
            console.log('query str',rec.Columns_SOQL__c);
            console.log('rec',rec);
            var result = sforce.connection.query(rec.Columns_SOQL__c);
            var it = new sforce.QueryResultIterator(result);
            while (it.hasNext()) {
                var item = it.next();

                // cleanup "item" fields, and join every non-ID field in item using a whitespace.
                var itemId = item.Id;
                delete item.attributes;
                delete item.type;
                delete item.Id;

                var buf = [];
                for (var k in item) {
                    if (item.hasOwnProperty(k)) {
                        buf.push(String(item[k]));
                    }
                }

                setValue(itemId, buf.join(' '));
            }
            setValue("", "(empty)", false);
        } catch (e) {
            e.prevStack = e.stack; // chrome workaround
            console.warn(e, e.prevStack);
            e.message = formatString(CopadoKanban.UI.msg.SALESFORCE_ERROR, "Columns_SOQL__c", e.faultstring ? e.faultstring : String(e));
            throw e;
        }
    }

    //ckb.JSON_Settings.states = newValues;

    callback ? callback(ckb.JSON_Settings.states) : null;
};

/**
 * Updates the status of an Item ( moving from column to column )
 * @param itemId
 * @param status
 * @param callback
 */
CopadoKanban.doChangeStatusItem = function (itemId, status, callback) {
    var item = CopadoKanban.itemIdxMap[itemId];
    item.status = status;

    // Save the status on SF.
    var sobj = new sforce.SObject(CopadoKanban.boardData.itemObjectName);
    sobj.Id = itemId;
    sobj[CopadoKanban.boardData.itemFieldName] = status;
    var result = sforce.connection.update([sobj]);
    console.debug('CopadoKanban.doChangeStatusItem', itemId, item.status, result);
    if (!result[0].getBoolean("success"))
        throw result;

    callback ? callback() : null;
};

/**
 *
 * @param boardData
 * @param callback
 */
CopadoKanban.initialize = function (boardData, callback) {

    // Copy the data preloaded from visualforce
    // and remove the namespacing
    delete boardData.attributes; // just getting rid of useless information
    for (var k in boardData) {
        if (boardData.hasOwnProperty(k)) {
            CopadoKanban.boardData[k] = boardData[k];
        }
    }
    sobjectsRemoveNamespace([CopadoKanban.boardData], NS);
    //console.log('CopadoKanban.initialize', CopadoKanban.isEditForm, JSON.stringify(CopadoKanban.boardData, null, '  '));

    if (CopadoKanban.isEditForm) {
        CopadoKanban.validateStatusList(CopadoKanban.boardData);
        callback ? callback() : null;
    } else {
        CopadoKanban.validateForm(CopadoKanban.boardData, true);
        CopadoKanban.fetchSFData(callback);
    }
};
var entityMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': '&quot;',
    "'": '&#39;',
    "/": '&#x2F;'
};
function escapeHtml(string) {
    return String(string).replace(/[&<>"'\/]/g, function (s) {
        return entityMap[s];
    });
}

CopadoKanban.UI = {
    elts: {}, // element handlers to bind.
    jqelts: {} // element handlers to bind.
};

CopadoKanban.UI.showStatus = function (msg) {
    CopadoKanban.UI.elts.statusBarElt.innerHTML = msg;
    console.info('CopadoKanban.UI.showStatus', msg);
    CopadoKanban.UI.elts.statusBarElt.style.display = msg ? 'block' : 'none';
};

CopadoKanban.UI.showError = function (msg, ex) {
    console.error('CopadoKanban.UI.showError', msg);
    CopadoKanban.UI.elts.generalErrorFrameElt.style.display = 'block';
    CopadoKanban.UI.elts.generalErrorMessageElt.innerText = msg;
};

CopadoKanban.UI.clearErrors = function () {
    console.debug('CopadoKanban.UI.clearErrors');
    CopadoKanban.UI.elts.generalErrorFrameElt.style.display = 'none';
    CopadoKanban.UI.elts.generalErrorMessageElt.innerText = '';
    CopadoKanban.UI.elts.statusBarElt.innerHTML = '';
    CopadoKanban.UI.elts.statusBarElt.style.display = 'none';
};

CopadoKanban.UI.showPrompt = function (msg, defaultValue, onSuccess, onCancel) {
    console.error('CopadoKanban.UI.showPrompt', msg);
    var val = window.prompt(msg, defaultValue);
    if (val != null) {
        onSuccess(val);
    } else if (onCancel) {
        onCancel();
    }
};

CopadoKanban.UI.showActivityDialog = function (msg, close) {
    CopadoKanban.UI.showStatus(msg);
    CopadoKanban.UI.elts.activityOverlay.style.visibility = close ? 'hidden' : 'visible';
};

CopadoKanban.UI.showConfirmation = function (msg, onConfirm, onCancel) {
    if (window.confirm(msg))
        return onConfirm();
    if (onCancel)
        onCancel();
};

CopadoKanban.UI.msg = {};
CopadoKanban.UI.msg.REQUIRED_VALUE = "Required value: {0}";
CopadoKanban.UI.msg.INVALID_VALUE = "Invalid value: {0}";
CopadoKanban.UI.msg.SALESFORCE_ERROR = "Could not retrieve {0}. Check the Board settings (Salesforce error was: {1})";
CopadoKanban.UI.msg.SAVED_KANBAN_BOARD = "Saved Kanban Board";

/*
 * Find html element references, and show/hide some CopadoKanban.UI elements, depending on the view/edit/record mode.
 * A very basic initialization before calling the main.intialize();
 */
CopadoKanban.UI.initialize = function () {
    CopadoKanban.UI.elts.statusBarElt = document.getElementById('generalStatus');
    CopadoKanban.UI.elts.generalErrorFrameElt = document.getElementById('generalErrorFrame');
    CopadoKanban.UI.elts.generalErrorMessageElt = document.getElementById('generalErrorMessage');
    CopadoKanban.UI.elts.activityOverlay = document.getElementById('overlay');
    console.log('CopadoKanban.UI.initialize', CopadoKanban.UI.elts);
};

/**
 * Prepare the Kanban object.
 *
 * @param callback
 */
CopadoKanban.UI.initializeAfterLoadingData = function (callback) {
    var i, dat = CopadoKanban.getUIData();
    console.debug('CopadoKanban.UI.initializeAfterLoadingData CopadoKanban.getUIData=', dat);

    var EMPTY_STATUS_VALUE = '(N.O.Ne]';
    var source = {
        localData: [],
        dataType: "array",
        dataFields: [
            {name: "id", type: "string"},
            {name: "content", map: "name", type: "string"},
            {name: "status", map: "status", type: "string"},
            {name: "text", map: "text", type: "string"}
        ]
    };

    source.localData = dat.items;
    var translateNameForLabel = dat.JSON_Settings.fieldNamesLabels || {};

    // pre-process the items, fixing some issues and formatting the text
    for (i = 0; i < source.localData.length; i++) {
        // jqxKanban does not seem to work with empty status, so we create a hopefully-unique string
        source.localData[i].status = source.localData[i].status || EMPTY_STATUS_VALUE;
        //if (source.localData[i].text) {
            var buf = [];
            var tp = source.localData[i].textParts;
            for (var k in tp) {
                if (tp.hasOwnProperty(k)) {
                    var l = translateNameForLabel[k] ? translateNameForLabel[k] : k;
                    buf.push("<dt><span>" + escapeHtml(l) + "</span></dt><dd>" + escapeHtml(tp[k] || '-') + "</dd>");
                }
            }
            source.localData[i].text = "<dl>" + buf.join("\n") + "</dl>";
        //} else {
        //    source.localData[i].text = "&nbsp;"
        //}
    }
    var dataAdapter = new $.jqx.dataAdapter(source);

    var opts = {
        width: "100%",
        height: 1000,
        source: dataAdapter,
        template: "<div class='jqx-kanban-item' id=''>"
        + "<div class='jqx-kanban-item-content' ></div>"
        + "<div class='jqx-kanban-template-icon' onmouseover=\"this.id=('lookup'+this.parentNode.id.replace('kanban_','')); LookupHoverDetail.getHover('lookup'+this.parentNode.id.replace('kanban_',''), '/'+this.id.replace('lookup','')+'/m?isAjaxRequest=1').show();\" onmouseout=\"LookupHoverDetail.getHover('lookup'+this.parentNode.id.replace('kanban_','')).hide();\"><a class='usLink' style='text-decoration: none' href=''>&#x26A1;</a></div>"
        + "<div class='jqx-kanban-item-text'></div>"
        + "</div>",
        templateContent: {status: "", text: "", content: "", tags: "", color: "", resourceId: 0, className: ""},
        columns: []
    };

    var stateMap = [];
    for (i = 0; i < dat.JSON_Settings.states.length; i++) {
        var r = dat.JSON_Settings.states[i];
        if (r.checked) {
            opts.columns.push({text: r.label, dataField: r.value || EMPTY_STATUS_VALUE});
        }
        stateMap[r.value || EMPTY_STATUS_VALUE] = r.label;
    }

    for (i = 0; i < source.localData.length; i++) {
        var e = source.localData[i];
        if(!stateMap[e.status]) {
            console.warn('status', e.status, 'not found in', stateMap);
        }
    }

    assert(opts.columns &&opts.columns.length,
    formatString(CopadoKanban.UI.msg.INVALID_VALUE, "No selected columns"))

    CopadoKanban.UI.jqelts.kanban = $('#kanban');

    CopadoKanban.UI.jqelts.kanban.jqxKanban(opts).on('itemMoved', function (event) {
        var args = event.args;

        // dragged and dropped on the same column? ignore
        if (!args || !args.itemData || !args.newColumn)
            return;

        var itemId = args.itemData.id;
        var newColumn = args.newColumn;

        CopadoKanban.UI.clearErrors();

        // jqxKanban does not seem to work with empty status, so we translate the empty value
        if (newColumn.dataField === EMPTY_STATUS_VALUE)
            newColumn.dataField = null;
        try {
            CopadoKanban.doChangeStatusItem(itemId, newColumn.dataField);
        } catch (e) {
            console.error(e);
            var msg = e.faultstring ? e.faultstring : (e[0] && e[0].errors && e[0].errors.message ? '' + e[0].errors.message + ' (' + e[0].errors.field + ' ' + e[0].errors.statusCode + ')' : String(e) );
            CopadoKanban.UI.showError('Could not load the data.' + msg, e);
            return false;
        }
        return true;
    });

    callback ? callback() : null;
};

/**
 * Prepare the create/edit form, particularly the jqxListBox with the columns
 *
 * @param callback
 */
CopadoKanban.UI.initializeForm = function (callback) {
    var theme = "";

    var dat = CopadoKanban.getUIData();

    var dataAdapterSel = new $.jqx.dataAdapter({
        localData: dat.JSON_Settings.states,
        dataType: "array",
        dataFields: [
            {name: "value", type: "string"},
            {name: "label", type: "string"},
            {name: "checked", type: "boolean"},
        ]
    });

    // create a new ordered list, with all the checkboxes according to the UI
    // this directly updates getUIData().Status_JSON.states
    var listChanged = function (items) {
        console.log('items=', items);
        var newList = [];
        for (var i = 0; i < items.length; i++) {
            var r = items[i];
            if (r) {
                console.debug(r);
                newList.push({value: r.value, label: r.label, checked: r.checked});
            }
        }
        var t = CopadoKanban.getUIData().JSON_Settings.states;
        t.splice(0, t.length);
        Array.prototype.push.apply(t, newList);
        document.getElementById(CopadoKanban.UI.elts.JSON_Settings__c).value = JSON.stringify(CopadoKanban.getUIData().JSON_Settings);
    }

    CopadoKanban.UI.jqelts.states = $('#listBoxSel');
    var lb = CopadoKanban.UI.jqelts.states;
    lb.jqxListBox({
        allowDrop: true,
        allowDrag: true,
        source: dataAdapterSel,
        width: 300,
        height: 250,
        theme: theme,
        checkboxes: true,
        enableSelection: true,
        dragEnd: function (dragItem, dropItem) {
            var args = event.args;
            // NOTE: dragEnd happens before actually reordering the items!
            window.setTimeout(function () {
                listChanged(lb.jqxListBox('getItems'));
            }, 10);
        }
    }).on('checkChange', function (event) {
        var args = event.args;
        listChanged(lb.jqxListBox('getItems'));
    });

    callback ? callback() : null;
};

/**
 * Create the status list from the picklist values or from the Columns_SOQL__c
 * this will MERGE the
 *
 * @param fromSource
 */
CopadoKanban.UI.doGenerateStatusList = function (fromSource, doClearAll) {
    CopadoKanban.UI.clearErrors();

    if(doClearAll) {
        // clear the list of states
        var t = CopadoKanban.getUIData().JSON_Settings.states;
        t.splice(0, t.length);

        // and now refresh the json data, and the listbox
        t = document.getElementById(CopadoKanban.UI.elts.JSON_Settings__c);
        t.value = JSON.stringify(CopadoKanban.getUIData().JSON_Settings)
        var lb = CopadoKanban.UI.jqelts.states;

        lb.jqxListBox('refresh');
        return;
    }

    var getValue = function (name) {
        //var t = document.getElementById(CopadoKanban.UI.elts[name]);
        var t = $("[data-id$="+name+"]")
        console.assert(t, 'Element CopadoKanban.UI.elts.' + name + 'not found');
        //return t.value;
        return t.val();
    };
    var rec = {
        Columns_SOQL__c: getValue('Columns_SOQL__c'),
        Field_to_read_update__c: getValue('Field_to_read_update__c')
    };
    try {
        CopadoKanban.doGenerateStatusList(rec, fromSource, function (states) {
            console.debug("doGenerateStatusList states =", states, CopadoKanban.getUIData().JSON_Settings);
            var t = document.getElementById(CopadoKanban.UI.elts.JSON_Settings__c);
            t.value = JSON.stringify(CopadoKanban.getUIData().JSON_Settings);
            var lb = CopadoKanban.UI.jqelts.states;
            lb.jqxListBox('refresh');
            //CopadoKanban.UI.refreshItems(states);
        });
    } catch (e) {
        console.error(e, e.stack, e.prevStack);
        var msg = e.faultstring ? e.faultstring : String(e);
        return CopadoKanban.UI.showError(msg, e);
    }
};

CopadoKanban.UI.doValidateForm = function () {
    CopadoKanban.UI.clearErrors();

    var getValue = function (name) {
        var t = $("[data-id$="+name+"]")
        //var t = document.getElementById(CopadoKanban.UI.elts[name]);
        //return t ? t.value : null;
        return t ? t.val() : null;
    };
    var rec = {
        SOQL_Query__c: getValue('SOQL_Query__c'),
        Columns_SOQL__c: getValue('Columns_SOQL__c'),
        Field_to_read_update__c: getValue('Field_to_read_update__c')
    };

    try {
        CopadoKanban.validateForm(rec, true);
    } catch (e) {
        console.error(e, e.stack);
        var msg = e.faultstring ? e.faultstring : String(e);
        CopadoKanban.UI.showError(msg, e);
        return false;
    }
    // always re-create the JSON_Settings__c field, in case the describesobject is different
    var t = document.getElementById(CopadoKanban.UI.elts.JSON_Settings__c);
    t.value = JSON.stringify(CopadoKanban.getUIData().JSON_Settings)
    return true;
};

CopadoKanban.UI.refreshItems = function (items) {
    //console.debug('CopadoKanban.UI.refreshItems', items, CopadoKanban.getUIData().JSON_Settings.states);
    CopadoKanban.UI.jqelts.states.jqxListBox('refresh');
};