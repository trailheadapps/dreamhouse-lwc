public with sharing class ContactInterestSummary {
    @InvocableMethod(
        CapabilityType='PromptTemplateType://einstein_gpt__fieldCompletion'
    )
    public static List<Response> getContactsPropertyInterest(
        List<Request> requests
    ) {
        Request input = requests[0];
        Contact contact = input.RelatedEntity;

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

        // Create expected response
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.Prompt = PropertyInterestService.formatPropertiesInterest(
            propertyInterests
        );
        responses.add(res);
        return responses;
    }

    // All inputs will be passed from the template into the apex class
    public class Request {
        @InvocableVariable
        public Contact RelatedEntity;
    }

    public class Response {
        @InvocableVariable(required=true)
        public String Prompt;
    }
}
