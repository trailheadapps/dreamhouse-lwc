public with sharing class SampleDataController {
    @AuraEnabled
    public static void importSampleData() {
        try {
            delete [SELECT Id FROM Property__c];
            delete [SELECT Id FROM Broker__c];

            StaticResource brokersResource = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'sample_data_brokers'
                WITH SECURITY_ENFORCED
            ];
            String brokersJSON = brokersResource.body.toString();
            List<Broker__c> brokers = (List<Broker__c>) JSON.deserialize(
                brokersJSON,
                List<Broker__c>.class
            );
            insert brokers;

            StaticResource propertiesResource = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'sample_data_properties'
                WITH SECURITY_ENFORCED
            ];
            String propertiesJSON = propertiesResource.body.toString();
            List<Property__c> properties = (List<Property__c>) JSON.deserialize(
                propertiesJSON,
                List<Property__c>.class
            );
            insert properties;
        } catch (Exception e) {
            System.debug(e);
        }
    }
}
