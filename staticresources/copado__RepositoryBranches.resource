var branches = branches || {};
var cacheDate;
(function () {
     branches.initBraches = function (conf) {
        var listOfBranches = [];
        conf.attachmentName = conf.attachmentName || 'GitBranches';
        console.assert(conf.repoId && conf.repoId != '000000000000000', "initBraches: Repository Id is mandatory");
         if(conf.repoId && conf.repoId != '000000000000000') {
            listOfBranches = branches.loadBranches(conf.repoId, conf.attachmentName);
        } else {
            localizationobj.emptydatastring = 'Repository not found';
            unlockScreen();
        }
         
        if(listOfBranches){ 
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
                //console.log('conf.gridMode : ',conf.gridMode);
                var html = '<a href="#" title="Select & Next" onclick="lockScreen(); selectBranch(' + htmlEntities(JSON.stringify(branchName)) + '); return false;">' + htmlEntities(branchName) + '</a>';
                return html;
            };
            var dataAdapter = new $copado.jqx.dataAdapter(source);
             // Create jqxGrid.
            //console.debug("initBraches() elt=", $copado("#branchSelectorGrid"));
            var rowSelectionMode = 'none';
            if(conf.gridMode === 'dxOperations') {
                rowSelectionMode = 'singlerow';
            }
    
            var types = []; 
            for (i =0; i<listOfBranches.length; i++){
                if(!types.includes(listOfBranches[i].type) && listOfBranches[i].type){
                    types.push(listOfBranches[i].type);
                }
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
                localization: localizationobj,
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
                        filterItems: types,
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
        } else {
            $copado("#branchSelectorGrid").hide();
        }
         
        if(conf.repoId && conf.repoId != '000000000000000') {
            branches._createCacheDeleteButton(conf.repoId);
        }
    };
     branches.loadBranches = function (repositoryId, attachmentName) {
        console.assert(repositoryId, "branches.loadBranches: had no repository");
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
     branches._createCacheDeleteButton = function(repoId){
        var $btn = $copado('[id$=removeCache]');
        this._createCacheDeleteButtonText = this._createCacheDeleteButtonText || $copado('[id$=removeCache]').html() || '';
        var text = this._createCacheDeleteButtonText;
        if (cacheDate && !repoId) {
            $copado('[id*=removeCacheContainer]').hide();
        } else if(cacheDate){
            cacheDate = Date.fromISOString(cacheDate).toLocaleString();
            $copado('[id*=removeCacheContainer]').show();
            text = this._createCacheDeleteButtonText.replace('__DATE__', cacheDate);
            $btn.html( text );
        } else if(repoId && !cacheDate){
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
})(branches); 