public with sharing class Run_QualityClouds_Scan_Page_Controller {
    public final SObject parent{get;set;}
    public String projectId ;
    public String pipeId ;
    public String repoID ;
    public String repoURL{get;set;}

    public String message{get;set;}

    public QCloudsSaaS__Instance__c instance;

    public Run_QualityClouds_Scan_Page_Controller(ApexPages.StandardController controller) {

        parent = controller.getRecord();

    }

    public void doScan(){

        repoURL = [SELECT copado__Project__r.copado__Deployment_Flow__r.copado__Git_Repository__r.copado__URI__c 
                    FROM copado__User_Story__c 
                    WHERE Id = :parent.id].copado__Project__r.copado__Deployment_Flow__r.copado__Git_Repository__r.copado__URI__c;

        repoURL = '%' + repoURL.substringAfterLast('/');

        instance = [SELECT QCloudsSaaS__url__c, 
                            QCloudsSaaS__Description__c, 
                            QCloudsSaaS__ID__c, 
                            QCloudsSaaS__Environment_Type__c, 
                            QCloudsSaaS__Instance_Type__c, 
                            QCloudsSaaS__Is_Featured_Banch__c, 
                            Id 
                        FROM QCloudsSaaS__Instance__c 
                        WHERE QCloudsSaaS__Is_Featured_Banch__c = true
                        AND QCloudsSaaS__url__c 
                        LIKE :repoURL 
                        ORDER BY CreatedDate DESC LIMIT 1];

        if(instance != null){
            QCloudsSaaS.globalCallsToQC globalCallsToQCObj = new QCloudsSaaS.globalCallsToQC();
            if(!Test.isRunningTest()) boolean succsess = globalCallsToQCObj.execute_scann(instance, 'feature/' + [SELECT Name FROM copado__User_Story__c WHERE Id = :parent.id].Name);
            message = 'Quality Clouds scan successfully launched';
        } else {
            message = 'No matching Quality Clouds instance was found for this Copado Repository. Please make sure that the Quality Clouds instances have been imported';
        }
    }

}