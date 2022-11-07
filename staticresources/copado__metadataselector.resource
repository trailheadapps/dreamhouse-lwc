var metadataGrid2 = null;
var copadoApp = copadoApp || {};

copadoApp.init = function(conf, force, isScalable, type){
    conf.force = force;    
    conf.isScalable = isScalable;
    conf.gridMode = 'metadataselector';
    metadataGrid2 = new MetadataGrid2(conf);
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

copadoApp.refreshCache = function() {
    metadataGrid2.refreshCache();
};

copadoApp.getSelectedElementList = function() {
    coGridHelper.datasource = metadataGrid2.sourceSelected;
    return coGridHelper.getSelectedObj();
};
copadoApp.save = function(){
    coGridHelper.datasource = metadataGrid2.datasource;
    coGridHelper.saveSelected(_config.data.id, _config.attachmentName, null, false, function(){
        window.top.location.href = '/'+metadataGrid2.conf.data.id;
    });
    copadoApp.diffCalculationGridDirty = false;
    return false;
};

copadoApp.cancel = function(){
    window.top.location.href = '/'+metadataGrid2.conf.data.id;
    return false;
};

copadoApp.deleteAttachment = function() {  
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


