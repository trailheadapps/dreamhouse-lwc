@isTest
public class TestPropertyController {
    public static void createProperties(Integer amount) {
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 0; i < amount; i++) {
            properties.add(
                new Property__c(
                    Title__c = 'Name ' + i,
                    Price__c = 20000,
                    Beds__c = 3,
                    Baths__c = 3
                )
            );
        }
        insert properties;
    }
    static testMethod void testGetPropertyList() {
        TestPropertyController.createProperties(5);
        Test.startTest();
        Property__c[] properties = PropertyController.getPropertyList(
            '',
            999999,
            0,
            0
        );
        Test.stopTest();
        System.assertEquals(5, properties.size());
    }
    static testMethod void testGetPagedPropertyList() {
        TestPropertyController.createProperties(5);
        Test.startTest();
        PagedResult result = PropertyController.getPagedPropertyList(
            '',
            999999,
            0,
            0,
            10,
            1
        );
        Test.stopTest();
        System.assertEquals(5, result.records.size());
    }

    static testMethod void testGetPictures() {
        Property__c property = new Property__c(Name = 'Name');
        insert property;
        Test.startTest();
        List<ContentVersion> items = PropertyController.getPictures(
            property.Id
        );
        Test.stopTest();
        System.assertEquals(null, items);
    }
}
