({
    handleInit: function (component, event, helper) {
        helper.getProperties(component);
    },

    handleFiltersChange: function (component, message, helper) {
        if (message !== null) {
            component.set('v.searchKey', message.getParam('searchKey').value);
            component.set('v.maxPrice', message.getParam('maxPrice').value);
            component.set(
                'v.minBedrooms',
                message.getParam('minBedrooms').value
            );
            component.set(
                'v.minBathrooms',
                message.getParam('minBathrooms').value
            );
            helper.getProperties(component);
        }
    },

    handleJSLoaded: function (component) {
        component.set('v.jsLoaded', true);
    }
});
