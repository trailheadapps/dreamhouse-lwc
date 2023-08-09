//Static Resources grid namespace
var srGrid = srGrid || {};

//closure
(function(app){

app = app || {};

app.stepType = 'MetaData';
app.FILTER_TYPE = 'StaticResource'

/**
 * shitch to edit mode the grid
 * @return {[type]} [description]
 */
app.edit = function(){

    //toogle edition mode
    $copado('#srSave,#srCancel').show();
    $copado('#srEdit').hide();

    app.editionMode = true;

    app.$grid.jqxGrid('clearfilters');

};

/**
 * cancel the edit mode
 * @param  {[type]} keep if false restore prev values on grid by reload the page
 * @return {[type]}      [description]
 */
app.cancel = function(keep){

    //toogle edition mode
    $copado('#srSave,#srCancel').hide();
    $copado('#srEdit').show();

    app.editionMode = false;

    if(!keep){
        $copado('#staticGridWrapper').html(loadingHTML);
        app.init(false,app.conf.backupId);
    }else{
        app.addSelectedFilter(app.$grid)
        
    }

};

/**
 * get selected items and save in unzipe attach related to git_backup
 * @return {[type]} [description]
 */
app.save = function(){

    coGridHelper.datasource = app.datasource;
    coGridHelper.saveSelected(app.conf.backupId , app.conf.attachName, null, true, function(){
        app.cancel(true);
    });
};

//config grid
app.startGrid = function (data) {         
    try{    

        //filter Static Resources items
        var len = data.length, 
        filtered = [];

        while(len--){
            //filter only staticresources type
            if(data[len].t == app.FILTER_TYPE){
                //initialize selection
                data[len].s = data[len].s || false;
                filtered.push(data[len]);

                app.hasPreviousSelected = app.hasPreviousSelected || data[len].s;
            }
        }

        //console.log('start typeof',typeof data)
        var theme = 'base',
        source = {
            localdata: filtered,
            datafields: [
                { name: 's', type: 'bool' },
                { name: 't', type: 'string' },
                { name: 'n', type: 'string' },
                { name: 'b', type: 'string' },
                { name: 'd', type: 'string' },
                { name: 'cb', type: 'string' },
                { name: 'cd', type: 'string' }
            ],
            datatype: 'array',
            updaterow: function (rowid, rowdata, commit) {
                if(app.editionMode){
                    commit(true);
                    filtered[rowid] = rowdata;

                }else{
                    commit(false);
                    alert(copadoLabels.BEFORE_EDITING_PRESS_EDIT_BUTTON);
                }
            }
        },

        //adapter wrapper
        dataAdapter = new $copado.jqx.dataAdapter(source),
        
        //keep jquery pointer for performance query
        $grid = $copado('<div>');
        
        $copado('#staticGridWrapper').html($grid);
        //save local source
        app.datasource = source;

        var types = [app.FILTER_TYPE]; 
        $grid.jqxGrid({
            width: '100%',
            height: '250px',
            source: dataAdapter,
            showfilterrow: true,
            filterable: true,
            theme: theme,
            editable: true, 
            selectionmode: 'none',
            enablebrowserselection: true,
            pageable: true,
            pagesizeoptions: ['10', '50','100','500','1000','5000'],
            pagesize: 200,
            sortable: true,
            columnsresize: true,
            localization: localizationobj,
            columns: [
              {text: copadoLabels.selected, columntype: 'checkbox', filtertype: 'bool', datafield: 's', width: 60 },
              {text: copadoLabels.name, filtertype: 'textbox', filtercondition: 'contains', editable:false, datafield: 'n'},
              {text: copadoLabels.type, filterItems: types, datafield: 't', filtertype: 'checkedlist',editable:false ,  columntype: 'textbox', width: 120 },
              {text: copadoLabels.LastModifiedById, filtertype: 'textbox', editable:false, datafield: 'b', width: 120},
              {text: copadoLabels.LastModifiedDate, filtertype: 'textbox', editable:false, datafield: 'd', width: 120},
              {text: copadoLabels.CREATEDBY, filtertype: 'textbox', editable:false, datafield: 'cb', width: 220},
              {text: copadoLabels.CREATEDDATE, filtertype: 'textbox', editable:false, datafield: 'cd', width: 120}
            ],
            ready: function(){
              console.log('ready grid event');
              
              //show selected if is edition
              app.hasPreviousSelected && app.addSelectedFilter($grid);
            }
        });

        app.$grid = $grid;

    }
    catch(e){
        console.error(e);
        throw e;
    }
};

app.addSelectedFilter = function( $grid){
    try{
        console.log('add selected fiter ')
        var filtergroup2 = new $copado.jqx.filter();
        var filter2 = filtergroup2.createfilter('booleanfilter', true, 'EQUAL');
        filtergroup2.addfilter(1,filter2);
        $grid.jqxGrid('clearfilters');
        $grid.jqxGrid('addfilter', 's', filtergroup2);
        $grid.jqxGrid('applyfilters');
    }catch(e){console.error('addfilter',e); };
};


app.refreshCache = function(){
    lockScreen();
    //statusManager.operationInProgress=true;
    //$copado('[id*=removeCacheContainer]').html('');
    $copado('[id$=removeCache]').hide();
    $copado('[id*=removeCacheContainer]').hide();
    $copado('#staticGridWrapper').html(loadingHTML);
    app.init(true, app.conf.backupId);
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
 * This method transform from Query SObject format 
 * to optimized metadata copado format
 *
 * e.g.: {Name:'aaa'} > {n:'aaa',t:'StaticResource'} 
 * 
 * @param  {[type]} data [description]
 * @return {[type]}      [description]
 */
app.transformQueriedData = function(data){

    if(!data) return [];

    var res = [], 
    len = data.length;

    for(var i=0; i<len ; i++){
        res.push({
            n: (data[i].NamespacePrefix ? data[i].NamespacePrefix +'__':'')+data[i].Name,
            t:'StaticResource'
        });
    }

    //console.log('transform res', res);
    return res;

};


/**
 * Start grid getting metadata and saved static resources
 * @param  {[type]} force    [description]
 * @param  {[type]} backupId [description]
 * @return {[type]}          [description]
 */
app.init = function(force, backupId){  

    app.conf = {
        orgId : metadataselector.orgId, 
        backupId: backupId,
        attachName: 'Unzip'
    };

    //start component
    lockScreen();

    //get metadata and saved statics resources and save
    dw.u.getCachedRemote({
       url: metadataselector.query_url,
       name:'ZippedStaticsResources',
       parentId: metadataselector.orgId,
       postData: 'SELECT Name, NamespacePrefix FROM StaticResource WHERE ContentType LIKE \'%zip%\' OR ContentType LIKE \'%octet-stream%\'',
       force: force,
       success:function(metaOrgData, cachedDate){

            //console.log('REMOTE', metaOrgData, cachedDate)
            metaOrgData = app.transformQueriedData(metaOrgData);

            var savedItems = dw.u.getSavedData(app.conf.backupId , app.conf.attachName);                  
            if(savedItems)metaOrgData = coGridHelper.mergeSavedData(metaOrgData,savedItems);  

            app.createCacheDeleteButton(cachedDate);
            app.startGrid(metaOrgData);
            unlockScreen();
       },
       error: function(r){
           console.log('Error: ',r)
       }
   }); 


};

}(srGrid)); //end closure
