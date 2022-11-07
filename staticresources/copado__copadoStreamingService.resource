var copadoStreamingService = copadoStreamingService || {
    ns: '',
    hasPushTopic: false,
    alreadyInitialized: false,
    streamingAPI_clientId: '',
    c: [],

    _errorOnAccessingSobject: function(e, sobjectType) {
            console.error(e, e.faultstring);
            var msg = ''+ (e.faultstring||e);
            msg = "There was an error accessing {SOBJECT}. This is usually cause by a missing permission.\nPlease contact your administrator requesting it.\n\nOriginal error was: "+msg;
            if(msg.indexOf('Copado_Notification__c')>-1)
                sobjectType = 'Copado_Notification__c';
            msg = msg.replace('{SOBJECT}', sobjectType);
            return alert(msg);
        },
    getPushTopics: function(){
        var me = copadoStreamingService;
        try{
            var result = sforce.connection.query("SELECT Id, Name, Query, ApiVersion, IsActive, NotifyForFields, NotifyForOperations, Description, NotifyForOperationCreate, NotifyForOperationUpdate, NotifyForOperationDelete, NotifyForOperationUndelete FROM PushTopic WHERE Name='CopadoDeployNotifications' or Name='CopadoNotifications'");
        }catch(e) {
            return copadoStreamingService._errorOnAccessingSobject(e,'PushTopic');
        }
        var records = result.getArray("records");
        console.info('getPushTopics', records.length, records)
        if(records.length > 0){
            var notificationsToFinish = [];
            for(var i=0; i<records.length; i++){
                if(records[i].Name=='CopadoNotifications' && records[i].Query.indexOf(me.ns+'Message__c')!=-1){
                    me.hasPushTopic = true;
                }else{
                    //if query doesn't contains new fields delete it
                    if(records[i].Query.indexOf(me.ns+'Message__c')==-1){
                        var n = new sforce.SObject(me.ns+"Copado_Notification__c");
                        n.Id = records[i].Id;
                        n[me.ns+"isFinished__c"] = true;
                        notificationsToFinish.push(n);
                    }
                }

            }
            // NR: do not delete notifications. They are kept as reference.
            //notificationsToDelete.length && sforce.connection.deleteIds(notificationsToDelete);
            notificationsToFinish.length && sforce.connection.upsert("Id", notificationsToFinish);
        }
    },
    createPushTopic: function(name, query){
        var me = copadoStreamingService;
        var pt = new sforce.SObject("PushTopic");
        pt.Name = name;
        pt.Query = query;
        pt.ApiVersion = 32.0;
        pt.NotifyForOperationCreate = true;
        pt.NotifyForOperationUpdate = true;
        pt.NotifyForOperationDelete = false;
        pt.NotifyForOperationUndelete = false;
        pt.NotifyForFields = 'All';

        try{
            var result = sforce.connection.create([pt]);
        }catch(e) {
            return copadoStreamingService._errorOnAccessingSobject(e,'PushTopic');
        }
        if(result[0].getBoolean('success')){
            console.log('PushTopic created: ', result);
            if(name=='CopadoNotifications')me.hasPushTopic = true;
        }
        else{
            console.error('Problem creating PushTopic: ', result[0]);
            return copadoStreamingService._errorOnAccessingSobject(result[0], 'PushTopic');
        }
    },

    init: function(){
        var me = copadoStreamingService;
        if(me.alreadyInitialized) {
            console.debug('copadoStreamingService() avoiding duplicated init.');
            return;
        }
        me.alreadyInitialized = true;
        try{
            var query = 'Select Id, Name, '+me.ns+'isFinished__c, '+me.ns+'Status__c, '+me.ns+'AttachmentId__c, '+me.ns+'Type__c, '+me.ns+'Message__c, '+me.ns+'ParentId__c, '+me.ns+'Parent2Id__c, CreatedDate, LastModifiedDate FROM '+me.ns+'Copado_Notification__c';
            me.getPushTopics();
            if(! me.hasPushTopic ){
                me.createPushTopic('CopadoNotifications', query);
            }
        }catch(e) {
            console.error(e);
            return copadoStreamingService._errorOnAccessingSobject(e, me.ns+'Copado_Notification__c');
        }
        me.c = $copado.cometd.init({
            url: window.location.protocol+'//'+window.location.hostname+'/cometd/23.0/',
            requestHeaders: { Authorization: 'OAuth '+__sfdcSessionId}
        });

    },
    disconnect: function(){
        $copado.cometd.disconnect();
    }
};
