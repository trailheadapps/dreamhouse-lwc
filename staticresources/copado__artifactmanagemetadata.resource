var metadataGrid2 = null;
var copadoApp = copadoApp || {};

copadoApp.init = function(conf, force, isScalable, type){
    conf.force = force;    
    conf.isScalable = isScalable;
    conf.gridMode = 'metadataselector';
    conf.dxGridType = 'dxartifact';
    metadataGrid2 = new MetadataGrid2(conf);

    metadataGrid2.loadMetaData = function(callbackFinished, forceRefresh) {
        console.log('called from artifact management');
        var that = this;
        var conf = this.conf;

        if(this.isTypeFilterable && !this.filterByType) {
            that._setGridData([]);
            if(callbackFinished)
                callbackFinished();
            return;
        }
        var url = conf.server.metadataUrl.replace(new RegExp('__ORGID__', 'g'), conf.data.orgId);
        url = this.filterByType ? url + '&type=' + (this.filterByType||'') + '&scalable=true' : url;
        if(this.conf.gridMode==='Users') {
            url = this.conf.users_url;
        }else if(this.conf.gridMode==='metadataselector' && window.rock !== undefined) {
            url = rock.config.metadata_url;
        }

        

        dw.u.getCachedRemote({
            url: url,
            name: this.filterByType || conf.attachmentName,
            parentId: conf.data.orgId,
            force: forceRefresh,
            synchronous: false,
            success: function(allMetaData, cachedDate){
                var relArtIds = _config.data.relArtifIds;
                var total = [];
                var types = [];
                if(relArtIds){
                    try {
                        for (var i=0; i<relArtIds.length; i++) {
                            var q = "Select Id, Body, LastModifiedDate, Name, ParentId From Attachment where Name='" + _config.artifactAttName + "' and parentId = '" + relArtIds[i] + "' order by LastModifiedDate DESC limit 1";
                            var result = sforce.connection.query(q);
                            var records = result.getArray("records");
                            if(records.length === 0) continue;
                            //decode the attach body
                            var res = Base64.decode(records[0].Body);
                            //parse json
                            var selectedMetadata =  $copado.parseJSON(res);
                            total = total.concat(selectedMetadata); // add current metadata scope into all retrieved metadata scope
                        }
                        if(total.length>0){
                            for( var i = 0; i < total.length; i++){
                                for( var j = 0; j< allMetaData.length; j++){
                                    if(!types.includes(allMetaData[j].t)){
                                        types.push(allMetaData[j].t);
                                    }
                                    allMetaData[j].rd = false;
                                    if ( (total[i].t === allMetaData[j].t) && (total[i].n === allMetaData[j].n) ){
                                        allMetaData.splice(j, 1);
                                    }

                                }
                            }
                        } else {
                            for( var j = 0; j< allMetaData.length; j++){
                                if(!types.includes(allMetaData[j].t)){
                                    types.push(allMetaData[j].t);
                                }
                                allMetaData[j].rd = false;
                            }
                        }

                    } catch (e) {
                        total = [];
                        console.warn('Exception on load metadata from JSON:', e);
                    }

                }
                console.log('allMetaData0',allMetaData[0]);
                that._setGridData(allMetaData);
                that.render();
                console.log('types==> ',types);
                that.eltGrid.jqxGrid('setcolumnproperty', 't', 'filteritems',types.sort());
                that.allMetaData_cachedDate  = cachedDate;
                that._createCacheDeleteButton();

                // refresh the grid/filter, so the column type has filter values
                if(!this.isTypeFilterable)
                    that.eltGrid.jqxGrid('updatebounddata');

                if(metadataGrid2.conf.gridMode === 'metadataselector' && metadataGrid2.conf.dxGridType === 'dxartifact') {
                    metadataGrid2.eltGrid.on('cellvaluechanged', function (event) {
                        var t = metadataGrid2.eltGrid.jqxGrid('getrowdata', event.args.rowindex);
                        if (event.args.datafield=='rd' && t.rd === true) {
                            metadataGrid2.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, "rd", true);
                            metadataGrid2.dependencyRetrieveArray.push(t);
                        } else if(event.args.datafield=='rd' && t.rd === false){
                            metadataGrid2.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, "rd", false);
                            var index = metadataGrid2.dependencyRetrieveArray.indexOf(t);
                            if (index > -1) {
                            metadataGrid2.dependencyRetrieveArray.splice(index, 1);
                            }
                        }
                    });
                }

                if(callbackFinished)
                    callbackFinished();
           },
           error: function(r){
               console.error('MetadataGrid2.Error: ',r);
                if(callbackFinished)
                    callbackFinished(r);
           }
        });
    };


    metadataGrid2._getColumnsByGridMode = function() {
        var columns;
            columns = [{
                text: copadoLabels.selected,
                columntype: 'checkbox',
                filtertype: 'bool',
                datafield: 's',
                width: '5%'
            },
            {
                text: 'Retrieve',
                columntype: 'checkbox',
                datafield: 'rd',
                width: '5%',
                cellsrenderer: function(row, columnfield, value, defaulthtml, columnproperties) {
                    if(typeof value === 'undefined' || value === null) {
                        value = false;
                    }
                }
            },
            {
                text: copadoLabels.name,
                columntype: 'textbox',
                filtertype: 'input',
                editable: false,
                datafield: 'n',
                width: '30%'
            },
            {
                text: copadoLabels.type,
                datafield: 't',
                filterable: !this.isTypeFilterable,
                filtertype: this.TypeFilterType,
                editable: false,
                width: '10%',
                columntype: 'textbox'
            },
            {
                text: copadoLabels.LASTMODIFIEDBY,
                columntype: 'textbox',
                filtertype: 'input',
                editable: false,
                datafield: 'b',
                width: '15%'
            },
            {
                text: copadoLabels.LastModifiedDate,
                filtertype: 'range',
                cellsformat: 'yyyy-MM-dd',
                editable: false,
                datafield: 'd',
                width: '10%'
            },
            {
                text: copadoLabels.CREATEDBY,
                columntype: 'textbox',
                filtertype: 'input',
                editable: false,
                datafield: 'cb',
                width: '15%'
            },
            {
                text: copadoLabels.CREATEDDATE,
                filtertype: 'range',
                cellsformat: 'yyyy-MM-dd',
                editable: false,
                datafield: 'cd',
                width: '10%'
            }
        ];
        return columns;
    };

    metadataGrid2.loadSelectedMetaData = function(callbackFinished) {
        var selectedMetadata = dw.u.getSavedData(this.conf.data.id, this.conf.artifactAttName);
        var sizeWarning = $copado('#mdHardSizeLimitMessage');
        if( selectedMetadata === false ) {
            setWithoutRebinding(this.selectedMetadata, []);
            if(sizeWarning){
                sizeWarning.hide();
            }
            if(callbackFinished)
                callbackFinished();
            return;
        }
        if(sizeWarning && selectedMetadata.length > 10000){
            sizeWarning.show();
        }
        setWithoutRebinding(this.selectedMetadata, selectedMetadata);
        if(callbackFinished)
            callbackFinished();
    };



    metadataGrid2.render(function() {
        lockScreen();
        metadataGrid2.loadSelectedMetaData();
        metadataGrid2.loadMetaData(function() {
            metadataGrid2.render();
           unlockScreen();
        });
    });
}

copadoApp.refreshCache = function() {
    metadataGrid2.refreshCache();
};

copadoApp.renderGridColumnsForDependency = function(tabIndex){
    console.log('renderGridColumnsForDependency:::tabIndex',tabIndex);
    if(tabIndex !== 2) {
        metadataGrid2.eltGrid.jqxGrid('hidecolumn', 'rd');
        metadataGrid2.eltGrid.jqxGrid('showcolumn', 's');
        $copado('button#selectAll').show();
        $copado('button#unselectAll').show();
    } else if(tabIndex === 2){
        metadataGrid2.dependencyRetrieveArray = [];
        metadataGrid2.eltGrid.jqxGrid('hidecolumn', 's');
        metadataGrid2.eltGrid.jqxGrid('showcolumn', 'rd');
        $copado('button#selectAll').hide();
        $copado('button#unselectAll').hide();
    }
}

copadoApp.save = function(callback){
    var sizeWarning = $copado('#mdHardSizeLimitMessage');
    var sizeExceeded = false;
    if(metadataGrid2 && metadataGrid2.selectedMetadata && metadataGrid2.selectedMetadata.length > 10000){
        sizeExceeded = true;
    }
    var sizeConfirm = true;
    if(sizeExceeded){
        sizeConfirm = confirm('Selected metadata exceeded Salesforce mdAPI and SFDX push command metadata size limit(10k). If you proceed this artifact will not be suitable to push into a scratch org. Would you like to proceed anyway?');
    }
    console.debug('copadoApp.save:::sizeConfirm',sizeConfirm);
    if(sizeConfirm === true){
        console.log('in save block');
        coGridHelper.datasource = metadataGrid2.datasource;
        //To Add whenever backend is User Story is ready: 0002089
        coGridHelper.saveSelected(_config.data.id, 'Temp'+_config.artifactAttName, null, true, function(){;
        //coGridHelper.saveSelected(_config.data.id, _config.artifactAttName, null, true, function(){;
            metadataApp.showMessage('CONFIRM', 'Data added.', -1);

        });
        copadoApp.diffCalculationGridDirty = false;
        if(callback) callback();

        return;
    }
    unlockScreen();
    return false;
};