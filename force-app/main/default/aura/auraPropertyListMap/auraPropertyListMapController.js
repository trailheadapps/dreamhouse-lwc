({
    handleInit: function (component, event, helper) {
        helper.getProperties(component);
    },

    handleFiltersChange: function (component, message, helper) {
        if (message !== null) {
            component.set('v.searchKey', message.getParam('searchKey'));
            component.set('v.maxPrice', message.getParam('maxPrice'));
            component.set('v.minBedrooms', message.getParam('minBedrooms'));
            component.set('v.minBathrooms', message.getParam('minBathrooms'));
            helper.getProperties(component);
        }
    },

    handleJSLoaded: function (component) {
        component.set('v.jsLoaded', true);
    }
});
