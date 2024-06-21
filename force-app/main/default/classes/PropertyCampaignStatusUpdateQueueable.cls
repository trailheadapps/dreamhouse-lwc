public with sharing class PropertyCampaignStatusUpdateQueueable implements Queueable {
    private List<Property__c> properties = new List<Property__c>();

    public PropertyCampaignStatusUpdateQueueable(List<Property__c> properties) {
        this.properties = properties;
    }

    public void execute(QueueableContext context) {
        System.debug('do status update queueable');
    }
}
