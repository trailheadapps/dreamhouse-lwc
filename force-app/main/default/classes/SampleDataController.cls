public with sharing class SampleDataController {

    @AuraEnabled
    public static void importSampleData() {
        try {
            delete [SELECT Id from Property__c];
            delete [SELECT Id from Broker__c];

            StaticResource brokersResource = [SELECT Id, Body from StaticResource WHERE Name = 'sample_data_brokers'];
            String brokersJSON = brokersResource.body.toString();
            List<Broker__c> brokers = (List<Broker__c>) JSON.deserialize(brokersJSON, List<Broker__c>.class);
            insert brokers;

            StaticResource propertiesResource = [SELECT Id, Body from StaticResource WHERE Name = 'sample_data_properties'];
            String propertiesJSON = propertiesResource.body.toString();
            List<Property__c> properties = (List<Property__c>) JSON.deserialize(propertiesJSON, List<Property__c>.class);
            insert properties;        

        } catch (Exception e) {
            System.debug(e);
        }
    }

}