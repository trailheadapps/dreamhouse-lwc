public with sharing class NeighbourhoodInfoService {
    @InvocableMethod(
        label='Neighbourhood Info'
        description='Get neighbourhood info for a property'
    )
    public static List<Response> getNeighbourhoodInfo(
        List<Property__c> properties
    ) {
        // Validate the expected number of properties as an input
        Assert.areEqual(1, properties.size());
        Property__c property = properties[0];

        // Query Google Search API
        String path =
            'q=' +
            property.Address__c +
            property.City__c +
            property.Zip__c;

        HttpRequest apiRequest = new HttpRequest();
        apiRequest.setMethod('GET');
        apiRequest.setEndpoint('callout:Google_Search_API' + path);
        Http http = new Http();
        HttpResponse response = http.send(apiRequest);

        // Create expected response
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.Prompt = response.getBody();
        responses.add(res);
        return responses;
    }
    public class Response {
        @InvocableVariable(required=true)
        public String Prompt;
    }
}
