public with sharing class ContactPropertyInterestService {
    @InvocableMethod(
        CapabilityType='PromptTemplateType://einstein_gpt__salesEmail'
    )
    public static List<Response> getContactsPropertyInterest(
        List<Request> requests
    ) {
        Request input = requests[0];
        Contact contact = input.Recipient;
        Property__c property = input.RelatedObject;

        // Query property interests for this contact
        List<Property_Interest__c> propertyInterests = [
            SELECT
                Property__r.Name,
                Property__r.Beds__c,
                Property__r.Baths__c,
                Property__r.Price__c
            FROM Property_Interest__c
            WHERE Contact__c = :contact.Id AND Property__c != :property.Id
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

    // All inputs will be passed from the template into the apex class
    public class Request {
        @InvocableVariable
        public User Sender;
        @InvocableVariable
        public Contact Recipient;
        @InvocableVariable
        public Property__c RelatedObject;
    }

    public class Response {
        @InvocableVariable(required=true)
        public String Prompt;
    }
}
