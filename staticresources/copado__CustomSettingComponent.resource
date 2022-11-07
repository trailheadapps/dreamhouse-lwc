
var customSetting = customSetting || {};
customSetting.ops = customSetting.ops || {};
customSetting.ui = customSetting.ui || {};





customSetting.data = {
    objSelected: 0,
    completeObjSelected: 0,
    step: false,
    values: [],
    preselections: []
};
initCS = function(task) {
    console.time('cs build')

    var me = customSetting;
    customSetting.data.task = task;
    //get obj data
    customSetting.ops.getObjects(task, customSetting.ops.getObjectsCB);

    customSetting.ui.getCSValues = $copado('#getCSValues');
    customSetting.ui.toogleAll = $copado('#cs-toggle-all');
    customSetting.ui.refreshCache = $copado('#refresh-cache-cs');

    if (customSetting.started) {
        customSetting.ops.reset();
    } else {
        customSetting.started = true;
    }
    customSetting.ui.toogleAll.off('click');
    customSetting.ui.getCSValues.off('click');
    customSetting.ui.refreshCache.off('click');

    customSetting.ui.toogleAll.on('click', customSetting.ops.toggleAll);
    customSetting.ui.getCSValues.on('click', customSetting.ops.getCSValues);
    customSetting.ui.refreshCache.on('click', customSetting.ops.refreshCache);

    console.timeEnd('cs build')
    if(me.data.objects && me.data.objects.length > 0){
        customSetting.data.objSelected = me.data.objects[0].N;
        customSetting.data.completeObjSelected = me.data.objects[0].L;
    }

};

customSetting.ops.reset = function(){
    $copado('#cs-values').html('');
    customSetting.data.objSelected = false;
    customSetting.data.completeObjSelected = false;
};

customSetting.ops.refreshCache = function() {

    if ($copado('#cs-values option:selected').length && !confirm('You have selected values. If continue will lose the current selection.')) {
        return false;
    }

    lock();
    customSetting.data.objects = false;
    customSetting.ops.reset();
    customSetting.ops.getObjects(customSetting.data.step, customSetting.ops.getObjectsCB, true);


};

customSetting.ops.getObjectsCB = function() {
    customSetting.ops.createObjectSelector('#objectsCJ', customSetting.data.objects, customSetting.ops.onSelectObject);
};

customSetting.ops.onSelectObject = function(name, label) {
    console.log('selected: ', name, label)
    customSetting.data.objSelected = name;
    customSetting.data.completeObjSelected = label;
    customSetting.ops.enabledBtn('#getCSValues', 'Get Custom Settings values');
};

customSetting.ops.prepareSource = function(data) {
    //normalize data
    var temp_source = [],
        len = data.length;
    for (var i = 0; i < len; i++) {
        temp_source[i] = data[i].L + ' (' + data[i].N + ')';
    }

    temp_source.sort();
    return temp_source;
};

customSetting.ops.createObjectSelector = function(selector, data, cb) {
    if(data){
        var $objects = $copado(selector).jqxComboBox({
            source: customSetting.ops.prepareSource(data),
            autoComplete: true,
            width: '400px',
            height: '25px',
            selectedIndex: 0
        });
        if(data && data.length>0){
            customSetting.ops.onSelectObject(data[0].N,customSetting.ops.prepareSource(data));
            console.log('what is this item',customSetting.ops.prepareSource(data));
        }
        $objects.bind('select', function(event) {
            var args = event.args;
            if (args && !isNaN(args.index)) {
                var item = $objects.jqxComboBox('listBox').visibleItems[args.index];
                cb && cb(item.label.split('(')[1].split(')')[0], item.label);
            }

        });
        customSetting.ops.createGrid(customSetting.data.values,customSetting.data.values);
        $objects.jqxComboBox('focus');


        return $objects;
    }else
        alert(copadoLabels.noCsFound);
};

customSetting.ops.toggleAll = function() {
    var prev = $copado(this).attr('data-all');    
    console.log('prev',prev=="true",$copado(this));
    $copado(this).attr('data-all',prev!="true").val(prev == "true" ? 'Unselect all' : 'Select all');
    console.log('asagsagag',$copado('#cs-toggle-all').attr('data-all'));
    var options = $copado('#cs-values').find('option');    
    var selectVal = prev=="true" ? true : false;
    options.prop('selected', selectVal);        
    return false;
};

customSetting.ops.getObjects = function(step, cb, force) {
    console.log('get objects')
    if (customSetting.data.objects) {
        console.log('get objects is in cache')
        cb();

        return;
    }
    
    dw.u.getCachedRemote({
        url: datasetup.config.sobjects_url + '&onlyCustomSettings=true',
        name: 'Custom Settings',
        force: force,
        parentId: datasetup.org__c,
        success: function(res, date) {

            console.log('get data callbacl');
            customSetting.data.objects = res;
            cb && cb();
            unlock();
        },
        error: function(r) {
            console.log('Error: ',r)
            unlock();
        }
    });
};
customSetting.ops.getRemoteCSValues = function() {
    lock();
    dw.u.getRemote(datasetup.config.custom_settings_url.replace('{sobject}', customSetting.data.objSelected), function(res) {
        customSetting.data.values = res.sort(function(a, b) {
            if (a.Name < b.Name)
                return -1;
            if (a.Name > b.Name)
                return 1;
            return 0;
        });
        if(customSetting.data.preselections && customSetting.data.preselections.length > 0){
            for(var cdv = 0; cdv < customSetting.data.values.length; cdv++){
                for(var ps = 0; ps < customSetting.data.preselections.length; ps++){
                    if(customSetting.data.values[cdv].Name == customSetting.data.preselections[ps].Name){
                        customSetting.data.values[cdv].s = customSetting.data.preselections[ps].s;
                    }
                }
            }
        }
        customSetting.ops.createGrid(customSetting.data.values,customSetting.data.values);

    }, false, false, function(res) {
        res && customSetting.showMessage('ERROR', res);
        unlock();
    });
};

/**
 * [showMessage description]
 * @param  {[type]} type CONFIRM, WARNING, ERROR
 * @param  {[type]} msg  [description]
 * @return {[type]}      [description]
 */
customSetting.showMessage = function(type, msg) {
    $copado('.fixedMsg')
        .html($copado('[id$=js-msg-' + type + ']').html().replace('__MSG__', msg))
        .fadeIn('slow');

    //showMessage(type,msg);

    setTimeout(function() {
        $copado('.fixedMsg').fadeOut('slow');
    }, 7000);
    if(typeof(reloadHistory) == "function")reloadHistory();
};

customSetting.selectedType = false;

customSetting.ops.prepareGrid = function() {
    var res = customSetting.data.values,
        len = res.length,
        options = '';
    customSetting.selectedType = len ? res[0].type : false;

    var typeField = customSetting.selectedType == 'Hierarchy' ? 'SetupOwnerId' : 'Name';

    for (var i = 0; len > i; i++) {
        var item = res[i];
        options += '<option value="' + item[typeField] + '">' + item.Name + '</option>';
    }
    $copado('#cs-values').html(options);
    unlock();
};

/**
 * Create the grid
 * @param  {[type]} res  data to show
 * @param  {[type]} prev prev selected items
 * @return {[type]}      [description]
 */
customSetting.ops.createGrid = function(res, prev,readonly) {
    console.log('creating custom setting grid');
    if(res && res.length>0 && res[0].s){
        customSetting.data.preselections = res;
    }
    lock();

    var me = customSetting;
    //below fields are all either not needed system fields or already in place our fields
    //the values of the following variables must match the one returns from backend as a respond(SF system fields and our fields), and changes will change the grid columns
    //If you change this, you should also change the same lines in Deployment.Resource
    var fields2prevent = '==SetupOwnerId==, ==s==, ==Name==, ==type==, ==LastModifiedDate==, ==SystemModstamp==, ==IsDeleted==, ==CreatedById==, ==CreatedDate==, ==Id==, ==LastModifiedById==';
    //reset flag
    copadoGrid.hasPreviousSelected = false;
    //merge previous selected
    me.data.metadata = res;


    //fix undefined selected field
    if(me.data.metadata){
        var len = me.data.metadata.length;
        while (len--) {
            var e = me.data.metadata[len];
            e.s = e.s || false;
        }
    }

    var objColumns;
    if(res && res.length > 0){
        objColumns = Object.keys(res[0]);
    }
    console.log('objColumns===> ',objColumns);

    //create datasource
    var source2 = {
        localdata: res,
        datafields: [{
            name: 's',
            type: 'bool'
        },{
            name: 'Name',
            type: 'string'
        }, {
            name: 'type',
            type: 'string'
        }, {
            name: 'SetupOwnerId',
            type: 'string'
        }],
        datatype: 'array',
        updaterow: function(rowid, rowdata, commit) {
            commit(true);
            datasetup.datasource.localdata[rowid] = rowdata;
            customSetting.dirty = true;
        }
    };
    if(objColumns){
        for(var c=0;c<objColumns.length;c++){
            if(fields2prevent.indexOf(objColumns[c]) < 0){
                if(objColumns[c].indexOf('Date') > -1){
                    source2.datafields.push({name:objColumns[c],type: 'date'});
                }
                else if(res[0] && res[0][objColumns[c]] == 'true' || res[0][objColumns[c]] == 'false'){
                    source2.datafields.push({name:objColumns[c],type: 'bool'});
                }
                else source2.datafields.push({name:objColumns[c],type: 'string'});
            }
        }
    }

    source2.localdata = prev;

    //adapter wrapper
    dataAdapter2 = new $copado.jqx.dataAdapter(source2);

    //keep jquery pointer for performance query
    $grid2 = $copado('<div>');

    $copado('#jqxgrid-custom-setting').html($grid2);

    //keep generic data source for later save and validate functions
    datasetup.datasource = source2;
    if(readonly){
        copadoGrid.showToggleButtons = false;
    }

    var gridObject = {
         width: '100%',
         source: dataAdapter2,
         showfilterrow: (readonly ? false : true),
         filterable: (readonly ? false : true),
         theme: 'base',
         editable: (readonly ? false : true),
         selectionmode: 'none',
         enablebrowserselection: true,
         pageable: true,
         pagesizeoptions: ['10', '20', '50', '100', '200'],
         pagesize: 50,
         sortable: true,
         columnsresize: true,
         localization: localizationobj,
         columns: [{
             text: copadoLabels.selected,
             columntype: 'checkbox',
             filtertype: 'bool',
             datafield: 's',
             width: 60
         }, {
             text: copadoLabels.type,
             filtertype: 'textbox',
             filtercondition: 'contains',
             datafield: 'type',
             width: 120,
             editable: false
         }, {
             text: 'Setup Owner Id',
             filtertype: 'textbox',
             filtercondition: 'contains',
             width: 250,
             editable: false,
             datafield: 'SetupOwnerId'
         }, {
             text: copadoLabels.name,
             filtertype: 'checkedlist',
             editable: false,
             datafield: 'Name'
         }],
         ready: function() {
             console.log('ready grid event');
             //show selected if is edition
             copadoGrid.hasPreviousSelected && copadoGrid.addSelectedFilter($grid2);

             unlock();

         }
         //*****UCU******Be careful with column order, if you change order also consider changing datasetup function under csPanel2Render outputPanel!!!
    }

    if(objColumns){
        for(var c=0;c<objColumns.length;c++){
            if(fields2prevent.indexOf(objColumns[c]) < 0){
                if(objColumns[c].indexOf('Date') > -1){
                    gridObject.columns.push({text: objColumns[c].replace('__c','').replace('_',' '),
                          filtertype: 'textbox',
                          filtercondition: 'contains',
                          editable: false,
                          datafield: objColumns[c]});
                }
                else if(res[0] && res[0][objColumns[c]] == 'true' || res[0][objColumns[c]] == 'false'){
                    gridObject.columns.push({text: objColumns[c].replace('__c','').replace('_',' '),
                           columntype: 'checkbox',
                           filtertype: 'bool',
                           editable: false,
                           datafield: objColumns[c],
                           width: 100});
                }
                else{
                    gridObject.columns.push({text: objColumns[c].replace('__c','').replace('_',' '),
                           filtertype: 'textbox',
                           filtercondition: 'contains',
                           editable: false,
                           datafield: objColumns[c]});
                }
            }
        }
    }
    $grid2.jqxGrid(gridObject);
    copadoGrid.addSelectAll($grid2);
};

customSetting.ops.enabledBtn = function(sel, label) {
    customSetting.ops.setBtn(true, sel, label);
};

customSetting.ops.setBtn = function(action, sel, label) {
    setTimeout(function() {
        var $btn = $copado(sel);

        if (action) {
            $btn
                .attr('disabled', null)
                .removeClass('btnDisabled');
        } else {
            $btn
                .attr('disabled', 'disabled')
                .addClass('btnDisabled');
        }
        $btn.prop('tagName') === 'INPUT' ? $btn.val(label) : $btn.html(label);
    }, 1);

};

customSetting.ops.getCSValues = function() {
    if (!customSetting.data.objSelected) {
        console.log('no selected');
        customSetting.ui.getCSValues.attr('disabled','disabled');
        return false;
    }

    customSetting.ops.getRemoteCSValues();
    return false;

};

/**
 * [copadoGrid complete controller for jqx-grid]
 * @type {Object}
 */
var copadoGrid = {

    //true is has previous selected items
    hasPreviousSelected: false,
    showToggleButtons:true,
    isActive: false,

    loading: function() {
        var loadingHTML = '<center><img src="/img/loading.gif" /> <i>' + copadoLabels.loading + '<span id="retry-label"></span></i></center>';
        $copado('#jqxgrid').html(loadingHTML);
    },

    setOrgFilteredLink: function(orgFiltered, orgId) {
        if (orgFiltered) {
            $copado('#link-org-filtered')
                .attr('href', '/' + orgId + '?_mtf=1')
                .show();
        } else {
            $copado('#link-org-filtered').hide();
        }
    },

    gridByType: {},

    startGrid: function(type, metaOrgData) {
        if (copadoGrid.gridByType[type]) {
            if(customSetting.stepType == 'MetaData' || customSetting.stepType == 'Delete MetaData') {
                datasetup.datasource = metadataGrid2.datasource;
                getMetadataGrid2(type);
                return;
            }
            copadoGrid.refreshGrid(type, metaOrgData)
        } else {
            copadoGrid.initGrid(type, metaOrgData);
        }
    },

    initGrid: function(type, metaOrgData) {
        console.log('initGrid');

        copadoGrid.gridByType[type] = copadoGrid.buildGrid(type, metaOrgData);

    },

    addSelectAll: function($grid) {
        var selectAll = function(sel) {
                $grid.jqxGrid('beginupdate');

                var list = $grid.jqxGrid('getrows');
                for (var i in list) {
                    datasetup.datasource.localdata[list[i].dataindex || i].s = sel;
                }

                $grid.jqxGrid('endupdate');
                setTimeout(function() {
                    $grid.jqxGrid('updatebounddata', 'cells');
                }, 222);

                customSetting.dirty = true;
            },

            $unselectAll = $copado('<button id="js-jqxGrid-unselectAll">' + copadoLabels.unselect_all + '</button>').
        on('click', function(e) {
                e.preventDefault();
                selectAll(false);
            }),

            $selectAll = $copado('<button id="js-jqxGrid-selectAll">' + copadoLabels.select_all + '</button>').
        on('click', function(e) {
            e.preventDefault();
            selectAll(true);
        });

        if(copadoGrid.showToggleButtons){
            $copado('.jqx-grid-pager > div', $grid)
            .prepend($unselectAll)
            .prepend($selectAll);
        }

    },

    buildGrid: function(type, data) {
        console.log('buildGrid len', type, data.length);

        if(customSetting.stepType == 'MetaData' || customSetting.stepType == 'Delete MetaData')
            return getMetadataGrid2(type);

        copadoGrid.isActive = true;

        try {

            //keep jquery pointer for performance query
            var $grid = $copado('<div>');

            $copado("#jqxgrid").html($grid);

            var params = copadoGrid.getBasicParams();
            params.source = copadoGrid.makeSource(type, data);
            params.columns = copadoGrid.getColumnsByType(type);
            console.time('Grid created time');
            copadoGrid.$currentGrid = $grid.jqxGrid(params);
            console.timeEnd('Grid created time');
        } catch (e) {
            console.error(e)
            throw e;
        }


        //console.log(' preselected ok ');
        copadoGrid.addSelectAll($grid);


        console.log(' init grid end');

        return $grid;
    },

    getBasicParams: function() {
        return {
            width: '100%',
            showfilterrow: true,
            filterable: true,
            theme: 'base',
            editable: true,
            selectionmode: 'none',
            pageable: true,
            pagesizeoptions: ['10', '20', '50', '100', '500'],
            pagesize: 20,
            sortable: true,
            columnsresize: true,
            localization: localizationobj,
            enablebrowserselection: true,
            ready: function() {
                console.log('ready grid event');
                copadoGrid.$currentGrid = $copado('#jqxgrid > div');
                //show selected if is edition
                copadoGrid.hasPreviousSelected && copadoGrid.addSelectedFilter(copadoGrid.$currentGrid);
            }
        };
    },

    addSelectedFilter: function($grid) {
        try {
            console.log('add selected fiter ', $grid)
            var filtergroup2 = new $copado.jqx.filter();
            var filter2 = filtergroup2.createfilter('booleanfilter', true, 'EQUAL');
            filtergroup2.addfilter(1, filter2);
            $grid.jqxGrid('clearfilters');
            $grid.jqxGrid('addfilter', 's', filtergroup2);
            $grid.jqxGrid('applyfilters');
        } catch (e) {
            console.error('addfilter', e);
        };
    },

    getColumnsByType: function(type) {

        if (type == 'Users') {
            var columns = [{
                text: copadoLabels.selected,
                columntype: 'checkbox',
                filtertype: 'bool',
                datafield: 's',
                width: 60
            }, {
                text: copadoLabels.name,
                filtertype: 'textbox',
                filtercondition: 'contains',
                editable: false,
                datafield: 'n'
            }, {
                text: copadoLabels.country,
                datafield: 'c',
                filtertype: 'checkedlist',
                editable: false,
                columntype: 'textbox',
                width: 70
            }, {
                text: copadoLabels.profile,
                datafield: 'p',
                filtertype: 'checkedlist',
                editable: false,
                columntype: 'textbox'
            }, {
                text: copadoLabels.role,
                filtertype: 'textbox',
                filtercondition: 'contains',
                editable: false,
                datafield: 'r'
            }, {
                text: copadoLabels.username,
                filtertype: 'textbox',
                filtercondition: 'contains',
                editable: false,
                datafield: 'u'
            }, {
                text: copadoLabels.isactive,
                datafield: 'a',
                filtertype: 'bool',
                editable: false,
                columntype: 'checkbox',
                width: 70
            }, ];

            console.log('TERRITORY', usersStep.hasTerritories);
            if (usersStep.hasTerritories) {
                columns.push({
                    text: 'Territory',
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 't'
                });
                //me.ui.$useTerritories.closest('tr').show();
                //me.ui.$useTerritories.attr('checked',saved ? saved.useTerritories: true);
            }
            return columns;
        } else {
            return [{
                text: copadoLabels.selected,
                columntype: 'checkbox',
                filtertype: 'bool',
                datafield: 's',
                width: 60
            }, {
                text: copadoLabels.name,
                filtertype: 'textbox',
                filtercondition: 'contains',
                editable: false,
                datafield: 'n',
                width: '40%'
            }, {
                text: copadoLabels.type,
                datafield: 't',
                filtertype: 'checkedlist',
                editable: false,
                columntype: 'textbox'
            }, {
                text: copadoLabels.LastModifiedById,
                filtertype: 'textbox',
                filtercondition: 'contains',
                editable: false,
                datafield: 'b',
                width: 220
            }, {
                text: copadoLabels.LastModifiedDate,
                filtertype: 'textbox',
                filtercondition: 'contains',
                editable: false,
                datafield: 'd',
                width: 120
            }];
        }
    },

    refreshGrid: function(type, data) {

        //TODO: hide during rebuild $copado("#jqxgrid").hide();
        copadoGrid.loading();

        var $grid = copadoGrid.gridByType[type];
        $copado("#jqxgrid").empty().html($grid);
        //get data source for data
        //get columns by config
        //preselect data
        var params = copadoGrid.getBasicParams();
        params.source = copadoGrid.makeSource(type, data);
        params.columns = copadoGrid.getColumnsByType(type);
        console.time('Grid refresh time');
        copadoGrid.$currentGrid = $grid.jqxGrid(params);
        console.timeEnd('Grid refresh time');
        // copadoGrid.hasPreviousSelected && copadoGrid.addSelectedFilter($grid);
        copadoGrid.addSelectAll($grid);
    },

    filterMap: {
        'Full Profiles': 'Profile',
        'Translations': 'Translations',
        'Full Permission Sets': 'PermissionSet',
        'Custom Settings': 'CustomObject'
    },

    makeSource: function(type, data) {

        //data = [{"t":"InstalledPackage","n":"sf_chttr_apps","b":"Proceso automatizado","d":"2014-10-21"}];
        //normalize data
        var len = data.length;

        var hasFilter = copadoGrid.filterMap[type];


        if (hasFilter) {
            var newData = [];
        }

        while (len--) {
            data[len].s = data[len].s || false;
            data[len].b = data[len].b || '';
            data[len].d = data[len].d || '';
            //if filtered by type remove other types.
            if (hasFilter && data[len].t == hasFilter) {
                newData.unshift(data[len]);
            }

            //for user type
            if (type == 'Users') {
                data[len].c = data[len].c || '--';
                if (data[len].t) {
                    usersStep.hasTerritories = 1;
                }
            }

        }
        //console.log('making source',usersStep.hasTerritories);


        if (hasFilter) {
            data = newData;
        }

        var source = {
            localdata: data,
            datafields: type != 'Users' ? [{
                name: 's',
                type: 'bool'
            }, {
                name: 't',
                type: 'string'
            }, {
                name: 'n',
                type: 'string'
            }, {
                name: 'b',
                type: 'string'
            }, {
                name: 'd',
                type: 'string'
            }] : [{
                name: 's',
                type: 'bool'
            }, {
                name: 'u',
                type: 'string'
            }, {
                name: 't',
                type: 'string'
            }, {
                name: 'e',
                type: 'string'
            }, {
                name: 'r',
                type: 'string'
            }, {
                name: 'c',
                type: 'string'
            }, {
                name: 'p',
                type: 'string'
            }, {
                name: 'n',
                type: 'string'
            }, {
                name: 'i',
                type: 'string'
            }, {
                name: 'a',
                type: 'bool'
            }],
            datatype: "array",
            updaterow: function(rowid, rowdata, commit) {
                commit(true);
                data[rowid] = rowdata;
                customSetting.dirty = true;
            }

        };
        //TODO: replace me by copadoGrid.activeDS
        datasetup.datasource = source;

        //adapter wrapper
        return new $copado.jqx.dataAdapter(source);
    },

    /**
     * Local cache of metadata get from attach
     * @type {Boolean}
     */
    metaDataCache: false,
    metaDataDateCache: false,

    usersDataCache: false,
    usersDataDateCache: false,

    initCallBack: function(metaOrgData, cachedDate) {
        if(metaOrgData === undefined) {
            console.warn("Deployment.Metadata initCallBack(): no metaOrgData? correcting");
            metaOrgData = [];
        }
        console.log('init initCallBack', metaOrgData.length, cachedDate);
        console.time('get saved data');
        var dataStep = dw.u.getSavedStepData(customSetting.stepType);

        if (dataStep) {

            if (customSetting.stepType == 'Delete MetaData') {
                metaOrgData = dataStep;
            } else {
                if (customSetting.stepType == 'Users') {
                    usersStep.savedData = dataStep;
                    metaOrgData = usersStep.mergeSavedMeta(metaOrgData, dataStep);
                } else {
                    metaOrgData = datasetup.mergeSavedMeta(metaOrgData, dataStep);
                }

                console.log('metaOrgData merged', metaOrgData.length);
            }
        } else {
            if (customSetting.stepType == 'Users') {
                usersStep.savedData = false;
            }

        }
        console.timeEnd('get saved data');
        datasetup.createCacheDeleteButton(cachedDate);
        copadoGrid.setOrgFilteredLink(copadoApp.orgFiltered, customSetting.orgId);

        copadoGrid.startGrid(customSetting.stepType, metaOrgData);
    },

    resetCache: function(data) {
        var len = data.length;
        while (len--) {
            data[len].s = false;
        }
    },

    preloadMetadata: function(orgId) {
        console.time('preload metadata');
        setTimeout(function() {
            dw.u.getCachedRemote({
                url: customSetting.getRemoteUrlByType('MetaData'),
                name: customSetting.mapAttachNameSource['MetaData'],
                parentId: orgId,
                force: false,
                success: function(metaOrgData, cachedDate) {

                    copadoGrid.metaDataCache = metaOrgData;
                    copadoGrid.metaDataDateCache = cachedDate;

                    console.timeEnd('preload metadata');
                },
                error: function(r) {
                    //console.log('Error: ',r)
                }
            });
        }, 1000);
    },

    init: function(force) {

        console.time('get meta data');
        //reset
        copadoGrid.hasPreviousSelected = false;

        console.log('copado grid init ', customSetting.stepType, customSetting.stepId, 'force:', force);

        if(customSetting.stepType == 'MetaData' || customSetting.stepType == 'Delete MetaData') {
            console.log('initGrid: showing new grid');
            $copado('#jqxgrid').hide();
            $copado('#metadataGrid2').show();
        }else{
            console.log('initGrid: showing old grid');
            $copado('#jqxgrid').show();
            $copado('#metadataGrid2').hide();
        }

        //check browser cache
        if (customSetting.stepType == 'Users') {
            var data = copadoGrid.usersDataCache;
            var date = copadoGrid.usersDataDateCache;
        } else {
            var data = copadoGrid.metaDataCache;
            var date = copadoGrid.metaDataDateCache;
        }

        if (!force && data) {
            copadoGrid.resetCache(data);
            console.log('metadata in browser cache')
            console.timeEnd('get meta data');
            copadoGrid.initCallBack(data, date);
        } else if (customSetting.stepType === 'Delete MetaData') {
            // NR: this else if is a no-op, since the delete metadata never has a url.
            console.log('Delete MetaData does not have a remote by url type. Ignoring');
            copadoGrid.initCallBack([], {});
        } else {
            console.log('metadata NOT in browser cache')

            if(customSetting.stepType == 'MetaData' || customSetting.stepType == 'Delete MetaData') {
                if(metadataGrid2) {
                    metadataGrid2.refreshCache(function() {
                        copadoGrid.initCallBack([], {});
                    });
                }else{
                    copadoGrid.initCallBack([], {});
                }
                return;
            }

                //start component
            dw.u.getCachedRemote({
                url: customSetting.getRemoteUrlByType(customSetting.stepType),
                name: customSetting.mapAttachNameSource[customSetting.stepType],
                parentId: customSetting.orgId,
                force: force,
                success: function(metaOrgData, cachedDate) {
                    console.log('get from attach or remote CB')
                    if (customSetting.stepType == 'Users') {
                        copadoGrid.usersDataCache = metaOrgData;
                        copadoGrid.usersDataDateCache = cachedDate;
                    } else {
                        copadoGrid.metaDataCache = metaOrgData;
                        copadoGrid.metaDataDateCache = cachedDate;
                    }
                    console.timeEnd('get meta data');
                    copadoGrid.initCallBack(metaOrgData, cachedDate);

                },
                error: function(r) {
                    //console.log('Error: ',r)
                }
            });
        }
    }
};