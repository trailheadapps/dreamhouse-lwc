trigger issueLinkToUserStory on QCloudsSaaS__QCIssue__c (before insert) {
    QCloudsSaaS__QCIssue__c issue = Trigger.new[0];
    String idUserStory = [SELECT User_Story__c FROM QCloudsSaaS__Scann__c WHERE Id = :issue.QCloudsSaaS__Scan__c].User_Story__c;   
            
        if ( ! String.isBlank(idUserStory)){
            List<QCloudsSaaS__QCIssue__c> isuelist = [SELECT Id, User_Story__c FROM QCloudsSaaS__QCIssue__c WHERE User_Story__c = :idUserStory AND QCloudsSaaS__Scan__c != :issue.QCloudsSaaS__Scan__c ];
            for(QCloudsSaaS__QCIssue__c isue : isuelist )
            {
                isue.User_Story__c = null;
            }
            if(isuelist.size() > 0)
            {
                update isuelist;
            }
        }
        
    for (QCloudsSaaS__QCIssue__c issue2 : Trigger.new) {
        issue2.User_Story__c = idUserStory;
    }

}