var metadataGrid2 = null;

var usTestClasses = usTestClasses || {};

usTestClasses.init = function (conf, force, isScalable, type, callback) {
    conf.force = force;
    conf.isScalable = isScalable;
    metadataGrid2 = metadataGrid2 || new MetadataGrid2(conf);

    metadataGrid2.render(function () {
        console.info("usTestClasses::MetadataGrid:init grid rendered", conf);
        lockScreen();
        metadataGrid2.loadData(function () {
            console.info("usTestClasses::MetadataGrid:init grid data loaded");
            metadataGrid2.render();
            unlockScreen();
        });
    });

    if (callback) {
        callback();
    }
};
usTestClasses.refreshCache = function () {
    metadataGrid2.refreshCache();
};

usTestClasses.save = function (isRollBack, namespace) {
    lockScreen();
    coGridHelper.datasource = metadataGrid2.datasource;
    coGridHelper.saveSelected(_config.data.id, _config.attachmentName, null, true, function () {
        if (isRollBack) {
            var sfQquery = `SELECT Id,${namespace}Deployment__c FROM ${namespace}Step__c WHERE Id='${metadataGrid2.conf.data.id}'`,
                result = sforce.connection.query(sfQquery),
                records = result.getArray('records');

            var deploymentId = records[0][`${namespace}Deployment__c`];
            window.top.location.href = `/apex/${namespace}DW_Overview?Id=${deploymentId}`;
        }
        else {
            window.top.location.href = '/' + metadataGrid2.conf.data.id;
        }
    },
        null,
        isRollBack
    );
    return false;
};

usTestClasses.cancel = function (isRollBack, namespace) {
    if (isRollBack) {
        var sfQquery = `SELECT Id,${namespace}Deployment__c FROM ${namespace}Step__c WHERE Id='${metadataGrid2.conf.data.id}'`,
            result = sforce.connection.query(sfQquery),
            records = result.getArray('records');
        window.top.location.href = '/apex/' + namespace + 'DW_Overview?id=' + records[0][`${namespace}Deployment__c`];
    }
    else {
        window.top.location.href = '/' + metadataGrid2.conf.data.id;
    }
    return false;
};

usTestClasses.autoIdentify = function (usId) {
    lockScreen();
    dw.u.getRemote(metadataGrid2.conf.server.autoSelectURL,
        function (res) {
            if (res) {
                console.log('res identified');
                if (res.copadoJobId) {
                    console.debug('job id located');
                    jsCreateRunningJob(res.copadoJobId, 'UserStoryTestClassesRetriever', usId, 'Preparing...');
                }
                console.info('usTestClasses.autoIdentify:::success', res);
                metadataGrid2.reloadSelections(0);
                return false;
            } else if (res && res.error) {
                console.error('usTestClasses.autoIdentify:::callback:::error', res.error);
                showMessage('ERROR', res.error);
                unlockScreen();
                return false;
            }
        },
        false,
        false,
        function (res) {
            console.error('usTestClasses.autoIdentify:::errorFunction:::error', res.error);
            showMessage('ERROR', (res.error || res));
            unlockScreen();
            return false;
        },
        'autoTestSelection'
    );
}