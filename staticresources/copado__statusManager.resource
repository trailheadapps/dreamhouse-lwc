var statusManager = statusManager || {
    ns: '',
    max_retries: 600,
    waitTimeout: 60000,
    statusCheckerInterval: 5000,
    retry_count: 0,
    fileName: 'PROGRESS_STATUS_COPADO',
    showAlert: true,
    copadoServer: '',
    urlParameters: '',
    operationInProgress: false,
    notificationId: '',
    copadoJobId: '',
    attachmentId: '',
    parentId: '',
    parentId2: '', // in circumstances such as /apex/SnapshotDifference where are two different process that can be started we need to monitor an additional parentId
    sessionId: '',
    elementId: null,
    initFunction: function() {},
    successFunction: function() {},


    /**
     * this object is to callback functions by addCallbackHelper
     * @type {Object}
     */
    callbackMap: {},


    /**
     * [addCallbackHelper description]
     * @param {[type]}   className [description]
     * @param {Function} cb        [description]
     */
    addCallback: function(className, cb) {
        statusManager.callbackMap[className] = cb;
    },

    // statusManager.isJobFinished(obj)

    /**
     * Determine if a job finished or not
     * obj.isFinished should be always available, but some legacy code has obj.status instead.
     * @param {[obj]}   obj the job object, with the isFinished true/false value
     */
    isJobFinished: function(obj) {
        if (obj) {
            result = obj.hasOwnProperty('isFinished') ? obj.isFinished : obj.status === 'done';
        } else {
            result = true;
        }
        console.debug('statusManager.isJobFinished=', result, obj ? obj.isFinished : 'n/a', obj ? obj.status : 'n/a');
        return result;
    },

    statusCheckerTimer: false,

    startStatusChecker: function(startStatusPoller) {
        var me = statusManager;
        if(startStatusPoller){
            me.operationInProgress = true; // NR: when the status checker starts, we assume there is a job in progress.
            if (!me.statusCheckerTimer) {
                window.setTimeout(function() {
                    me.statusCheckerTimer = setInterval(me.statusChecker, me.statusCheckerInterval);
                }, 5000); // NR: testing a timing issue, when statusChecker() is called even before creating the attachment
            }
        }
    },
    stopStatusChecker: function() {
        var me = statusManager;
        me.statusCheckerTimer && clearInterval(me.statusCheckerTimer);
        me.statusCheckerTimer = false;
    },
    statusChecker: function(avoidStatusRefresh) {
        var me = statusManager;
        if (avoidStatusRefresh) {
            me.stopStatusChecker();
        } else {
            me.waitForResponse();
        }
    },

    checkCopadoJobStatus: function() {
        console.info('checkCopadoJobStatus...');

        var me = statusManager;
        var uri = me.herokuServer + '/json/v1/copadoJob/' + me.copadoJobId + me.urlParameters;
        sforce.connection.remoteFunction({
            url: uri,
            requestHeaders: {
                "Content-Type": "text/json",
                "userId": _temp_conf.userId,
                "orgId": _temp_conf.orgId,
                "token2": _temp_conf.token2
            },
            method: "GET",
            requestData: {},
            onSuccess: function(res) {
                console.log('checkCopadoJobStatus success', res);
                var obj = JSON.parse(res);
                if (obj.copadoJobId) {
                    me.copadoJobId = obj.copadoJobId;
                }
                if (statusManager.isJobFinished(obj)) {
                    me.handleStatusComplete(obj);
                }
                return obj;
            },
            onFailure: function(response) {
                console.log('Failed: Response was: ', response);
            },
            timeout: 25000
        });
    },
    getAttachment: function(parentId, name) {
        console.log('status manager get attachment');
        console.log('status manager get attachment name',name);
        var me = statusManager;
        var att = dw.u.getDecodedAttach(parentId, name);
        console.log('status manager get attachment att',att);
        if (att) {
            statusManager.attachmentId = att[0].Id;
        } else {
            me.attachmentId = '';
        }
        return att;
    },

    /**
     * reset the job status, clearing internal flags, the UI, and removing the attachment
     */
    setStatusComplete: function() {
        //reset values
        var me = statusManager;
        me.retry_count = 0;
        me.operationInProgress = false;
        //delete attachment & notification
        var ids = [];
        if (me.attachmentId != '') ids.push(me.attachmentId);
        // NR: do not delete the notification
        //if (me.notificationId && me.notificationId != '') ids.push(me.notificationId);
        var delResult = sforce.connection.deleteIds(ids);

        //update UI
        if (me.elementId) {
            setStatusMessage('', me.elementId);
        } else {
            setLockScreenMessage('');
        }
        unlockScreen();
    },

    /** UCU
     * when "isFinished":true,
     *      "status":"done",
     *      "isSuccess":false
     * it is either unexpected error or there is a merge conflict for the current promotion.
     * So, added conflict check logic to prevent showing unexpected error pop-up when unnecessery
     */
    checkConflict: function(){
        try{
            var q = "Select Id, Body, LastModifiedDate, Name, ParentId From Attachment where Name LIKE 'US-%' and parentId = '" + statusManager.parentId + "' order by LastModifiedDate DESC limit 1",
            result = sforce.connection.query(q);

            return result.getArray("records");
        } catch(ex){
            console.log("An error has occurred " + ex);
        }
    },

    /**
     * basic callback
     * @return {[type]} [description]
     */
    handleStatusComplete: function(msg) {
        console.log('### Job completed... Deleting attachment and notification. ###', msg);
        var me = statusManager;

        if (msg && msg.isSuccess == false) {
            var conflictAtt = me.checkConflict();
            if(conflictAtt && conflictAtt.length == 1) {
                me.showAlert = false;
            }
            var errorMsgs = (msg.messages && msg.messages.length > 0) ? msg.messages.join('\n') : (msg.type == 'MetadataRetriever' ?  copadoLabels.IF_MODIFY_METADATA_ENABLED : copadoLabels.UNEXPECTED_ERROR);
            //to Prevent multiple error pop-ups when an error occurs in a callout
            if(me.showAlert == true) {
                alert(errorMsgs);
                me.showAlert = false;
                console.error('Error Messages: ', errorMsgs);
            }
            me.stopStatusChecker();
        }

        me.setStatusComplete();

        //invoke callback
        msg && console.log('invoke callback', msg.type, me.callbackMap, me.successFunction, me.successFunction2);
        unlockScreen();
        //additional callback using className
        if (msg && typeof me.callbackMap[msg.type] == 'function') {
            me.callbackMap[msg.type]();
        } else {
            typeof me.successFunction == 'function' && me.successFunction();
            // NR: alternative, additional handler, since in some pages (viewOrg), the previous handler is already used
            typeof me.successFunction2 == 'function' && me.successFunction2();
        }
        // NR: also fire a browser event to notify anyone listening that the task finished.
        // this is a better way of handling stuff than single callbacks.
        if(msg){
            var event = new CustomEvent('copadoJobFinished1', { 'detail': {jobType: msg.type, parentId: me.parentId} });
            document.dispatchEvent(event);
        }
    },

    readStatusFromResponse: function(res) {
        console.log('readStatusFromResponse', res);

        var me = statusManager;
        var obj = (res != null) ? JSON.parse(res) : [];

        console.log('obj', obj);

        if (statusManager.isJobFinished(obj)) {
            me.handleStatusComplete(obj);
            return;
        }
        if (obj.status) {
            if (me.elementId) {
                setStatusMessage(obj.status, me.elementId);
            } else {
                setLockScreenMessage(obj.status);
            }
        }
        dw.u.upsertAttach(me.parentId, me.fileName, res, false);
    },
    retryWait: function() {
        statusManager.waitForResponse();
    },

    readStatusFromAttachment: function(att) {
        console.info('readStatusFromAttachment: Reading status from attachment...');
        var me = statusManager;
        me.lastAttachment = att;
        var obj = JSON.parse(att.Body);
        me.lastAttachmentBodyJSON = obj;

        if (obj.copadoJobId) {
            me.copadoJobId = obj.copadoJobId;
            me.checkCopadoJobStatus();
        }
        if (statusManager.isJobFinished(obj)) {
            me.handleStatusComplete(obj);
            return;
        } else {
            console.log('not status complete', obj);
            me.operationInProgress = true;
            me.updateStatus(obj.status, att);

            // NR: if there is an EXISTING status attachment file, show the option to cancel it
            // and show the age of the last update on that status.
            var millisecondsToStr = function(milliseconds) {
                var numberEnding = function(number) { return (number>1) ? 's' : ''; };
                var temp = Math.floor(milliseconds / 1000);
                var days = Math.floor((temp %= 31536000) / 86400);
                var hours = Math.floor((temp %= 86400) / 3600);
                var minutes = Math.floor((temp %= 3600) / 60);
                if (days)       return days + ' day' + numberEnding(days);
                if (hours)      return hours + ' hour' + numberEnding(hours);
                if (minutes)    return minutes + ' min' + numberEnding(minutes);
                return 'few seconds'; //or other string you like;
            };
            var t;
            if( (t=document.getElementById('statusManager_clearLastStatus')) && me.lastAttachment.length) {
                t.style.display = 'inline';
                var LastModifiedDate = me.lastAttachment[0].getDateTime('LastModifiedDate');
                var diff = (new Date()) - LastModifiedDate;
                // save the age to be used in the confirm message.
                me.lastStatusAge = millisecondsToStr(diff);
                //if( (t=document.getElementById('statusManager_lastStatusAge')) ) {
                //    t.innerText = millisecondsToStr(diff);
                //}
            }
        }
    },

    waitForResponse: function() {

        var me = statusManager;
        if (me.operationInProgress == false) {
            console.info('operation in progress false');
            return;
        }
        me.retry_count++;
        if (me.max_retries == me.retry_count) {
            alert(copadoLabels.OPERATION_TIMEOUT_RUNNING_IN_BACKGROUND);
            return;
        }
        var att = me.getAttachment(me.parentId, me.fileName);

        console.log('getAttachment ', me.parentId, me.fileName, att, me.operationInProgress)

        if (att != null) {
            me.readStatusFromAttachment(att);
        } else {
            /* NR: temporarily commented out the else to test US-0000259
             * It seems this is the issue: the new attachment PROGRESS_STATUS_COPADO is not found
             * and this assumes the process finished. TBD.
             * NR: nope, without this other processes ( such as Refresh Cache in the same page)
             * fail.
             */
            //me.handleStatusComplete();
        }
    },
    initialise: function() {

        console.info('initialise');

        var me = statusManager;
        if (me.sessionId != '') me.initialiseStreamingApi(me.sessionId);

        me.operationInProgress = false;
        me.lastAttachment = null; // NR: see if this fixes issues when a job starts AFTER another job
        console.log('me',me);
        //when statusManager is initialised determine if job is ongoing.
        var att = me.getAttachment(me.parentId, me.fileName);

        if (att != null) {
            lockScreen();
            me.readStatusFromAttachment(att)
            me.retry_count = 0;
            //we know job is in progress so we wait for streaming API.
        } else {
            me.operationInProgress = false;
            console.log('typeof me.initFunction ',typeof me.initFunction);
            if (typeof me.initFunction != "undefined"){
                me.initFunction();
            }
            //unlockScreen(); Expecting the initFunction to lock/unlock screen as required.
        }
    },

    /**
     * update status in UI
     * @param  {[type]} obj [description]
     * @return {[type]}     [description]
     */
    updateStatus: function(status, att) {
        console.info('updateStatus', status);
        if (status) {
            var me = statusManager;

            if (me.elementId) {
                setStatusMessage(status, me.elementId);
            } else {
                setLockScreenMessage(status);
            }
        }
    },

    /**
     * get type and status from pushed msg
     * filter only binded && update status or callback
     * @param  {[type]} message [description]
     * @return {[type]}         [description]
     */
    readStream: function(message) {
        if(!message || !message.data || !message.data.sobject) {
            console.warn('statusManager.readStream: incorrect message=', message);
            return;
        }
        var me = statusManager,
            notification = message.data.sobject;
        me.notificationId = notification.Id;

        console.debug('statusManager.readStream: msg', notification.Id, 'P:'+notification.ParentId, notification.Message__c);

        var attParentId = notification[me.ns + 'ParentId__c'];
        if (attParentId != me.parentId && attParentId != me.parentId2) {
            console.log('The message parentId does not match, continuing (expect: ', me.parentId, me.parentId2, 'got:', attParentId, ')');
            return false;
        }

        var msg = JSON.parse(notification[me.ns + 'Message__c']);
        if (!msg) {
            console.log('readStream: no Message__c field found in', notification);
            var att = me.getAttachment(notification[me.ns + 'ParentId__c'], me.fileName);
            if (att) {
                me.readStatusFromAttachment(att);
            } else {
                me.handleStatusComplete();
            }
            return;
        }

        if (statusManager.isJobFinished(msg)) {
            console.log('Status completed: ', msg);
            me.handleStatusComplete(msg);
        } else {
            console.log('Status not completed: ', msg.status);
            me.operationInProgress = true;
            me.updateStatus(msg.status, message.data.sobject);
        }
    },
    initialiseStreamingApi: function(sessionId) {

        //to prevent multiple
        if (statusManager._hasBeenInitialized) return;
        statusManager._hasBeenInitialized = true;

        console.info('initialiseStreamingApi');
        $copado(function() {
            $copado.cometd.subscribe('/topic/CopadoNotifications', function(message) {
                // NR: added the setTimeout to detatch readStream, otherwise exceptions will be always ignored, invisible.
                window.setTimeout(function() { statusManager.readStream(message); },1);
            });
        });
    },

    /**
    * set the operationInProgress flag, create the PROGRESS_STATUS_COPADO attachment and calls the rest of the code that will call the Copado webhook
    * also locks the screen.
    **/
    startProcess: function(callback, isParentId2, jobType) {
        console.assert(!isParentId2 || statusManager.parentId2,  'statusManager.startProcess: requested to monitor another parentId, but statusManager.parentId2 is empty');
        parentId = isParentId2? statusManager.parentId2 :statusManager.parentId;
        console.assert(parentId,  'statusManager.startProcess: No parentId ( or parentId2 ) defined.');

        console.info('statusManager.startProcess(): starting for parentId='+parentId, arguments);
        statusManager.operationInProgress = true;

        // If there is an attachment, it means the job is in progress.
        if(statusManager.lastAttachment) {
            console.info('statusManager.startProcess(): attachment exists, do not re-create');
            callback.call(window);
            console.info('statusManager.startProcess(): done');
            return;
        }

        var callbackOnFailed = function(result) {
            console.error('callbackOnFailed:', result);
            var msg = String(result);
            alert("There was an error trying to contact Copado webhooks. No job was started. The error was:\n"+msg);
            statusManager.setStatusComplete();
            throw new Error("error: "+msg);
        };
        var payload = '{"isFinished":false,"type":"'+(jobType||'n/a')+'","status":"Sending request..."}';
        var so = new sforce.SObject("Attachment");
        so.ParentId = parentId;
        so.Name = statusManager.fileName;
        so.Body = Base64.encode(payload);

        lockScreen();
        var result = sforce.connection.create([so], {onFailure : callbackOnFailed, onSuccess : function(result) {
            console.info('statusManager.startProcess(): result', result);
            if(!result[0].getBoolean("success"))
                return callbackOnFailed(result);
            statusManager.attachmentId = result[0].id;
            // now continue with whatever the job needs to do
            callback.call(window);
            console.info('statusManager.startProcess(): done');
        }});
    }
};