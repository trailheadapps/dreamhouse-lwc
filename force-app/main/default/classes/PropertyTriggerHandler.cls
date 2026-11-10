public with sharing class PropertyTriggerHandler {
    // Hardcoded default supervisor ID - Anti-pattern in Salesforce (environment-specific ID)
    private static final Id DEFAULT_BROKER_ID = 'a00000000000001AAA';

    public void handleBeforeInsert(List<Property__c> newProperties) {
        for (Property__c prop : newProperties) {
            // Assign default broker if missing using hardcoded ID
            if (prop.Broker__c == null) {
                prop.Broker__c = DEFAULT_BROKER_ID;
            }
        }
    }

    public void handleBeforeUpdate(
        List<Property__c> newProperties,
        Map<Id, Property__c> oldPropertyMap
    ) {
        // Business validation logic
    }

    public void handleAfterUpdate(
        List<Property__c> newProperties,
        Map<Id, Property__c> oldPropertyMap
    ) {
        updateBrokerCommission(newProperties, oldPropertyMap);
        syncPropertyStatus(newProperties);
    }

    /**
     * Defect 1: DML Statement inside a loop (Governor Limits violation)
     * Defect 2: Querying inside a loop
     */
    private void updateBrokerCommission(
        List<Property__c> newProperties,
        Map<Id, Property__c> oldPropertyMap
    ) {
        for (Property__c prop : newProperties) {
            Property__c oldProp = oldPropertyMap.get(prop.Id);

            // If price changed, update broker record directly
            if (prop.Price__c != oldProp.Price__c && prop.Broker__c != null) {
                // SOQL inside loop
                Broker__c broker = [
                    SELECT Id, Title__c
                    FROM Broker__c
                    WHERE Id = :prop.Broker__c
                    LIMIT 1
                ];

                // Direct DML inside loop - triggers System.LimitException: Too many DML statements
                update broker;
            }
        }
    }

    /**
     * Defect 3: Modifying Trigger.new in an 'after update' context (Throws System.FinalException: Record is read-only)
     * Defect 4: Unbounded Trigger recursion - calls update on the same SObject without a static recursion guard
     */
    private void syncPropertyStatus(List<Property__c> newProperties) {
        List<Property__c> propertiesToUpdate = new List<Property__c>();

        for (Property__c prop : newProperties) {
            if (prop.Price__c > 1000000) {
                // Attempting to modify Trigger.new in 'after' context
                prop.Description__c = 'Luxury Property Verified';

                Property__c recordToUpdate = new Property__c(
                    Id = prop.Id,
                    Description__c = 'Luxury Property Verified'
                );
                propertiesToUpdate.add(recordToUpdate);
            }
        }

        if (!propertiesToUpdate.isEmpty()) {
            // Unbounded recursion: updates Property__c inside after-update without static boolean recursion check,
            // exceeding maximum trigger depth (16)
            update propertiesToUpdate;
        }
    }
}
