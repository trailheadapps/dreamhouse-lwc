//Namespaces
var urlCallout = urlCallout || {};


((app) => {
    app.bindings = app.bindings || {};
    app.template = app.template || {};
    app.param = app.param || {};
    app.header = app.header || {};
    app.config = app.config || {};
    app.hookUrl = app.hookUrl || {};
    app.webhookLookup = app.webhookLookup || {};
    //Properties
    app.config.ns = '';
    app.config.herokuServer = '';
    app.host = '';
    app.url = '';
    app.urlParams = [];
    app.headers = [];
    app.responseUrl = '';
    app.webhookLookup.currentUrl = '';

    //LABELS
    app.config.VIEW_DOCUMENTATION = 'View Documentation';
    app.config.NAME = 'Name';
    app.config.DESCRIPTION = 'Description';

    /*Hook URL namespace*/
    app.hookUrl.show = function(){
        if(!copadoStep || !copadoStep.stepId || copadoStep.stepId.length==0){
            alert('You must save the step first before a Resume URL can be produced.');
            return false;
        }
        if(!copadoApp.data.destinations || copadoApp.data.destinations.length==0 || !copadoApp.data.destinations[0].Id){
            alert('You must have 1 Destination Org before a Resume URL can be produced.');
            return false;
        }
        app.hookUrl.get();
        return false;
    };
    app.save = function(){
        var h = app.header.encode();
        if($copado('#jsUrlCalloutType').val() == null || $copado('[id$=jsUrlCalloutUrl]').val().trim().length <=0 || $copado('[id=jsUrlCalloutMethod]').val() == null){
            alert('Please fill all required fields before saving the task.');
            return false;
        }
        return JSON.stringify({
            type: $copado('#jsUrlCalloutType').val(),
            method: $copado('#jsUrlCalloutMethod').val(),
            url: $copado('[id$=jsUrlCalloutUrl]').val(),
            body: $copado('[id$=jsUrlCalloutBody]').val(),
            queryParameters: app.urlParams,
            headers: app.headers
        });
    }
    app.setPreviousData = function(data){
        data = data ? JSON.parse(data) : false;
        //fill or reset if field is empty
        $copado('[id=jsUrlCalloutType]').val(data ? data.type : '');
        $copado('[id=jsUrlCalloutMethod]').val(data ? data.method : '');
        $copado('[id$=jsUrlCalloutUrl]').val(data ? data.url : '');
        $copado('[id$=jsUrlCalloutBody]').val(data ? data.body : '');
        app.url = (data && data.url) ? data.url : '';
        app.urlParams = (data && data.queryParameters) ? data.queryParameters : [];
        app.headers = (data && data.headers) ? data.headers : [];
        if (data && data.headers){
            app.header.decode();
        }
        app.createChildRows(app.urlParams, 'param');
        app.createChildRows(app.headers, 'header');
        app.hookUrl.toggleVisibility();
    }
    app.setPreviousDataView = function(data){
        data = data ? JSON.parse(data) : false;
        //fill or reset if field is empty
        $copado('[id=jsUrlCalloutTypeView]').val(data ? data.type : '');
        $copado('[id=jsUrlCalloutMethodView]').val(data ? data.method : '');
        $copado('[id$=jsUrlCalloutUrlView]').text(data ? data.url : '');
        $copado('[id$=jsUrlCalloutBodyView]').text(data ? data.body : '');
        app.urlParams = (data && data.queryParameters) ? data.queryParameters : [];
        app.headers = (data && data.headers) ? data.headers : [];
        if (data && data.headers){
            urlCallout.header.decode();
        }
        app.createStaticChildRows(urlCallout.urlParams, 'param');
        app.createStaticChildRows(urlCallout.headers, 'header');
    }

    app.hookUrl.hide = function(){
        $copado('#js-urlCallOut-hide-div').hide();
        $copado('#js-urlCallOut-show-div').show();
        $copado('#jsUrlCalloutResumeUrl').text('');
        app.responseUrl = '';
        return false;
    };
    app.hookUrl.get = function(){
        var ns = app.config.ns;
        console.info("ns: "+ns);

        JsRemoting.apiKey.createKey(ns,
            function(result){
                var thisJobId = JsRemoting.deploymentJobs.getJobForCalloutStep(ns, copadoStep.stepId, copadoApp.data.destinations[0].Id);
                if(thisJobId && thisJobId==''){
                    alert('The job Id for this step could not be retrieved.  Please ensure it was not deleted and reload the page.');
                    return;
                }
                app.responseUrl = 'POST  '+app.config.herokuServer+'/json/v1/webhook/resumeDeployment/'+thisJobId+'?api_key='+result+'&deploymentId='+copadoApp.data.dep.Id+'&success=TRUE';
                $copado('#js-urlCallOut-hide-div').show();
                $copado('#js-urlCallOut-show-div').hide();
                $copado('#jsUrlCalloutResumeUrl').text(app.responseUrl);
            }, function(event){
                alert('Exception: '+event.message);
            }, function(event){
                alert('Error: '+event.message);
            }
        );
    };
    app.hookUrl.toggleVisibility = function(){
        if($copado('[id=jsUrlCalloutType]').val()=='wait'){
            $copado('[id$=js-stepBlock-UrlCallout-ResumeUrl]').show();
        }
        else{
            $copado('[id$=js-stepBlock-UrlCallout-ResumeUrl]').hide();
        }
    };

    /*
     *  This method will parse the url and create the params list
     *  return {[]}  nothing
    */
    app.parseUrl = function(value){
        var parseUrl = value;
        if(value==''){
            var parent = document.getElementById('urlCalloutUrlParameters');
            while (parent.firstChild) {
                parent.removeChild(parent.firstChild);
            }
            app.urlParams = [];
        }

        var query="";
        if(value.indexOf("?")>-1){
            query=value.substring(value.indexOf("?"));
            value=value.substring(0,value.indexOf("?"));
        }
        app.host = value;
        app.url = value+query;
        app.urlParams = app.paramsToObject(query);
        app.createChildRows(app.urlParams, 'param');
    };

    /*
     *  converts string parameters to object and sets against urlParams
     *  return { array }  object array
    */
    app.paramsToObject = function(value){
        var value = (value.charAt(0) === '?')?value.substr(1):value;
        if(value.indexOf("=") == -1)return app.urlParams;
        var kvps = value.replace(/&/g, '|');
        kvps = kvps.split('|');
        app.urlParams = [];
        for(var i=0; i<kvps.length; i++){
            var pair = kvps[i].split('=');
            if(pair.length==2){
                app.urlParams.push([pair[0], pair[1]]);
            }
            if(pair.length==0){
                app.urlParams.push(['', '']);
            }
            if(pair.length==1){
                app.urlParams.push([pair[0], '']);
            }
        }
        return app.urlParams;
    };

    /*
     *  This method will create the rows depending on which type is selected (for as Header or as Param).
     *  type = param | header
     *   return {[]}
    */
    app.createChildRows = function(array, type){
        var parentId = (type=='param')?'urlCalloutUrlParameters':'urlCalloutUrlHeaders';

        var parent = document.getElementById(parentId);
        while (parent.firstChild) {
            parent.removeChild(parent.firstChild);
        }

        if(array.length==0 && type=='param'){
            app.urlParams = [];
            return;
        }
        for(var i=0; i<array.length; i++){
            var wrapper = (type=='param')?app.template.paramRow(i, array[i]):app.template.headerRow(i, array[i]);
            $copado(wrapper).appendTo('#'+parentId);
        }
    };
    /**
     * [createChildRows description]
     * @param  {[type]} array [description]
     * @param  {[type]} type  [description]
     * @return {[type]}       [description]
     */
    app.createStaticChildRows = function(array, type){
        var parentId = (type=='param')?'urlCalloutUrlParametersView':'urlCalloutUrlHeadersView';

        var parent = document.getElementById(parentId);
        while (parent.firstChild) {
            parent.removeChild(parent.firstChild);
        }

        if(array.length==0 && type=='param'){
            app.urlParams = [];
            return;
        }
        for(var i=0; i<array.length; i++){
            var wrapper = (type=='param')?app.template.staticParamRow(i, array[i]):app.template.staticHeaderRow(i, array[i]);
            $copado(wrapper).appendTo('#'+parentId);
        }
    };

    /*
     *  Convert the object array to a flat string url
     *  return { string }  the flattened url
    */
    app.paramsToUrl = function($obj){
        var me = urlCallout;
        var al = $obj?$obj.data('al'):0;
        var at = $obj?$obj.data('type'):'';

        //set host if not already set
        if(me.host=='' && me.url!=''){
            if(me.url.indexOf("?")>-1){
                me.host = me.url.substring(0,me.url.indexOf("?"));
            }
            else{
                me.host = me.url;
            }
        }

        var url = me.host;
        if($obj)me.urlParams[al] = [(at=='name')?$obj.val():me.urlParams[al][0], (at=='value')?$obj.val():me.urlParams[al][1]];
        var data = me.urlParams;
        for(var i=0; i<data.length; i++){
            url = url+((i==0)?'?':'&')+data[i][0]+'='+data[i][1];
        }
        me.url = url;
        $copado('[id$=jsUrlCalloutUrl]').val(url);
        return url;
    };

    /*
     *  The object of the field that cause this method to be triggered is called.
     *  $obj = jQuery object for field
     *  return {[]} nothing
    */
    app.setHeaderProperty = function($obj){
        var al = $obj?$obj.data('al'):0;
        var at = $obj?$obj.data('type'):'';
        if($obj)app.headers[al] = [(at=='name')?$obj.val():app.headers[al][0], (at=='value')?$obj.val():app.headers[al][1]];
    };


    /* BINDINGS METHODS */
    app.bindings.headerKeyUp = function(){
        $copado('#urlCalloutUrlHeaders').on('keyup', '.js-header', function(event){
            if((event.which>=16&&event.which<=20)||(event.which>=36&&event.which<=40))return;
            app.setHeaderProperty($copado(this));
        });
    };
    app.bindings.paramKeyUp = function(){
        $copado('div[id=urlCalloutUrlParameters]').on('keyup', '.js-param', function(event){
            if((event.which>=16&&event.which<=20)||(event.which>=36&&event.which<=40))return;
            app.paramsToUrl($copado(this));
        });
    };
    app.bindings.urlKeyUp = function(){
        $copado('input[id$=jsUrlCalloutUrl]').on('keyup blur', function(event){
            app.url = $copado(this).val()
            app.parseUrl($copado(this).val());
        });
    };
    app.bindings.typeChange = function(){
        $copado('[id=jsUrlCalloutType]').on('change', function(event){
            app.hookUrl.toggleVisibility();
        });
    };
    app.bindings.bindActions = function(){
        app.bindings.urlKeyUp();
        app.bindings.paramKeyUp();
        app.bindings.headerKeyUp();
        app.bindings.typeChange();
    };

    /* PARAM METHODS */
    app.param.addRow = function(){
        var wrapper;
        var parentId = 'urlCalloutUrlParameters';
        wrapper = app.template.paramRow(app.urlParams.length, null);
        app.urlParams.push(["",""]);
        $copado(wrapper).appendTo('#'+parentId);
    };
    app.param.deleteRow = function(i){
        app.urlParams.splice(i,1);
        app.createChildRows(app.urlParams, 'param');
        app.paramsToUrl();
    };
    /*
        Pre-save validation method to ensure we don't have empty params.
    */
    app.param.validate = function(){
        var isValid = true;
        var params = app.urlParams;
        for(var i=0; i<params.length; i++){
            if(isValid==false)break;
            isValid = (params[i][0].length>0 && params[i][1].length>0);
        }
        return isValid;
    };

    /* HEADER METHODS */
    app.header.addRow = function(){
        var wrapper;
        var parentId = 'urlCalloutUrlHeaders';
        wrapper = app.template.headerRow(app.headers.length, null);
        app.headers.push(["",""]);
        $copado(wrapper).appendTo('#'+parentId);
    };
    app.header.deleteRow = function(i){
        app.headers.splice(i,1);
        app.createChildRows(app.headers, 'header');
    };
    app.header.decode = function(){
        for(var i=0; i<app.headers.length; i++){
            app.headers[i][0] = decodeURIComponent(app.headers[i][0]);
            app.headers[i][1] = decodeURIComponent(app.headers[i][1]);
        }
    };
    app.header.encode = function(){
        for(var i=0; i<app.headers.length; i++){
            app.headers[i][0] = encodeURIComponent(app.headers[i][0]);
            app.headers[i][1] = encodeURIComponent(app.headers[i][1]);
        }
    };
    /*
        Pre-save validation method to ensure we don't have empty header params.
    */
    app.header.validate = function(){
        var isValid = true;
        var params = app.headers;
        for(var i=0; i<params.length; i++){
            if(isValid==false)break;
            isValid = (params[i][0].length>0 && params[i][1].length>0);
        }
        return isValid;
    };

    /* TEMPLATES */
    app.template.paramRow = function(rowNumber, keyPair){
        var n = keyPair?keyPair[0]:'';
        var v = keyPair?keyPair[1]:'';
        if(typeof datasetup === "undefined"){
            var btn = '<button id="del-param-'+rowNumber+'" onclick="urlCallout.param.deleteRow('+rowNumber+'); return false;" class="btn copado-lightning">Delete</button';
            var nameField =   '<input type="text" class="js-param" id="param-'+rowNumber+'-name" data-type="name" data-al="'+rowNumber+'" value="'+n+'" />';
            var valueField = '<input type="text" class="js-param" id="param-'+rowNumber+'-value" data-type="value" data-al="'+rowNumber+'" value="'+v+'" />';
            var wrapper = '<div id="paramWrapper-'+rowNumber+'" style="clear:both;">'+nameField+valueField+btn+'</div>';
            return wrapper;
        }else{
            var btn = '<button id="del-param-'+rowNumber+'" onclick="urlCallout.param.deleteRow('+rowNumber+'); return false;" class="btn slds-button slds-button--neutral">Delete</button>';
            var nameField =   '<input type="text" class="js-param slds-input" id="param-'+rowNumber+'-name" data-type="name" data-al="'+rowNumber+'" value="'+n+'" />';
            var valueField = '<input type="text" class="js-param slds-input" id="param-'+rowNumber+'-value" data-type="value" data-al="'+rowNumber+'" value="'+v+'" />';
            var wrapper = '<div class="slds-grid slds-m-vertical_medium" id="paramWrapper-'+rowNumber+'" style="clear:both;"><div class="slds-col">'+nameField+'</div><div class="slds-col">'+valueField+'</div><div class="slds-col">'+btn+'</div></div>';
            return wrapper;

        }
    };
    app.template.headerRow = function(rowNumber, keyPair){
        var n = keyPair?keyPair[0]:'';
        var v = keyPair?keyPair[1]:'';
        if(typeof datasetup === "undefined"){
            var btn = '<button id="del-header-'+rowNumber+'" onclick="urlCallout.header.deleteRow('+rowNumber+'); return false;" class="btn copado-lightning">Delete</button';
            var nameField =   '<input type="text" class="js-header" id="header-'+rowNumber+'-name" data-type="name" data-al="'+rowNumber+'" value="'+n+'" />';
            var valueField = '<input type="text" class="js-header" id="header-'+rowNumber+'-value" data-type="value" data-al="'+rowNumber+'" value="'+v+'" />';
            var wrapper = '<div id="headerWrapper-'+rowNumber+'" style="clear:both;">'+nameField+valueField+btn+'</div>';
            return wrapper;
        }else{
            var btn = '<button id="del-header-'+rowNumber+'" onclick="urlCallout.header.deleteRow('+rowNumber+'); return false;" class="btn slds-button slds-button--neutral">Delete</button>';
            var nameField =   '<input type="text" class="js-header slds-input" id="header-'+rowNumber+'-name" data-type="name" data-al="'+rowNumber+'" value="'+n+'" />';
            var valueField = '<input type="text" class="js-header slds-input" id="header-'+rowNumber+'-value" data-type="value" data-al="'+rowNumber+'" value="'+v+'" />';
            var wrapper = '<div class="slds-grid slds-m-vertical_medium" id="headerWrapper-'+rowNumber+'" style="clear:both;"><div class="slds-col">'+nameField+'</div><div class="slds-col">'+valueField+'</div><div class="slds-col">'+btn+'</div></div>';
            return wrapper;
        }


    };
    app.template.staticParamRow = function(rowNumber, keyPair){
        var n = keyPair?keyPair[0]:'';
        var v = keyPair?keyPair[1]:'';

        var nameField =   '<input disabled type="text" class="js-param slds-input" id="param-'+rowNumber+'-name" data-type="name" data-al="'+rowNumber+'" value="'+n+'" />';
        var valueField = '<input disabled type="text" class="js-param slds-input" id="param-'+rowNumber+'-value" data-type="value" data-al="'+rowNumber+'" value="'+v+'" />';
        var wrapper = '<div class="slds-grid slds-m-vertical_medium" id="paramWrapper-'+rowNumber+'" style="clear:both;"><div class="slds-col">'+nameField+'</div><div class="slds-col">'+valueField+'</div></div>';
        return wrapper;
    };
    app.template.staticHeaderRow = function(rowNumber, keyPair){
        var n = keyPair?keyPair[0]:'';
        var v = keyPair?keyPair[1]:'';

        var nameField =   '<input disabled type="text" class="js-header slds-input" id="header-'+rowNumber+'-name" data-type="name" data-al="'+rowNumber+'" value="'+n+'" />';
        var valueField = '<input disabled type="text" class="js-header slds-input" id="header-'+rowNumber+'-value" data-type="value" data-al="'+rowNumber+'" value="'+v+'" />';
        var wrapper = '<div class="slds-grid slds-m-vertical_medium" id="headerWrapper-'+rowNumber+'" style="clear:both;"><div class="slds-col">'+nameField+'</div><div class="slds-col">'+valueField+'</div></div>';
        return wrapper;
    };

})(urlCallout);