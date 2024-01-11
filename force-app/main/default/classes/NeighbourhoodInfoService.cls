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
        String body =
            '{' +
            '    "includedTypes": ["restaurant"],' +
            '    "maxResultCount": 10,' +
            '    "locationRestriction": {' +
            '        "circle": {' +
            '            "center": {' +
            '                "latitude": 37.7937,' +
            '                "longitude": -122.3965' +
            '             },' +
            '        "radius": 500.0' +
            '        }' +
            '    }' +
            '}';

        HttpRequest apiRequest = new HttpRequest();
        apiRequest.setMethod('POST');
        apiRequest.setEndpoint('callout:Google_Search_API');
        apiRequest.setBody(body);

        Http http = new Http();
        HttpResponse response = http.send(apiRequest);
        System.debug(response.getBody());

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
