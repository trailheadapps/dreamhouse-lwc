var deploymentFlow = deploymentFlow || {};
deploymentFlow.data = deploymentFlow.data || {};
deploymentFlow.config = deploymentFlow.config || {};
deploymentFlow.branch = deploymentFlow.branch || {};
deploymentFlow.showCIEnvironments = false;

deploymentFlow.config.ns = copadoApp.ns;
deploymentFlow.config.AUTOCOMPLETE_MIN_LENGTH = 2;
//deploymentFlow.config.searchbox = $copado('.jsEnvAutoComplete');
deploymentFlow.config.canvas = $copado('#boxCanvas').connectSVG();

//deploymentFlow.envBoxes = $copado('.jsEnvBoxWrapper');

deploymentFlow.data.flowId = copadoApp.data.flowId;
deploymentFlow.data.env2branchMap = [];


deploymentFlow.getFlowStepCoordinates = function(){
    var records = JsRemoting.deploymentFlows.getFlowStepCoordinates(deploymentFlow.config.ns, deploymentFlow.data.flowId);
    __coordinates__ = records[0][deploymentFlow.config.ns+'Flow_Step_Coordinates__c'];
    return __coordinates__;
};
deploymentFlow.getsetCoordinates = function(){
    console.log('Setting coordinates...');
    var __coordinates__ = deploymentFlow.getFlowStepCoordinates();
    if(__coordinates__ && __coordinates__.length != 0){
        var tmp = deploymentFlow.splitCoordinates(__coordinates__);
        for(var i=0; i<tmp.length; i++){
            var tmp2 = tmp[i].split('-');
            var box = document.getElementById(tmp2[0]);
            if(box != null){
                box.style.left = tmp2[1];
                box.style.top = tmp2[2];
            }
        }
    }
    deploymentFlow.drawEnvironmentConnections();
};
deploymentFlow.reinitiateCanvas = function(){
    console.log('Reinitiating canvas...');
    $copado('#boxCanvas canvas').remove();
    deploymentFlow.config.canvas = $copado('#boxCanvas').connectSVG();
    deploymentFlow.getsetCoordinates();
    // NR: this is redundant, since deploymentFlow.getsetCoordinates() already calls deploymentFlow.drawEnvironmentConnections();
};
deploymentFlow.initialiseDraggable = function(){
    console.log('Initialising draggable...');
    if(envConnections.length>0){
        $copado('.jsEnvBoxWrapper').draggable({
            drag: function(event, ui){
                deploymentFlow.config.canvas.redrawLines();
            },
            stop: function( event, ui ) {
                deploymentFlow.getsetLocations(ui.helper.attr('id'), ui.position.left,ui.position.top);
            }
        });
    }
    else{
        console.log('envConnections array is empty!');
        $copado('.jsEnvBoxWrapper').draggable({
            stop: function( event, ui ) {
                deploymentFlow.getsetLocations(ui.helper.attr('id'), ui.position.left,ui.position.top);
            }
        });
    }
};
deploymentFlow.drawSVGlines = function(leftNode, rightNode, destinationNode, envConnection){
    console.log('Drawing SVG lines...');
    color = 'light-blue';
    if(envConnection.ContinuousIntegrationId) {
        if(!deploymentFlow.showCIEnvironments)
            return;
        color = 'green';
    }
    deploymentFlow.config.canvas.drawLine({
        left_node: leftNode,
        right_node: rightNode,
        destinationNode: destinationNode,
        horizantal_gap:25,
        error:true,
        style:'solid',
        color:color,
        width:2
    });
};
deploymentFlow.drawEnvironmentConnections = function(){
    console.log('Drawing environment connections...');
    for (i=0; i<envConnections.length; i++) {
        deploymentFlow.drawEnvironmentConnection(envConnections[i].fromEnvId, envConnections[i].toEnvId, envConnections[i]);
    }
};
deploymentFlow.drawEnvironmentConnection = function(fromEnvId, toEnvId, envConnection){
    console.log('Draw connection: '+fromEnvId+' '+toEnvId);
    deploymentFlow.setDestinatonEnvName(fromEnvId, toEnvId);
    var fromEnvBox = '#wrapper_'+fromEnvId;
    var toEnvBox = '#wrapper_'+toEnvId;
    deploymentFlow.drawSVGlines(fromEnvBox, toEnvBox, toEnvBox, envConnection);
};
deploymentFlow.addDetailHover = function(env){
    var content = '';
    content = '<b>Name:</b> '+env.envName+'<br />'+
        '<b>Branch:</b> '+((env.branch)?env.branch:'')+'<br />'+
        '<b>Test Level:</b> '+((env.testLevel)?env.testLevel:'')+'<br />'+
        '<b>Auto Merge & Deploy:</b> '+((env.autoMergeDeploy && env.autoMergeDeploy=='true')?'Yes':'No')+'<br />'+
        '<b>Flow Step Id:</b> '+env.flowStepId;
    var t = $copado('#viewInfo_'+env.envId);
    if(t.length)
        t.jqxTooltip({ content:content, position:'mouse', name:env.envName+'Details'});
};
deploymentFlow.drawEnvironmentBoxes = function(){
    console.log('Drawing Environment Boxes...');
    for(var i=0; i<environments.length; i++) {
        deploymentFlow.addEnvBox(null, environments[i].envName, environments[i].envId, environments[i].flowStepId, environments[i].branch);
        deploymentFlow.addDetailHover(environments[i]);
    }
    deploymentFlow.getsetCoordinates();
    deploymentFlow.initialiseDraggable();
};
deploymentFlow.initialiseAutoComplete = function(envId){
    console.log('Initialising Auto Complete...');
    if(envId==null){
        $copado("#envAutoComplete").autocomplete({
            source : function(request, callback){
                var searchParam  = request.term;
                callback(deploymentFlow.doSearch(searchParam));
            },
            select: function(event, ui){
                deploymentFlow.addEnvBox(null, ui.item.label, ui.item.value, null);
                deploymentFlow.initialiseDraggable();
                $copado(this).val('');
                return false;
            },
            minLength: deploymentFlow.config.AUTOCOMPLETE_MIN_LENGTH
        });
    }
    else{
        $copado(".jsEnvAutoComplete").autocomplete({
            source : function(request, callback){
                var searchParam  = request.term;
                callback(deploymentFlow.doSearch(searchParam));
            },
            select: function(event, ui){
                var envBox = document.getElementById('box_'+envId);
                if(envBox != null){
                    if(envId!=null){
                        if(ui.item.value==envId){
                            alert('You cannot create a flow where the source environment equals destination environment.');
                            return;
                        }
                        var actionToTake = ($copado('#box_'+envId+' #hdn_DestEnvId').val()==ui.item.value)?'none':'update';
                        actionToTake = ($copado('#box_'+envId+' #hdn_DestEnvId').val() == '' && actionToTake=='update')?'insert':'update';
                        if(actionToTake=='insert'){
                            var flowStepId = deploymentFlow.insertFlowStep(envId, ui.item.value);
                            deploymentFlow.addEnvBox(envId, ui.item.label, ui.item.value, flowStepId);
                            deploymentFlow.setEnvironmentValues(envId, ui.item.label, ui.item.value, flowStepId);
                            deploymentFlow.reinitiateCanvas();
                            deploymentFlow.initialiseDraggable();
                        }
                        if(actionToTake=='update'){
                            var flowStepId = $copado('#wrapper_'+envId).attr('data-flowStepId');
                            var destEnvId = $copado('#box_'+envId+' #hdn_DestEnvId').val()
                            if(deploymentFlow.hasOtherEnvConnections(destEnvId)){
                                deploymentFlow.removeEnvironment(destEnvId);
                            }
                            deploymentFlow.updateFlowStep(flowStepId, envId, ui.item.value);
                            deploymentFlow.setEnvironmentValues(envId, ui.item.label, ui.item.value, flowStepId);
                            deploymentFlow.reinitiateCanvas();
                            deploymentFlow.initialiseDraggable();
                        }
                        if(actionToTake!='none'){
                            deploymentFlow.drawEnvironmentConnection(envId, ui.item.value);
                        }
                    }
                }
            },
            minLength: deploymentFlow.config.AUTOCOMPLETE_MIN_LENGTH
        });
    }
    $copado(".jsEnvAutoComplete").attr('placeholder','Type to search');
    $copado("#envAutoComplete").attr('placeholder','Type to search');
};
deploymentFlow.editEnvironment = function(envId){
    console.log('Edit Environment');
    $copado('#detailMode_'+envId).hide();
    $copado('#editMode_'+envId+' input').val('');
    $copado('#editMode_'+envId).show();
    $copado('#editMode_'+envId+' input').focus();
    deploymentFlow.initialiseAutoComplete(envId);
};
deploymentFlow.setDestinatonEnvName = function(fromEnvId, toEnvId){
    console.log('Setting Destination Environment Name...');
    var toEnvName = $copado('#'+toEnvId+'_title').text();
    $copado('#nextDestEnvBody_'+fromEnvId).text(toEnvName);
    if(toEnvName.length>0)$copado('#detailModeBody_'+fromEnvId).show();
    $copado('#box_'+fromEnvId+' #hdn_DestEnvName').val(toEnvName);
    $copado('#box_'+fromEnvId+' #hdn_DestEnvId').val(toEnvId);
};
deploymentFlow.clearDestinationEnvironmentValues = function(envId){
    console.log('Clearing Destination Environment values');
    $copado('#detailModeBody_'+envId).hide();
    $copado('#nextDestEnvBody_'+envId).text('');
    $copado('#wrapper_'+envId).attr('data-flowStepId', '');
    $copado('#box_'+envId+' #hdn_DestEnvName').val('');
    $copado('#box_'+envId+' #hdn_DestEnvId').val('');
    $copado('#branchBody_'+envId).text('');
    $copado('#txtBranch_'+envId).val('');
};
deploymentFlow.setEnvironmentValues = function(envId, destEnvName, destEnvId, flowStepId){
    console.log('Setting Environment values...');
    deploymentFlow.setDestinatonEnvName(envId, destEnvId);
    $copado('#wrapper_'+envId).attr('data-flowStepId', flowStepId);
    $copado("#editMode_"+envId).hide();
    $copado('#detailMode_'+envId).show();
};
deploymentFlow.cancelEnvironmentEdit = function(envId){
    console.log('Cancel Environment Edit');
    $copado('#editMode_'+envId).hide();
    $copado('#detailMode'+envId).val($copado('#box_'+envId+' #hdn_DestEnvName').val());
    $copado('#detailMode_'+envId).show();
    $copado('#editMode_'+envId+' input').val('');
    deploymentFlow.drawEnvironmentConnections();
};
deploymentFlow.removeEnvironment = function(envId){
    console.log('Removing environment '+envId);
    var flowStepId = $copado('#wrapper_'+envId).attr('data-flowStepId');
    var deletionIds = [];
    if(flowStepId){
        deletionIds.push(flowStepId);
        var sourceEnvironmentIds = [];
        for(var i=0; i<envConnections.length; i++){
            if(envId == envConnections[i].toEnvId){
                sourceEnvironmentIds.push(envConnections[i].fromEnvId);
            }
        }
        for(var i=0; i<envConnections.length; i++){
            if(envConnections[i].flowStepId == flowStepId){
                envConnections.splice(i, 1);
            }
        }
        deploymentFlow.deleteFlowStep(null, deletionIds);
        for(var i=0; i<sourceEnvironmentIds.length; i++){
            deploymentFlow.clearDestinationEnvironmentValues(sourceEnvironmentIds[i]);
        }
    }

    deploymentFlow.reinitiateCanvas();
    deploymentFlow.initialiseDraggable();

    $copado('#wrapper_'+envId).remove();
};

deploymentFlow.buildEnvBox = function(envName, envId, style, branch){
    console.log('Building Environment Box: '+envId);
    style = (style=='' || style==null || typeof style == 'undefined')?'top:20px;left:500px;':style;
    branch = (typeof branch=='undefined'||branch==null)?'':branch;

    // NR: this determines if this EnvBox is the dest org of a CI job.
    // if so, it needs to be rendered differently.
    var step = deploymentFlow.data.flowStepMapByToEnvId? deploymentFlow.data.flowStepMapByToEnvId[envId] : null;
    var s;
    if(step && step.ContinuousIntegrationId) {
        s = "<div style='"+style+"'class='jsEnvBoxWrapper CIStepWrapper' id='wrapper_"+envId+"' data-flowStepId=''>"+
                "<div id='box_"+envId+"' class='envBox CIStep'>"+
                    "<h3 class='clearfix'>"+
                        "<a onclick='javascript:return false;' id='"+envId+"_title' class='title' target='_blank'>"+envName+"</a>"+
                    "</h3>"+
                    "<div class='envContent'>"+
                        "<ol class='rowItems'>"+
                            "<li>"+
                                "<div id='detailMode_"+envId+"' style='display:block;'>"+
                                    "<span id='branchHeader_"+envId+"' style='font-weight:bolder'>CI Status: </span><span>"+step.ContinuousIntegrationStatus+"</span><br />"+
                                    "<hr/>"+
                                    "<span id='gotoCI_"+envId+"' data-ciId=\""+step.ContinuousIntegrationId+"\" onclick=\"window.open('/"+step.ContinuousIntegrationId+"')\">View CI</span>"+
                                "</div>"+
                            "</li>"+
                        "</ol>"+
                    "</div>"+
                "</div>"+
            "</div>";

    }else{
        s = "<div style='"+style+"'class='jsEnvBoxWrapper' id='wrapper_"+envId+"' data-flowStepId=''>"+
                "<div id='box_"+envId+"' class='envBox'>"+
                    "<h3 class='clearfix'>"+
                        "<a onclick='javascript:return false;' id='"+envId+"_title' class='title' target='_blank'>"+envName+"</a>"+
                    "</h3>"+
                    "<div class='envContent'>"+
                        
                    "</div>"+
                    "<input type='hidden' id='hdn_DestEnvId' value='' />"+
                    "<input type='hidden' id='hdn_DestEnvName' value='' />"+
                    "<input type='hidden' id='hdn_Branch' value='"+branch+"' />"+
                "</div>"+
            "</div>";

    }
    return s;
};
deploymentFlow.environmentboxOnCanvas = function(envId){
    if($copado('#box_'+envId).length)return true;
    return false;
};
deploymentFlow.addEnvBox = function(fromEnvId, envName, envId, flowStepId, branch){
    console.log('Adding Environment Box...');
    var style = '';
    if(typeof fromEnvId != 'undefined' && fromEnvId!=null){
        $copado('#wrapper_'+envId).attr('data-flowStepId', flowStepId);
        var top = $copado('#wrapper_'+fromEnvId).css('top');
        var left = $copado('#wrapper_'+fromEnvId).css('left');
        var width = $copado('#wrapper_'+fromEnvId).width();
        style = 'top:'+top+'; left:'+ (parseInt(left)+width+50)+'px;';
    }
    if(deploymentFlow.environmentboxOnCanvas(envId)==false){
        $copado("#boxCanvas").append(deploymentFlow.buildEnvBox(envName, envId, style, branch));
        $copado('#wrapper_'+envId).attr('data-flowStepId', flowStepId);
        if($copado('#box_'+envId+' #hdn_DestEnvName').val() != ''){
            $copado('#nextDestEnvBody_'+envId).val($copado('#box_'+envId+' #hdn_DestEnvName').val());
            $copado('#detailModeBody_'+envId).show();
            $copado('#lnkRemoveDestEnv_'+envId).show();
        }
    }
};
deploymentFlow.doSearch = function(query){
    console.log('Searching...');
    var records = JsRemoting.deploymentFlows.doSearch(deploymentFlow.config.ns, query);
    var response = [ ];
    console.log('Results found: ', records);
    for(var i=0; i<records.length; i++){
        response.push({label: records[i].Name, value: records[i].Id});
    }
    return response;
};
deploymentFlow.splitCoordinates = function(s){
    console.info('Splitting coordinates: ', s);
    var data = s.split(',');
    return data;
};
deploymentFlow.doUpdate = function(coordinates){
    console.log('Updating Flow...');
    if(coordinates.substring(0, 1)==','){
        coordinates = coordinates.substring(1);
    }
    var records = [];
    var r = new sforce.SObject(deploymentFlow.config.ns+"Deployment_Flow__c");
    r.Id = deploymentFlow.data.flowId;
    r[deploymentFlow.config.ns+'Flow_Step_Coordinates__c'] = coordinates;
    records[0] = r;
    //var result = sforce.connection.update(records);
    var result = JsRemoting.common.update(records);
    console.log(result);
    __coordinates__ = coordinates;
};
/**
 * Retrieve the CI records associated with all the environments+branches of each Deployment Flow Step
 * implements US-0000243 (NR: In progress)
 * This *MUST* be called after deploymentFlow.queryFlowSteps, so we already have the list of environments.
 */
deploymentFlow.queryCIRecords = function(environments){
    var i;
    console.log('queryCIRecords...');

    deploymentFlow.data.env2CIMap = {};

    // get a hashmap of which branch goes to which list of envs.
    var envConnectionMapByBrach = {}, allEnvIds={};

    //environments.push({envName: map[v].envName, envId:map[v].envId, flowStepId:map[v].flowStepId, branch:branch, testLevel:map[v].testLevel, autoMergeDeploy:map[v].autoMergeDeploy});
    for(i=0; i<environments.length; i++){
        envConnectionMapByBrach[environments[i].branch] = envConnectionMapByBrach[environments[i].branch] || [];
        envConnectionMapByBrach[environments[i].branch].push(environments[i]);
        allEnvIds[environments[i].envId]=environments[i];
    }

    // now request all the CI records associated to each envConnection.toEnvId
    // we will filter the git branches later.
    var records = JsRemoting.deploymentFlows.getCIRecords(deploymentFlow.config.ns, copadoApp.data.repositoryId);

    var newEnvConnections = [], t;
    deploymentFlow.data.flowStepMapByToEnvId  = {};

    for(i=0; i<records.length; i++){
        var branch = records[i][deploymentFlow.config.ns+'Branch__c'];
        var toEnvId = records[i][deploymentFlow.config.ns+'Destination_Org_Credential__r'][deploymentFlow.config.ns+'Environment__c'];
        var toEnvName = records[i][deploymentFlow.config.ns+'Destination_Org_Credential__r'][deploymentFlow.config.ns+'Environment__r'].Name;
        var status = records[i][deploymentFlow.config.ns+'Status__c'];
        var envs = envConnectionMapByBrach[branch];
        if(!envs || envs.length === 0) {
            console.log("... branch", branch, "not found in ", envConnectionMapByBrach, environments);
            continue;
        }
        if(allEnvIds[toEnvId]) {
            var warningMessage = "- Cannot show "+toEnvName+" of <a target='_blank' href='/"+records[i].Id+"'>"+records[i].Name+"</a><br/>";
            console.warn(warningMessage);
            $copado('#warningMessages').append(warningMessage);
            deploymentFlow.data.hasCIWarningMessages = true;
            continue;
        }

        // Add the environments ONLY if they are not previously listed.

        for(j=0; j<envs.length; j++){
            var env = envs[j];
            if( env.branch === branch ) {
                t = {
                    flowStepId: 'CIRecord_'+records[i].Id, 
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
                deploymentFlow.data.flowStepMapByToEnvId[t.toEnvId] = t;
                newEnvConnections.push(t);
            }else{
                console.log('discard NR:', env);
            }
        }
    }
    // load the new environments (not listed in the deployment flow)
    deploymentFlow.addToEnvironmentArray(newEnvConnections);
    // append the new env connections to the existing array.
    Array.prototype.push.apply(envConnections, newEnvConnections);
    
    console.log('queryCIRecords found: ',newEnvConnections);
};
deploymentFlow.queryFlowSteps = function(){
    console.log('Query Flow Steps...');
    envConnections = [];
    deploymentFlow.data.env2branchMap = [];
    var records = JsRemoting.deploymentFlows.queryFlowSteps(deploymentFlow.config.ns, deploymentFlow.data.flowId);
    for(var i=0; i<records.length; i++){
        deploymentFlow.data.env2branchMap[records[i][deploymentFlow.config.ns+'Source_Environment__c']] = records[i][deploymentFlow.config.ns+'Branch__c'];
        envConnections.push({flowStepId:records[i].Id, fromEnvId:records[i][deploymentFlow.config.ns+'Source_Environment__c'], fromEnvName:records[i][deploymentFlow.config.ns+'Source_Environment__r'].Name, toEnvId:records[i][deploymentFlow.config.ns+'Destination_Environment__c'], toEnvName:records[i][deploymentFlow.config.ns+'Destination_Environment__r'].Name, repositoryId: records[i][deploymentFlow.config.ns+'Git_Repository__c'], branch:records[i][deploymentFlow.config.ns+'Branch__c'], testLevel:records[i][deploymentFlow.config.ns+'Test_Level__c'], autoMergeDeploy:records[i][deploymentFlow.config.ns+'Automatically_Merge_and_Deploy__c']});
    }
    console.log('Flows Steps found: ',records);
};
deploymentFlow.getFlowSteps = function(){
    console.log('Get Flow Steps...');
    deploymentFlow.queryFlowSteps();
    environments = deploymentFlow.createEnvironmentArray(envConnections);
    deploymentFlow.queryCIRecords(environments); // NR: after the flow steps and envs are loaded, we can query the CI records
};
deploymentFlow.insertFlowStep = function(fromEnvId, toEnvId){
    console.log('Inserting Flow Step...');
    var r = new sforce.SObject(deploymentFlow.config.ns+"Deployment_Flow_Step__c");
    r[deploymentFlow.config.ns+'Deployment_Flow__c'] = deploymentFlow.data.flowId;
    r[deploymentFlow.config.ns+'Source_Environment__c'] = fromEnvId;
    r[deploymentFlow.config.ns+'Destination_Environment__c'] = toEnvId;
    //var result = sforce.connection.create([r]);
    var result = JsRemoting.common.create([r]);
    if(result[0].getBoolean('success')){
        console.log('Insert Success',result);
        deploymentFlow.queryFlowSteps();
        return result[0].id;
    }
    else{
        deploymentFlow.sforceFailure(result[0]);
    }
};
deploymentFlow.updateFlowStep = function(flowStepId, fromEnvId, toEnvId){
    console.log('Updating flow Step...');
    var records = [];
    var r = new sforce.SObject(deploymentFlow.config.ns+"Deployment_Flow_Step__c");
    r.Id = flowStepId;
    r[deploymentFlow.config.ns+'Source_Environment__c'] = fromEnvId;
    r[deploymentFlow.config.ns+'Destination_Environment__c'] = toEnvId;
    records[0] = r;

    var result = JsRemoting.common.update([r]);
    if(result[0].getBoolean('success')){
        console.log('Update Success' +result);
        deploymentFlow.queryFlowSteps();
    }
    else{
        deploymentFlow.sforceFailure(result[0]);
    }
};
deploymentFlow.deleteFlowStep = function(id, ids){
    console.log('Deleting Flow Step(s)...', id, ids);
    var records = [];
    var count = 0;
    if(typeof ids !='undefined' && ids!=null){
        for(var i=0; i<ids.length; i++){
            records[i] = ids[i];
        }
        count = ids.length;
    }
    if(typeof id !='undefined' && id!=null){
        records[count+1] = id;
    }
    if(records.length>0){
        var result = JsRemoting.common.deleteIds([records]);
        if(result[0].getBoolean('success')){
            console.log('Delete Success:',result);
            setTimeout(function(){deploymentFlow.queryFlowSteps();},200);
        }
        else{
            deploymentFlow.sforceFailure(result[0]);
        }
    }
};
deploymentFlow.sforceFailure = function(error){
    console.error('An error has occured with the Salesforce Ajax Toolkit: ',error);
};
deploymentFlow.getsetLocations = function(id, top, left){
    var envBoxes = $copado('.jsEnvBoxWrapper');
    var new_data = [''];
    for(var i = 0; i<envBoxes.length; i++) {
        new_data[i] = envBoxes[i].getAttribute('id')+'-'+envBoxes[i].style.left+'-'+envBoxes[i].style.top;
        if(envBoxes[i].getAttribute('Id') == id){
            new_data[i] = id+'-'+top+'px-'+left+'px';
        }
    }
    deploymentFlow.doUpdate(new_data.toString());
};
deploymentFlow.hasOtherEnvConnections = function(envId){
    if(envId == null || envId.length==0)return false;
    var count = 0;
    for (var i=0; i<envConnections.length; i++){
        if(envConnections[i].fromEnvId == envId)count++;
        if(envConnections[i].toEnvId == envId)count++;
    }
    if(count > 2)return true;
    return false;
};
deploymentFlow.addToEnvironmentArray = function(envConnections){
    var map = new Object();
    for(var i=0; i<envConnections.length; i++){
        deploymentFlow.data.env2branchMap[envConnections[i].fromEnvId] = envConnections[i].branch;
        var tmpFrom = [{envName:envConnections[i].fromEnvName, envId:envConnections[i].fromEnvId, flowStepId:envConnections[i].flowStepId, branch:envConnections[i].branch, testLevel:envConnections[i].testLevel, autoMergeDeploy:envConnections[i].autoMergeDeploy}];
        var tmpTo = [];
        if(tmpFrom[0].toEnvId!=null || tmpFrom[0].toEnvId!=''){
            tmpTo = [{envName:envConnections[i].toEnvName, envId:envConnections[i].toEnvId, flowStepId:envConnections[i].flowStepId, branch:'', testLevel:'', autoMergeDeploy:false}];
            map[envConnections[i].toEnvId] = tmpTo[0];
        }
        map[envConnections[i].fromEnvId] = tmpFrom[0];
    }
    for(var v in map){
        console.info(map[v].envId, deploymentFlow.data.env2branchMap, deploymentFlow.data.env2branchMap[map[v].envId]);
        var branch = (typeof deploymentFlow.data.env2branchMap[map[v].envId]!='undefined')?deploymentFlow.data.env2branchMap[map[v].envId]:copadoApp.data.mainBranch;
        environments.push({envName: map[v].envName, envId:map[v].envId, flowStepId:map[v].flowStepId, branch:branch, testLevel:map[v].testLevel, autoMergeDeploy:map[v].autoMergeDeploy});
    }
    return environments;
};
deploymentFlow.createEnvironmentArray = function(envConnections){
    environments = [];
    return deploymentFlow.addToEnvironmentArray(envConnections);
};
deploymentFlow.loadPage = function(){
    console.log('Loading Page function...');
    deploymentFlow.getFlowStepCoordinates();
    deploymentFlow.getFlowSteps();
    deploymentFlow.drawEnvironmentBoxes();
};

deploymentFlow.branch.setBranch = function(envId){
    //update salesforce here...
    var flowStepId = $copado('#wrapper_'+envId).attr('data-flowStepId');
    var records = [];
    var r = new sforce.SObject(deploymentFlow.config.ns+"Deployment_Flow_Step__c");
    r.Id = flowStepId;
    var newBranch = $copado('#txtBranch_'+envId).val();
    r[deploymentFlow.config.ns+'Branch__c'] = newBranch;
    records[0] = r;
    console.log(r, $copado('#branchBody_'+envId).val());
    var result = JsRemoting.common.update([r]);
    if(result[0].getBoolean('success')){
        console.log('Branch was updated successfully.', result[0]);
        $copado('#box_'+envId+' #hdn_Branch').val(newBranch);
        $copado('#branchBody_'+envId).text(newBranch);
        $copado('#txtBranch_'+envId).val('');
        deploymentFlow.branch.hideEditMode(envId);
    }
    else{
        alert(result[0]);
    }
};
deploymentFlow.branch.cancelEdit = function(envId){
    deploymentFlow.branch.hideEditMode(envId);
    console.info($copado('#box_'+envId+' #hdn_Branch').val(), $copado('#branchBody_'+envId).val(), $copado('#txtBranch_'+envId).val());
    $copado('#branchBody_'+envId).text($copado('#box_'+envId+' #hdn_Branch').val());
    $copado('#txtBranch_'+envId).val('');
};
deploymentFlow.branch.showEditMode = function(envId){
    if($copado('#box_'+envId+' #hdn_DestEnvId').val()==''){
        alert('You cannot set the branch for an Environment that does not have a Destination Environment set.');
        return false;
    }
    console.log('Edit Branch');
    $copado('#detailMode_'+envId).hide();
    $copado('#editModeBranch_'+envId).show();
    $copado('#txtBranch_'+envId).val($copado('#box_'+envId+' #hdn_Branch').val());
};
deploymentFlow.branch.hideEditMode = function(envId){
    console.log('Hide Branch edit mode');
    $copado('#detailMode_'+envId).show();
    $copado('#editModeBranch_'+envId).hide();
};
deploymentFlow.showHideCIEnvironments = function(isShow){
    console.log('deploymentFlow.branch.showHideCIEnvironments isShow=', isShow);
    deploymentFlow.showCIEnvironments = isShow;
    if(isShow)
        $copado('.CIStepWrapper').show();
    else
       $copado('.CIStepWrapper').hide();
    document.getElementById(window.warningMessagesPageBlockSectionId).style.display = (deploymentFlow.data.hasCIWarningMessages && isShow)?'block':'none';
    deploymentFlow.reinitiateCanvas();
};
