var metadataGrid2 = null;

/**
* Previous hookups and initialization code:
**/
var snapshotDifferences = snapshotDifferences || {};
snapshotDifferences.init = function(conf, force, isScalable, type){
    if(metadataGrid2)
        return;

    conf.force = force;
    conf.isScalable = isScalable;
    conf.gridMode = 'snapshotDifferences';
    metadataGrid2 = new MetadataGrid2(conf);
    metadataGrid2.render(function() {
        console.info("MetadataGrid2:init grid rendered", conf);
        lockScreen();
        metadataGrid2.loadData(function() {
            console.info("MetadataGrid2:init grid data loaded");
            metadataGrid2.render();
            unlockScreen();

            // listen to any change in the selection
            document.addEventListener("copadoMetadataGrid2Changed", function(e) {
                if(snapshotDifferences) {
                    if(!snapshotDifferences.diffCalculationGridDirty) {
                    // NR: if this was the first change on the checked items of the grid, enable saving the changes.
                        snapshotDifferences.diffCalculationGridDirty = true;
                        snapshotDifferences.edit();
                    }
                }
            });

        });
    });
};

snapshotDifferences.getSelectedElementList = function() {
    if(metadataGrid2)
        coGridHelper.datasource = metadataGrid2.datasource;
    return coGridHelper.getSelectedObj();
};

snapshotDifferences.edit = function(){
    //toogle edition mode
    $copado('#btnSelectionsSave, #btnSelectionsCancel').show();
    $copado('#btnSelectionsEdit').hide();
};

snapshotDifferences.refreshCache = function() {
    metadataGrid2.refreshCache();
};

/**
 * get selected items and save in unzipe attach related to git_backup
 * @return {[type]} [description]
 */
snapshotDifferences.save = function(){
    coGridHelper.datasource = metadataGrid2.datasource;
    coGridHelper.saveSelected(_config.data.id, _config.attachmentName, null, true, function(){
        snapshotDifferences.cancel(true);
    });
    // NR: if this was the first change on the checked items of the grid, enable saving the changes.
    snapshotDifferences.diffCalculationGridDirty = false;
};

snapshotDifferences.cancel = function(keep){
    //toogle edition mode
    $copado('#btnSelectionsSave, #btnSelectionsCancel').hide();
    $copado('#btnSelectionsEdit').show();
    snapshotDifferences.editionMode = false;
    metadataGrid2.reloadSelections();
    // NR: if this was the first change on the checked items of the grid, enable saving the changes.
    snapshotDifferences.diffCalculationGridDirty = false;
};
