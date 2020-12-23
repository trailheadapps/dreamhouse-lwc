public with sharing class GeocodingService {
    @InvocableMethod(label='Geocode address')
    public static List<Coordinates> geocodeAddresses(
        List<GeocodingAddress> addresses
    ) {
        List<Coordinates> computedCoordinates = new List<Coordinates>();

        String baseUrl = 'https://nominatim.openstreetmap.org/search?format=json';

        for (GeocodingAddress address : addresses) {
            String url = baseUrl;
            url += (String.isNotBlank(address.street))
                ? '&street=' + address.street
                : '';
            url += (String.isNotBlank(address.city))
                ? '&city=' + address.city
                : '';
            url += (String.isNotBlank(address.state))
                ? '&state=' + address.state
                : '';
            url += (String.isNotBlank(address.country))
                ? '&country=' + address.country
                : '';
            url += (String.isNotBlank(address.postalcode))
                ? '&postalcode=' + address.postalcode
                : '';

            Boolean found = false;
            if (url != baseUrl) {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(url);
                request.setMethod('GET');
                request.setHeader(
                    'http-referer',
                    'https://github.com/trailheadapps/dreamhouse-lwc'
                );
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    List<Coordinates> deserializedCoords = (List<Coordinates>) JSON.deserialize(
                        response.getBody(),
                        List<Coordinates>.class
                    );
                    computedCoordinates.add(deserializedCoords[0]);
                    found = true;
                }
            }
            // Add empty coordinates if not found
            if (!found) {
                computedCoordinates.add(new Coordinates());
            }
        }
        return computedCoordinates;
    }

    public with sharing class GeocodingAddress {
        @InvocableVariable
        public String street;
        @InvocableVariable
        public String city;
        @InvocableVariable
        public String state;
        @InvocableVariable
        public String country;
        @InvocableVariable
        public String postalcode;
    }

    public class Coordinates {
        @InvocableVariable
        public Decimal lat;
        @InvocableVariable
        public Decimal lon;
    }
}
