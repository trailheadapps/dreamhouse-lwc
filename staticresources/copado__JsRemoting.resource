//Namespaces
var JsRemoting = JsRemoting || {};
JsRemoting.common = JsRemoting.common || {};
JsRemoting.attachments = JsRemoting.attachments || {};
JsRemoting.apiKey = JsRemoting.apiKey || {};
JsRemoting.metaData = JsRemoting.metaData || {};
JsRemoting.vlocity = JsRemoting.vlocity || {};
JsRemoting.backDeploy = JsRemoting.backDeploy || {};
JsRemoting.deploymentJobs = JsRemoting.deploymentJobs || {};
JsRemoting.deploymentFlows = JsRemoting.deploymentFlows || {};

//Attachments
JsRemoting.attachments.getAttachmentByFileName_NoBody = function(parentId, name){
   var q = 'Select Id, BodyLength, LastModifiedDate, Name, ParentId From Attachment where Name=\''+name+'\' and parentId = \''+parentId+'\' order by LastModifiedDate DESC limit 1';
   var result =  sforce.connection.query(q);
   var records = result.getArray('records');
   return records;
};
JsRemoting.attachments.getAttachmentByFileName = function(parentId, name){
   var q = 'Select Id, Body, BodyLength, LastModifiedDate, Name, ParentId From Attachment where Name=\''+name+'\' and parentId = \''+parentId+'\' order by LastModifiedDate DESC limit 1';
   var result =  sforce.connection.query(q);
   var records = result.getArray('records');
   return records;
};
JsRemoting.attachments.getDecodedAttachment = function(parentId, name){
    var a = JsRemoting.attachments.getAttachmentByFileName(parentId, name);
    if(!a.length)return null;
    a[0].Body = Base64.decode(a[0].Body);
    return a[0];
};
JsRemoting.attachments.getDecodedAttachmentById = function(id){
    var q = 'Select Id, Body, BodyLength, LastModifiedDate, Name, ParentId From Attachment where id=\''+id+'\' limit 1';
    var result =  sforce.connection.query(q);
    var records = result.getArray('records');
    if(!records.length)return null;
    records[0].Body = Base64.decode(records[0].Body);
    return records[0];
};
JsRemoting.attachments.getLatestDeploymentJobResult = function(deploymentId, jobId){
    var q = 'SELECT Id, Body, BodyLength, ContentType, Name, ParentId FROM Attachment where Name=\''+jobId+'.json\' and ParentId=\''+deploymentId+'\' order by createdDate DESC limit 1';
    var result =  sforce.connection.query(q);
    var records = result.getArray('records');
    if(!records.length)return null;
    records[0].Body = Base64.decode(records[0].Body);
    return records[0];
};

//DeploymentJobs
JsRemoting.deploymentJobs.getJobForCalloutStep = function(ns, stepId, destOrgId){
    var q = 'Select Id, __NAMESPACE__Step__c, __NAMESPACE__Destination_Org__c from __NAMESPACE__Deployment_Job__c where __NAMESPACE__Step__c=\''+stepId+'\' and __NAMESPACE__Destination_Org__c=\''+destOrgId+'\' limit 1';
    q = q.replace(new RegExp('__NAMESPACE__','g'), ns);
    var result = sforce.connection.query(q);
    var records = result.getArray("records");
    return (records.length==1)?records[0].Id:''; 
};
JsRemoting.deploymentJobs.getJobById = function(ns, jobId){
    var q = 'Select Id, Name, __NAMESPACE__Step__r.__NAMESPACE__dataJson__c, __NAMESPACE__Early_Completion_Status__c, __NAMESPACE__Step__r.__NAMESPACE__Type__c ,__NAMESPACE__Step__r.Name,__NAMESPACE__Destination_Org__r.__NAMESPACE__To_Org__r.Name, __NAMESPACE__Deployed__c, __NAMESPACE__Destination_Org__c, __NAMESPACE__External_Id__c, __NAMESPACE__Status__c, __NAMESPACE__Status_Flag__c, __NAMESPACE__Step__c, __NAMESPACE__To_Org_Name__c from __NAMESPACE__Deployment_Job__c where Id=\''+jobId+'\' limit 1';
    q = q.replace(new RegExp('__NAMESPACE__','g'), ns);
    var result = sforce.connection.query(q);
    var records = result.getArray("records");
    return (records.length==1)?records[0]:null; 
};

//Branch Management Permissions
JsRemoting.backDeploy.getPermissionsForUser = function(ns, userId){
    var q = 'Select Id, Name, __NAMESPACE__Environment__c, __NAMESPACE__User__c, __NAMESPACE__Allow_Deployments__c from __NAMESPACE__Branch_Management_Permission__c where __NAMESPACE__Allow_Deployments__c=true and __NAMESPACE__User__c=\''+userId+'\'';
    q = q.replace(new RegExp('__NAMESPACE__','g'), ns);
    var result = sforce.connection.query(q);
    var records = result.getArray("records");
    return records; 
};

//API Key
JsRemoting.apiKey.createKey = function(ns, successCB, exceptionCB, errorCB){
    var core = ns ? window[ns.split('__')[0]] : window;
    (core).JsRemotingController.createAPIKey(function(result, event){
        if (event.status) {
            console.info('STATUS: --> '+event.status, result);
            successCB(result);
        } 
        else if (event.type === 'exception') {
            exceptionCB(event);
        } 
        else {
            errorCB(event);
        }
    });
};

//List of Metadata types
JsRemoting.metaData.getList = function(envId, ns, successCB, exceptionCB, errorCB){
    var core = ns ? window[ns.split('__')[0]] : window;
    console.debug("JsRemoting.metaData.getList starting", envId,core);
    var attach = dw.u.getAttach(envId,'MetadataTypes');
    console.log('Metadata type cache found : ',attach.length == 1 );
    console.log('attach===> ',attach);
    if(attach.length){
        console.log('jsr in if....');
        var res = JSON.parse(Base64.decode(attach[0].Body));
        if(res && res.length) {
            successCB(res);
            return;
        }else{
            console.info('Could not load metadata types from attachment?', res);
        }
    }
    console.log('envId=====> ',envId);
    (core).JsRemotingController.getMetadataTypes(envId,function(result, event){
        console.log("(core).JsRemotingController.getMetadataTypes event=", event);
        if (event.status) {
            dw.u.upsertAttach(envId,'MetadataTypes',JSON.stringify(result), false);
            console.info('Upserting metadata type cache...', result);
            successCB(result);
        } 
        else if (event.type === 'exception') {
            console.error(event);
            exceptionCB(event);
        } 
        else {
            console.error(event);
            errorCB(event);
        }
    },{escape : false});
};

//Deployment Flows
JsRemoting.deploymentFlows.getFlowStepCoordinates = function(ns, flowId){
    var q = 'SELECT Id, __NAMESPACE__Flow_Step_Coordinates__c, __NAMESPACE__Branch_Management_Coordinates__c FROM __NAMESPACE__Deployment_Flow__c WHERE Id =\''+flowId+'\'';
    q = q.replace(new RegExp('__NAMESPACE__','g'), ns);
    var result = sforce.connection.query(q);
    var records = result.getArray('records');
//    console.debug('JsRemoting.deploymentFlows.getFlowStepCoordinates()', JSON.stringify(records, null, '  '));
    return records;
};
JsRemoting.deploymentFlows.queryFlowSteps = function(ns, flowId){
    var q = 'SELECT Id, Name, __NAMESPACE__Branch__c, __NAMESPACE__Destination_Branch__c,__NAMESPACE__Test_Level__c, __NAMESPACE__Automatically_Merge_and_Deploy__c, __NAMESPACE__Deployment_Flow__c, __NAMESPACE__Destination_Environment__c, __NAMESPACE__Destination_Environment__r.Name, __NAMESPACE__Source_Environment__c, __NAMESPACE__Source_Environment__r.Name,  __NAMESPACE__Source_Environment__r.__NAMESPACE__Type__c FROM __NAMESPACE__Deployment_Flow_Step__c WHERE __NAMESPACE__Deployment_Flow__c = \''+flowId+'\' order by __NAMESPACE__Source_Environment__c ASC';
    q = q.replace(new RegExp('__NAMESPACE__','g'), ns);
    var result = sforce.connection.query(q);
    var records = result.getArray('records');
//    console.debug('JsRemoting.deploymentFlows.queryFlowSteps()', JSON.stringify(records, null, '  '));
    return records;
};
JsRemoting.deploymentFlows.doSearch = function(ns, query){
    var q = 'SELECT Id, __NAMESPACE__Org_ID__c, Name FROM __NAMESPACE__Environment__c WHERE Name LIKE \'%'+query+'%\' order by Name ASC limit 9';
    q = q.replace(new RegExp('__NAMESPACE__','g'), ns);
    var result = sforce.connection.query(q);
    var records = result.getArray('records');
    return records;
};
JsRemoting.deploymentFlows.getCIRecords = function(ns, repositoryId){
    // now request all the CI records associated to each envConnection.toEnvId
    // we will filter the git branches later.
    var q = "SELECT Id, Name, __NAMESPACE__Destination_Org_Credential__r.__NAMESPACE__Environment__r.Name, __NAMESPACE__Destination_Org_Credential__r.__NAMESPACE__Environment__c, __NAMESPACE__Branch__c, __NAMESPACE__Status__c FROM __NAMESPACE__Continuous_Integration__c "+
        " WHERE __NAMESPACE__Active__c = true AND __NAMESPACE__Git_Repository__c = '"+repositoryId+"' AND __NAMESPACE__Destination_Org_Credential__r.__NAMESPACE__Environment__r.Name!=''";
    q = q.replace(new RegExp('__NAMESPACE__','g'), ns);
    var result = sforce.connection.query(q);
    var records = result.getArray('records');
    console.debug('JsRemoting.deploymentFlows.getCIRecords()', JSON.stringify(records, null, '  '));
    return records;
};


JsRemoting.common.update = function(records){
    var result = sforce.connection.update(records);
    return result;
};
JsRemoting.common.create = function(record){
    var result = sforce.connection.create(record);
    return result;
};
JsRemoting.common.deleteIds = function(ids){
    var result = sforce.connection.deleteIds(ids);
    return result;
};
JsRemoting.vlocity.getDependencies = function(usId,keys,ns,successCB,exceptionCB,errorCB){
     var core = ns ? window[ns.split('__')[0]] : window;
     console.log("JsRemoting.vlocity.getDependencies starting", usId);
     console.log("JsRemoting.vlocity.getDependencies starting", keys);

     var jobId = (core).JsRemotingController.getVlocityDependencies(usId,keys,function(result, event){
         console.log("(core).JsRemotingController.getVlocityDependencies event=", event);
         if (event.status) {
             successCB();
         }else if (event.type === 'exception') {
             console.error(event);
             exceptionCB(event);
         }else {
             console.error(event);
             errorCB(event);
         }
     },{escape : false});
}