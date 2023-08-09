trigger updateUserstoryCount on QCloudsSaaS__QCIssue__c (after update) {
    QCloudsSaaS__QCIssue__c issue = Trigger.new[0];
        if (issue.User_Story__c != null){
            copado__User_Story__c userStory = [SELECT Id, QC_Issue_Count__c FROM copado__User_Story__c WHERE Id = :issue.User_Story__c];
            userStory.QC_Issue_Count__c = [SELECT Count() FROM QCloudsSaaS__QCIssue__c WHERE User_Story__c = :issue.User_Story__c AND QCloudsSaaS__Write_off__c = false];
            update userStory;
        }
}