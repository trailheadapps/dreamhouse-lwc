var apexTestResult = {
    ns: '',    
    userStory: [],
    attachmentBody: '',
    userStoryClassesArray: [],
    userStoryTriggersArray: [],
    namespace: '',
    testClassesArray: [],
    globalObject: {},
    classCoverageResults: [],
    triggerCoverageResults: [],
    testClassResults: [],
    orgTestClasses: [],
    showError: false,
    renderTables: true,
    hasApexCode: false,
    orgCoverage: 0,
    userStoryCoverage: 0,
    orgCoverageTotal: 0,
    userStoryCoverageTotal: 0,
    userStoryItemsCount: 0,

    totalLines: 0,
    linesNotCovered: 0,

    maxretries: 30,
    retries: 0,

    triggersWithoutCoverage: 0,
    classesWithoutCoverage: 0,
    failingMethods: 0,
    
    showErrorMessage: function(){
        var me = apexTestResult;
        me.showError = true;
        me.renderTables = false;
    },

    updateEnvironmentCodeCoverage: function(){
        var me = apexTestResult;
        if(copadoApp.envId && !isNaN(me.orgCoverage)) {
            var env = new sforce.SObject(me.ns+'Environment__c');
            env.Id = copadoApp.envId;
            env[me.ns+'Current_Code_Coverage__c'] = me.orgCoverage;
            result = sforce.connection.update([env]);
            if (result[0].getBoolean("success")) {
                console.log('Env successfully updated.');
            }else{
                console.error('Env could not be updated.');
            }
        }else{
            console.warn("No Environment ID or code coverage present, nothing to update", copadoApp.envId, me.orgCoverage);
        }
    },
    getAttachment: function(){
        var me = apexTestResult;
        try{
            var result = sforce.connection.query("Select Id, Body from Attachment where Id='"+copadoApp.attachmentId+"' limit 1");
            records = result.getArray("records");
            console.log('Attachments found: '+records.length);
            me.attachmentBody = Base64.decode(records[0].Body);
            return records[0];
        }
        catch(error){
            me.showErrorMessage();
            console.error('Error getting attachment: '+error);
        }
    },
    getUserStoryAttachment: function(name, parentId){
        var me = apexTestResult;
        try{
            let result = sforce.connection.query("Select Id, Name, Body from Attachment where Name='"+name+"' and ParentId='"+parentId+"' Order By LastModifiedDate DESC limit 1");
            records = result.getArray("records");
            return records;
        }
        catch(error){
            console.error('Error getting attachment by name and parentId: '+error);
            return;
        }
    },
    getUserStoryAllAttachments: function(name, parentId){
        try{
            let result = sforce.connection.query("Select Id from Attachment where Name='"+name+"' and ParentId='"+parentId+"'");
            var records = result.getArray("records");
            return records;
        }
        catch(error){
            console.error('Error getting all attachment by name and parentId: '+error);
            return;
        }
    },
    getUserStoryMetadataRecords: function(userStoryId) {
        var me = apexTestResult;
        try {
            // NOTE: this will fail if any of this fields have no FLS for the current user.
            var result = sforce.connection.query(("SELECT {Co}Metadata_API_Name__c, {Co}Type__c FROM {Co}User_Story_Metadata__c WHERE {Co}User_Story__c = '" + userStoryId + "'").replace(/\{Co\}/g, me.ns));

            records = result.getArray("records");
            return records;
        }
        catch(error){
            console.error('Error getting child user story metadata records by user story id: '+error);
            return;
        }
    },
    getOrgTestClasses: function(cb){
        var me = apexTestResult;

        var useBackendLogic = true;
        var isUsingDxExtension = me.isUsingDxExtension();
        if (isUsingDxExtension) {
            var core = me.ns ? window[me.ns.split('__')[0]] : window;

            core.RetrieveOrgTestClasses.isApexTestsV2ToggleOff(function (result, event) {
                if (event.status) {
                    if (result == true) {
                        useBackendLogic = false;
                        newApexLogic();
                    } else {
                        useBackendLogic = true;
                    }
                } else {
                    useBackendLogic = true;
                }

                if (useBackendLogic) {
                    oldBackendLogic();
                }
            });
        } else {
            oldBackendLogic();
        }

        function newApexLogic() {
            core.RetrieveOrgTestClasses.execute(me.userStory[me.ns + 'Org_Credential__c'], function (result, event) {
                if (event.status) {
                    result = JSON.parse(result.replaceAll('&quot;', '"'));
                    var testClasses = result.searchRecords;

                    for (var i = 0; i < testClasses.length; i++) {
                        me.orgTestClasses.push(testClasses[i].Name);
                    }

                    cb();
                } else {
                    if (me.retries >= me.maxretries) {
                        console.error('Maximum retries were reached.');
                        return false;
                    }
                    setTimeout(function () {
                        me.getOrgTestClasses(cb);
                        me.retries++;
                    }, 2000);
                }
            });
        }

        function oldBackendLogic() {

            url = copadoApp.urlBase+'testClasses/'+copadoApp.orgId+copadoApp.urlParameters;

            console.log('getOrgTestClasses, ', url);
        
            utilsV2.onSuccessCB = function(res){
                console.log('getOrgTestClasses callback, Raw', res);
                var obj = $copado.parseJSON(res);
                console.log('getOrgTestClasses callback, ', obj);
            
                if(obj.ok){ //we have to check ok having a value, because is where heroku is setting the msg
                    if(me.retries>=me.maxretries){
                        console.error('Maximum retries were reached.');
                        return false;
                    }
                    setTimeout(function(){
                        me.getOrgTestClasses(cb);
                        me.retries++;
                    }, 2000);
                }
                else{
                    //checking is the response is an array we get sure that heroku has retrieved the list of classes
                    if(obj instanceof Array){
                        for(var i=0; i<obj.length; i++){
                            me.orgTestClasses.push(obj[i].n);
                        }
                        cb();

                    }                
                }            
            }
            utilsV2.getRemote(url);
        }
    },
    getUserStoryAttachments: function(){
        var me = apexTestResult;
        try{
            var result = me.getUserStoryAttachment('MetaData', copadoApp.userStoryId);
            var len = 0;
            if(result.length > 0){
                var obj = $copado.parseJSON(Base64.decode(result[0].Body));
                len = Object.keys(obj).length;
                for(var z=0; z<len; z++){
                    var ns = obj[z].n.split('__').length>1?obj[z].n.split('__')[0]:'';
                    var cl = {n:obj[z].n, ns:ns};
                    if(obj[z].t=='ApexClass')me.userStoryClassesArray.push(cl);
                    if(obj[z].t=='ApexTrigger')me.userStoryTriggersArray.push(cl);
                }
            }
            var gitResult = me.getUserStoryAttachment('Git MetaData', copadoApp.userStoryId);
            var len = 0;
            if(gitResult.length > 0){
                var obj = $copado.parseJSON(Base64.decode(gitResult[0].Body));
                len = Object.keys(obj).length;
                for(var z=0; z<len; z++){
                    var ns = obj[z].n.split('__').length>1?obj[z].n.split('__')[0]:'';
                    var cl = {n:obj[z].n, ns:ns};
                    if(obj[z].t=='ApexClass')me.userStoryClassesArray.push(cl);
                    if(obj[z].t=='ApexTrigger')me.userStoryTriggersArray.push(cl);
                }
            }
            var testOnly = me.getUserStoryAttachment('Test Classes', copadoApp.userStoryId);
            var len = 0;
            if(testOnly.length > 0){
                var obj = $copado.parseJSON(Base64.decode(testOnly[0].Body));
                len = Object.keys(obj).length;
                for(var z=0; z<len; z++){
                    var ns = obj[z].n.split('__').length>1?obj[z].n.split('__')[0]:'';
                    var cl = {n:obj[z].n, ns:ns};
                    me.userStoryClassesArray.push(cl);
                }
            }

            var isUsingDxExtension = me.isUsingDxExtension();
            if (isUsingDxExtension) {
                var metadataRecords = me.getUserStoryMetadataRecords(copadoApp.userStoryId);

                for(var i = 0; i < Object.keys(metadataRecords).length; i++){
                    var metadataRecord = metadataRecords[i];

                    var fileName = metadataRecord[me.ns + 'Metadata_API_Name__c'];
                    var fileType = metadataRecord[me.ns + 'Type__c'];
                    var ns = fileName.split('__').length > 1 ? fileName.split('__')[0] : '';
                    var item = {n:fileName, ns:ns};

                    if (fileType == 'ApexClass') {
                        me.userStoryClassesArray.push(item);
                    }

                    if (fileType == 'ApexTrigger') {
                        me.userStoryTriggersArray.push(item);
                    }
                    
                }
            }

            return;
        }
        catch(error){
            me.showErrorMessage();
            console.error('Error getting attachment: '+error);
            return;
        }
    },
    isUsingDxExtension : function() {
        var me = apexTestResult;
        var DX_PLATFORM = 'SFDX';

        var pipelinePlatform = (me.userStory[me.ns + 'Project__r'] != null) ? me.userStory[me.ns + 'Project__r'][me.ns + 'Deployment_Flow__r'][me.ns + 'Platform__c'] : me.userStory[me.ns + 'Release__r'][me.ns + 'Project__r'][me.ns + 'Deployment_Flow__r'][me.ns + 'Platform__c'];

        var environmentPlatform = me.userStory[me.ns+'Environment__r'][me.ns+'Platform__c'];

        return pipelinePlatform == DX_PLATFORM || environmentPlatform == DX_PLATFORM;
    },
    setCookie: function(cname, cvalue, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays*24*60*60*1000));
        var expires = "expires="+ d.toUTCString();
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    },
    getCookie: function (cname) {
        console.info('cname',cname);
        var name = cname + "=";
        console.info('name',name);
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            console.info('c',c);
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return false;
    },
    /**
     * This method runs the apex test
     * lock the UI in the midtime
     * And process the results
     * @return {[type]} [description]
     */
    runApexTests: function(){
        // var definition 
        var me = apexTestResult;
        me.setCookie('ApexTestRunning',true,1);
        var namespace = '';
        //if there is not apex selected in the userStory
        if(me.userStoryClassesArray.length==0){
            alert(copadoLabels.NO_APEX_TESTS_FOUND);
            me.setCookie('ApexTestRunning',null,0);
            return false;
        }

        //ui lock and update
        var apexTestsButton = $copado('#btnRunTests');

        lockScreen();
        setLockScreenMessage(copadoLabels.GETTING_APEX_TESTS_CLASSES);

        $copado('#divPBbuttonsLoading').show();
        apexTestsButton.attr('value', copadoLabels.INPROGRESS);
        apexTestsButton.attr('disabled', true);

        try{
            let result = me.getUserStoryAllAttachments('ApexTestResult',copadoApp.userStoryId);
            if(result.length > 0){
                const attachmentIds = result.map(result => result.Id);
                sforce.connection.deleteIds(attachmentIds);
            }
        }catch(e){
            console.error('error occured while deleting the attachment', e);
        }
        //launch the tests
        me.getOrgTestClasses(function(){

            // Merge data
            for(var i=0; i<me.userStoryClassesArray.length; i++){
                var b = $copado.inArray(me.userStoryClassesArray[i].n, me.orgTestClasses);
                if(b>-1){
                    me.testClassesArray.push(me.userStoryClassesArray[i]);
                }
            }
            if(me.testClassesArray.length==0){
                alert(copadoLabels.NO_APEX_TESTS_FOUND);
                me.setCookie('ApexTestRunning',null,0);
                $copado('#divPBbuttonsLoading').hide();
                apexTestsButton.attr('value', copadoLabels.RUN_APEX_TESTS);
                apexTestsButton.attr('disabled', false);
                unlockScreen();
                return false;
            }
            // validate only one namespace
            var uniqueNameSpaceName = '';

            //helper 
            Object.size = function(obj) {
                var size = 0, key;
                for (key in obj) {
                    if (obj.hasOwnProperty(key)) size++;
                }
                return size;
            };

            var len = Object.size(me.testClassesArray);
            var testClassList = '';
            //Check if has multiple namespaces
            for(var z=0; z<len; z++){
                if(uniqueNameSpaceName=='')uniqueNameSpaceName = me.testClassesArray[z].ns;
                if(uniqueNameSpaceName!='' && me.testClassesArray[z].ns!=uniqueNameSpaceName){
                    alert(copadoLabels.APEX_TESTS_BELONG_TO_MULTIPLE_NAMESPACES);
                    me.setCookie('ApexTestRunning',null,0);
                    return;
                }
            }

            //prepare list of testClases in string
            var names = [];
            for(var z=0; z<len; z++){
                names.push(testClassList+me.testClassesArray[z].n);
            }
            testClassList = names.join(',');

            //set namespace from first item
            me.namespace = me.testClassesArray[0].ns;
            var nsPrefix = (uniqueNameSpaceName.length == 0) ? 'none/' : uniqueNameSpaceName + '/';
            //prepare URL
            var herokuServer = copadoApp.herokuServer;
            if(copadoApp.userStoryId) {
                // this means it is a user story commit, use the new UserStoryWaitingFor page
                redirectToWaitingForPage(testClassList, nsPrefix);
                return;
            }
            var uri = herokuServer + '/json/v1/apexTest/' + copadoApp.orgId + '/' + nsPrefix + testClassList + copadoApp.urlParameters + '&parentId=' + copadoApp.userStoryId;

            console.log('before remote2', uri);

            statusManager.startProcess(function() {
                utilsV2.onSuccessCB = function(res){
                    // the API might return the metadata directly, or a job starting with a copadoJobId
                    var obj = $copado.parseJSON(res);
                    if(!obj.copadoJobId && statusManager) {
                        statusManager.setStatusComplete(); // api did not start a job
                        $copado('#divPBbuttonsLoading').hide();
                        me.setCookie('ApexTestRunning',null,0);
                        alert('Job couldn\'t be queued. Apex tests can be executed once in every minute. Please try again later.'); // Replace this with a custom label for v10.
                    }
                };
                utilsV2.getRemote(uri);
            });
            return true;
        });
    },
    /**
     * Helper to access nested objects by string key
     * @param {[type]} o [Object to be queried]
     * @param {[type]} s [String key to search for]
     * @return {[type]}  [Return object of key found or return nothing]
     */
    getObjectByString: function(o, s) {
        s = s.replace(/\[(\w+)\]/g, '.$1');  // convert indexes to properties
        s = s.replace(/^\./, ''); // strip leading dot
        var a = s.split('.');
        while (a.length) {
            var n = a.shift();
            if (n in o) {
                o = o[n];
            } else {
                return;
            }
        }
        return o;
    },
    /**
     * Helper to find element in array
     * Because IE doesnt support indexOf in Array
     * @param  {[type]} arr [description]
     * @param  {[type]} val [description]
     * @return {[type]}     [description]
     */
    valueInArray: function(arr, val) {
        return $copado.inArray(val, arr)>-1 ;
    },
    /**
     * This method creates an array that includes:
     *  the name, covetage, is include in User Story
     * @param  {[type]} source     [description]
     * @param  {[type]} result     [description]
     * @param  {[type]} sourceName [description]
     * @return {[type]}            [description]
     */
    createCoverageArray: function(source, result, sourceName){

        var me = apexTestResult;
        //key == className
        var keys = Object.keys(source);
        var userStoryItemsCount = 0;

        var useNamespace = (me.namespace.length>0) ? me.namespace + '__' : '';

        //prepare classes/trigger names for US Array
        var tmp_names = [];
        var usArray = sourceName=='classCoverageResults' ?  me.userStoryClassesArray : me.userStoryTriggersArray;

        for(var k in usArray){
            tmp_names.push(usArray[k].n);
        }

        //for each item in test results
        for(var i=0; i<keys.length; i++){

            var name = keys[i];
            var classRes = source[name];

            // get coverage or zero
            var c = (classRes && classRes.coverage) || 0;

            //Seek if key (className ) is in results
            var booly = me.valueInArray( tmp_names, useNamespace+name);

            // prepare the complete coverage row
            var row = {
                inUserStory: booly,
                name: name,
                coverage:  Math.floor(c)+'%',
                coverageStatus: (c >=copadoApp.minCodeCoverage)? copadoLabels.PASSED : copadoLabels.FAILED,
                progress:  c
            }

            if (booly && row.coverageStatus == copadoLabels.FAILED) {
                if (sourceName=='classCoverageResults') {
                    me.classesWithoutCoverage++;
                }
                else {
                    me.triggersWithoutCoverage++;
                }
            }

            result.push(row);
            console.log('create coverage array', classRes);
            me.addCoverageData(classRes, booly);
        }
    },
    /**
     * This method use two algorithm to calculate the code coverage
     * 1. By general coverage for org and old user stories
     * 2. By calculating lines covered and not covered
     * @param {[type]} classRes [description]
     */
    addCoverageData: function(classRes, booly){
        console.log('booly : ',booly);
        var me = apexTestResult;

        if(classRes && (classRes.numLocations||classRes.numLocations===0)){
            // NR: it seems classRes.numLocations can be undefined/null, or ZERO, or has a value.
            // *ONLY* when it's null/undefined/whatever, we should go to mode 1.
            me.coverageMode = 2;
            if(booly &&  copadoApp.userStoryId){
                console.log('classRes.numLocations : ',classRes.numLocations);
                me.totalLines += classRes.numLocations;
                me.linesNotCovered += classRes.numLocationsNotCovered;
            }
            if(!copadoApp.userStoryId){
                console.log('classRes.numLocations : ',classRes.numLocations);
                me.totalLines += classRes.numLocations;
                me.linesNotCovered += classRes.numLocationsNotCovered;
            }
        }
        else{
            //Algorithm 1 by coverage average
            var c = classRes.coverage || 0;
            me.coverageMode = 1;

            // calculate the total coverage
            me.orgCoverageTotal = me.orgCoverageTotal + c;
            if(booly){
                me.userStoryCoverageTotal = me.userStoryCoverageTotal + c;
                me.userStoryItemsCount++;
            }
        }
    },
    calculateCoverage: function(){
        var me = apexTestResult;

        console.log('calculate coverage')
        if(me.coverageMode == 2){
            //coverage = (1 - (notCover /totalLines)) * 100
            me.userStoryCoverage = (1 - (me.linesNotCovered /me.totalLines)) * 100;
            me.orgCoverage = me.userStoryCoverage;
            console.log('mode 2', me.userStoryCoverage, me.linesNotCovered, me.totalLines);
        }
        else{
            if(copadoApp.userStoryId){
                me.userStoryCoverage = me.userStoryCoverageTotal / (me.userStoryItemsCount);
            }
            else{
                me.orgCoverage = me.orgCoverageTotal / (me.classCoverageResults.length + me.triggerCoverageResults.length);
            }
        }
    },
    createMethodArray: function(source, result){
        var me = apexTestResult;
        var keys = Object.keys(source);
        for(var i=0; i<keys.length; i++){
            var methods = me.getObjectByString(source, keys[i]+'.methods');
            for(var j=0; j<methods.length; j++){
                var row = {};
                row['class'] = keys[i];
                row['method'] = methods[j].name;
                row['msg'] = methods[j].message;
                row['success'] = (methods[j].success)?'Passed':'Failed';
                result.push(row);

                if (row.success == 'Failed') {
                    me.failingMethods++;
                }
            }
        }
    },
    parseJSON: function(){
        var me = apexTestResult;
        if(me.attachmentBody !=''){
            me.globalObject = $copado.parseJSON(me.attachmentBody);
            me.createCoverageArray(me.globalObject.classCoverageResults, me.classCoverageResults, 'classCoverageResults');
            me.createCoverageArray(me.globalObject.triggerCoverageResults, me.triggerCoverageResults, 'triggerCoverageResults');
            me.createMethodArray(me.globalObject.testClassResults, me.testClassResults);
            me.calculateCoverage();
        }
        return false;
    },
    getUserStory: function(){
        var me = apexTestResult;

        // NOTE: this will fail if any of this fields have no FLS for the current user.
        var soql = ("Select Id, {Co}Has_Apex_Code__c, {Co}Apex_Code_Coverage__c, " +
            " {Co}Classes_Without_Coverage__c, {Co}Triggers_Without_Coverage__c, {Co}Failing_Methods__c," +
            " {Co}Project__r.{Co}Deployment_Flow__r.{Co}Platform__c," + 
            " {Co}Release__r.{Co}Project__r.{Co}Deployment_Flow__r.{Co}Platform__c," +
            " {Co}Environment__r.{Co}Platform__c, " +
            " {Co}Org_Credential__c" +
            " from {Co}User_Story__c where Id='"+copadoApp.userStoryId+"' limit 1").replace(/\{Co\}/g, me.ns);
        console.warn(soql);
        var result = sforce.connection.query(soql);
        var records = result.getArray("records");
        if(records.length == 1)me.userStory = records[0];
    },
    _init: function(){
        var me = apexTestResult;
        if(copadoApp.attachmentId == null || copadoApp.attachmentId=='' && copadoApp.userStoryId == ''){
            me.showErrorMessage();
            $copado('#errorMessage').show();
            $copado('#pbWrapper').hide();
            return false;
        }
        if(copadoApp.userStoryId == ''){
            console.log('Do parsing for Orgs');
            me.getAttachment();
        }
        else{
            //if has not org credentials 
            if(!!copadoApp.userStoryObj && !copadoApp.userStoryObj[me.ns+'Org_Credential__c']){
                $copado('#warningNoOrgCredential').show();
                $copado('#btnRunTests').hide();
                return false;
            }

            console.log('Do parsing for User Stories');
            var records = me.getUserStoryAttachment('ApexTestResult',copadoApp.userStoryId);
            if(records.length == 1){
                me.attachmentBody = Base64.decode(records[0].Body);
                me._apexTestResultAttachmentID = records[0].Id;
            }
            else{
                $copado('#warningNoTestToShow').show();                     
            }
        }
        
        if(me.showError){
            $copado('#errorMessage').show();
            return false;
        }
        if(copadoApp.userStoryId!='')me.getUserStory();
        if(!me.showError)me.getUserStoryAttachments();
        if(!me.showError)me.parseJSON();
        if(me.renderTables)$copado('#globalWrapper').show();

        // Override an additional callback, so we can capture the code coverage results
        statusManager.successFunction2 = function() {
            me.updateEnvironmentCodeCoverage();
        };

    }
};
/**** END OF NAME SPACE ****/
/**** START OF AUTO RUN CODE ****/

//handler init function 
// this is always better as a function instead of inline code
// because you can controll better when it will be executed
apexTestResult.init =  function(){
    console.info('apexTestResult.init');
    if(copadoApp.userStoryId!=''){
        $copado('runTestsTab').show();
    }
    
    apexTestResult._init();
    $grid_class = $copado('<div>');
    $grid_trigger = $copado('<div>');
    $grid_methods = $copado('<div>');
    $copado("#jqxgrid_classCoverage").html($grid_class);
    $copado("#jqxgrid_triggerCoverage").html($grid_trigger);
    $copado("#jqxgrid_testMethods").html($grid_methods);

    var source_class = {
        localdata: apexTestResult.classCoverageResults,
        datatype: "array"
    };
    var source_trigger = {
        localdata: apexTestResult.triggerCoverageResults,
        datatype: "array"
    };
    var source_methods = {
        localdata: apexTestResult.testClassResults,
        datatype: "array"
    };

    var cellsrenderer = function (row, columnfield, value, defaulthtml, columnproperties) {
        var styleColor = (value >= copadoApp.minCodeCoverage)?'success':'danger';
        var prog = "<div class='progress' style='height:20px;width:100%'>"+
            "<div class='bar bar-"+styleColor+"' style='width:"+value+"% !important;'> </div>"+
        "</div>"
        return prog;
    }
    var cellclass_success = function (row, columnfield, value) {
        if (value == copadoLabels.PASSED) {
            return 'passed';
        }
        else return 'failed';
    }
    var cellsrenderer_message = function (row, columnfield, value, defaulthtml, columnproperties) {
        var r = "<p style='width:100%; height:auto; word-wrap:break-word; margin-top:0px;'>"+value+"</p>";
        return r;
    }

    //adapter wrapper
    dataAdapter_class = new $copado.jqx.dataAdapter(source_class);
    dataAdapter_trigger = new $copado.jqx.dataAdapter(source_trigger);
    dataAdapter_methods = new $copado.jqx.dataAdapter(source_methods);

    var columns_class = [
      {text: copadoLabels.name, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'name', width: 400},
      {text: copadoLabels.COVERAGE_STATUS, filtertype:'list', cellclassname:cellclass_success, editable:false, datafield:'coverageStatus', width:100},
      {text: copadoLabels.COVERAGE, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'coverage', width: 100},
      {text: '', cellsrenderer: cellsrenderer, filtertype: 'textbox', editable:false, datafield:'progress', minwidth:400}
    ];
    var columns_trigger = [
      {text: copadoLabels.name, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'name', width: 400},
      {text: copadoLabels.COVERAGE_STATUS, filtertype:'list', cellclassname:cellclass_success, editable:false, datafield:'coverageStatus', width:100},
      {text: copadoLabels.COVERAGE, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'coverage', width: 100},
      {text: '', cellsrenderer: cellsrenderer, filtertype: 'textbox', editable:false, datafield:'progress', minwidth:400}
    ];
    var column_methods = [
      {text: copadoLabels.APEX_CLASS, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'class', width: 400},
      {text: copadoLabels.METHOD_NAME, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'method', width: 200},
      {text: copadoLabels.PASS_FAIL_COLUMN_HEADER, cellclassname: cellclass_success, filtertype: 'list', editable:false, datafield:'success', width: 100},
      {text: copadoLabels.MESSAGE, cellsrenderer: cellsrenderer_message, filtertype: 'textbox', editable:false, datafield:'msg', width:400}
    ];

    if(copadoApp.userStoryId != ''){
        columns_class= [
            {text: copadoLabels.IN_USERSTORY, filtertype:'bool', columntype: 'checkbox', editable:false, datafield:'inUserStory', width: 100, type:'bool'},  
            {text: copadoLabels.name, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'name', width: 400},
            {text: copadoLabels.COVERAGE_STATUS, filtertype:'list', cellclassname:cellclass_success, editable:false, datafield:'coverageStatus', width:100},
            {text: copadoLabels.COVERAGE, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'coverage', width: 100},
            {text: '', cellsrenderer: cellsrenderer, filtertype: 'textbox', editable:false, datafield:'progress', minwidth:400}
        ];
        columns_trigger = [
          {text: copadoLabels.IN_USERSTORY, filtertype:'bool', columntype: 'checkbox', editable:false, datafield:'inUserStory', width:100, type:'bool'},  
          {text: copadoLabels.name, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'name', width:400},
          {text: copadoLabels.COVERAGE_STATUS, filtertype:'list', cellclassname:cellclass_success, editable:false, datafield:'coverageStatus', width:100},
          {text: copadoLabels.COVERAGE, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'coverage', width:100},
          {text: '', cellsrenderer: cellsrenderer, filtertype: 'textbox', editable:false, datafield:'progress', minwidth:400}
        ];
        column_methods = [
          {text: copadoLabels.APEX_CLASS, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'class', width:400},
          {text: copadoLabels.METHOD_NAME, filtertype: 'textbox', filtercondition:'contains', editable:false, datafield:'method', width:200},
          {text: copadoLabels.PASS_FAIL_COLUMN_HEADER, cellclassname: cellclass_success, filtertype: 'list', editable:false, datafield:'success', width:100},
          {text: copadoLabels.MESSAGE, cellsrenderer: cellsrenderer_message, filtertype: 'textbox', editable:false, datafield:'msg'}
        ];
    }
    $grid_class.jqxGrid({
        width: '100%',
        autorowheight: true,
        source: dataAdapter_class,
        showfilterrow: true,
        filterable: true,
        theme: 'base',
        editable: true, 
        selectionmode: 'none',
        enablebrowserselection: true,
        pageable: true,
        pagesizeoptions: ['10', '20', '50', '100', '200', '500'],
        pagesize: 20,
        sortable: true,
        columnsresize: true,
        columns: columns_class
    });
    $grid_trigger.jqxGrid({
        width: '100%',
        autorowheight: true,
        source: dataAdapter_trigger,
        showfilterrow: true,
        filterable: true,
        theme: 'base',
        editable: true, 
        selectionmode: 'none',
        enablebrowserselection: true,
        pageable: true,
        pagesizeoptions: ['10', '20', '50', '100', '200', '500'],
        pagesize: 50,
        sortable: true,
        columnsresize: true,
        columns: columns_trigger
    });
    $grid_methods.jqxGrid({
        width: '100%',
        autorowheight: true,
        altrows: true,
        source: dataAdapter_methods,
        showfilterrow: true,
        filterable: true,
        theme: 'base',
        editable: true, 
        selectionmode: 'none',
        enablebrowserselection: true,
        pageable: true,
        pagesizeoptions: ['10', '20', '50', '100', '200', '500'],
        pagesize: 50,
        sortable: true,
        columnsresize: true,
        columns: column_methods
    });


    if(!isNaN(apexTestResult.globalObject.time)){
        var duration = reformatMilliseconds(apexTestResult.globalObject.time);
        $copado('.jstxt_Duration').text(duration);
        
        var perecent = ((apexTestResult.globalObject.tests-apexTestResult.globalObject.failures)/apexTestResult.globalObject.tests)*100
        var testPassedCalc = (apexTestResult.globalObject.tests>0)?(apexTestResult.globalObject.tests-apexTestResult.globalObject.failures)+'/'+apexTestResult.globalObject.tests+' ('+Math.floor(perecent)+'%)':'0/0 0%';
        $copado('.jstxt_TestsPassed').text(testPassedCalc);
    }
        
    if(copadoApp.userStoryId){
        if(!isNaN(apexTestResult.userStoryCoverage)){
            $copado('.jstxt_userStoryCoverage').text(Math.floor(apexTestResult.userStoryCoverage)+'%');
        }
        var url_string = location.href;
        var url = new URL(url_string);
        var reload = url.searchParams.get("rl");

        $copado('#summaryUserStory').show();
    }
    else{
        if(!isNaN(apexTestResult.orgCoverage)){
            $copado('.jstxt_Coverage').text(Math.floor(apexTestResult.orgCoverage)+'%');
            $copado('#summaryOrg').show();
        } else {
            $copado('.jstxt_Coverage').text('0%');
            $copado('#summaryOrg').show();
        }
    }
    $copado('#loadingDiv').hide();
    $copado('#globalWrapper').fadeIn();

    $copado('#jqxTabs').jqxTabs();
};
//end of init()
