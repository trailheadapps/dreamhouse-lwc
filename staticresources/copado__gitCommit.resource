var gitCommit = gitCommit || {};
var metadataGrid2;
//Back-Promotion enablement comment
//closure
(function(app){

//basic types to filter
app.filteredTypes = ['ApexClass'];

/**
 * Call the metadataGrid2.resetGrid function from outside the closure.
 * Currently used in GitCommitChanges page
 * @param  {[type]} _config [description] array of configuration details
 */
app.resetGrid = function(_config){
    metadataGrid2.resetGrid(_config);
    metadataGrid2.render(function() {
        console.info("MetadataGrid2:init grid rendered", _config);
        // leave the datasource available for save
        app.datasource = metadataGrid2.datasource;

        lockScreen();
        metadataGrid2.loadData(function() {
            console.info("MetadataGrid2:init grid data loaded");
            metadataGrid2.render();
            unlockScreen();
        });
    });
};

/**
 * Update the config values from outside the closure. These values are different from the init values if the user changed the Git Operation in the UI.
 * Currently used in GitCommitChanges page
 * @param  {[type]} branchName        [description] new base branch name
 * @param  {[type]} type              [description] type of the selected Git Operation
 * @param  {[type]} label             [description] label of the selected Git Operation
 * @param  {[type]} attachmentName    [description] name of the Git Snapshot attachment
 * @param  {[type]} endpoint          [description] endpoint to replace in the CommitURL
 * @param  {[type]} formElementParams [description] list of parameters to append to the CommitURL
 * @param  {[type]} customSelections  [description] body of selected items to be saved as an attachment
 * @param  {[type]} showCommitMessage [description] bool if showMessage field is displayed to enforce that it is not BLANK
 */
 app.updateConfig = function (branchName, type, label, attachmentName, endpoint, formElementParams, customSelections, showCommitMessage) {
    if(branchName) {
        app.conf.data.mainBranch = branchName;
    }
    if(type) {
        app.conf.data.type = type;
    }
    if(label) {
        app.conf.data.operationLabel = label;
    }
    if(attachmentName) {
        app.conf.attachmentName = attachmentName;
    }
    if(endpoint) {
        app.conf.server.endpoint = endpoint;
    }
    if(formElementParams) {
        app.conf.data.formElementParams = formElementParams;
    }
    if(customSelections) {
        app.conf.data.customSelections = customSelections;
    }
    if(showCommitMessage === 'true') {
        app.conf.data.showCommitMessage = true;
    }
 };

/**
 * Call heroku to request the commit action
 * @param  {[type]} commitId [description]
 * @return {[type]}          [description]
 */
app.callBackEnd = function(commitId){
    console.log('remote call for ', commitId, app.conf.data.userStoryId, app.conf.data.snapshotId, app.conf.data.repositoryId);
    // add both snapshot AND repo. snapshot for regular commits, repo for user story (unconfirmed?)
    if(app.conf.data.userStoryId) {
        // this means it is a user story commit, use the new UserStoryWaitingFor page
        redirectToWaitingForPage(commitId);
        return;
    }
    statusManager.parentId = app.conf.data.snapshotId;
    statusManager.parentId2 = app.conf.data.repositoryId;
    document.addEventListener('copadoJobFinished1', function (e) {
        if(!e.detail)
            return;
        console.debug('copadoJobFinished1', e.detail.jobType, e.detail.jobType);
        if( e.detail.jobType.indexOf('apex')>-1 )
            return;
        if( e.detail.jobType.indexOf('retriever')>-1 )
            return;
        // waiting 1 seconds after redirecting to allow the sf attachemnt of metadata to get created
        console.log('redirect will start in 3.5 second');
        setTimeout(function(){location.href='/'+ (app.conf.data.snapshotId );},3500);
    }, false);
    // first tell the global job manager, THEN, call the status mgr.
    statusManager.lastAttachment = globalJobsManagerStart(app.conf.data.snapshotId, 'GitCommit', 'GIT-'+app.conf.data.repositoryId+'-'+app.conf.data.branch);
    statusManager.startProcess(function() {
        var msg = encodeURIComponent($copado('.js-message').val());
        var commitUrl = app.conf.server.commitUrl.replace('__ENDPOINT__',app.conf.server.endpoint).replace('__COMMITID__',commitId).replace('__MSG__',msg);
        console.log('commitURL : ',commitUrl);
        dw.u.getRemote(commitUrl,function(res){
            console.info('commit callback >',res);
            jsCreateRunningJob(res.copadoJobId,'GitCommit',app.conf.data.snapshotId,res.ok);
            statusManager.setStatusComplete();
            setStatusMessage(res.ok,'screenLockerMessage');
            lockScreen();
        }, null, true);
    }, false, 'GitCommit');
};

/**
 * create a Git_Org_Commit__c record in salesforce
 * @return {[type]} [description]
 */
app.createCommitSObject = function(){

    var commit = new sforce.SObject(app.conf.ns + 'Git_Org_Commit__c');
    commit[app.conf.ns + 'Commit_Message__c'] = $copado('.js-message').val();
    commit[app.conf.ns + 'Org__c'] = app.conf.data.orgId;
    commit[app.conf.ns + 'Git_Backup__c'] = app.conf.data.snapshotId;
    commit[app.conf.ns + 'Status__c'] = 'Pending';
    commit[app.conf.ns + 'Git_Operation__c'] = app.conf.data.operationLabel;

    var res = sforce.connection.create([commit]);

    if(res && res.length && res[0].success == 'true'){
        return res[0].id;
    }else{
        console.error(res);
        alert('Unexpected error whilst creating the commit record: '+res);
        unlockScreen();
        return false;
    }

};

//AutoSelect Function
app.autoSelect = function(gitOperation){
    console.log(gitOperation);
    var dC = false;
    if(gitOperation === 'Destructive Changes'){
        dC = true;
    }
    metadataGrid2.loadSourceStatus(dC);
}


/**
 * this method retrieve the selected items
 * then create a record in salesforce, attach the items to be commited
 * and finally call heroku to procede
 * @return {[type]} [description]
 */
app.doCommit = function(sel){
    lockScreen();

    //get selectd
    coGridHelper.datasource = app.datasource;

    // "sel" might come as a parameter (from gitcommitchangesDX, or from the grid itself)
    sel = sel || coGridHelper.getSelectedObj();
    //validate
    if(app.conf.data.customSelections) {
        // Ignore the selected metadata items in the Grid
    } else {
        var sele = coGridHelper.getSelectedObj();
        if(!sele.length){
            alert(copadoPageLabels.SELECT_AT_LEAST_ONE_ITEM);
            unlockScreen();
            return;
        }
    }

    // Require Commit Message if it is shown
    if(app.conf.data.showCommitMessage) {
        if( !(elt_commitMessage.value||'').trim()) {
            alert(copadoPageLabels.ENTER_COMMIT_MESSAGE);
            unlockScreen();
            return;
        }
    }

    if(_config && _config.data.artifactsParentOrgId && _config.data.artifactsParentOrgId !== '' && app.conf.data.type != 'GitDeletion'){
        console.info("Scratch Org From Artifacts");
        if(gitCommit.DXArtifact_validateItems(sel)) {
            console.log("validateItems");
            unlockScreen();
            gitCommit.DXArtifact_render();
            return false;
        }
    }

    // Create Commit Record
    var commitId = app.createCommitSObject();

    // Attachment Name
    var attachmentName = 'MetaData';
    if(app.conf.attachmentName) {
       attachmentName = app.conf.attachmentName;
    }

    // CommitURL parameter: type
    if(app.conf.data.type && !app.conf.server.commitUrl.includes("&type=") ) {
        app.conf.server.commitUrl += '&type=' + app.conf.data.type;
    }


    // Commit URL parameter: operationForm ElementParams
    if(app.conf.data.formElementParams) {
        app.conf.server.commitUrl += app.conf.data.formElementParams;
    }

    // CommitURL parameter: mainBranch
    if(app.conf.data.mainBranch && !app.conf.server.commitUrl.includes("&mainBranch=") ) {
        app.conf.server.commitUrl += '&mainBranch=' + app.conf.data.mainBranch;
    }
    console.log('app.conf.server.commitUrl===> ',app.conf.server.commitUrl);
    if(app.conf.data.customSelections) {
        try {
            dw.u.upsertAttach(commitId, attachmentName, app.conf.data.customSelections, true);
            console.log('... callBackEnd');
            app.callBackEnd(commitId);
        } catch(e){
            alert('Error saving attachment: '+e);
            unlockScreen();
            return;
        }
    } else {
        commitId && coGridHelper.saveSelected(commitId , attachmentName, null, true, function(){
            console.log('... callBackEnd');
            app.callBackEnd(commitId);
        },sel);
    }

    //back
    return false;

};


app.getVlocityDepencencies = function(){
    lockScreen();
    coGridHelper.datasource = app.datasource;
    var sel = coGridHelper.getSelectedObj();
    if(sel.length === 0){
        alert('Please select at least one metadata to retrieve dependencies for.');
        unlockScreen();
        return;
    }
    setLockScreenMessage('Retrieving Vlocity dependencies...');
    JsRemoting.vlocity.getDependencies(
        app.conf.data.userStoryId,
        JSON.stringify(sel),
        app.conf.ns,
        function(result) {
            console.log('app.getVlocityDepencencies getDependencies: result',result);
            // start the polling
            jsCreateRunningJobPoll();
        },
        function(event) {
            //console.warn('optionalCallout() gitcommit #1 Exception', event);
            alert('Exception: ' + event.message);
            unlockScreen();
        },
        function(event) {
            //console.error('optionalCallout() gitcommit #2 Error', event);
            alert('Error: ' + event.message);
            unlockScreen();
        }
    );
}
app.forceVlocitySelections = function(results){
    //console.log('app.forceVlocitySelections:::results',results,results.length);
    if(!results) return;
    var resultArray = results;
    for(var i = 0; i<resultArray.length; i++){
        resultArray[i].s = true;
    }
    return resultArray;
}

/**
 * Refresh cache
 * @return {[type]} [description]
 */
app.refreshCache = function(){
    metadataGrid2.refreshCache();
};

/**
 * update or hide refresh button
 * @param  {[type]} date [description]
 * @return {[type]}      [description]
 */
app.createCacheDeleteButton = function(date){
    if(!date){
        $copado('[id*=removeCacheContainer]').hide();
    }
    else{
        var $btn = $copado('[id$=removeCache]');
        $btn.length && $btn.html($btn.html().replace('__DATE__',date)).show();
    }
};

/**
 * Set the basic configuration,
 * Get supported types and create the grid.
 * @param  {[type]} conf  [description]
 * @param  {[type]} force [description]
 * @return {[type]}       [description]
 */
app.init = function(conf, force){
    console.log('init app using:', conf)
    app.conf = conf;

    //do normalize ns to empty string or value
    app.conf.ns = app.conf.ns || '';

    //start component
    lockScreen();

    dw.u.getRemote(app.conf.server.typesUrl,function(res){
        app.filteredTypes = res;
    });

};


//var metadataGrid2 = null;

/**
* Previous hookups and initialization code:
**/
app.init = function(conf){
    console.log('init app using:', conf);
    app.conf = conf;

    //do normalize ns to empty string or value
    app.conf.ns = app.conf.ns || '';

    dw.u.getRemote(app.conf.server.typesUrl,function(res){
        app.filteredTypes = res;
    });

    conf.isScalable = conf.scalableGrid;
    if(!(metadataGrid2 && metadataGrid2.conf))
        metadataGrid2 = new MetadataGrid2(conf);

    var QueryString = function () {
      // This function is anonymous, is executed immediately and
      // the return value is assigned to QueryString!
      var query_string = {};
      var query = window.location.search.substring(1);
      var vars = query.split("&");
      for (var i=0;i<vars.length;i++) {
        var pair = vars[i].split("=");
            // If first entry with this name
        if (typeof query_string[pair[0]] === "undefined") {
          query_string[pair[0]] = decodeURIComponent(pair[1]);
            // If second entry with this name
        } else if (typeof query_string[pair[0]] === "string") {
          var arr = [ query_string[pair[0]],decodeURIComponent(pair[1]) ];
          query_string[pair[0]] = arr;
            // If third or later entry with this name
        } else {
          query_string[pair[0]].push(decodeURIComponent(pair[1]));
        }
      }
      return query_string;
    }();

    // note: can be null
    app.userStoryId = QueryString.userStoryId;
    console.info("initGrid", conf, QueryString.MetadataPreselectionId);

    // override loading selected metadata, since git commit has none (except the metadata preselection)
    metadataGrid2.loadSelectedMetaData = function(callbackFinished) {
            // if this comes
            var preselectionId = QueryString.MetadataPreselectionId;
            if(app.conf.data.userStoryPreselectionId) {
                preselectionId = app.conf.data.userStoryPreselectionId;
            }

            if(preselectionId) {
            var savedItems = dw.u.getAttachById(preselectionId);
                console.debug("gitCommit: MetadataPreselectionId=", preselectionId, savedItems);
                if(savedItems) {
                    savedItems = Base64.decode(savedItems[0].Body);
                    savedItems = $copado.parseJSON(savedItems);
                }else{
                    alert("Could not load selections from other User Story commits.");
                }
            setWithoutRebinding(metadataGrid2.selectedMetadata, savedItems);
            }

        if(callbackFinished){
            callbackFinished();
        }
};
 //MethodTo add selections from org credential
        metadataGrid2.loadSourceStatus = function(isDestructive) {
            var att = dw.u.getDecodedAttach(app.conf.data.orgId,"SourceStatus");
            if(att){
                var body = att.Body;
                try{
                    var metadataRecords = JSON.parse(body);
                    var actData = metadataGrid2.allMetaData;
                    var actSelected = metadataGrid2.selectedMetadata;
                    // startGrid(metadataRecords);
                    var toDelSet = new Set();

                    for(var i = 0; i < actData.length; i++){
                        for(var j = 0; j < metadataRecords.length; j++){
                            //if(decodeURIComponent(actData[i].n) == metadataRecords[j].n && decodeURIComponent(actData[i].t) == metadataRecords[j].t && metadataRecords[j].st.includes("Remote") ){
                            if(!isDestructive && actData[i].n == metadataRecords[j].n && actData[i].t == metadataRecords[j].t && (metadataRecords[j].st.includes("Remote Add") || (metadataRecords[j].st.includes("Remote Changed")))  ){
                                actData[i].s = true;
                                actSelected.push(actData[i]);
                            }else if(isDestructive && actData[i].n == metadataRecords[j].n && actData[i].t == metadataRecords[j].t && (metadataRecords[j].st.includes("Remote Deleted"))){
                                actData[i].s = true;
                                actSelected.push(actData[i]);
                            }else if(isDestructive && (metadataRecords[j].st.includes("Remote Deleted") && !toDelSet.has(metadataRecords[j]))){
                                //Item is not found in the Metadata Selections but still show in Source Status, auto select
                                toDelSet.add(metadataRecords[j]);
                                metadataRecords[j].s = true;
                                actSelected.push(metadataRecords[j]);
                            }
                        }
                    }
                } catch(e){
                    console.error(e);
                }
            } else {
                alert('Please Check Org Status');
            }
            metadataGrid2.render();
            metadataGrid2.reloadSelections(1); //1 Means second tab
            metadataGrid2._reapplyFilters();
        };


    // Filter Grid given CSV
    metadataGrid2.setGridFiltersByCSV = function(filtersCSV) {
        var filteredMetadata = [];
        if(filtersCSV){
            var filteredTypes = filtersCSV.split(',');
            for(i=0 ; i < filteredTypes.length ; i++ ) {
                for(j=0; j < metadataGrid2.allMetaData.length ; j++){
                    if(metadataGrid2.allMetaData[j].t == filteredTypes[i]){
                        filteredMetadata.push(metadataGrid2.allMetaData[j]);
                    }
                }
            }
        }
        metadataGrid2._setGridData(filteredMetadata);
        metadataGrid2.render();
        metadataGrid2._reapplyFilters(0);
    };

    metadataGrid2.render(function() {
        console.info("MetadataGrid2:init grid rendered", conf);
        // leave the datasource available for save
        app.datasource = metadataGrid2.datasource;

            lockScreen();
        metadataGrid2.loadData(function() {
            console.info("MetadataGrid2:init grid data loaded");
            metadataGrid2.render();
            selectionTab();
            unlockScreen();
        });
    });

    app.refreshMetadataTypes = function() { metadataGrid2.refreshMetadataTypes(); };

    };

}(gitCommit)); //end closure