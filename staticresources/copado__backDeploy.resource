var backDeploy = backDeploy || {};
backDeploy.bindings = backDeploy.binding || {};
backDeploy.data = backDeploy.data || {};
backDeploy.config = backDeploy.config || {};
backDeploy.config.imageUrl = backDeploy.config.imageUrl || {};
backDeploy.branch = backDeploy.branch || {};
backDeploy.floater = backDeploy.floater || {};
backDeploy.floater.lockers = backDeploy.floater.lockers || [];
backDeploy.diff = backDeploy.diff || {};
backDeploy.labels = backDeploy.labels || {};
backDeploy.error = backDeploy.error || {};

var $copado = $copado || jQuery.noConflict();
backDeploy.resultMapforU;

backDeploy.config.ns = copadoApp.ns;
backDeploy.config.fileName = 'PROGRESS_STATUS_COPADO';
backDeploy.config.resultName = 'result.json';
backDeploy.config.viewType = 0;
backDeploy.config.contextSize = 5;
backDeploy.config.leftContent = '';
backDeploy.config.rightContent = '';
backDeploy.config.fromBranch = '';
backDeploy.config.toBranch = '';
backDeploy.config.currentUserId = '';
backDeploy.config.canvas = $copado('#boxCanvas').connectSVG();
backDeploy.config.imageUrl.loading = '../../src/statics/img/icons/loading.gif';
backDeploy.config.imageUrl.confirm = '../../src/statics/img/icons/confirm16.png';
backDeploy.config.imageUrl.error = '../../src/statics/img/icons/error16.png';
backDeploy.config.imageUrl.spacer = '../../src/statics/img/icons/s.gif';
backDeploy.config.imageUrl.lookup = '../../src/statics/img/icons/view.png';
backDeploy.config.herokuServer = '';

backDeploy.data.flowId = copadoApp.data.flowId;
backDeploy.data.calculationBasedOn = copadoApp.data.calculationBasedOn;
backDeploy.data.diffIndex = {};
backDeploy.data.mapStepIdEnvironments = [];
backDeploy.data.mapBoxIdToStepId = [];
backDeploy.data.stepIds = [];
backDeploy.data.env2branchMap = [];
backDeploy.data.DiffLinkTypePressed = '';
backDeploy.data.FlowStepPressed = '';
backDeploy.data.results = {};
backDeploy.data.currentGrid = {};
backDeploy.data.permissions = [];
backDeploy.data.attachmentIds = [];
backDeploy.data.gridItems = []; // MY added for fileDifferences grid data.
backDeploy.data.gridConflictedItems = []; // MY added for fileDifferences grid data.

backDeploy.polling = {};
backDeploy.polling.INTERVAL = 60;
backDeploy.recentlyFinishedTasks = {};


backDeploy.labels.AHEAD = 'ahead';
backDeploy.labels.BEHIND = 'behind';
backDeploy.labels.LOADING = 'Loading';
backDeploy.labels.NAME = 'Name';
backDeploy.labels.BRANCH = 'Branch';
backDeploy.labels.TEST_LEVEL = 'Test Level';
backDeploy.labels.AUTO_MERGE_DEPLOY = 'Auto Merge & Deploy';
backDeploy.labels.YES = 'Yes';
backDeploy.labels.NO = 'No';
backDeploy.labels.NEXT_ENVIRONMENT = 'Next Environment';
backDeploy.labels.MORE_DETAILS = 'More Details';
backDeploy.labels.IN_SYNC = 'In Sync';
backDeploy.labels.VIEW_DEPLOYMENT_STATUS = 'View Deployment Status';
backDeploy.labels.SYNC_BUTTON = 'Sync';
backDeploy.labels.CLICK_TO_VIEW_DETAILS = 'Click to view details';
backDeploy.labels.SYNC_NOT_ALLOWED = 'You are not allowed to perform this action. Please check with your administrator or refresh the page if the permissions were recently changed.';
backDeploy.labels.ARE_YOU_SURE = 'Are you sure?';


// prepares the call of fn(...) after some milliseconds in the future. If the call is repetated, it'll call it only once.
// -1 as seconds will just clear any previous call
backDeploy._callOnceAfter_cache = {};
backDeploy.callOnceAfter = function(fn, seconds, args) {
    //console.debug('backDeploy.callOnceAfter SET ', seconds, backDeploy._callOnceAfter_cache[fn]?'C':'-', fn.toString().replace(/[ \r\n]+/g, " ").substring(0,64), args);
    var callbackId = backDeploy._callOnceAfter_cache[fn] || null;
    if(callbackId) {
        window.clearTimeout(callbackId);
        delete backDeploy._callOnceAfter_cache[fn];
    }
    if(seconds>-1) {
        backDeploy._callOnceAfter_cache[fn] = window.setTimeout(function() {
            //console.debug('backDeploy.callOnceAfter CALL', seconds, backDeploy._callOnceAfter_cache[fn]?'C':'-', fn.toString().replace(/[ \r\n]+/g, " ").substring(0,64), args);
            fn(args);
        }, seconds);
    }
};


backDeploy.getFlowStepCoordinates = function() {
    var records = JsRemoting.deploymentFlows.getFlowStepCoordinates(backDeploy.config.ns, backDeploy.data.flowId);
    if (records[0][backDeploy.config.ns + 'Branch_Management_Coordinates__c'] == null) {
        __coordinates__ = records[0][backDeploy.config.ns + 'Flow_Step_Coordinates__c'];
    } else {
        __coordinates__ = records[0][backDeploy.config.ns + 'Branch_Management_Coordinates__c'];
    }
    return __coordinates__;
};
backDeploy.getsetCoordinates = function() {
    console.log('Setting coordinates...');
    var __coordinates__ = backDeploy.getFlowStepCoordinates();

    if (__coordinates__ && __coordinates__.length != 0) {
        var tmp = backDeploy.splitCoordinates(__coordinates__);
        for (var i = 0; i < tmp.length; i++) {
            var tmp2 = tmp[i].split('-');
            var box = document.getElementById(tmp2[0]);
            var $doc = $copado(document);
            if (box != null) {
                box.style.left = parseInt(tmp2[1]) > 0 ? tmp2[1] : 0;
                box.style.top = parseInt(tmp2[2]) > 0 ? tmp2[2] : 0;
            }
        }
    }
    backDeploy.parseCoordinates(__coordinates__);
    backDeploy.drawEnvironmentConnections();
};
/*
MY: Auto calculate env location
Parsing existing coordinates to calculate missing step or steps
*/
backDeploy.parseCoordinates = function(coordinates){
	var parsedEnvs = [];
	var envCoordinates = {};
	if (coordinates && coordinates.length != 0) {
        var tmp = coordinates.split(',')
        for (var i = 0; i < tmp.length; i++) {
            var tmp2 = tmp[i].split('-');
			var envId = tmp2[0].split('_')[1];
			parsedEnvs.push(envId)
            var leftPX = parseInt(tmp2[1]) > 0 ? tmp2[1] : 0;
            var topPX = parseInt(tmp2[2]) > 0 ? tmp2[2] : 0;
            var temp = {};
            temp.left = leftPX;
            temp.top = topPX;
            envCoordinates[envId] = temp;
        }
        backDeploy.getScratchEnvironments(parsedEnvs,envCoordinates);
    }
};
/*
MY: Auto calculate env location
Creating map of steps by using destination env id as a key and source environments as a value
*/
backDeploy.getScratchEnvironments = function(parsedEnvs,envCoordinates){
	var querySteps = "'"+parsedEnvs.join("','")+"'";
	var sourceMap = {};
	var destinationMaps = [];
	// Query deployment flow steps to get all environment related information to be used in the calculation
	var q = 'Select Id, Name , _NS_Source_Environment__c, _NS_Source_environment__r._NS_Type__c, _NS_Destination_Environment__c, _NS_Destination_environment__r._NS_Type__c From _NS_Deployment_Flow_Step__c where _NS_Deployment_Flow__c = \''+backDeploy.data.flowId+'\' AND _NS_Source_environment__c IN (' + querySteps + ')';
	q = q.replace(/_NS_/g, backDeploy.config.ns);
    var result = sforce.connection.query(q);
    var records = result.getArray("records");
    var destinationMap = {};
    var n = 0;
    //Creating map of steps by using destination env id as a key and source environments as a value
    for (var i = 0; i < records.length ; i++) {
        if(records[i].Source_Environment__r)
            sourceMap[records[i].Id] = records[i].Source_Environment__r[backDeploy.config.ns+'Type__c'];
		if(destinationMap.hasOwnProperty(records[i].Destination_Environment__c)){
			var temp = destinationMap[records[i].Destination_Environment__c];
			temp.push(records[i].Id);
			destinationMap[records[i].Destination_Environment__c] = temp;

		} else {
			var temp = [];
			temp.push(records[i].Id);
			destinationMap[records[i].Destination_Environment__c] = temp;
		}
		destinationMaps[n] = destinationMap;
		n++;
    }
    // Process map to draw new environment boxes in the proper place
    for (var i = destinationMaps.length - 1; i >= 0; i--) {
        $copado.each(destinationMaps[i],function(key,value){
            if(key && value)
            backDeploy.findEnvConnection(key,destinationMaps[i][key],envCoordinates)
        });
    }


};
/*
MY: Auto calculate env location
Calculate left and top of latest environment that points to given destination Id and put new environment box underneath it.
*/
backDeploy.findEnvConnection = function(destinationId,lowerEnvArray,envCoordinates){
	var maxTop = 0;
	var setLeft = 0;
	var newBoxes = [];
	copadoApp.envConnections.find(function(elem){
	    // Coordinate not found so set calculated left and top
	    if(lowerEnvArray && elem.toEnvId === destinationId && lowerEnvArray.indexOf(elem.flowStepId) <= -1){
	        console.log('couldnt find in the coordinates');
	        newBoxes.push( elem );
	    } else if(elem && elem.toEnvId === destinationId){
	    	var tempCo = envCoordinates[elem.fromEnvId];
			if(tempCo && parseInt(tempCo.top) > maxTop){
				maxTop = parseInt(tempCo.top);
				setLeft = parseInt(tempCo.left);
			}
	    }
	});
	if(newBoxes && newBoxes.length !== 0) {
	    for (var k = 0; k < newBoxes.length ; k++) {
            backDeploy.getsetLocations('wrapper_'+newBoxes[k].fromEnvId,setLeft,maxTop+75);
        }
	}
}
backDeploy.initialiseDraggable = function() {
    console.log('Initialising draggable...');
    if (copadoApp.envConnections.length > 0) {
        $copado('.jsEnvBoxWrapper').draggable({
            drag: function(event, ui) {
                backDeploy.config.canvas.redrawLines();
                backDeploy.floater.repositionFloater(ui.helper.attr('id'));
            },
            stop: function(event, ui) {
                backDeploy.getsetLocations(ui.helper.attr('id'), ui.position.left, ui.position.top);
            }
        });
    } else {
        setLockScreenMessage("");
        console.log('copadoApp.envConnections array is empty!');
        $copado('.jsEnvBoxWrapper').draggable();
    }
};
backDeploy.getsetLocations = function(id, top, left) {
    var envBoxes = $copado('.jsEnvBoxWrapper');
    var new_data = [''];
    for (var i = 0; i < envBoxes.length; i++) {
        new_data[i] = envBoxes[i].getAttribute('id') + '-' + envBoxes[i].style.left + '-' + envBoxes[i].style.top;
        if (envBoxes[i].getAttribute('Id') == id) {
            new_data[i] = id + '-' + top + 'px-' + left + 'px';
        }
    }
    backDeploy.doUpdate(new_data.toString());
};
backDeploy.doUpdate = function(coordinates) {
    console.log('Updating Flow...');
    if (coordinates.substring(0, 1) == ',') {
        coordinates = coordinates.substring(1);
    }
    var records = [];
    var r = new sforce.SObject(backDeploy.config.ns + "Deployment_Flow__c");
    r.Id = backDeploy.data.flowId;
    r[backDeploy.config.ns + 'Branch_Management_Coordinates__c'] = coordinates;
    records[0] = r;
    //var result = sforce.connection.update(records);
    var result = JsRemoting.common.update(records);
    __coordinates__ = coordinates;
    if (onResize) {
        onResize();
    }
};
backDeploy.drawSVGlines = function(leftNode, rightNode, destinationNode, envConnection) {
    //console.log('Drawing SVG lines...');
    color = 'light-blue';
    if (envConnection.ContinuousIntegrationId) {
        if (!backDeploy.showCIEnvironments)
            return;
        color = 'green';
    }
    backDeploy.config.canvas.drawLine({
        left_node: leftNode,
        right_node: rightNode,
        destinationNode: destinationNode,
        horizantal_gap: 25,
        error: true,
        style: 'solid',
        color: color,
        width: 2
    });
};
backDeploy.drawEnvironmentConnections = function() {
    for (i = 0; i < copadoApp.envConnections.length; i++) {
        backDeploy.drawEnvironmentConnection(copadoApp.envConnections[i].fromEnvId, copadoApp.envConnections[i].toEnvId, copadoApp.envConnections[i]);
    }
    backDeploy.floater.initialiseDraggable();
};
backDeploy.cssToInteger = function(ip) {
    if (!ip || ip == 'auto') return 0;
    if (typeof ip == 'number') return parseInt(ip.toFixed());
    var ip = (ip.length > 0) ? ip.replace(new RegExp('px', 'g'), '') : ip;
    var output = (ip != '') ? parseInt(ip) : 0;
    return parseInt(output.toFixed());
};
backDeploy.verifyPermission = function(destEnvId) {
    var currentUserId = '';
    for (var i = 0; i < backDeploy.data.permissions.length; i++) {
        if (backDeploy.data.permissions[i][backDeploy.config.ns + 'Environment__c'] == destEnvId) {
            return backDeploy.data.permissions[i][backDeploy.config.ns + 'Allow_Deployments__c'] == "true";
        }
    }
    return false;
};

// returns true if the job did start.
backDeploy.callHerokuAction = function(fromEnvId, toEnvId, action) {
    //var floaterId = 'floater_'+fromEnvId+'-'+toEnvId;
    var flowStepId = backDeploy.data.mapBoxIdToStepId[fromEnvId + '-' + toEnvId];
    console.assert(flowStepId, 'no flowStepId',fromEnvId + '-' + toEnvId,'in', backDeploy.data.mapBoxIdToStepId);

    var url = backDeploy.config.herokuServer + '/json/v1/gitBranchSync/' + backDeploy.data.flowId + '/' + flowStepId + '/' + action + copadoApp.urlParameters;
    console.log('Calling Heroku', url);
    utilsV2.method = 'POST';
    utilsV2.onFailureCB = function(res) {
        console.error(res);
        alert(res);
    };
    utilsV2.onSuccessCB = function() {
        setLockScreenMessage("Preparing Sync...");
    };
    var isSure = confirm(backDeploy.labels.ARE_YOU_SURE);
    if (!isSure) return false;

    var syncAllowed = backDeploy.verifyPermission(toEnvId);

    console.log('backDeploy.callHerokuAction() ... syncAllowed',syncAllowed,toEnvId,action);
    if (syncAllowed) {
        return utilsV2.getRemote(url);
    } else {
        alert(backDeploy.labels.SYNC_NOT_ALLOWED);
        return false;
    }
    return false;
};
backDeploy.recalculate = function(el) {
    var calBase = $copado('[id$="calbase"]').attr('id').slice(0,1);
    if(calBase == 'b'){
        el.value = 'Recalculating';
        var url = backDeploy.config.herokuServer + '/json/v1/branchStatuses/' + backDeploy.data.flowId + copadoApp.urlParameters;

        utilsV2.method = 'GET';
        utilsV2.onSuccessCB = function() {
            el.value = 'Recalculate';
        };
        utilsV2.onFailureCB = function(res) {
            console.error(res);
            el.value = 'Recalculate';
            unlock();
            alert(res);
        };

        var jobDidStart = utilsV2.getRemote(url);
        if(jobDidStart)
            setLockScreenMessage("Recalculating...");
    }
    else{
        setLockScreenMessage("Recalculating ");
        backDeploy.resultMapforU = null;
        backDeploy.setBoxStates();
    }
};
backDeploy.recalculateSingleBranch = function(el, branchName) {

    el.value = '';
    branchName = branchName || $copado(el).attr('data-branch');
    var flowStepId = $copado(el).closest("div[data-boxId]").attr('data-boxId');

    var url = backDeploy.config.herokuServer + '/json/v1/branchStatuses/' + backDeploy.data.flowId + copadoApp.urlParameters + '&branch=' + encodeURIComponent(branchName);
    console.log('Calling Heroku', url);
    utilsV2.method = 'GET';
    utilsV2.onSuccessCB = function() {
        el.value = '\u21ba';
    };
    utilsV2.onFailureCB = function(res) {
        console.error(res);
        el.value = '\u21ba';
        unlock();
        alert(res);
    };

    var jobDidStart = utilsV2.getRemote(url);
    if(jobDidStart)
        setLockScreenMessage("Recalculating " + branchName + "... ");
};

backDeploy.setIframeLocker = function(url) {
    $copado('#copadoIframe').attr('data-src', url);
};
backDeploy.floater.repositionFloater = function(boxId) {
    var $box = $copado('#' + boxId);
    var array = $box.attr('data-floaters');
    // NR: CI boxes have no floaters
    if (!array || !array.length)
        return;
    array = array.split(',');
    for (var i = 0; i < array.length; i++) {
        var envIds = array[i].replace(new RegExp('floater_', 'g'), '').split('-');
        backDeploy.floater.drawFloaterDiv(envIds[0], envIds[1]);
    }
};
backDeploy.floater.openDeploymentStatus = function(el) {
    var deploymentId = $copado(el).attr('data-deploymentId');
    backDeploy.setIframeLocker('/apex/'+backDeploy.config.ns+'deploymentStatus?id=' + deploymentId);
    openIframeBox();
};
backDeploy.floater.resetIcons = function(boxId) {
    $copado('#' + boxId + '_mergeValidation > img').prop('src', backDeploy.config.imageUrl.spacer);
    $copado('#' + boxId + '_pullValidation > img').prop('src', backDeploy.config.imageUrl.spacer);
    $copado('#' + boxId + '_mergeError > img').prop('src', backDeploy.config.imageUrl.spacer);
    $copado('#' + boxId + '_pullError > img').prop('src', backDeploy.config.imageUrl.spacer);
};
backDeploy.floater.drawFloaterDiv = function(fromEnvId, toEnvId) {

    var floaterId = 'floater_' + fromEnvId + '-' + toEnvId;

    $copado(".btn_" + fromEnvId + "_promotion").each(function() {
        if ($copado(this).attr('data-type') == 'merge') {
            $copado(this).attr('data-from', fromEnvId);
            $copado(this).attr('data-to', toEnvId);
        } else {
            $copado(this).attr('data-from', toEnvId);
            $copado(this).attr('data-to', fromEnvId);
        }
    });

    var $fromEnvBox = $copado('#wrapper_' + fromEnvId);
    var $toEnvBox = $copado('#wrapper_' + toEnvId);
    var $floaterBox = $copado('#' + floaterId);

};
backDeploy.floater.showInProgress = function(boxId, type) {
    $copado('#' + boxId + '_InProgress').show();
    $copado('#' + boxId + '_NoSync').hide();
    $copado('#' + boxId + '_InSync').hide();
    $copado('#' + boxId + '_DeploymentComplete').hide();
    if (type == 'GitBranchStatus') {
        backDeploy.data.results = [];
        backDeploy.floater.resetIcons(boxId);
    }
};
backDeploy.floater.hideInProgress = function(boxId) {
    $copado('#' + boxId + '_InProgress').hide();
    //backDeploy.floater.setStatusMessage(boxId, '');
};
backDeploy.floater.setDiffLinkVisibility = function(boxId, obj) {
    $copado('#' + boxId + '_pullDiff').hide();
    $copado('#' + boxId + '_mergeDiff').hide();
    if (obj.filesMergedBehind && obj.filesMergedBehind.length > 0) $copado('#' + boxId + '_pullDiff').show();
    if (obj.filesMergedAhead && obj.filesMergedAhead.length > 0) $copado('#' + boxId + '_mergeDiff').show();
};
backDeploy.floater.setDeploymentLinkVisibility = function(boxId, obj) {
    $copado('#' + boxId + '_deploymentStatus').hide();
    if (obj.deploymentId) {
        $copado('#' + boxId + '_deploymentStatus').attr('data-deploymentid', obj.deploymentId);
        $copado('#' + boxId + '_deploymentStatus').show();
    }
};
backDeploy.floater.setButtonsVisibility = function(boxId, obj) {
    if (!obj || !boxId) return null;

    $copado('#' + boxId + '_actionButtonPushUp').hide();
    $copado('#' + boxId + '_actionButtonPullDown').hide();

    if (obj.mergeValidationSuccess) {
        $copado('#' + boxId + '_actionButtonPushUp').show();
    }
    if (obj.pullValidationSuccess) {
        $copado('#' + boxId + '_actionButtonPullDown').show();
    }
    return true;
};
/*backDeploy.floater.setStatusMessage = function(boxId, value){
    $copado('#'+boxId+'_statusMessage').text(value);
};*/
backDeploy.floater.setValidationLinkVisibility = function(boxId, obj) {
    $copado('#' + boxId + '_pullValidation').hide();
    $copado('#' + boxId + '_mergeValidation').hide();
    $copado('#' + boxId + '_pullValidation > img').attr('src', backDeploy.config.imageUrl.spacer);
    $copado('#' + boxId + '_mergeValidation > img').attr('src', backDeploy.config.imageUrl.spacer);

    if (obj.pullValidationSuccess == false) {
        $copado('#' + boxId + '_pullValidation').show();
        $copado('#' + boxId + '_pullValidation > img').attr('src', backDeploy.config.imageUrl.error);
    } else if (obj.pullValidationSuccess == true) {
        $copado('#' + boxId + '_pullValidation').show();
        $copado('#' + boxId + '_pullValidation > img').attr('src', backDeploy.config.imageUrl.confirm);
    }
    if (obj.mergeValidationSuccess == false) {
        $copado('#' + boxId + '_mergeValidation').show();
        $copado('#' + boxId + '_mergeValidation > img').attr('src', backDeploy.config.imageUrl.error);
    } else if (obj.mergeValidationSuccess == true) {
        $copado('#' + boxId + '_mergeValidation').show();
        $copado('#' + boxId + '_mergeValidation > img').attr('src', backDeploy.config.imageUrl.confirm);
    }
};
backDeploy.floater.showInSyncMessage = function(boxId) {
    $copado('#' + boxId + '_NoSync').hide();
    $copado('#' + boxId + '_InSync').show();
    $copado('#' + boxId + '_InProgress').hide();
    $copado('#' + boxId + '_DeploymentComplete').hide();
};
backDeploy.floater.hideInSyncMessage = function(boxId) {
    $copado('#' + boxId + '_InSync').hide();
    $copado('#' + boxId + '_NoSync').show();
    //$copado('#'+boxId+'_InProgress').hide();
};

backDeploy.floater.setFloaterContent = function(boxId, obj, parentType) {
    console.debug("setFloaterContent", boxId, obj, parentType);
    //parentType = flow | step
    if (!obj) {
        $copado('#' + boxId + '_content').append('<div class="backDeploy">No results to display</p>');
        return;
    }
    if (!backDeploy.data.mapStepIdEnvironments) {
        $copado('#' + boxId + '_content').append('<div class="backDeploy">No flow step to display</p>');
        return;
    }

    //Set branch names
    $copado('#' + boxId + '_sourceBranch').html(obj.sourceBranch);
    $copado('#' + boxId + '_destinationBranch').html(obj.destinationBranch);


    if (parentType == 'flow') {
        //Set in Sync message
        if (obj.commitsBehind == 0 && obj.commitsAhead == 0) {
            backDeploy.floater.showInSyncMessage(boxId);
            $copado('#' + boxId + '_NoSync').hide();
            $copado('#' + boxId + '_InProgress').hide();
        } else {
            backDeploy.floater.hideInSyncMessage(boxId);
            (obj.pullConflictedFiles && obj.pullConflictedFiles.length > 0) ? $copado('#' + boxId + '_pullError').show(): $copado('#' + boxId + '_pullError').hide();
            (obj.mergeConflictedFiles && obj.mergeConflictedFiles.length > 0) ? $copado('#' + boxId + '_mergeError').show(): $copado('#' + boxId + '_mergeError').hide();
        }
        backDeploy.floater.setDiffLinkVisibility(boxId, obj);
        $copado('#' + boxId + '_commitsBehind').html(obj.commitsBehind + ' ' + backDeploy.labels.BEHIND);
        $copado('#' + boxId + '_commitsAhead').html(obj.commitsAhead + ' ' + backDeploy.labels.AHEAD);

    } else if (parentType == 'step') {
        if (obj.isDeployment == true) {
            $copado('#' + boxId + '_DeploymentComplete').show();
            $copado('#' + boxId + '_NoSync').hide();
            $copado('#' + boxId + '_InSync').hide();
            $copado('#' + boxId + '_InProgress').hide();
        }
        ((obj.pullValidationErrors && obj.pullValidationErrors.length > 0) || (obj.pullDeploymentErrors && obj.pullDeploymentErrors.length > 0)) ? $copado('#' + boxId + '_pullError').show(): $copado('#' + boxId + '_pullError').hide();
        ((obj.mergeValidationErrors && obj.mergeValidationErrors.length > 0) || (obj.mergeDeploymentErrors && obj.mergeDeploymentErrors.length > 0)) ? $copado('#' + boxId + '_mergeError').show(): $copado('#' + boxId + '_mergeError').hide();

        //Set Validation link visibility
        backDeploy.floater.setValidationLinkVisibility(boxId, obj);

        //Set buttons to enabled/disabled
        backDeploy.floater.setButtonsVisibility(boxId, obj);
    }
};
backDeploy.floater.hideActionButtons = function() {
    for (var i = 0; i < backDeploy.data.stepIds.length; i++) {
        var boxId = 'floater_' + backDeploy.data.mapStepIdEnvironments[backDeploy.data.stepIds[i]];
        $copado('#' + boxId + '_actionButtonPullDown').hide();
        $copado('#' + boxId + '_actionButtonPushUp').hide();
    }
};
backDeploy.floater.hideDiffLinks = function() {
    var boxId = 'floater_' + backDeploy.data.stepIds[i];
    for (var i = 0; i < backDeploy.data.stepIds.length; i++) {
        var boxId = 'floater_' + backDeploy.data.mapStepIdEnvironments[backDeploy.data.stepIds[i]];
        $copado('#' + boxId + '_pullDiff').hide();
        $copado('#' + boxId + '_mergeDiff').hide();
    }
};
backDeploy.floater.getFloaterObjectFromArray = function(stepId, array) {
    for (var i = 0; i < array.length; i++) {
        if (array[i].id == stepId) return array[i];
    }
    return null;
};
backDeploy.floater.initialiseDraggable = function() {
    $copado('.js-draggable').draggable();
};

backDeploy.displayLogs = function(dbug) {
    var elt = document.getElementById('syncLogs');
    elt.innerText = '';
    // NR: retrieve the "Logs" notes, and show it.
    var q = "SELECT Body FROM Note WHERE Title='Logs' AND ParentId='" + backDeploy.data.flowId + "' ORDER BY LastModifiedDate DESC limit 1",
        result = sforce.connection.query(q),
        records = result.getArray("records");
    for (var ix = 0; ix < records.length; ix++) {
        elt.innerText = ('' + records[ix].Body).replace(/(:[0-9]+)\.[0-9]+/g, '$1').replace(/\n/g, '\n\n');
    }
};

/**
Sets the text status and Locks/unlocks one or two boxes ( the ones belonging to a step ID )
(unlocks the box when status == null)
**/
backDeploy.setStatusOfBoxesInStepId = function(stepId, status) {
    var srcEnvId, destEnvId, t;
    if ((t = backDeploy.data.mapStepIdEnvironments[stepId])) {
        t = t.split('-');
        srcEnvId = t[0];
        destEnvId = t[1];
    }
    var srcEnv = $copado('#box_' + srcEnvId),
        destEnv = $copado('#box_' + destEnvId);
    var stepInfo = backDeploy.config.map[stepId];
    console.debug('backDeploy.setStatusOfBoxesInStepId()', stepId, status, srcEnvId, destEnvId, srcEnv.length, destEnv.length,
        stepInfo? (stepInfo.Branch__c) : 'n/a');

    if (status !== null) {
        srcEnv.find('.statusContent').removeClass('statusContentSync').show().text(status);
        destEnv.find('.statusContent').removeClass('statusContentSync').show().text(status);

        // create the overlay append it to the env box and show it.
        var html = html || '<div class="co-lockerBlock1"><center><img style="width:40px" src="' + copadoApp.lightningSpinner + '" /></center></div>';
        var srcLock = $copado(html),
            destLock = $copado(html);
        if (!srcEnv.find('.co-lockerBlock1').length)
            srcEnv.css({
                position: 'relative'
            }).append(srcLock);
        if (!destEnv.find('.co-lockerBlock1').length)
            destEnv.css({
                position: 'relative'
            }).append(destLock);
    } else {
        srcEnv.find('.co-lockerBlock1').remove();
        destEnv.find('.co-lockerBlock1').remove();
        srcEnv.find('.statusContent').hide().text('');
        destEnv.find('.statusContent').hide().text('');
    }
};

backDeploy.initializeStatusManagerMessage = function(elem) {
    /*
    var stepId = $copado(elem).attr('data-boxId');

    var destEnv, t;
    if( (t=backDeploy.data.mapStepIdEnvironments[stepId]) ) {
        t = t.split('-');
        destEnv = $copado('#box_'+t[1]+' .statusContent');
    }

    var html = '<span>Initialising...</span>'
        $copado('[data-stepContent$=' + stepId + ']').html(html);
        $copado('[data-stepContent$=' + stepId + ']').show();
    if(destEnv&&destEnv.length) {
        destEnv.html(html);
        destEnv.show();
    }
    */
};
backDeploy.lockSection = function(elem) {
    //Lock section will be enabled when the proper attachment and status management structure are implemented
    /*backDeploy.polling.INTERVAL = 20;
    var stepId = $copado(elem).attr('data-boxId');
    $copado('[data-stepContent$=' + stepId + ']').hide();
    if (backDeploy.data && backDeploy.data.mapStepIdEnvironments && backDeploy.data.mapStepIdEnvironments[stepId]) {
        var envIds = backDeploy.data.mapStepIdEnvironments[stepId].split('-');
        for (var i = envIds.length - 1; i >= 0; i--) {
            var box = $copado('#box_' + envIds[i]);
            if (box.data('locked'))
                continue;
            box.data('locked', 'on');
            // create the overlay append it to the env box and show it.
            var html = html || '<div class="co-lockerBlock"><center><img style="width:40px" src="' + copadoApp.lightningSpinner + '" /></center></div>';
            var $locker = $copado(html);
            box.css({
                position: 'relative'
            }).append($locker);
            $locker.show();
        }
    }*/

};

backDeploy.hideStatusMessage = function(elemId) {
    console.info('hideStatusMessage()', elemId);
    $copado('[data-stepContent$=' + elemId + ']').hide();
};

backDeploy.unlockSection = function(envId) {
    //Lock section will be enabled when the proper attachment and status management structure are implemented
    /*console.info('unlockSection()', envId);
    var box = $copado('#box_' + envId);
    box.find('div.co-lockerBlock').hide();
    box.data('locked', '');*/
};

backDeploy.refreshStepData = function(callback) {
    /// reloads the deployment flow steps
    var core = copadoApp.ns ? window[copadoApp.ns.split('__')[0]] : window;
    (core).BranchManagementExtension.getAllStepDetails(
        copadoApp.data.flowId,
        function(result, event) {
            if (event.status) {
                backDeploy.config.map = result;
            } else if (event.status === 'exception') {
                console.error("backDeploy.refreshStepData() err", result);
                alert(result);
            } else {
                console.warn(result);
                alert(result);
            }
            backDeploy.setBoxStates();
        }
    );
};

var _bm_refreshStep = function() {
    backDeploy.refreshStepData(function() {
        backDeploy.setBoxStates();
    });
};

/// reloads the deployment flow steps and redraw. Can be called multiple times, but will redraw only once
backDeploy.refreshAndRerender = function() {
    backDeploy.callOnceAfter(_bm_refreshStep, 5000);
};

backDeploy.processAttachments = function(calledFrom, onlyFlowAndStepId) {
    console.debug('processAttachments()', calledFrom);
    if (!backDeploy.data.flowId || backDeploy.data.stepIds.length == 0) return [];

    // copy the array backDeploy.data.stepIds, since it'll be changed.
    var localList = [];
    if(onlyFlowAndStepId) {
        localList.push(backDeploy.data.flowId);
        localList.push(onlyFlowAndStepId);
    }else{
        localList = backDeploy.data.stepIds.slice();
        localList.push(backDeploy.data.flowId);
    }
    var idString = '';
    for (var i = 0; i < localList.length; i++) {
        idString += ((i != 0) ? ',' : '') + '\'' + localList[i] + '\'';
    }
    var q1 = 'Select Id, Name, ParentId From Attachment where ParentId IN (' + idString + ') and Name IN (\'' + backDeploy.config.resultName + '\',\'' + backDeploy.config.fileName + '\') order by Name DESC';
    result = sforce.connection.query(q1);
    records = result.getArray('records');

    if (records.length > 0) {
        var atts = [];
        for (var i = 0; i < records.length; i++) {
            var att = JsRemoting.attachments.getDecodedAttachmentById(records[i].Id);
            if (!att) continue; // the attachment might have been deleted between select and this.

            // set when was the last time this was called, so the polling function can know wether to check or not
            backDeploy.polling.lastTimeInProgress = new Date().getTime();

            if (att.Name === backDeploy.config.fileName) {
                // never reprocess an attachment if it was called from attachment. To avoid recursion
                backDeploy.statusHandler(att, calledFrom);
                backDeploy.startPolling(); // in case it was not started.
            } else if (att.Name === backDeploy.config.resultName) {
                backDeploy.resultHandler(att, calledFrom);
            } else {
                console.error('Unknown attachment type', att, calledFrom);
            }
        }
    }
    return records;
};

backDeploy.resultHandler = function(attachment, calledFrom) {
    if (!attachment || attachment.Body.length === 0) return false;

    var obj = JSON.parse(attachment.Body);
    console.debug('backDeploy.resultHandler obj=', calledFrom, attachment.Name, attachment.ParentId,
        attachment.ParentId == backDeploy.data.flowId?'FLOW': 'STEP');

    backDeploy.data.results[attachment.ParentId] = obj;

    if (attachment.ParentId == backDeploy.data.flowId) {
        // the results changed. This means the brachStatus/branchValidation was finished (?)
        // NO! THIS IS ALSO REACHED BY READING THE ATTACHMENTS, WHILE LOADING, FOR EXAMPLE.
        backDeploy.refreshAndRerender();
    }

};

backDeploy._countPendingCopadoNotifications = function() {
    var localList = backDeploy.data.stepIds.slice();
    if(!localList || !localList.length) return;
    for (var i = 0; i < localList.length; i++)
        localList[i] = "'BranchValidationDeployment-"+localList[i]+"'";
    localList.push("'GitBranchStatus-"+backDeploy.data.flowId+"'");
    var q1 = 'SELECT Id, _NS_ParentId__c, _NS_isFinished__c FROM _NS_Copado_Notification__c where CreatedDate = LAST_N_DAYS:1 AND _NS_isFinished__c=false AND _NS_Matching_Key__c IN (_KEYS_)'.replace(/_NS_/g, backDeploy.config.ns).replace(/_KEYS_/g, localList);
    var result = sforce.connection.query(q1);
    console.debug("result BranchValidationDeployment", result.size, 'waiting jobs', q1, result);
    return parseInt(result.size);
};

_checkForBranchValidation = function(calledFrom) {
    console.debug('_checkForBranchValidation');
    var thereArePendingJobs = backDeploy._countPendingCopadoNotifications();
    if(!thereArePendingJobs) {

        backDeploy.data.stepIds.forEach(function(stepId) {
            backDeploy.setStatusOfBoxesInStepId(stepId, null);
        });
        backDeploy.refreshAndRerender();
        //var result = sforce.connection.deleteIds([attachment.Id]);
        //console.debug("Deleted: ", result[0].success);
        // we stop the polling, even when there might be other BranchValidationDeployment running.
        backDeploy.stopPolling();
    }
};

// this function can be called DIRECTLY from statusManager ( calledFrom == undefined )
backDeploy.statusHandler = function(attachment, calledFrom) {
    if (!attachment || attachment.Body.length === 0) return false;
    var obj = JSON.parse(attachment.Body);

    var stepInfo = backDeploy.config.map[attachment.ParentId];
    console.log('backDeploy.statusHandler()', 'fr:'+calledFrom, attachment.Id, attachment.ParentId,
        backDeploy.data.stepIds.indexOf(attachment.ParentId) > -1, obj.type, obj.isFinished?'[FIN]':'running',
        stepInfo? (stepInfo.Branch__c) : 'n/a');

    backDeploy.startPolling(); // if it's started, it'll just return

    // if a gitbranchstatus returns differences, copado starts a BRANCHVALIDATION, so we need to keep on the lookout for this job.
    if (obj.type === 'BranchValidationDeployment') {
        // ignore any other step not in  deployment flow.
        if (backDeploy.data.stepIds.indexOf(attachment.ParentId) > -1) {
            if (obj.isFinished) {
                var _callAfter = function() {
                    backDeploy.setStatusOfBoxesInStepId(attachment.ParentId, null);
                    backDeploy.refreshAndRerender();
                };
                // In a few seconds, remove the last message (gives time to actually get the results)
                backDeploy.callOnceAfter(_callAfter, 5000);
            } else {
                backDeploy.setStatusOfBoxesInStepId(attachment.ParentId, obj.status||'Still processing...');
                backDeploy.refreshAndRerender();
            }
        }
        return;
    }else if (obj.isFinished) {
        setLockScreenMessage('');
        backDeploy.refreshAndRerender();
    } else {
        setLockScreenMessage(obj.status);
    }

    backDeploy.displayLogs(1);
};

backDeploy.startPolling = function() {
    if(backDeploy.polling.pollingIsStarted)
        return;
    backDeploy.polling.pollingIsStarted = true;
    backDeploy.polling.lastTimeInProgress = new Date().getTime();
    var pollerFunction = function() {
        var timeDiff = (new Date().getTime() - backDeploy.polling.lastTimeInProgress)/1000;
        if(timeDiff>backDeploy.polling.INTERVAL) {
            _checkForBranchValidation('polling');
            backDeploy.polling.lastTimeInProgress = new Date().getTime();
        }
        if(backDeploy.polling.pollingIsStarted)
            backDeploy.polling.setTimeoutId = window.setTimeout(pollerFunction, 5000);
    };
    backDeploy.polling.setTimeoutId = window.setTimeout(pollerFunction, 5000);
};

backDeploy.stopPolling = function() {
    console.debug("backDeploy.stopPolling");
    backDeploy.polling.pollingIsStarted = false;
    window.clearTimeout(backDeploy.polling.setTimeoutId);
};

backDeploy.drawEnvironmentConnection = function(fromEnvId, toEnvId, envConnection) {
    //console.log('Draw connection: ' + fromEnvId + ' ' + toEnvId);
    backDeploy.setDestinatonEnvName(fromEnvId, toEnvId);
    var fromEnvBox = '#wrapper_' + fromEnvId;
    var toEnvBox = '#wrapper_' + toEnvId;
    backDeploy.drawSVGlines(fromEnvBox, toEnvBox, toEnvBox, envConnection);
    if (!envConnection.ContinuousIntegrationId)
        backDeploy.floater.drawFloaterDiv(fromEnvId, toEnvId);
};
backDeploy.addDetailHover = function(env) {
    var content = '';
    content = '<b>' + backDeploy.labels.NAME + ':</b> ' + env.envName + '<br />' +
        '<b>' + backDeploy.labels.BRANCH + ':</b> ' + ((env.branch) ? env.branch : '') + '<br />' +
        '<b>' + backDeploy.labels.TEST_LEVEL + ':</b> ' + ((env.testLevel) ? env.testLevel : '') + '<br />' +
        '<b>' + backDeploy.labels.AUTO_MERGE_DEPLOY + ':</b> ' + ((env.autoMergeDeploy && env.autoMergeDeploy == 'true') ? backDeploy.labels.YES : backDeploy.labels.NO) + '<br />' +
        '<b>Flow Step Id:</b> ' + env.flowStepId;
    var elt = $copado('#viewInfo_' + env.envId);
    if (elt && elt.length)
        elt.jqxTooltip({
            content: content,
            position: 'mouse',
            name: env.envName + 'Details'
        });
};
backDeploy.drawEnvironmentBoxes = function() {
    console.log('Drawing Environment Boxes...');
    for (var i = 0; i < copadoApp.environments.length; i++) {
        backDeploy.addEnvBox(null, copadoApp.environments[i].envName, copadoApp.environments[i].envId, copadoApp.environments[i].flowStepId, copadoApp.environments[i].branch, copadoApp.environments[i]);
        backDeploy.addDetailHover(copadoApp.environments[i]);
    }
    // Give the browser a few ms to stabilize the DOM
    window.setTimeout(function() {
        backDeploy.getsetCoordinates();
        backDeploy.initialiseDraggable();
    },100);
};
backDeploy.setDestinatonEnvName = function(fromEnvId, toEnvId) {
    var toEnvName = $copado('#' + toEnvId + '_title').text();
    $copado('#nextDestEnvBody_' + fromEnvId).text(toEnvName);
    if (toEnvName.length > 0) $copado('#detailModeBody_' + fromEnvId).show();
    $copado('#box_' + fromEnvId + ' #hdn_DestEnvName').val(toEnvName);
    $copado('#box_' + fromEnvId + ' #hdn_DestEnvId').val(toEnvId);
};
backDeploy.setEnvironmentValues = function(envId, destEnvName, destEnvId, flowStepId) {
    console.log('Setting Environment values...');
    backDeploy.setDestinatonEnvName(envId, destEnvId);
    $copado('#wrapper_' + envId).attr('data-flowStepId', flowStepId);
    //$copado('#detailMode_'+envId).show();
};
backDeploy.buildEnvBox = function(envName, envId, style, branch, env, flowStepId) {
    //console.debug('backDeploy.buildEnvBox', envName, branch);
    style = (style == '' || style == null || typeof style == 'undefined') ? '' : style;
    branch = (typeof branch == 'undefined' || branch == null) ? '' : htmlEntities(branch);
    // NR: this determines if this EnvBox is the dest org of a CI job.
    // if so, it needs to be rendered differently.
    var step = backDeploy.data.flowStepMapByToEnvId ? backDeploy.data.flowStepMapByToEnvId[envId] : null;
    var s;
    var callBase = $copado('[id$="calbase"]').attr('id').slice(0,1);
    if (step && step.ContinuousIntegrationId) {
        s = "<div style='" + style + "'class='jsEnvBoxWrapper CIStepWrapper' id='wrapper_" + envId + "' data-flowStepId=''>" +
            "<div id='box_" + envId + "' class='envBox CIStep'>" +
            "<h4 class='clearfix' style='text-overflow: ellipsis; white-space: nowrap; overflow: hidden;'>" +
            "<span onclick=\"window.open('/" + step.ContinuousIntegrationId + "')\" class='title' title='Click to see details...' target='_blank' style='cursor: pointer;float:left;'><u>" + htmlEntities(envName) + "</u></span>" +
            "</h4>" +
            "<p> Status: " + step.ContinuousIntegrationStatus + "</p>" +
        "</div>" +
        "</div>";
    } else {
        s = "<div style='" + style + "'class='jsEnvBoxWrapper' id='wrapper_" + envId + "' data-flowStepId='"+flowStepId+"' data-floaters='' data-branch='" + branch + "'>" ;
        if(env.orgType == 'Scratch Org'){
            s += "<img id='typeImage' src='https://lh3.googleusercontent.com/-SKXUk6eYz2I/WmDRX0UjIPI/AAAAAAAAAW8/dCvjQ4cQWBYJldC9HaVZSSozqWpU32PegCK8BGAs/s0/2018-01-18.png' style='width: 62px;position:  absolute;bottom: 10px;right: 159px; z-index: 100;'>";
        }
        s += "<div id='box_" + envId + "' data-branch='" + branch + "' data-boxId='' class='envBox' style='background-color:#f4f6f9 !important; border-color:#0070d2;margin-left:5px !important'>"+
        "<div style='float: left;height: 100%;text-align: center;background-color:#f4f6f9;'>";
        if(backDeploy.data.calculationBasedOn != 'User Story'){
          s+="<input type='button' onclick='backDeploy." +(callBase == 'u' ? "recalculate" : "recalculateSingleBranch")+"(this);' data-branch='" + branch + "' data-parentSelector='box_" + envId + "' class='resyncEnv' value='↺'' title='Recalculate this branch'>";
        } else {
            s+="<input type='button'class='resyncEnv' title='Re-calculation is disabled for user story based flows' disabled='true'>";
        }
        s += "</div>"+
        "<div style='float:left;width:70%;'><h3 class='clearfix' style='text-overflow: ellipsis; white-space: nowrap; overflow: hidden;'>" +
        "<a onclick='javascript:return false;' id='" + envId + "_title' class='title' style='color:#16325c;' target='_blank' title='" + envName + "'>" + htmlEntities(envName) + "</a></br>" +
        "<p class='title' style='color:darkgray;font-size:12px;padding:0;' title='"+branch+"'>branch : "+htmlEntities(branch)+"</p></div>" +
        "</h3>"+
        "<div>";
        if (envId != copadoApp.finalDestination) {
            s += "<button type='button' style='border-top-right-radius:.44em' onclick='openModal(this);' title='Promote...' class='btnPromotion paper-raise slds-button btn_" + envId + "_promotion' data-envId='" + envId + "' data-type='merge' data-flowStepId='"+flowStepId+"' data-flowId='" + backDeploy.data.flowId + "'>" + backDeploy.SVG_ARROW_RIGHT + "</button>";
            if(env.orgType != 'Scratch Org'){
                s += "<button type='button' style='border-bottom-right-radius:.44em' onclick='openModal(this);' title='Back Promote...' class='btnPromotion slds-button paper-raise btn_" + envId + "_promotion' data-envId='" + envId + "' data-type='pull' data-flowStepId='"+flowStepId+"' data-flowId='" + backDeploy.data.flowId + "'>" + backDeploy.SVG_ARROW_LEFT + "</button>";
            }

        }
        s += "</div>" +
            "<input type='hidden' id='hdn_DestEnvId' value='' />" +
            "<input type='hidden' id='hdn_DestEnvName' value='' />" +
            "<input type='hidden' id='hdn_Branch' value='" + branch + "' />" +
            "<div id='box_" + envId + "_content' class='statusContent' data-stepContent='' data-envContent='" + envId + "' width='100%' height='22px' style='display:none;'></div>" +
            "</div>" +

            "</div>";
    }
    return s;
};
backDeploy.environmentboxOnCanvas = function(envId) {
    if ($copado('#box_' + envId).length) return true;
    return false;
};
backDeploy.calloutCounter = 0;
backDeploy.setBoxStates = function() {
    console.log('here we are again!');
    var calBase = $copado('[id$="calbase"]').attr('id').slice(0,1);
    //there are two inputHiddens each ends with calbase(calculation base) but starts with u or b
    //if the first letter is U then, User panel is rendered, if not then, Branch panel is rendered
    var ns = backDeploy.config.ns;
    var core = ns ? window[ns.split('__')[0]] : window;
    console.log('calbase==> ',calBase);
    if(calBase!='b' && !backDeploy.resultMapforU){
        console.log('selam...');
        var jIter;
        console.time();
        //it supports up to 200 parallel async callouts which means 199 different deployment flow step under 1 deployment flow.
        //https://help.salesforce.com/articleView?id=000187436&type=1


        //UCU - used to send flowId instead but changed it to flowStepId based on too many soql query promlem
        var returnColor4perOrg = function(j) {
            console.log('backDeploy.calloutCounter===> ',backDeploy.calloutCounter);
            if(document.querySelectorAll('.jsEnvBoxWrapper').length != backDeploy.calloutCounter){
                (core).BranchManagementExtension.returnOrgColors(
                document.querySelectorAll('.jsEnvBoxWrapper')[j].getAttribute('data-flowstepid'),
                function( result, event ) {
                    if(event.status){
                        backDeploy.resultMapforU = backDeploy.resultMapforU ? $copado.extend(backDeploy.resultMapforU ,result) : result;
                        backDeploy.calloutCounter++;
                        console.log('remaining cpu ===> ',parseInt(backDeploy.resultMapforU.cpuTime.color));
                        if(document.querySelectorAll('.jsEnvBoxWrapper').length  == backDeploy.calloutCounter){
                            backDeploy.setStates(backDeploy.resultMapforU,calBase);
                        } else{
                            setLockScreenMessage('Loaded '+(j+1)+' of '+document.querySelectorAll('.jsEnvBoxWrapper').length+' deployment flow steps.');
                            returnColor4perOrg(++j);
                        }
                    }
                });
            } else if(document.querySelectorAll('.jsEnvBoxWrapper').length  == backDeploy.calloutCounter){
                backDeploy.setStates(backDeploy.resultMapforU,calBase);
            }
        }
        returnColor4perOrg(0);
    }
    else if(calBase=='b'){
        backDeploy.setStates(null,calBase);
    }
};

backDeploy.setStates = function(resultMapforU,calBase){
    $copado(".btnPromotion").each(function(wrapperElt) {
        var buttonElt = $copado(this);
        var boxElt = buttonElt.closest('.envBox');
        var flowStepId = buttonElt.data('flowstepid');
        var contentElt = boxElt.find(".statusContent");

        var usRelatedData = {fromEnvId : $copado(this).data('to'), envId : $copado(this).data('from'),sucCount:0,errCount:0,nullCount:0,totalCount:0}

        // reset any state
        buttonElt.removeClass('btnAheadOrBehind');
        buttonElt.css('background-color', 'transparent');

        var htmlMessage = '';
        var isMergeOrPull = buttonElt.attr('data-type') === 'merge';

        var stepDetail = backDeploy.config.map[flowStepId];
        if(!stepDetail) {
            console.error("step detail does not exist", flowStepId);
            return;
        }
        var Commits_Ahead = stepDetail[backDeploy.config.ns+'Commits_Ahead__c'];
        var Commits_Behind = stepDetail[backDeploy.config.ns+'Commits_Behind__c'];
        var Sync_Merge_State = stepDetail[backDeploy.config.ns+'Sync_Merge_State__c'];
        var Sync_Pull_State = stepDetail[backDeploy.config.ns+'Sync_Pull_State__c'];

        var inSync = Sync_Merge_State=='In sync'&&Sync_Pull_State=='In sync';
        //console.log('calBase===> ',calBase);
        if(calBase=='b'){
            if(inSync) {
                if(!contentElt.text()) {
                    htmlMessage = ''+backDeploy.SVG_INSYNC_CHECKBOX + backDeploy.labels.IN_SYNC+'';
                    contentElt.addClass('statusContentSync').show().html(htmlMessage);
                }
            }else{

                if( (contentElt.text()||'').indexOf(backDeploy.labels.IN_SYNC)>-1 )
                    contentElt.hide().html('');

                //If the step source and destination are not in sync change bg-color of the action buttons on the env box.
                var color='transparent', msg='', isUnsynced=false;

                if (isMergeOrPull) {
                    if(Sync_Merge_State=='Needs recalculating') { color = 'yellow'; msg=Sync_Merge_State; }
                    else if(Sync_Merge_State=='Validated') { color = 'green'; isUnsynced=true; }
                    else if(Sync_Merge_State=='Validation errors') { color = 'red'; isUnsynced=true; }
                } else {
                    if(Sync_Pull_State=='Needs recalculating') { color = 'yellow'; msg=Sync_Pull_State; }
                    else if(Sync_Pull_State=='Validated') { color = 'green'; isUnsynced=true; }
                    else if(Sync_Pull_State=='Validation errors') { color = 'red'; isUnsynced=true; }
                }
                if(isUnsynced)
                    buttonElt.addClass('btnAheadOrBehind');
                buttonElt.css('background-color', color);
                buttonElt.attr('title', (isMergeOrPull?'Promote...':'Back Promote...') + msg );
            }
        }
        else if(resultMapforU && calBase!='b'){
            var color = '';
            //below control is to prevent showing US's available for back promotion to same org
            var key = (isMergeOrPull == false ? usRelatedData.fromEnvId : '') + usRelatedData.envId + isMergeOrPull.toString();
            //console.log('key===========> ',key);
			color = (resultMapforU[key] ? resultMapforU[key].color : 'transparent');
            if(color != 'transparent' && color != 'yellow'){
                buttonElt.addClass('btnAheadOrBehind');
            }
            buttonElt.css('background-color', color);
            buttonElt.attr('title', (isMergeOrPull?'Promote...':'Back Promote...'));
        }
    });
    console.timeEnd();
    setLockScreenMessage('');
};
backDeploy.counter = 0;
backDeploy.addEnvBox = function(fromEnvId, envName, envId, flowStepId, branch, environment) {

    var style = '';
    if (typeof fromEnvId != 'undefined' && fromEnvId != null) {
        $copado('#wrapper_' + envId).attr('data-flowStepId', flowStepId);
        
        var box = document.getElementById('wrapper_' + envId);
        box.style.left = '20px';
        box.style.top = '20px';
        $copado('#box_' + envId).attr('data-boxId', flowStepId);
        $copado("#box_" + envId + "_content").attr('data-stepContent', flowStepId);

        $copado(".btn_" + envId + "_promotion").each(function() {
            $copado(this).attr('data-flowStepId', flowStepId);
        });
        var top = $copado('#wrapper_' + fromEnvId).css('top');
        var left = $copado('#wrapper_' + fromEnvId).css('left');
        var width = $copado('#wrapper_' + fromEnvId).width();
        style = 'top:' + top + '; left:' + (parseInt(left) + width + 50) + 'px;';
    }
    if (backDeploy.environmentboxOnCanvas(envId) == false) {
        $copado("#boxCanvas").append(backDeploy.buildEnvBox(envName, envId, style, branch, environment, flowStepId));
        $copado('#wrapper_' + envId).attr('data-flowStepId', flowStepId);
        var box = document.getElementById('wrapper_' + envId);
        box.style.left = '20px';
        box.style.top = '20px';
        $copado('#box_' + envId).attr('data-boxId', flowStepId);
        $copado("#box_" + envId + "_content").attr('data-stepContent', flowStepId);

        // DEBUGGING oNLY
        console.debug("--", envId, flowStepId, $copado("#" + envId + "_title").text())

        if ($copado('#box_' + envId + ' #hdn_DestEnvName').val() != '') {
            $copado('#nextDestEnvBody_' + envId).val($copado('#box_' + envId + ' #hdn_DestEnvName').val());
            $copado('#detailModeBody_' + envId).show();
        }
    }
    backDeploy.counter++;
    //UCU - below condition checks for +1 cause there will be always one more environment box than a deployment flow steps
    if((backDeploy.data.stepIds.length + 1) == backDeploy.counter){
        backDeploy.setBoxStates();
    }
};
backDeploy.splitCoordinates = function(s) {
    var data = s.split(',');
    return data;
};

backDeploy.queryCIRecords = function(environments) {
    var i;
    console.log('queryCIRecords...');

    backDeploy.data.env2CIMap = {};

    // get a hashmap of which branch goes to which list of envs.
    var envConnectionMapByBrach = {},
        allEnvIds = {};

    //environments.push({envName: map[v].envName, envId:map[v].envId, flowStepId:map[v].flowStepId, branch:branch, testLevel:map[v].testLevel, autoMergeDeploy:map[v].autoMergeDeploy});
    for (i = 0; i < environments.length; i++) {
        envConnectionMapByBrach[environments[i].branch] = envConnectionMapByBrach[environments[i].branch] || [];
        envConnectionMapByBrach[environments[i].branch].push(environments[i]);
        allEnvIds[environments[i].envId] = environments[i];
    }

    // now request all the CI records associated to each envConnection.toEnvId
    // we will filter the git branches later.
    var records = JsRemoting.deploymentFlows.getCIRecords(backDeploy.config.ns, copadoApp.data.repositoryId);

    var newEnvConnections = [],
        t;
    backDeploy.data.flowStepMapByToEnvId = {};

    for (i = 0; i < records.length; i++) {
        var branch = records[i][backDeploy.config.ns + 'Branch__c'];
        var toEnvId = records[i][backDeploy.config.ns + 'Destination_Org_Credential__r'][backDeploy.config.ns + 'Environment__c'];
        var toEnvName = records[i][backDeploy.config.ns + 'Destination_Org_Credential__r'][backDeploy.config.ns + 'Environment__r'].Name;
        var status = records[i][backDeploy.config.ns + 'Status__c'];
        var envs = envConnectionMapByBrach[branch];
        if (!envs || envs.length === 0) {
            console.log("... branch", branch, "not found in ", envConnectionMapByBrach, environments);
            continue;
        }
        if (allEnvIds[toEnvId]) {
            var warningMessage = "- Cannot show " + htmlEntities(toEnvName) + " of <a target='_blank' href='/" + records[i].Id + "'>" + htmlEntities(records[i].Name) + "</a><br/>";
            console.warn(warningMessage);
            $copado('#warningMessages').append(warningMessage);
            backDeploy.data.hasCIWarningMessages = true;
            continue;
        }

        // Add the environments ONLY if they are not previously listed.

        for (j = 0; j < envs.length; j++) {
            var env = envs[j];
            if (env.branch === branch) {
                t = {
                    flowStepId: 'CIRecord_' + records[i].Id,
                    fromEnvId: env.envId,
                    fromEnvName: env.envName,
                    toEnvId: toEnvId,
                    toEnvName: toEnvName,
                    branch: branch,
                    testLevel: 0,
                    autoMergeDeploy: false,
                    ContinuousIntegrationId: records[i].Id,
                    ContinuousIntegrationStatus: status
                };
                console.log('found NR:', t, env);
                backDeploy.data.flowStepMapByToEnvId[t.toEnvId] = t;
                newEnvConnections.push(t);
            } else {
                console.log('discard NR:', env);
            }
        }
    }
    // load the new environments (not listed in the deployment flow)
    backDeploy.addToEnvironmentArray(newEnvConnections);
    // append the new env connections to the existing array.
    Array.prototype.push.apply(copadoApp.envConnections, newEnvConnections);

    console.log('queryCIRecords found: ', newEnvConnections);
};
backDeploy.queryFlowSteps = function() {
    var NS = backDeploy.config.ns;
    copadoApp.envConnections = [];
    copadoApp.finalDestination = '';
    var fromIds = [];
    var toIds = [];
    backDeploy.data.env2branchMap = [];
    backDeploy.data.stepIds = [];
    var records = JsRemoting.deploymentFlows.queryFlowSteps(backDeploy.config.ns, backDeploy.data.flowId);
    for (var i = 0; i < records.length; i++) {
        var r = records[i];
        if(r[NS + 'Source_Environment__c'] === null){
            alert(backDeploy.labels.noSource+' '+r['Name']);
            return;

        } else if(r[NS + 'Destination_Environment__c'] === null) {
            alert(backDeploy.labels.noDestination+' '+r['Name']);
            return;
        }
        backDeploy.data.env2branchMap[r[NS + 'Source_Environment__c']] = r[NS + 'Branch__c'];

        copadoApp.envConnections.push({
            flowStepId: r.Id,
            fromEnvId: r[NS + 'Source_Environment__c'],
            fromEnvName: r[NS + 'Source_Environment__r'].Name,
            toEnvId: r[NS + 'Destination_Environment__c'],
            toEnvName: r[NS + 'Destination_Environment__r'].Name,
            branch: r[NS + 'Branch__c'],
            testLevel: r[NS + 'Test_Level__c'],
            autoMergeDeploy: r[NS + 'Automatically_Merge_and_Deploy__c'],
            orgType : r[NS + 'Source_Environment__r'][backDeploy.config.ns+'Type__c']
        });

        fromIds.push(r[NS + 'Source_Environment__c']);
        toIds.push(r[NS + 'Destination_Environment__c']);
        backDeploy.data.mapStepIdEnvironments[r.Id] = r[NS + 'Source_Environment__c'] + '-' + r[NS + 'Destination_Environment__c'];
        // we add both forward src->dest and the reverse (backdeploy)
        backDeploy.data.mapBoxIdToStepId[r[NS + 'Source_Environment__c'] + '-' + r[NS + 'Destination_Environment__c']] = r.Id;
        backDeploy.data.mapBoxIdToStepId[r[NS + 'Destination_Environment__c'] + '-' + r[NS + 'Source_Environment__c']] = r.Id;
        backDeploy.data.stepIds.push(r.Id);
    }

    for (var j = 0; j < toIds.length; j++) {
        if (fromIds.indexOf(toIds[j]) < 0) {
            copadoApp.finalDestination = toIds[j];
        }
    }

};
backDeploy.getFlowSteps = function() {
    console.log('Get Flow Steps...');
    backDeploy.queryFlowSteps();
    copadoApp.environments = backDeploy.createEnvironmentArray(copadoApp.envConnections);
    backDeploy.queryCIRecords(copadoApp.environments); // NR: after the flow steps and envs are loaded, we can query the CI records
};

backDeploy.sforceFailure = function(error) {
    console.error('An error has occured with the Salesforce Ajax Toolkit: ', error);
};

backDeploy.hasOtherEnvConnections = function(envId) {
    if (envId == null || envId.length == 0) return false;
    var count = 0;
    for (var i = 0; i < copadoApp.envConnections.length; i++) {
        if (copadoApp.envConnections[i].fromEnvId == envId) count++;
        if (copadoApp.envConnections[i].toEnvId == envId) count++;
    }
    if (count > 2) return true;
    return false;
};

backDeploy.addToEnvironmentArray = function(envConns) {
    var map = new Object();
    for (var i = 0; i < envConns.length; i++) {
        var conn = envConns[i];
        backDeploy.data.env2branchMap[conn.fromEnvId] = conn.branch;
        var tmpFrom = {
            envName: conn.fromEnvName,
            envId: conn.fromEnvId,
            flowStepId: conn.flowStepId,
            branch: conn.branch,
            testLevel: conn.testLevel,
            autoMergeDeploy: conn.autoMergeDeploy,
            orgType: conn.orgType
        };
        var tmpTo = null;
        if (tmpFrom.toEnvId && tmpFrom.toEnvId !== null || tmpFrom.toEnvId !== '') {
            tmpTo = {
                envName: conn.toEnvName,
                envId: conn.toEnvId,
                flowStepId: conn.flowStepId,
                branch: '',
                testLevel: '',
                autoMergeDeploy: false
            };
            // never overwrite an existing env.
            if(!map[conn.toEnvId])
                map[conn.toEnvId] = tmpTo;
        }
        map[conn.fromEnvId] = tmpFrom;
    }
    for (var v in map) {
        var branch = (typeof backDeploy.data.env2branchMap[map[v].envId] != 'undefined') ? backDeploy.data.env2branchMap[map[v].envId] : copadoApp.data.mainBranch;
        copadoApp.environments.push({
            envName: map[v].envName,
            envId: map[v].envId,
            flowStepId: map[v].flowStepId,
            branch: branch,
            testLevel: map[v].testLevel,
            autoMergeDeploy: map[v].autoMergeDeploy,
            _tto: map[v]._tto,
            orgType: map[v].orgType
        });
    }
    return copadoApp.environments;
};

backDeploy.createEnvironmentArray = function(envConnections) {
    copadoApp.environments = [];
    return backDeploy.addToEnvironmentArray(envConnections);
};

backDeploy.getPermissions = function() {
    backDeploy.data.permissions = JsRemoting.backDeploy.getPermissionsForUser(backDeploy.config.ns, backDeploy.config.currentUserId);
};

backDeploy.loadPage = function() {
    console.log('load page');
    setLockScreenMessage(backDeploy.labels.LOADING);
    //lockScreen();
    try {
        backDeploy.getPermissions();
        backDeploy.getFlowStepCoordinates();
        backDeploy.getFlowSteps();

        backDeploy.drawEnvironmentBoxes();

        window.setTimeout(function() {
            backDeploy.processAttachments('load');
            // Only close if there were no git status running processes
            // it was not unlocking at the page load so opened the code block again
            //if($copado('#screenLockerLightningText').html()==backDeploy.labels.LOADING)
                //setLockScreenMessage('');
        }, 500);
    } catch (error) {
        console.error(error);
        setLockScreenMessage(''); // unlock the screen
        alert(error);
    }
    backDeploy.displayLogs(0);
};

backDeploy.showHideCIEnvironments = function(isShow) {
    console.log('backDeploy.showHideCIEnvironments isShow=', isShow);
    backDeploy.showCIEnvironments = isShow;
    if (isShow)
        $copado('.CIStepWrapper').show();
    else
        $copado('.CIStepWrapper').hide();
    document.getElementById(window.warningMessagesPageBlockSectionId).style.display = (backDeploy.data.hasCIWarningMessages && isShow) ? 'block' : 'none';
    backDeploy.reinitiateCanvas();
};

backDeploy.reinitiateCanvas = function() {
    console.log('Reinitiating canvas...');
    $copado('#boxCanvas canvas').remove();
    backDeploy.config.canvas = $copado('#boxCanvas').connectSVG();
    backDeploy.getsetCoordinates();
};

backDeploy.assignCBMTabLabels = function(elem, newText){
    elem.text(newText);
}
// MY & FO : View state issue fix for file differences tab on branch management page.
// By using following function we parse the branch management calculatation result and display differences in JQX grid
// @see backDeploy initFileDifferences
backDeploy.calculateFileDifferences = function(jsonObject,conf){
	var fileDiffSize = 0;
	var autoResolveSize = 0;
	console.log('backDeploy:::calculateFileDifferences',jsonObject,conf);
	backDeploy.data.gridConflictedItems = [];
	try{
        for(var i=0; i < jsonObject.length; i++){
            var item = jsonObject[i];
            console.log('backDeploy.uiData.stepId',backDeploy.uiData.stepId);
            if(item["id"] === backDeploy.uiData.stepId){
                console.info("item ===>",item["id"],item);
                console.log('backDeploy.calculateFileDifference:::backDeploy.uiData.type',backDeploy.uiData.type);

                if( backDeploy.uiData.type === "pull"){
                    var commitsBehindNumber = item["commitsBehind"];
                    var commitsBehindLabel = $copado('#commBehind');

                    backDeploy.assignCBMTabLabels(commitsBehindLabel,commitsBehindNumber);
                    $copado('[Id$=commitBehindNum]').val(commitsBehindNumber);

                    backDeploy.data.gridItems = item["filesMergedBehind"];
                    var fileDiffLabel = $copado('#filediff');
                    if(backDeploy.data.gridItems){
                        fileDiffSize = backDeploy.data.gridItems.length;
                        backDeploy.assignCBMTabLabels(fileDiffLabel,fileDiffSize);
                        if(conf.dataMode && conf.dataMode == 'mergeDiff'){
                            var t = backDeploy.data.gridItems;
                            backDeploy.data.gridItems = [];
                            backDeploy.data.gridItems = backDeploy.filterGridMetadata(t,'d','update');
                            backDeploy.assignCBMTabLabels($copado('#mergeddiffsize'),backDeploy.data.gridItems.length);
                        } else if(!conf.dataMode){
                            var fileDiffElem = backDeploy.filterGridMetadata(backDeploy.data.gridItems,'d','update');
                            var fileMergedDiffLabel = $copado('#mergeddiffsize');
                            backDeploy.assignCBMTabLabels(fileMergedDiffLabel,fileDiffElem.length);
                        }
                    } else {
                        backDeploy.assignCBMTabLabels(fileDiffLabel, 0);
                    }
                    var autoResolvedLabel = $copado('#autoresolved');
                    if(backDeploy.data.gridConflictedItems){
                        var elem = item["filesMergedConflictBehind"];
                        if(elem){
                        for(var j = 0; j < elem.length;j++){
                            backDeploy.data.gridConflictedItems.push({f:elem[j]})
                        }
                        }
                        autoResolveSize = backDeploy.data.gridConflictedItems.length;
                        backDeploy.assignCBMTabLabels(autoResolvedLabel,autoResolveSize);
                    } else {
                        backDeploy.assignCBMTabLabels(autoResolvedLabel, 0);
                    }
                } else {
                    var commitsAheadNumber = item["commitsAhead"];
                    var commitsAheadLabel = $copado('#commAhead');

                    backDeploy.assignCBMTabLabels(commitsAheadLabel,commitsAheadNumber);
                    $copado('[Id$=commitAheadNum]').val(commitsAheadNumber);

                    backDeploy.data.gridItems = item["filesMergedAhead"];
                    var elem = item["filesMergedConflictAhead"];
                    if(backDeploy.data.gridItems){
                        fileDiffSize = backDeploy.data.gridItems.length;
                        var fileDiffLabel = $copado('#filediff');
                        backDeploy.assignCBMTabLabels(fileDiffLabel,fileDiffSize);
                        if(conf.dataMode && conf.dataMode == 'mergeDiff'){
                            var t = backDeploy.data.gridItems;
                            backDeploy.data.gridItems = backDeploy.filterGridMetadata(t,'d','update');
                            if(backDeploy.data.gridItems) {
                            backDeploy.assignCBMTabLabels($copado('#mergeddiffsize'),backDeploy.data.gridItems.length);
                            } else {
                                backDeploy.assignCBMTabLabels($copado('#mergeddiffsize'), 0);
                            }
                        } else if(!conf.dataMode){
                            var t = backDeploy.data.gridItems;
                            var fileDiffElem = backDeploy.filterGridMetadata(t,'d','update');
                            var fileMergedDiffLabel = $copado('#mergeddiffsize');
                            if(fileDiffElem){
                            backDeploy.assignCBMTabLabels(fileMergedDiffLabel,fileDiffElem.length);
                            } else {
                                backDeploy.assignCBMTabLabels(fileMergedDiffLabel, 0);
                            }
                        }
                    }
                    var autoResolvedLabel = $copado('#autoresolved');
                    if(backDeploy.data.gridConflictedItems){
                        for(var k = 0; k < elem.length;k++){
                            backDeploy.data.gridConflictedItems.push({f:elem[k]})
                        }
                        autoResolveSize = backDeploy.data.gridConflictedItems.length;
                        console.log('autoresolvedsize : '+autoResolveSize);
                        backDeploy.assignCBMTabLabels(autoResolvedLabel,autoResolveSize);
                    } else {
                        backDeploy.assignCBMTabLabels(autoResolvedLabel, 0);
                    }
                }
            }
        }
	} catch(e){
	    console.error(e);
    }
	console.debug("fileSizes",fileDiffSize,autoResolveSize);
};

backDeploy.filterGridMetadata = function (jsonArray, jsonField, filter) {
    return $copado.grep(jsonArray, function (n, i) {
        return n[jsonField] == filter;
    });
};


backDeploy.initFileDifferences = function(conf,initF) {
    if(initF) initF();
    var jsonObject = JSON.parse(backDeploy.uiData.flowResult)
    backDeploy.calculateFileDifferences(jsonObject,conf);
    var datalocal;
    if(conf.gridMode !== 'fileConflicts'){
        datalocal = backDeploy.data.gridItems;
    } else {
        datalocal = backDeploy.data.gridConflictedItems;
    }

    if(!datalocal) return;
    var datafields = [];
    if(conf.gridMode !== 'fileConflicts'){
        datafields = [
             {name: 'd', type: 'string'},
             {name: 'f', type: 'string'},
             {name: 'l', type: 'string'}
         ];
    } else {
        datafields = [
            {name: 'f', type: 'string'}
        ];
    }
    var source = {
        localdata: datalocal,
        datafields: datafields
    };
    if(!$copado.jqx) return;
    var dataAdapter = new $copado.jqx.dataAdapter(source);

    var cellsrenderer = function (row, column, value, defaultHtml) {

        var color = false;
        if (value == 'delete' ) {
          color = '#FFC6C6';
        }else if (value == 'update' ) {
          color = '#FFFFE3';
        }else if (value == 'create'){
          color = '#CCFFCC'
        } else {
             var element = $copado(defaultHtml);
             element.append('<div style="overflow: hidden; text-overflow: ellipsis; padding-bottom: 2px; text-align: center; margin-right: 2px; margin-left: 4px; margin-top: 4px;">Auto Resolved</div>');
             element.css({'background-color' : '#565b63', 'text-align': 'center' , 'color' : 'white'});
             return element[0].outerHTML;
        }
        if(color){
          var element = $copado(defaultHtml);
          element.css({ 'background-color': color, 'text-align': 'center'});
          return element[0].outerHTML;
        }
        return defaultHtml;
    };

    var cellsrendererView = function (row, column, value, defaultHtml) {
        if(datalocal[row].d == 'update'){
          var diffFileName = datalocal[row].f;
          var diffType;
          if(backDeploy.uiData.type === 'merge'){
             diffType = 'div-m-m';
          } else {
              diffType = 'div-p-m';
          }
          var element = $copado(defaultHtml );
          element.append(' <a href="javascript:void(0);" onclick="showFileModal(this);" data-stepId="'+backDeploy.uiData.stepId+'" file-name="'+diffFileName+'" data-type="'+diffType+'">Show Differences</a>');
          element.css({ 'cursor': 'pointer'});
          return element[0].outerHTML;
        }
        return defaultHtml;
    };


    var diffColumns = [];
    if(conf.gridMode !== 'fileConflicts'){
          diffColumns = [
          {
              text: copadoLabels.type,
              filtertype: 'checkedlist',
              columntype : 'textbox',
              editable: false,
              datafield: 'd',
              width: '20%',
              cellsrenderer: cellsrenderer
          },
          {
              text: 'File Path',
              datafield: 'f',
              filterable: true,
              filtertype: 'textbox',
              filtercondition: 'contains',
              editable: false,
              width: '60%'
          },
          {
              text: '',
              filterable : false,
              editable: false,
              datafield: 'lastUpdate',
              width: '20%',
              cellsrenderer: cellsrendererView
          }
      ];

    } else {
        diffColumns = [
          {
              text: copadoLabels.type,
              filterable: false,
              columntype : 'textbox',
              editable: false,
              width: '20%',
              cellsrenderer: cellsrenderer
          },
          {
              text: 'File Path',
              datafield: 'f',
              filterable: true,
              filtertype: 'textbox',
              filtercondition: 'contains',
              editable: false,
              width: '80%'
          }
      ];
    }
    var fileDifferencesGrid = $copado("#fileDiffGrid").jqxGrid({
        width: '80%',
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
        columns: diffColumns
    })
};