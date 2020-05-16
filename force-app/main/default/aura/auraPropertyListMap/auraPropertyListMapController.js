({
    handleInit: function (component, event, helper) {
        helper.getProperties(component);
    },

    handlePubsubReady: function (component, event, helper) {
        var pubsub = component.find('pubsub');
        var callback = $A.getCallback(function (filters) {
            component.set('v.searchKey', filters.searchKey);
            component.set('v.maxPrice', filters.maxPrice);
            component.set('v.minBedrooms', filters.minBedrooms);
            component.set('v.minBathrooms', filters.minBathrooms);
            helper.getProperties(component);
        });
        pubsub.registerListener('dreamhouse__filterChange', callback);
    },

    handleJSLoaded: function (component) {
        component.set('v.jsLoaded', true);
    }
});
