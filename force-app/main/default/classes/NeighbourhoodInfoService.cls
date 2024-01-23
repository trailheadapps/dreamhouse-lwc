public with sharing class NeighbourhoodInfoService {
    @InvocableMethod(
        CapabilityType='PromptTemplateType://einstein_gpt__fieldCompletion'
    )
    public static List<Response> getNeighbourhoodInfo(List<Request> requests) {
        Request input = requests[0];
        Property__c property = input.RelatedEntity;

        property = [
            SELECT Location__Latitude__s, Location__Longitude__s
            FROM Property__c
            WHERE Id = :property.Id
        ];

        // Query Google Places API
        String body =
            '{' +
            '    "includedTypes": ["restaurant"],' +
            '    "maxResultCount": 10,' +
            '    "locationRestriction": {' +
            '        "circle": {' +
            '            "center": {' +
            '                "latitude": ' +
            property.Location__Latitude__s +
            ',' +
            '                "longitude": ' +
            property.Location__Longitude__s +
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

    public class Request {
        @InvocableVariable
        public Property__c RelatedEntity;
    }

    public class Response {
        @InvocableVariable(required=true)
        public String Prompt;
    }
}
