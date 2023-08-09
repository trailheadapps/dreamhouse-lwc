var metadataGridDX = null;
var copadoDX = copadoDX || {};
var globalSelectedArtifacts = [];
var allMetadata = [];
var unmList = [];
var unmSelectionsList = [];
(function () {
    var permissionSets = permissionSets || [];
    var cacheDate = "";
    var listOfBranches;
    console.warn('Copado DX:init before');
    copadoDX.clearMetadataTabState = function(){
        globalSelectedArtifacts = [];
        allMetadata = [];
        listOfBranches = [];
    }
    copadoDX.getPermissionSets = function(metadataToFilter){
        return copadoDX.filterGridMetadata(metadataToFilter, 't', 'PermissionSet');
    }
    copadoDX.init = function (conf, force, isScalable, type, callback) {
        copadoDX.conf = conf;
        conf.force = force;
        conf.isScalable = isScalable;
        metadataGridDX = new copadoDXGrid(conf);
        metadataGridDX._setGridData([]);
        // for delete metadata view (not editing), we do not need to load the org's metadata.
        console.debug("is metadata in view mode. Prevent loading all the org metadata", conf.gridMode == 'orgMetadata', conf, type)
        if (conf.gridMode === 'DXpermissionSet') {
            metadataGridDX.loadMetaData = function (callbackFinished, forceRefresh) {
                console.log();
                metadataGridDX._setGridData([]);
                if (callbackFinished)
                    callbackFinished();
                return;
            };
        } else if(conf.gridMode === 'orgMetadata' && conf.data.orgId === ""){
            unlockScreen();
        }
        try{
        metadataGridDX.render(function () {
            var orgMDsizeWarning = $copado('#orgHardSizeLimitMessage');
            if(orgMDsizeWarning) orgMDsizeWarning.hide();
            console.info("MetadataGrid:init grid rendered", conf);
            lockScreen();
            metadataGridDX.loadData(function () {
                // enable the refresh cache link, right after loadSelectedMetadata gets called.
                var t = dw.u.getSavedData_AttachmentLastModifiedDate;

                metadataGridDX.allMetaData_cachedDate = t? Date.fromISOString(t).toLocaleString() : 'n/a';
                metadataGridDX._createCacheDeleteButton();
                console.log('allMetadata 1',allMetadata);
                if(metadataGridDX && metadataGridDX.allMetaData && metadataGridDX.allMetaData.length > 0) {
                    allMetadata = metadataGridDX.allMetaData;
                }
                console.log('allMetadata 2',allMetadata);

                if(orgMDsizeWarning && allMetadata && allMetadata.length > 10000){
                    orgMDsizeWarning.show();
                }
                metadataGridDX.render(function() {
                    // this call is to refresh the type filter, which must be recalculated after having data in the grid.
                    metadataGridDX.render();
                });
                unlockScreen();
            });

        });
        } catch(e) {console.error(e);}

        if(callback)
            callback();
    };


    /**
     * Since artifacts will have different and uniq metadata sets following method will retrieve and read them from their related object.
     * So that artifact selected metadata will be stored as an attachment for cache, reuse and display purposes.
     * @param selected Array of selected artifact Ids
     * @param attachmentName Name of artifact metadata attachment
     */
    copadoDX.loadArtifactMetadata = function (selected, attachmentName,loadToGrid, filterType,callback) {
        console.assert(selected, "copadoDX.loadMetadataFromJSON: had no selections");
        console.assert(attachmentName, "copadoDX.loadMetadataFromJSON: config has no attachment name to query");
        var total = [];

        //There may be more than one artifact associated with this flow and since we cannot query attachment body if query return more than one record following query inside for loop is necessary.
        for (var i = 0; i < selected.length; i++) {
            var q = "Select Id, Body, LastModifiedDate, Name, ParentId From Attachment where Name='" + attachmentName + "' and parentId = '" + selected[i] + "' order by LastModifiedDate DESC limit 1";
            var result = sforce.connection.query(q);
            var records = result.getArray("records");
            if (records.length === 0) continue;
            try {
                //decode the attach body
                var res = Base64.decode(records[0].Body);
                //parse json
                var selectedMetadata = $copado.parseJSON(res);
                console.log(selectedMetadata);
                total = total.concat(selectedMetadata); // add current metadata scope into all retrieved metadata scope
                total = copadoDX.preventXSSonJQXGrid(total);
                //permissionSets = permissionSets.concat(selectedMetadata);
                console.log(filterType);
                console.info('total',total);
                if(filterType){
                    console.log('filtering...');
                    total = copadoDX.filterGridMetadata(total, 't', filterType);
                    if(filterType === 'PermissionSet'){
                        total = $copado.map(total,function(k,v){
                            if(k.s === true){
                                k.s = false;
                            }
                            return k;
                        });
                    }
                }
            } catch (e) {
                total = [];
                console.warn('Exception on load metadata from JSON:', e);
            }
        }

        if(loadToGrid){
            metadataGridDX.render(function() {
                metadataGridDX.loadSelectedMetaDataJSON(total, function() {
                    metadataGridDX.render();
                    if(callback)
                        callback();
                });
            });
            return total;
        }
        if(callback)
            callback();
        return null;

    };
    //added this function to be able to prevent Stored XSS Vulnerability based on Salesforce security report - UCU
    copadoDX.preventXSSonJQXGrid = function(objectArray){
        //below return all fields of the current object to check on the loop
        if(typeof objectArray == undefined || objectArray.length === 0) return; // added this condition, because it was throwing error if the objectArray was null or undefined

        var fields = Object.keys(objectArray[0]);
        for(var i=0;i<objectArray.length;i++){
                for(var c=0;c<fields.length;c++){
                    var currentValue = objectArray[i][fields[c]];
                    if(currentValue && typeof currentValue === 'string'){
                        while(currentValue.indexOf('<') > -1 || currentValue.indexOf('>') > -1){
                            currentValue = currentValue.replace('<','').replace('>','');
                        }
                        objectArray[i][fields[c]] = currentValue;
                    }
                }
            }

        return objectArray;
    };

    copadoDX.filterGridMetadata = function (jsonArray, jsonField, filter) {
        if(!jsonArray) return jsonArray;
        return $copado.grep(jsonArray, function (n, i) {
            return n[jsonField] == filter;
        });
    };

    copadoDX.setSelectedPackages = function(artifactId,attachmentName,orgId,orgAttachment,cb){
        console.log('artifactId',artifactId);
        if(artifactId && (artifactId.indexOf('[') > -1 || artifactId.indexOf(']') > -1 )){
            artifactId = artifactId.replace('[','').replace(']','');
        }
        var artifactsArray = artifactId.split(',');
        for(var u=0;u<artifactsArray.length;u++){
            var q = "Select Id, Body, LastModifiedDate, Name, ParentId From Attachment where Name='" + attachmentName + "' and parentId = '" + artifactsArray[u] + "' order by LastModifiedDate DESC limit 1";
            var result = sforce.connection.query(q);
            var records = result.getArray("records");
            var res = JSON.parse(Base64.decode(records[0].Body));
            var selectedPackage = res.packageInfo;
            var item = $copado.grep(unmList, function (n, i) {
                return n['MetadataPackageVersionId'] == selectedPackage.MetadataPackageVersionId;
            });
            var selectionIndex = unmList.indexOf(item[0]);
            unmList[selectionIndex].s = true;
            unmSelectionsList.push(unmList[selectionIndex]);
        }
        copadoDX.initUnmanagedPackages(orgId,orgAttachment,cb,true);
    }
    copadoDX.loadUnmanagedPackages = function (orgId, attachmentName,callback) {
        console.assert(orgId, "copadoDX.loadUnmanagedPackages: had no org");
        var q = "Select Id, Body, LastModifiedDate, Name, ParentId From Attachment where Name='" + attachmentName + "' and parentId = '" + orgId + "' order by LastModifiedDate DESC limit 1";
        var result = sforce.connection.query(q);
        var records = result.getArray("records");
        var _createCacheDeleteButtonText = $copado('[id$=removeCacheUMP]').html() || '';
        var text = _createCacheDeleteButtonText;
        var $btn = $copado('[id$=removeCacheUMP]');
        if(records.length <= 0){
            text = _createCacheDeleteButtonText.replace('__DATE__', 'n/a');
            $btn.html( text );
            return;
        }
        try {
            cacheDate = records[0].LastModifiedDate;
            if (!cacheDate) {
                $copado('[id*=removeCacheContainerUMP]').hide();
            } else {
                cacheDate = Date.fromISOString(cacheDate).toLocaleString();
                $copado('[id*=removeCacheContainerUMP]').show();
                text = _createCacheDeleteButtonText.replace('__DATE__', cacheDate);
                $btn.html( text );
            }
            var res = Base64.decode(records[0].Body);
            var packagesData = $copado.parseJSON(res);
            if(callback) callback();
            return packagesData;
        } catch (e) {
            unlockScreen();
            console.error('Exception on load UnmanagedPackages', e);
        }
    };
    copadoDX.initUnmanagedPackages = function(orgId,attachmentName,cb,hasData){
        attachmentName = attachmentName || 'Packages';
        console.assert(orgId && orgId != '000000000000000' && orgId != '-- None --', "copadoDX.initUnmanagedPackages: orgId is mandatory");
        if(!hasData){
            if(orgId && orgId != '000000000000000' && orgId != '-- None --'){
                unmList = copadoDX.loadUnmanagedPackages(orgId, attachmentName);
                for(var p=0; p<unmList.length; p++){
                    unmList[p].s = false;
                }
            } else {
                 $copado('[id*=removeCacheContainerUMP]').hide();
            }
        }
        var source = {
            localdata: unmSelectionsList,
            datafields: [
                {name: 's', type: 'bool'},
                {name: 'MetadataPackageVersionId', type: 'string'},
                {name: 'MetadataPackageId', type: 'string'},
                {name: 'Name', type: 'string'},
                {name: 'ReleaseState', type: 'string'},
                {name: 'Version', type: 'string'},
                {name: 'BuildNumber', type: 'int'}
            ],
        };
        var dataAdapter = new $copado.jqx.dataAdapter(source);
        // Create jqxGrid.
        $copado("#unmanagedPackageSelectorGrid").jqxGrid({
            width: '100%',
            height: '100%',
            source: dataAdapter,
            pageable: true,
            autoheight: false,
            selectionmode: 'multiplerows',
            filterable: true,
            sortable: true,
            pagesizeoptions: ['10', '50', '100', '500', '1000', '5000'],
            pagesize: 200,
            theme: 'base',
            showfilterrow: true,
            columns: [
                {
                    text: copadoLabels.selected,
                    columntype: 'checkbox',
                    filtertype: 'bool',
                    datafield: 's',
                    width: '5%'
                },
                {
                    text: 'MetadataPackageVersionId',
                    datafield: 'MetadataPackageVersionId',
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    columntype: 'textbox',
                    width: '15%'
                },
                {
                    text: 'MetadataPackageId',
                    datafield: 'MetadataPackageId',
                    filterable: true,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    columntype: 'textbox',
                    width: '15%'
                },
                {
                    text: copadoLabels.name,
                    datafield: 'Name',
                    filterable: true,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    columntype: 'textbox',
                    width: '35%'
                },
                {
                    text: 'ReleaseState',
                    datafield: 'ReleaseState',
                    filterable: true,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    columntype: 'textbox',
                    width: '10%'
                },
                {
                    text: 'Version',
                    datafield: 'Version',
                    filterable: true,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    columntype: 'textbox',
                    width: '10%'
                },
                {
                    text: 'BuildNumber',
                    datafield: 'BuildNumber',
                    filterable: true,
                    filtercondition: 'contains',
                    editable: false,
                    width: '10%'
                }

            ]
        });
        if(cb) cb();
    };

    copadoDX._createCacheDeleteButton = function(repoId){
        var $btn = $copado('[id$=removeCache]');
        this._createCacheDeleteButtonText = this._createCacheDeleteButtonText || $copado('[id$=removeCache]').html() || '';
        var text = this._createCacheDeleteButtonText;
        if (!cacheDate && !repoId) {
            $copado('[id*=removeCacheContainer]').hide();
        } else if(cacheDate){
            cacheDate = Date.fromISOString(cacheDate).toLocaleString();
            $copado('[id*=removeCacheContainer]').show();
            text = this._createCacheDeleteButtonText.replace('__DATE__', cacheDate);
            $btn.html( text );
        } else if(repoId){
            $copado('[id*=removeCacheContainer]').show();
            text = this._createCacheDeleteButtonText.replace('__DATE__', 'n/a');
            $btn.html( text );
        }
        if (this.filterByType) {
            text = text.replace('__METATYPE__', 'for ' + this.filterByType||'');
            $btn.html( text );
        } else {
            text = text.replace('__METATYPE__', '');
            $btn.html( text );
        }

        $btn.show();
    };
    copadoDX.resetBranchInit = function(){

    }
    copadoDX.loadBranches = function (repositoryId, attachmentName) {
        console.assert(repositoryId, "copadoDX.loadBranches: had no repository");
        var q = "Select Id, Body, LastModifiedDate, Name, ParentId From Attachment where Name='" + attachmentName + "' and parentId = '" + repositoryId + "' order by LastModifiedDate DESC limit 1";
        var result = sforce.connection.query(q);
        var records = result.getArray("records");
        if(records && records.length > 0){
            try {
                var res = Base64.decode(records[0].Body);
                cacheDate = records[0].LastModifiedDate;
                var branchData = $copado.parseJSON(res);
                for(var i = 0; i < branchData.length; i++){
                    var dateEpoch = new Date(0);
                    dateEpoch.setMilliseconds(branchData[i].lastUpdate);
                    branchData[i].lastUpdate = dateEpoch.getFullYear() + '-' + ('0'+ dateEpoch.getMonth()).slice(-2) + '-' + ('0'+dateEpoch.getDate()).slice(-2);
                }
                return branchData;
            } catch (e) {
                console.error('Exception on load branches', e);
            }
        }
    };
    copadoDX.initBraches = function (conf) {
        var branchMDsizeWarning = $copado('#branchHardSizeLimitMessage');
        if(branchMDsizeWarning) branchMDsizeWarning.hide();
        listOfBranches = [];
        conf.attachmentName = conf.attachmentName || 'GitBranches';
        console.assert(conf.repoId && conf.repoId != '000000000000000', "copadoDX.initBraches: Repository Id is mandatory");

        if(conf.repoId && conf.repoId != '000000000000000') {
            listOfBranches = copadoDX.loadBranches(conf.repoId, conf.attachmentName);
            if(branchMDsizeWarning){
                branchMDsizeWarning.show();
            }
        } else {
            unlockScreen();
        }
        if(conf.isPatch){
            listOfBranches = copadoDX.filterGridMetadata(listOfBranches, 'type', 'Git Tag');
        }
        //copadoDX.init(_config, false, {!scalableGrid}, 'orgMetadata');
        // prepare the data
        var source = {
            localdata: listOfBranches,
            datafields: [
                {name: 's', type: 'bool'},
                {name: 'name', type: 'string'},
                {name: 'type', type: 'string'},
                {name: 'lastUpdate', type: 'string'}
            ]
        };

        var linkrenderer = function (row, column, branchName) {
            console.log('conf.gridMode : ',conf.gridMode);
            if(conf.gridMode === 'userStoryWizard' || conf.gridMode === 'dxOperations') {
                if (!nextStep) {
                    return false;
                }
                var html = '<a href="#" title="Select & Next" onclick="lockScreen(); nextStep(' + htmlEntities(JSON.stringify(branchName)) + '); return false;">' + htmlEntities(branchName) + '</a>';
                console.debug(html);

                return html;
            }
        };
        var dataAdapter = new $copado.jqx.dataAdapter(source);

        // Create jqxGrid.
        console.debug("initBraches() elt=", $copado("#branchSelectorGrid"));
        var rowSelectionMode = 'none';
        if(conf.gridMode === 'dxOperations') {
            rowSelectionMode = 'singlerow';
        }
        var branchGrid = $copado("#branchSelectorGrid").jqxGrid({
            width: '100%',
            height: '100%',
            source: dataAdapter,
            pageable: true,
            autoheight: false,
            filterable: true,
            sortable: true,
            selectionmode: rowSelectionMode,
            pagesizeoptions: ['10', '50', '100', '500', '1000', '5000'],
            pagesize: 200,
            theme: 'base',
            showfilterrow: true,
            columns: [
                {
                    text: copadoLabels.name,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 'name',
                    width: '40%',
                    cellsrenderer: linkrenderer
                },
                {
                    text: copadoLabels.type,
                    datafield: 'type',
                    filterable: !conf.isPatch,
                    filtertype: 'checkedlist',
                    editable: false,
                    columntype: 'textbox',
                    width: '30%'
                },
                {
                    text: copadoLabels.LastModifiedDate,
                    filtertype: 'textbox',
                    editable: false,
                    datafield: 'lastUpdate',
                    width: '30%'
                }
            ]
        });
        /*if(conf.gridMode === 'dxOperations') {
            $copado("#branchSelectorGrid").bind('rowselect', function (event) {
                var selectedRowIndex = event.args.rowindex;
                alert(selectedRowIndex);
            });
        }*/
        if(conf.repoId && conf.repoId != '000000000000000') {
            copadoDX._createCacheDeleteButton(conf.repoId);
        }
    };

    copadoDX.initErrors = function (conf) {
            conf.attachmentName = conf.attachmentName || 'DxLoadMetadataError';
            var errors = [];
            console.log('conf',conf);
            var q = "Select Id, Body, LastModifiedDate, Name, ParentId From Attachment where Name='" + conf.attachmentName + "' and parentId = '" + conf.orgId + "' order by LastModifiedDate DESC limit 1";
            var result = sforce.connection.query(q);
            console.debug('result',result);
            var records = result.getArray("records");
            try {
                var res = Base64.decode(records[0].Body);
                var pagetitle = $copado('[Id$=errorTitle]').find('.mainTitle');
                pagetitle.text(pagetitle.text()+' on: '+Date.fromISOString(records[0].LastModifiedDate).toLocaleString());
                errors = $copado.parseJSON(res);
            } catch (e) {
                console.error('Exception on load errors', e);
            }

            var source = {
                localdata: errors,
                datafields: [
                    {name: 'error', type: 'string'},
                    {name: 'fullName', type: 'string'},
                    {name: 'type', type: 'string'},
                    {name: 'filePath', type: 'string'}
                ]
            };
            var dataAdapter = new $copado.jqx.dataAdapter(source);

            // Create jqxGrid.
            var errorsGrid = $copado("#errorsGrid").jqxGrid({
                width: '100%',
                height: '100%',
                source: dataAdapter,
                pageable: true,
                autoheight: false,
                filterable: true,
                sortable: true,
                selectionmode: 'none',
                pagesizeoptions: ['10', '50', '100', '500', '1000', '5000'],
                pagesize: 200,
                theme: 'base',
                showfilterrow: true,
                columns: [
                    {
                        text: 'Error',
                        filtertype: 'textbox',
                        filtercondition: 'contains',
                        editable: false,
                        datafield: 'error',
                        width: '40%'
                    },
                    {
                        text: 'Full Name',
                        filtertype: 'textbox',
                        filtercondition: 'contains',
                        editable: false,
                        datafield: 'fullName',
                        width: '20%'
                    },
                    {
                        text: 'Type',
                        filtertype: 'textbox',
                        filtercondition: 'contains',
                        editable: false,
                        datafield: 'type',
                        width: '15%'
                    },
                    {
                        text: 'File Path',
                        filtertype: 'textbox',
                        filtercondition: 'contains',
                        editable: false,
                        datafield: 'filePath',
                        width: '25%'
                    }
                ]
            });
        };

    copadoDX.csvPermissions = function (selectedPerms) {
        var csvPerm = '';
        var permArray = [];
        if(selectedPerms){
          for(var j = 0; j < selectedPerms.length; j++) {
              permArray.push(selectedPerms[j].n);
          }
          csvPerm = permArray.toString();
        }
        console.log(csvPerm);
        return csvPerm;
    };

    copadoDX.refreshCache = function () {
        metadataGridDX.refreshCache();
    };
    copadoDX.refreshMetadataTypeCache = function () {
        metadataGridDX.refreshMetadataTypes();
    };
})(metadataGridDX, copadoDX);