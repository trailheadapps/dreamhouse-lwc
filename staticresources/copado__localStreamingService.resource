var localStreamingService = localStreamingService || {};
localStreamingService.config = localStreamingService.config = {};
localStreamingService.data = localStreamingService.data = {};

//Properties
localStreamingService.streamingAPI_clientId = '';
localStreamingService.config.ns = '';
localStreamingService.config.attachmentFileName = '';
localStreamingService.data.parentId = '';
localStreamingService.data.childrenArray = [];
localStreamingService.data.readStatusFromAttachmentCB = function(){};

localStreamingService.readStatusFromAttachment = function(att){
    if(!att) return;
    if(att.Name==localStreamingService.config.attachmentFileName){
        localStreamingService.data.readStatusFromAttachmentCB(att);
    }
};
localStreamingService.getAttachment = function(parentId, name){
    var att = JsRemoting.attachments.getDecodedAttachment(parentId, name);
    return att;
};
localStreamingService.readStream = function(message){
    // NR: Detach the process so we can see the errors, if any (streaming cuts of any error notif)
    window.setTimeout(function() {

        var me = localStreamingService;
        me.streamingAPI_clientId = message.clientId;
        //console.log('Stream received:',message);
        if(message.channel=='/topic/CopadoNotifications'){
            //console.log('FileName', message.data.sobject.Name==me.config.attachmentFileName);
            //console.log('isInArray',$copado.inArray(message.data.sobject[me.config.ns+'ParentId__c'], me.data.childrenArray)>=0);
            var validParentId = (message.data.sobject[me.config.ns+'Parent2Id__c']!=null)?((message.data.sobject[me.config.ns+'Parent2Id__c']==me.data.parentId)?true:false):false;
            validParentId = (validParentId==false && message.data.sobject[me.config.ns+'ParentId__c']==me.data.parentId)?true:false;
            //console.log('ParentId compare', validParentId, message.data.sobject[me.config.ns+'ParentId__c'], message.data.sobject[me.config.ns+'Parent2Id__c']);
            
            if(message.data.sobject.Name==me.config.attachmentFileName){
                //console.log('--> inside fileName if function');
                var att = new sforce.SObject("Attachment");
                att.Id = message.data.sobject[me.config.ns+'AttachmentId__c'];
                var parentId = message.data.sobject[me.config.ns+'ParentId__c'];
                var parent2Id = message.data.sobject[me.config.ns+'Parent2Id__c'];
                var continueParsing = false;
                
                if($copado.inArray(parentId, me.data.childrenArray)>=0){
                    console.log('--> ParentId in childrenArray');
                    att.ParentId = parentId;
                    continueParsing = true;
                }
                if($copado.inArray(parent2Id, me.data.childrenArray)>=0){
                    console.log('--> Parent2Id in childrenArray');
                    att.ParentId = parentId;
                    continueParsing = true;
                }
                if(parentId===me.data.parentId)continueParsing = true;
                if(parent2Id===me.data.parentId)continueParsing = true;
                
                if(continueParsing==false)return;

                //console.log('Relevant Stream:', message);
                var msg = message.data.sobject[me.config.ns+'Message__c'];
                var name = message.data.sobject.Name;

                att = new sforce.SObject("Attachment");
                att.Id = message.data.sobject[me.config.ns+'AttachmentId__c'];
                att.ParentId = parentId;
                if(msg != null){
                    att.Name = me.config.attachmentFileName;
                    att.Body = msg;
                }
                else{
                    att = me.getAttachment(parentId, name);
                }
                me.readStatusFromAttachment(att);
            }
        }
    },1);
};