({
    /*
    When a new Property is selected (in another component), load the corresponding
    property record.
    */
    handlePubsubReady: function(component) {
        var pubsub = component.find('pubsub');
        var callback = $A.getCallback(function(propertyId) {
            component.set('v.recordId', propertyId);
            var service = component.find('service');
            service.reloadRecord();
        });
        pubsub.registerListener('dreamhouse__propertySelected', callback);
    },

    handleDestroy: function(component) {
        var pubsub = component.find('pubsub');
        pubsub.unregisterAllListeners();
    },

    handleEditRecord: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var editRecordEvent = $A.get('e.force:editRecord');
        editRecordEvent.setParams({
            recordId: recordId
        });
        editRecordEvent.fireEvent();
    },

    handleNavigateToBrokerRecord: function(component, event) {
        var navigateEvent = $A.get('e.force:navigateToSObject');
        navigateEvent.setParams({
            recordId: component.get('v.property').Broker__r.Id,
            slideDevName: 'detail'
        });
        navigateEvent.fireEvent();
    }
});
