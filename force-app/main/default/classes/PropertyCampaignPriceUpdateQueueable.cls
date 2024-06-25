public with sharing class PropertyCampaignPriceUpdateQueueable implements Queueable {
    private List<Property__c> properties = new List<Property__c>();

    public PropertyCampaignPriceUpdateQueueable(List<Property__c> properties) {
        this.properties = properties;
    }

    public void execute(QueueableContext context) {
        Map<Id, Property__c> propMap = new Map<Id, Property__c>(properties);

        List<Campaign> campaigns = [
            SELECT Id, ExpectedRevenue, Property__c
            FROM Campaign
            WHERE Property__c IN :propMap.keyset()
        ];
        for (Campaign campgn : campaigns) {
            campgn.ExpectedRevenue = propMap.get(campgn.Property__c).Price__c;
        }

        Database.update(campaigns);
    }
}
