public with sharing class PropertyInterestService {
    public static String formatPropertiesInterest(
        List<Property_Interest__c> propertyInterests
    ) {
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
        return responseData;
    }
}
