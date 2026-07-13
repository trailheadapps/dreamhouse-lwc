@isTest
private class TestSampleDataController {
    @isTest
    static void importSampleData() {
        Test.startTest();
        SampleDataController.importSampleData();
        Test.stopTest();

        Integer propertyNumber = [SELECT COUNT() FROM Property__c];
        Integer brokerNumber = [SELECT COUNT() FROM Broker__c];
        Integer contactNumber = [SELECT COUNT() FROM Contact];

        Assert.isTrue(propertyNumber > 0, 'Expected properties were created.');
        Assert.isTrue(brokerNumber > 0, 'Expected brokers were created.');
        Assert.isTrue(contactNumber > 0, 'Expected contacts were created.');

        List<Broker__c> brokers = [SELECT Realtor_User__c FROM Broker__c];
        for (Broker__c broker : brokers) {
            Assert.areEqual(
                UserInfo.getUserId(),
                broker.Realtor_User__c,
                'Expected each broker to be stamped with the current user as realtor.'
            );
        }
    }
}
