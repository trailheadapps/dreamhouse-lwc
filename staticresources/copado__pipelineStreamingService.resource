var ccdStream = ccdStream || {};

((service) => {
    service.config = service.config || {};

    ((config) => {
        config.ns = '';
        config.timeout = 0;
        config.duration = 0;
        config.sobjectAccessError = '';
        config.pushTopicName = 'CopadoEnvironments';
        config.streamCallback = {};
    })(service.config);

    var subscriptionRef;
    var hasPushTopic = false;
    var alreadyInitialized = false;
    var retryTimes = 20;
    var timeoutInterval;
    const cometd_statuses = {
       CONNECTED : 'connected',         // State assumed when this BayeuxClient is connected to the Bayeux server
       CONNECTING : 'connecting',       // State assumed when the connect is being sent for the first time
       DISCONNECTED : 'disconnected',   // State assumed before the handshake and when the disconnect is completed
       DISCONNECTING : 'disconnecting', // State assumed when the disconnect is being sent
       HANDSHAKEN : 'handshaken',       // State assumed when the handshake is received, but before connecting
       HANDSHAKING : 'handshaking',     // State assumed when the handshake is being sent
       REHANDSHAKING : 'rehandshaking', // State assumed when a first handshake failed and the handshake is retried, or when the Bayeux server requests a re-handshake
       TERMINATING : 'terminating',     // State assumed when the disconnect is received but terminal actions must be performed
       UNCONNECTED : 'unconnected'      // State assumed after the handshake when the connection is broken
    }

    var _errorOnAccessingSobject = (e, sobjectType) => {
        console.error(e, e.faultstring);
        var msg = service.config.sobjectAccessError + (e.faultstring || e);
        msg = msg.replace('{SOBJECT}', sobjectType);
        return alert(msg);
    };

    var _getPushTopics = () => {
        var pushTopicName = service.config.pushTopicName;
        try {
            var result = sforce.connection.query('SELECT Id, Name, Query, ApiVersion, IsActive, NotifyForFields, NotifyForOperations, '
                                               + 'Description, NotifyForOperationCreate, NotifyForOperationUpdate, NotifyForOperationDelete, '
                                               + 'NotifyForOperationUndelete FROM PushTopic WHERE Name = \'' + pushTopicName + '\'');
        } catch(e) {
            return _errorOnAccessingSobject(e,'PushTopic');
        }
        var records = result.getArray('records');
        if(records.length > 0) {
            for(var i = 0; i < records.length; i++) {
                if(records[i].Name == pushTopicName) {
                    console.info('Push topic for ' + pushTopicName + ' already exists.');
                    hasPushTopic = true;
                }
            }
        }
    };

     var _createPushTopic = (name, query) => {
         var pt = new sforce.SObject('PushTopic');
         pt.Name = name;
         pt.Query = query;
         pt.ApiVersion = 46.0;
         pt.NotifyForOperationCreate = true;
         pt.NotifyForOperationUpdate = true;
         pt.NotifyForOperationDelete = false;
         pt.NotifyForOperationUndelete = false;
         pt.NotifyForFields = 'Select';

         try {
             var result = sforce.connection.create([pt]);
         } catch(e) {
             return _errorOnAccessingSobject(e, 'PushTopic');
         }
         var pushTopicName = service.config.pushTopicName;
         if(result[0].getBoolean('success')) {
             console.info(pushTopicName + ' PushTopic not found and a new one is created');
         } else {
             console.error('Problem creating ' + pushTopicName + ' PushTopic: ', result[0]);
             return _errorOnAccessingSobject(result[0], 'PushTopic');
         }
     };

     service.initStreaming = () => {
         var query = 'SELECT Id, Name FROM PushTopic limit 10';
         var result = sforce.connection.query(query, {
             onSuccess: function(res) {
                 _init();
             },
             onFailure: function(res) {
                 console.error(res);
             }
         });
     };

     var _init = () => {
        if(alreadyInitialized) {
            return;
        }
        alreadyInitialized = true;
        try {
            var query = 'Select Id, Name, ' + service.config.ns + 'Latest_Deployment__c, ' + service.config.ns + 'Latest_Deployment_Status__c FROM ' + service.config.ns + 'Environment__c';
            _getPushTopics();
            if(!hasPushTopic) {
                _createPushTopic(service.config.pushTopicName, query);
            }
        } catch(e) {
            console.error(e);
            return _errorOnAccessingSobject(e, service.config.ns + 'Environment__c');
        }
        var status = $copado.cometd.getStatus();
        if(status !== cometd_statuses.CONNECTED) {
            var asyncConnect = new Promise(function(resolve, reject) {
                _connectToStreaming();
            });
        } else {
            _subscribeToStreaming();
        }
     };

     var _connectToStreaming = () => {
         var status = $copado.cometd.getStatus();
         if(status == cometd_statuses.DISCONNECTED || status == cometd_statuses.UNCONNECTED) {
             if(retryTimes == 0) {
                 return;
             }
             retryTimes--;
             console.info('[' + service.config.pushTopicName + '] connecting to streaming... retry attempts left: ' + retryTimes);
         }
         setTimeout(function() {
             status = $copado.cometd.getStatus();
             console.log('[' + service.config.pushTopicName + '] status: ' + status);
             switch(status) {
                 case cometd_statuses.CONNECTED:
                    _subscribeToStreaming();
                    break;
                 case cometd_statuses.HANDSHAKING:
                 case cometd_statuses.HANDSHAKEN:
                 case cometd_statuses.CONNECTING:
                 case cometd_statuses.REHANDSHAKING:
                    _connectToStreaming();
                    break;
                 case cometd_statuses.DISCONNECTED:
                 case cometd_statuses.UNCONNECTED:
                    service.c = $copado.cometd.init({
                          url: window.location.protocol + '//' + window.location.hostname + '/cometd/37.0/',
                          requestHeaders: { Authorization: 'OAuth ' + __sfdcSessionId }
                     });
                    _connectToStreaming();
                    break;
                 default:
                    break;
             }
         }, 1000);
     };

     var _subscribeToStreaming = () => {
         subscriptionRef = $copado.cometd.subscribe('/topic/' + service.config.pushTopicName, function(message) {
             _readStream(message);
         });
         if(service.config.duration) {
             _startTimer();
         }
     };

     var _startTimer = () => {
         setTimeout(function() {
            timeoutInterval = setInterval(_runCountdown(), 1000);
         }, 10000);
         document.addEventListener('click', function() {
            service.config.timeout = service.config.duration;
         });
     };

     var _runCountdown = () => {
          if(service.config.timeout == 0) {
              if(subscriptionRef) {
                  $copado.cometd.unsubscribe(subscriptionRef);
                  console.info('Subscription to ' + service.config.pushTopicName + ' ended.');
              }
              clearInterval(timeoutInterval);
              return;
          }
          setTimeout(function() {
              service.config.timeout -= 1000;
              _runCountdown();
          }, 1000);
     };

     service.disconnect = () => {
          $copado.cometd.disconnect();
     };

     var _readStream = (message) => {
         console.info('Push message: ', message);
         var statusMap = service.statusMap;
         if(message.channel == '/topic/' + service.config.pushTopicName) {
             var thisRecord = message.data.sobject;
             var newStatus = thisRecord[service.config.ns + 'Latest_Deployment_Status__c'];
             var idString = '#deploymentStatus_' + thisRecord.Id;
             var idStringNoStatus = '#noDeploymentStatus_' + thisRecord.Id;
             var noDeploymentStatus = $copado(idStringNoStatus);
             var environmentStatus = $copado(idString);
             var container = $copado(idString).parent();
             if(noDeploymentStatus.length > 0) {
                environmentStatus = $copado(idStringNoStatus);
                container = $copado(idStringNoStatus).parent();
                $copado(idStringNoStatus).remove();
                container.append('<img id="' + idString.replace('#','') + '" src="" />');
             }
             if(environmentStatus) {
                 var elementType = environmentStatus.prop('nodeName');
                 if(elementType === 'DIV' && newStatus !== 'In progress') {
                     _replaceSpinner(idString, container);
                 } else if (elementType === 'IMG' && newStatus === 'In progress') {
                     _replaceImg(idString, container);
                     return;
                 }
                 var statusElem = $copado(idString);
                 if(statusElem && statusMap && (newStatus in statusMap)) {
                    $copado(statusElem).attr('src', statusMap[newStatus]);
                 }
             }
         }
     };

     var _replaceSpinner = (elemId, container) => {
        $copado(elemId).remove();
        container.append('<img id="' + elemId.replace('#','') + '" src="" />')
     };

     var _replaceImg = (elemId, container) => {
         $copado(elemId).remove();
         var spinner = '<div id="' + elemId.replace('#','') + '" class="spinner">'
                       + '<div role="status" class="slds-spinner slds-spinner_xx-small slds-spinner_brand">'
                       + '<span class="slds-assistive-text">Loading</span>'
                       + '<div class="slds-spinner__dot-a"></div>'
                       + '<div class="slds-spinner__dot-b"></div>'
                       + '</div></div>'
         container.append(spinner);
     }
})(ccdStream);