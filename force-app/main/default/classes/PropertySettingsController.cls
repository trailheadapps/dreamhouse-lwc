public with sharing class PropertySettingsController {
    @AuraEnabled(cacheable=true)
    public static String getDefaultView() {
        String defaultComponent = 'propertyListDataTable';
        try {
            List<DreamHouseAppSetting__mdt> dreamhouseAppSettings = [
                SELECT Id, Component__c
                FROM DreamHouseAppSetting__mdt
                WHERE DeveloperName = 'Property_Explorer'
            ];
            if (dreamhouseAppSettings.size() > 0) {
                defaultComponent = dreamhouseAppSettings[0].Component__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return defaultComponent;
    }
}