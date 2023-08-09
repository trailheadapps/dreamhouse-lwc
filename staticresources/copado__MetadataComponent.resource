var metadataGrid2 = null;
var metadataTask = metadataTask || {};
var copadoApp = copadoApp || {};

(function(metadataGrid2, metadataTask) {

metadataTask.init = function(conf, force, isScalable, type){
    conf.force = force;    
    conf.isScalable = isScalable;
    
    metadataGrid2 = new MetadataGrid2(conf);

    // for delete metadata view (not editing), we do not need to load the org's metadata.
    console.debug("is metadata in view mode. Prevent loading all the org metadata", conf.gridMode == 'orgMetadata', conf, type)
    if(conf.gridMode == 'orgMetadata') {
        metadataGrid2.loadMetaData = function(callbackFinished, forceRefresh) {
            metadataGrid2._setGridData([]);
            if(callbackFinished)
                callbackFinished();
            return;
        };
    }

    metadataGrid2.render(function() {
        console.info("MetadataGrid:init grid rendered", conf);
        lockScreen();
        metadataGrid2.loadData(function() {
            console.info("MetadataGrid:init grid data loaded");
            metadataGrid2.render();
            unlockScreen();

        });
    });
}

metadataTask.refreshCache = function() {
    metadataGrid2.refreshCache();
};
metadataTask.refreshMetadataTypeCache = function() {
    metadataGrid2.refreshMetadataTypes();
};

metadataTask.loadSelectedData = function(){
    metadataGrid2.loadSelectedMetaData(unlockScreen);
}

metadataTask.save = function(){
    coGridHelper.datasource = metadataGrid2.datasource;
    
    console.log('helper',coGridHelper.datasource);
    
    coGridHelper.getSelectedObj();
    
    if (!coGridHelper._selectedNames.length) {
        
        //check if copadoApp showmessage is active
        if (copadoApp.showMessage) {
            copadoApp.showMessage('ERROR', copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY, 0);
        } else {
            alert(copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY);
        }
        return false;
    }
    /*coGridHelper.saveSelected(_config.data.id, _config.attachmentName, null, false, function(){
        console.info('Metadata Component: Delete Metadata Attachment saved!!');

    });*/
    metadataTask.diffCalculationGridDirty = false;
    return JSON.stringify(coGridHelper._selectedNames)
};

metadataTask.deleteAttachment = function() {  
    var parentId = _config.data.id;
    
    var result = dw.u.deleteAttach(_config.data.id, _config.attachmentName);
    if(result.success){
        metadataApp.showMessage('CONFIRM', copadoLabels.DELETE_SUCCESS_CLOSE_WINDOW, -1);
        metadataGrid2.render(function() {
            lockScreen();
            metadataGrid2.loadData(function() {
                metadataGrid2.render();
                unlockScreen();
            });
        });
        return false;
    }else{
        metadataApp.showMessage('ERROR', result.message, -1);
    }
    return false;
}

})(metadataGrid2, metadataTask);

