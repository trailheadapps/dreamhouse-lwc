var ccdStoryStream = ccdStoryStream || {};

(service => {
    service.config = service.config || {};
    service.params = service.params || {};

    (config => {
        config.ns = '';
        config.timeout = 0;
        config.duration = 0;
        config.sobjectAccessError = '';
        config.pushTopicName = 'CopadoStories';
        config.streamCallback = {};
    })(service.config);

    (params => {
        params.pipelineId = '';
        params.sourceIds = '';
        params.destinationIds = '';
        params.filterJSON = '';
        params.flowStepToEnvJSON = '';
        params.allEnvironmentKeyJSON = '';
        params.allEnvironmentToStageJSON = '';
        params.allEnvironmentsMapJSON = '';
    })(service.params);

    var subscriptionRef;
    var hasPushTopic = false;
    var alreadyInitialized = false;
    var retryTimes = 20;
    var timeoutInterval;
    const cometd_statuses = {
        CONNECTED: 'connected', // State assumed when this BayeuxClient is connected to the Bayeux server
        CONNECTING: 'connecting', // State assumed when the connect is being sent for the first time
        DISCONNECTED: 'disconnected', // State assumed before the handshake and when the disconnect is completed
        DISCONNECTING: 'disconnecting', // State assumed when the disconnect is being sent
        HANDSHAKEN: 'handshaken', // State assumed when the handshake is received, but before connecting
        HANDSHAKING: 'handshaking', // State assumed when the handshake is being sent
        REHANDSHAKING: 'rehandshaking', // State assumed when a first handshake failed and the handshake is retried, or when the Bayeux server requests a re-handshake
        TERMINATING: 'terminating', // State assumed when the disconnect is received but terminal actions must be performed
        UNCONNECTED: 'unconnected' // State assumed after the handshake when the connection is broken
    };

    var _errorOnAccessingSobject = (e, sobjectType) => {
        console.error(e.faultstring);
        var msg = service.config.sobjectAccessError + (e.faultstring || e);
        msg = msg.replace('{SOBJECT}', sobjectType);
        return alert(msg);
    };

    var _getPushTopics = () => {
        var pushTopicName = service.config.pushTopicName;
        try {
            var result = sforce.connection.query(
                'SELECT Id, Name, Query, ApiVersion, IsActive, NotifyForFields, NotifyForOperations, ' +
                    'Description, NotifyForOperationCreate, NotifyForOperationUpdate, NotifyForOperationDelete, ' +
                    "NotifyForOperationUndelete FROM PushTopic WHERE Name = '" +
                    pushTopicName +
                    "'"
            );
        } catch (e) {
            return _errorOnAccessingSobject(e, 'PushTopic');
        }
        var records = result.getArray('records');
        if (records.length > 0) {
            for (var i = 0; i < records.length; i++) {
                if (records[i].Name == pushTopicName) {
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
        pt.NotifyForOperationCreate = false;
        pt.NotifyForOperationUpdate = true;
        pt.NotifyForOperationDelete = false;
        pt.NotifyForOperationUndelete = false;
        pt.NotifyForFields = 'Select';

        try {
            var result = sforce.connection.create([pt]);
        } catch (e) {
            return _errorOnAccessingSobject(e, 'PushTopic');
        }
        var pushTopicName = service.config.pushTopicName;
        if (result[0].getBoolean('success')) {
            console.info(pushTopicName + ' PushTopic not found and a new one is created');
        } else {
            console.error('Problem creating ' + pushTopicName + ' PushTopic: ', result[0]);
            return _errorOnAccessingSobject(result[0], 'PushTopic');
        }
    };

    service.initStreaming = () => {
        var query = 'SELECT Id, Name FROM PushTopic LIMIT 10';
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
        if (alreadyInitialized) {
            return;
        }
        alreadyInitialized = true;
        try {
            var query =
                'Select Id, ' +
                service.config.ns +
                'Promote_Change__c,' +
                service.config.ns +
                'Environment__c FROM ' +
                service.config.ns +
                'User_Story__c';
            _getPushTopics();
            if (!hasPushTopic) {
                _createPushTopic(service.config.pushTopicName, query);
            }
        } catch (e) {
            console.error(e);
            return _errorOnAccessingSobject(e, service.config.ns + 'Environment__c');
        }
        var status = $copado.cometd.getStatus();
        if (status !== cometd_statuses.CONNECTED) {
            var asyncConnect = new Promise(function(resolve, reject) {
                _connectToStreaming();
            });
        } else {
            _subscribeToStreaming();
        }
    };

    var _connectToStreaming = () => {
        var status = $copado.cometd.getStatus();
        if (status == cometd_statuses.DISCONNECTED || status == cometd_statuses.UNCONNECTED) {
            if (retryTimes == 0) {
                return;
            }
            retryTimes--;
            console.info('[' + service.config.pushTopicName + '] connecting to streaming... retry attempts left: ' + retryTimes);
        }
        setTimeout(function() {
            status = $copado.cometd.getStatus();
            console.log('[' + service.config.pushTopicName + '] status: ' + status);
            switch (status) {
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
        if (service.config.duration) {
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
        if (service.config.timeout == 0) {
            if (subscriptionRef) {
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

    var _readStream = message => {
        console.info('Push message: ', message);
        if (message.channel == '/topic/' + service.config.pushTopicName) {
            _recalculateUserStoryCounts();
        }
    };

    var _recalculateUserStoryCounts = () => {
        var core = service.config.ns ? window[service.config.ns.split('__')[0]] : window;
        core.PipelineManagerExtension.promotableStoriesForRemoteAction(
            service.params.pipelineId,
            service.params.sourceIds,
            service.params.filterJSON,
            function(userStoryCountMap, event) {
                if (event.status) {
                    _updateUserStoryCounts(userStoryCountMap, 'storyCountAhead');
                }
            },
            { escape: false }
        );
        core.PipelineManagerExtension.backPromotableStoriesForRemoteAction(
            service.params.pipelineId,
            service.params.sourceIds,
            service.params.destinationIds,
            service.params.filterJSON,
            service.params.flowStepToEnvJSON,
            service.params.allEnvironmentToStageJSON,
            service.params.allEnvironmentKeyJSON,
            service.params.allEnvironmentsMapJSON,
            function(userStoryCountMap, event) {
                if (event.status) {
                    _updateUserStoryCounts(userStoryCountMap, 'storyCountBehind');
                }
            },
            { escape: false }
        );
    };

    var _updateUserStoryCounts = (userStoryCountMap, storyCountType) => {
        var environmentBoxes = document.querySelectorAll("[id^='wrapper_'");
        if (environmentBoxes) {
            for (var i = 0; i < environmentBoxes.length; i++) {
                var environmentId = environmentBoxes[i].id.split('wrapper_')[1];
                var storyCount = environmentBoxes[i].querySelector('.' + storyCountType);
                if (storyCount && environmentId && environmentId in userStoryCountMap) {
                    var count = userStoryCountMap[environmentId];
                    if (count == 0) {
                        $copado(storyCount).addClass('disabled');
                    } else {
                        $copado(storyCount).removeClass('disabled');
                    }
                    var storyCountBtn = storyCount.querySelector('.' + storyCountType + 'Btn');
                    if (storyCountBtn) {
                        storyCountBtn.innerHTML = count;
                    }
                }
            }
        }
    };
})(ccdStoryStream);
