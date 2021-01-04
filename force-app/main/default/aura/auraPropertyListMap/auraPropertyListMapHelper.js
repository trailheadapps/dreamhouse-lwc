({
    getProperties: function getProperties(component) {
        var action = component.get('c.getPagedPropertyList');

        action.setParams({
            searchKey: component.get('v.searchKey'),
            maxPrice: component.get('v.maxPrice'),
            minBedrooms: component.get('v.minBedrooms'),
            minBathrooms: component.get('v.minBathrooms'),
            pageSize: 100,
            pageNumber: 1
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var pagedResults = response.getReturnValue();

                component.set('v.properties', pagedResults.records);
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
