//Namespaces
var salesforceFlow = salesforceFlow || {};

(app => {
    app.bindings = app.bindings || {};
    app.template = app.template || {};
    app.param = app.param || {};
    //Properties
    app.flowParams = [];
    app.data = {};

    app.save = function() {
        if ($copado('#jsSalesforceFlowName').val() == null) {
            alert('Please select a Flow before saving the task.');
            return false;
        }
        return JSON.stringify({
            flowApiName: $copado('#jsSalesforceFlowName').val(),
            flowLabel: $copado('#jsSalesforceFlowName option:selected').text(),
            type: $copado('#jsSalesforceFlowType').val(),
            flowParameters: app.flowParams
        });
    };

    app.setPreviousData = function(data) {
        data = data ? JSON.parse(data) : false;
        app.data = data;
        //fill or reset if field is empty
        $copado('[id=jsSalesforceFlowName]').val(data ? data.flowApiName : '');
        $copado('[id=jsSalesforceFlowType]').val(data ? data.type : 'wait');
        app.flowParams = data && data.flowParameters ? data.flowParameters : [];
        app.createChildRows(app.flowParams);
    };

    app.setPreviousDataView = function(data) {
        data = data ? JSON.parse(data) : false;
        //fill or reset if field is empty
        const selectElement = document.getElementById('jsSalesforceFlowNameView');
        const node = document.createElement('option');
        node.value = data.flowApiName;
        const textnode = document.createTextNode(data.flowLabel);
        node.appendChild(textnode);
        selectElement.appendChild(node);
        $copado('[id=jsSalesforceFlowNameView]').val(data ? data.flowApiName : '');
        $copado('[id=jsSalesforceFlowTypeView]').val(data ? data.type : 'wait');
        app.flowParams = data && data.flowParameters ? data.flowParameters : [];
        app.createStaticChildRows(app.flowParams);
    };

    /*
     *  This method will create the rows depending on which type is selected (for as Header or as Param).
     *  type = param | header
     *   return {[]}
     */
    app.createChildRows = function(array) {
        var parentId = 'flowParameters';

        var parent = document.getElementById(parentId) || {};
        while (parent.firstChild) {
            parent.removeChild(parent.firstChild);
        }

        if (array.length == 0) {
            app.flowParams = [];
            return;
        }
        for (var i = 0; i < array.length; i++) {
            var wrapper = app.template.paramRow(i, array[i]);
            $copado(wrapper).appendTo('#' + parentId);
        }
    };

    app.createStaticChildRows = function(array) {
        var parentId = 'flowParametersView';

        var parent = document.getElementById(parentId);
        while (parent.firstChild) {
            parent.removeChild(parent.firstChild);
        }

        if (array.length == 0) {
            app.flowParams = [];
            return;
        }
        for (var i = 0; i < array.length; i++) {
            var wrapper = app.template.staticParamRow(i, array[i]);
            $copado(wrapper).appendTo('#' + parentId);
        }
    };

    app.saveParams = function($obj) {
        var me = salesforceFlow;
        var al = $obj ? $obj.data('al') : 0;
        var at = $obj ? $obj.data('type') : '';

        if ($obj) me.flowParams[al] = [at == 'name' ? $obj.val() : me.flowParams[al][0], at == 'value' ? $obj.val() : me.flowParams[al][1]];
    };

    /* BINDINGS METHODS */
    app.bindings.paramKeyUp = function() {
        $copado('div[id=flowParameters]').on('keyup', '.js-param', function(event) {
            if ((event.which >= 16 && event.which <= 20) || (event.which >= 36 && event.which <= 40)) return;
            app.saveParams($copado(this));
        });
    };

    app.bindings.bindActions = function() {
        app.bindings.paramKeyUp();
    };

    app.createHtmlFlowOptionsElements = function(flowOptions) {
        const selectElement = document.getElementById('jsSalesforceFlowName');
        if (selectElement.childElementCount === 0) {
            if(flowOptions.length === 0){
                const node = document.createElement('option');
                node.value = null;
                node.disabled = "disabled";
                const textnode = document.createTextNode(copadoLabels.NO_SALESFORCE_FLOWS_AVAILABLE);
                node.appendChild(textnode);
                selectElement.appendChild(node);
            }
            for (const flow of flowOptions) {
                const node = document.createElement('option');
                node.value = flow['flowApiName'];
                const textnode = document.createTextNode(flow['flowLabel']);
                node.appendChild(textnode);
                selectElement.appendChild(node);
            }
            $copado('[id=jsSalesforceFlowName]').val(app.data ? app.data.flowApiName : '');
        }
    };

    /* PARAM METHODS */
    app.param.addRow = function() {
        var wrapper;
        var parentId = 'flowParameters';
        wrapper = app.template.paramRow(app.flowParams.length, null);
        app.flowParams.push(['', '']);
        $copado(wrapper).appendTo('#' + parentId);
    };
    app.param.deleteRow = function(i) {
        app.flowParams.splice(i, 1);
        app.createChildRows(app.flowParams, 'param');
    };

    /*
        Pre-save validation method to ensure we don't have empty params.
    */
    app.param.validate = function() {
        var isValid = true;
        var params = app.flowParams;
        for (var i = 0; i < params.length; i++) {
            if (isValid == false) break;
            isValid = params[i][0].length > 0 && params[i][1].length > 0;
        }
        return isValid;
    };

    /* TEMPLATES */
    app.template.paramRow = function(rowNumber, keyPair) {
        var n = keyPair ? keyPair[0] : '';
        var v = keyPair ? keyPair[1] : '';
        if (typeof datasetup === 'undefined') {
            var btn =
                '<button style="margin: 0.5rem" id="del-param-' +
                rowNumber +
                '" onclick="salesforceFlow.param.deleteRow(' +
                rowNumber +
                '); return false;" class="btn copado-lightning">Delete</button';
            var nameField =
                '<input type="text" style="margin: 0.5rem 0.5rem 0.5rem 0rem" placeholder="Parameter Name" class="js-param" id="param-' +
                rowNumber +
                '-name" data-type="name" data-al="' +
                rowNumber +
                '" value="' +
                n +
                '" />';
            var valueField =
                '<input type="text" style="margin: 0.5rem" placeholder="Value" class="js-param" id="param-' +
                rowNumber +
                '-value" data-type="value" data-al="' +
                rowNumber +
                '" value="' +
                v +
                '" />';
            var wrapper = '<div id="paramWrapper-' + rowNumber + '" style="clear:both;">' + nameField + valueField + btn + '</div>';
            return wrapper;
        } else {
            var btn =
                '<button id="del-param-' +
                rowNumber +
                '" onclick="salesforceFlow.param.deleteRow(' +
                rowNumber +
                '); return false;" class="btn slds-button slds-button--neutral">Delete</button>';
            var nameField =
                '<input type="text" placeholder="Parameter Name" class="js-param slds-input" id="param-' +
                rowNumber +
                '-name" data-type="name" data-al="' +
                rowNumber +
                '" value="' +
                n +
                '" />';
            var valueField =
                '<input type="text" placeholder="Value" class="js-param slds-input" id="param-' +
                rowNumber +
                '-value" data-type="value" data-al="' +
                rowNumber +
                '" value="' +
                v +
                '" />';
            var wrapper =
                '<div class="slds-grid slds-m-vertical_medium" id="paramWrapper-' +
                rowNumber +
                '" style="clear:both;"><div class="slds-col">' +
                nameField +
                '</div><div class="slds-col">' +
                valueField +
                '</div><div class="slds-col">' +
                btn +
                '</div></div>';
            return wrapper;
        }
    };

    app.template.staticParamRow = function(rowNumber, keyPair) {
        var n = keyPair ? keyPair[0] : '';
        var v = keyPair ? keyPair[1] : '';

        var nameField =
            '<input disabled type="text" placeholder="Parameter Name" class="js-param slds-input" id="param-' +
            rowNumber +
            '-name" data-type="name" data-al="' +
            rowNumber +
            '" value="' +
            n +
            '" />';
        var valueField =
            '<input disabled type="text" placeholder="Value" class="js-param slds-input" id="param-' +
            rowNumber +
            '-value" data-type="value" data-al="' +
            rowNumber +
            '" value="' +
            v +
            '" />';
        var wrapper =
            '<div class="slds-grid slds-m-vertical_medium" id="paramWrapper-' +
            rowNumber +
            '" style="clear:both;"><div class="slds-col">' +
            nameField +
            '</div><div class="slds-col">' +
            valueField +
            '</div></div>';
        return wrapper;
    };
})(salesforceFlow);
