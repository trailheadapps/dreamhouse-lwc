public with sharing class ContactPropertyInterestService {
    @InvocableMethod(
        label='Property Interest Info'
        description='Get information of the properties in which the contact is interested'
    )
    public static List<Response> getContactsPropertyInterest(
        List<Contact> contacts
    ) {
        // Validate the expected number of properties as an input
        Assert.areEqual(1, contacts.size());
        Contact contact = contacts[0];

        // Query property interests for this contact
        List<Property_Interest__c> propertyInterests = [
            SELECT
                Property__r.Name,
                Property__r.Beds__c,
                Property__r.Baths__c,
                Property__r.Price__c
            FROM Property_Interest__c
            WHERE Contact__c = :contact.Id
            WITH USER_MODE
        ];

        String responseData = '';
        if (propertyInterests.isEmpty()) {
            responseData = 'The prospect didn\'t demostrate interest in any other property.';
        } else {
            for (Property_Interest__c propertyInterest : propertyInterests) {
                responseData += 'Property Details: ';
                responseData += 'Name: ' + propertyInterest.Property__r.Name;
                responseData += ', ';
                responseData +=
                    'Bedrooms: ' + propertyInterest.Property__r.Beds__c;
                responseData += ', ';
                responseData +=
                    'Bathrooms ' + propertyInterest.Property__r.Baths__c;
                responseData += ', ';
                responseData +=
                    'Price: ' + propertyInterest.Property__r.Price__c;
                responseData += '.';
            }
        }

        // Create expected response
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.Prompt = responseData;
        responses.add(res);
        return responses;
    }
    public class Response {
        @InvocableVariable(required=true)
        public String Prompt;
    }
}
