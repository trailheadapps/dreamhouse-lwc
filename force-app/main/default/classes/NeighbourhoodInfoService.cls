public with sharing class NeighbourhoodInfoService {
    @InvocableMethod(
        label='Neighbourhood Info'
        description='Get neighbourhood info for a property'
    )
    public static List<Response> getNeighbourhoodInfo(
        List<Property__c> properties
    ) {
        System.debug(properties);
        // Validate the expected number of properties as an input
        Assert.areEqual(1, properties.size());
        Property__c property = properties[0];

        // Query Google Places API
        String body =
            '{' +
            '    "includedTypes": ["restaurant"],' +
            '    "maxResultCount": 10,' +
            '    "locationRestriction": {' +
            '        "circle": {' +
            '            "center": {' +
            '                "latitude": ' +
            Location__Latitude__s +
            ',' +
            '                "longitude": ' +
            Location__Longitude__s +
            ',' +
            '             },' +
            '        "radius": 500.0' +
            '        }' +
            '    }' +
            '}';

        HttpRequest apiRequest = new HttpRequest();
        apiRequest.setMethod('POST');
        apiRequest.setEndpoint('callout:Google_Places_API');
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
