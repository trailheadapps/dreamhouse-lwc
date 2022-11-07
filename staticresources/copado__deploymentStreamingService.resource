var deploymentStreamingService = deploymentStreamingService || {};

deploymentStreamingService.streamingAPI_clientId  = '';
deploymentStreamingService.fileName = 'PROGRESS_STATUS_COPADO';
deploymentStreamingService.ns = '';

deploymentStreamingService.initStreaming = function(){
   var query = 'SELECT Id, Name FROM PushTopic limit 10';
   var result = sforce.connection.query(query, {
       onSuccess: function(res) {
           //console.log('res===> ',res);
           deploymentStreamingService.ns = copadoApp.ns;

           copadoStreamingService.ns = copadoApp.ns;
           copadoStreamingService.init();

           $copado.cometd.subscribe('/topic/CopadoNotifications', function(message) {
               console.info('Push message: ', message);
               deploymentStreamingService.readStream(message);
           });
       },
       onFailure: function(res) {
           console.log('Push Topic is not accessible for current user');
       }
   });
};

deploymentStreamingService.finalUpdateBeforeStart = false;
deploymentStreamingService.calloutCounter = 0;
deploymentStreamingService.maxAllowedCallout = 60;
deploymentStreamingService.calloutInterval = 10000;
deploymentStreamingService.initPoller = function(){
    //console.log('deploymentStreamingService.initPoller');
    var me = deploymentStreamingService;
    if(me.calloutCounter < me.maxAllowedCallout){
        me.calloutCounter++;
        var query = 'SELECT '+me.ns+'Read_Only__c, '+me.ns+'dataJson__c, Id, Name, '+me.ns+'Status__c, '+me.ns+'Deployment__r.'+me.ns+'Status__c,' +me.ns+'Deployment__r.'+me.ns+'Promotion__c,' +me.ns+'Order__c, '+me.ns+'Type__c, '+me.ns+'Branch__c, '+me.ns+'Git_Repository__c, '+me.ns+'Commit_Name__c, '+me.ns+'Commit_Id__c, '+me.ns+'Deployment__c, '+me.ns+'CheckOnly__c FROM '+me.ns+'Step__c WHERE '+me.ns+'Deployment__c =\'' + copadoApp.data.dep.Id + '\'';
        //console.log('query===> ',query);
        var result = sforce.connection.query(query, {
           onSuccess: function(res) {
               var isManual = (res.records && (res.records.length ? res.records[0][me.ns+'Deployment__r'][me.ns + 'Promotion__c'] == null : res.records[me.ns+'Deployment__r'][me.ns + 'Promotion__c'] == null));
               console.log('isManual ==> ',isManual);
               //console.log('result==> ',res);
               if(res.records && (copadoApp.renderedSteps.length != res.records.length || res.records.length != $copado('div[data-stepId]').length)){
                   //console.log('1......');
                   if(isManual){
                       deploymentStreamingService.finalUpdateBeforeStart = true;
                   }
                   for(var i = 0; i<res.records.length; i++){
                       copadoApp.renderInsertedStep(res.records[i]);
                   }
               }

               if(res.records && (res.records.length ? res.records[0][me.ns+'Deployment__r'][me.ns + 'Status__c'].toLowerCase() == 'in progress' : res.records[me.ns+'Deployment__r'][me.ns + 'Status__c'].toLowerCase() == 'in progress')){
                   //console.log('4......');
                   deploymentStreamingService.finalUpdateBeforeStart = true;
                   for(var i = 0; i<res.records.length; i++){
                       copadoApp.renderInsertedStep(res.records[i]);
                   }
               } else if(!deploymentStreamingService.finalUpdateBeforeStart && (!res.records || (res.records && (res.records.length ? res.records[0][me.ns+'Deployment__r'][me.ns + 'Status__c'] == 'Draft' : res.records[me.ns+'Deployment__r'][me.ns + 'Status__c'] == 'Draft'))) && copadoApp.ccdEnabled){
                   //console.log('2......');
                   setTimeout(deploymentStreamingService.initPoller, me.calloutInterval);
               } else if(deploymentStreamingService.finalUpdateBeforeStart){
                   //console.log('3......');
                   deploymentStreamingService.finalUpdateBeforeStart = false;
                   for(var i = 0; i<res.records.length; i++){
                       copadoApp.renderInsertedStep(res.records[i]);
                   }
               }
           },
           onFailure: function(res) {
               console.log('failure response ===> ',res);
           }
        });
    }
};

deploymentStreamingService.readStream = function(message){
    var me = deploymentStreamingService;
    
    me.streamingAPI_clientId = message.clientId;

    if(message.channel=='/topic/CopadoNotifications'){
        if(me.ParentIdinArray(message.data.sobject[me.ns+'ParentId__c'])){
            if(message.data.sobject.Name==me.fileName){
                copadoApp.updateDeployment();
                copadoApp.statusCheckerCallBack();
                setTimeout(function(){
                    copadoApp.updateDeployment();
                    copadoApp.statusCheckerCallBack();
                }, 5000);
            }
        }
    }
};
deploymentStreamingService.ParentIdinArray = function(parentId){
    for(var i=0; i<copadoApp.data.jobs.length; i++){
        var id1 = parentId;
        var id2 = copadoApp.data.jobs[i].Id;
        console.info(id1, id2, id1 == id2);
        if(id1 == id2)return true;
    }
    return false;
};