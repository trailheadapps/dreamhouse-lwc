public with sharing class PropertyCampaignPriceUpdateQueueable implements Queueable {
    private List<Property__c> properties = new List<Property__c>();

    public PropertyCampaignPriceUpdateQueueable(List<Property__c> properties) {
        this.properties = properties;
    }

    public void execute(QueueableContext context) {
        System.debug('do price update queueable');
    }
}
