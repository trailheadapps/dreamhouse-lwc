public with sharing class PropertyCampaignStatusUpdateQueueable implements Queueable {
    /*
As property status updates, move campaign into proper status. 

States as follows: 
Property                    Campaign
  Contracted                Planned (Inactive)
  Pre Market                Planned (Inactive)
  Available                 In Progress (Active)
  Under Agreement           In Progress (Inactive)
  Closed                    Completed

*/

    private List<Property__c> properties = new List<Property__c>();

    private static final Map<String, String> STATUS_MAP = new Map<String, String>{
        'Contracted' => 'Planned',
        'Pre Market' => 'Planned',
        'Available' => 'In Progress',
        'Under Agreement' => 'In Progress',
        'Closed' => 'Completed'
    };

    private static final Map<String, Boolean> AVAILABLE_MAP = new Map<String, Boolean>{
        'Contracted' => false,
        'Pre Market' => false,
        'Available' => true,
        'Under Agreement' => false,
        'Closed' => false
    };

    public PropertyCampaignStatusUpdateQueueable(List<Property__c> properties) {
        this.properties = properties;
    }

    public void execute(QueueableContext context) {
        Map<Id, Property__c> propMap = new Map<Id, Property__c>(properties);

        List<Campaign> campaigns = [
            SELECT Id, Status, IsActive, Property__c
            FROM Campaign
            WHERE Property__c IN :propMap.keyset()
        ];
        for (Campaign campgn : campaigns) {
            String propStatus = propMap.get(campgn.Property__c).Status__c;
            campgn.Status = STATUS_MAP.get(propStatus);
            campgn.IsActive = AVAILABLE_MAP.get(propStatus);
        }

        Database.update(campaigns);
    }
}
