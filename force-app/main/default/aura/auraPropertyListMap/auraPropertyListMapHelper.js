({
    getProperties: function getProperties(component) {
        var action = component.get('c.getPropertyList');

        action.setParams({
            searchKey: component.get('v.searchKey'),
            maxPrice: component.get('v.maxPrice'),
            minBedrooms: component.get('v.minBedrooms'),
            minBathrooms: component.get('v.minBathrooms')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var properties = response.getReturnValue();

                component.set('v.properties', properties);
            } else {
                var toastEvent = $A.get('e.force:showToast');

                toastEvent.setParams({
                    title: 'Error',
                    message: 'Error retrieving properties.',
                    type: 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
});
