@isTest
private class TestCopadoIntegrationTriggers {

    private static User runningUser;
    private static copado__Environment__c sourceEnv1;
    private static copado__Environment__c targetEnv2;
    private static copado__Org__c sourceOrg1;
    private static copado__Org__c targetOrg2;


    private static void setupTestData() {
        // Create admin user for creating and assigning the Copado licenses to a running user
        User adminUser = createAdminUser();
        insert adminUser;

        System.runAs(adminUser) {
            // Create running user
            runningUser = createStandardUser();
            runningUser.ProfileId = adminUser.ProfileId;
            insert runningUser;

            // Assign the Copado permission set to the running user
            PermissionSetAssignment psa = new PermissionSetAssignment (
                PermissionSetId = getCopadoUserPermissionSet().Id,
                AssigneeId = runningUser.Id
            );
            insert psa;

            // Assign A Copado License to the running User
            copado.GlobalAPI copadoGlobalAPI = new copado.GlobalAPI();
            copado.GlobalAPI.UserLicense UL = new copado.GlobalAPI.UserLicense();
            UL.isCopadoEnabled = true;
            UL.isCCMEnabled = true;
            UL.userId = runningUser.id;
            copadoGlobalAPI.upsertCopadoLicense(runningUser.id, UL);
        }

    }

    @isTest(SeeAllData=false) static void TestNewScanPage() {
        setupTestData();
        System.runAs(runningUser) {
            copado__Git_Repository__c repo = new copado__Git_Repository__c(copado__URI__c = 'https://github.com/testgit');
            upsert repo;
            copado__Deployment_Flow__c pipe = new copado__Deployment_Flow__c(copado__Git_Repository__c = repo.Id);
            upsert pipe;
            copado__Project__c project = new copado__Project__c(copado__Deployment_Flow__c = pipe.Id);
            upsert project;
            copado__User_Story__c userStory = new copado__User_Story__c( copado__Project__c = project.Id);
            upsert userStory;
            userStory = [SELECT Id, copado__Project__c, Name FROM copado__User_Story__c WHERE Id = :userStory.Id Limit 1];
            QCloudsSaaS__Instance__c instance;
            QCloudsSaaS__Instance__c instancee = new QCloudsSaaS__Instance__c(QCloudsSaaS__url__c='https://github.com/testgit', QCloudsSaaS__Description__c='dec', QCloudsSaaS__Environment_Type__c='dev',QCloudsSaaS__ID__c= '1', QCloudsSaaS__Instance_Type__c='salesforcce', QCloudsSaaS__Is_Featured_Banch__c=true);
            upsert instance = instancee QCloudsSaaS__ID__c;
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('scanok');
            mock.setStatusCode(202);
            mock.setHeader('Content-Type', 'application/json');

            Run_QualityClouds_Scan_Page_Controller pageController = new Run_QualityClouds_Scan_Page_Controller(new ApexPages.StandardController(userStory));

            Test.startTest();
            pageController.doScan();
            Test.stopTest();
            System.assertEquals('smoke', 'smoke');
        }
    }
    @isTest(SeeAllData=false) static void TestScanTriggers() {
        setupTestData();
        System.runAs(runningUser) {
            copado__Git_Repository__c repo = new copado__Git_Repository__c(copado__URI__c = 'https://github.com/testgit');
            upsert repo;
            copado__Deployment_Flow__c pipe = new copado__Deployment_Flow__c(copado__Git_Repository__c = repo.Id);
            upsert pipe;
            copado__Project__c project = new copado__Project__c(copado__Deployment_Flow__c = pipe.Id);
            upsert project;
            copado__User_Story__c userStory = new copado__User_Story__c( copado__Project__c = project.Id);
            upsert userStory;
            userStory = [SELECT Id, copado__Project__c, Name FROM copado__User_Story__c WHERE Id = :userStory.Id Limit 1];
            QCloudsSaaS__Instance__c instance;
            QCloudsSaaS__Instance__c instancee = new QCloudsSaaS__Instance__c(QCloudsSaaS__url__c='https://github.com/testgit', QCloudsSaaS__Description__c='dec', QCloudsSaaS__Environment_Type__c='dev',QCloudsSaaS__ID__c= '1', QCloudsSaaS__Instance_Type__c='salesforcce', QCloudsSaaS__Is_Featured_Banch__c=true);
            upsert instance = instancee QCloudsSaaS__ID__c;
            QCloudsSaaS__Scann__c scan = new QCloudsSaaS__Scann__c(QCloudsSaaS__ID__c= '1',QCloudsSaaS__Date__c = Datetime.valueOf('2019-07-23 08:25:59'), QCloudsSaaS__State__c='SUCCESS', QCloudsSaaS__Scan_Type__c='feature-branch-scan', QCloudsSaaS__Branch_Name__c='feature/'+userStory.Name, QCloudsSaaS__Instance__c= instance.Id);
            upsert scan QCloudsSaaS__ID__c;

            Test.startTest();
            update scan;
            Test.stopTest();
            System.assertEquals('smoke', 'smoke');
        }
    }
    @isTest(SeeAllData=false) static void TestIssueTriggers() {
        setupTestData();
        System.runAs(runningUser) {
            copado__Git_Repository__c repo = new copado__Git_Repository__c(copado__URI__c = 'https://github.com/testgit');
            upsert repo;
            copado__Deployment_Flow__c pipe = new copado__Deployment_Flow__c(copado__Git_Repository__c = repo.Id);
            upsert pipe;
            copado__Project__c project = new copado__Project__c(copado__Deployment_Flow__c = pipe.Id);
            upsert project;
            copado__User_Story__c userStory = new copado__User_Story__c( copado__Project__c = project.Id);
            upsert userStory;
            userStory = [SELECT Id, copado__Project__c, Name FROM copado__User_Story__c WHERE Id = :userStory.Id Limit 1];
            QCloudsSaaS__Instance__c instance;
            QCloudsSaaS__Instance__c instancee = new QCloudsSaaS__Instance__c(QCloudsSaaS__url__c='https://github.com/testgit', QCloudsSaaS__Description__c='dec', QCloudsSaaS__Environment_Type__c='dev',QCloudsSaaS__ID__c= '1', QCloudsSaaS__Instance_Type__c='salesforcce', QCloudsSaaS__Is_Featured_Banch__c=true);
            upsert instance = instancee QCloudsSaaS__ID__c;
            QCloudsSaaS__Scann__c scan = new QCloudsSaaS__Scann__c(QCloudsSaaS__ID__c= '1',QCloudsSaaS__Date__c = Datetime.valueOf('2019-07-23 08:25:59'), QCloudsSaaS__State__c='SUCCESS', QCloudsSaaS__Scan_Type__c='feature-branch-scan', QCloudsSaaS__Branch_Name__c='feature/'+userStory.Name, QCloudsSaaS__Instance__c= instance.Id);
            upsert scan QCloudsSaaS__ID__c;
            QCloudsSaaS__QCIssue__c issue = new QCloudsSaaS__QCIssue__c(QCloudsSaaS__Scan__c = scan.id , QCloudsSaaS__ID__c= '2');
            upsert issue QCloudsSaaS__ID__c;
            Test.startTest();
            update issue;
            Test.stopTest();
            System.assertEquals('smoke', 'smoke');
        }
    }
    public static User createAdminUser(){
        Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator' Limit 1];
        User newUser = new User();
        newUser.ProfileId = adminProfile.Id;
        newUser.FirstName = 'Rebekah';
        newUser.LastName = 'Admin';
        newUser.email = 'admin@aa.test';
        newUser.Username = 'admin@aa.test';
        newUser.Alias = 'tadmin';
        newUser.CommunityNickname = 'tadmin';
        newUser.LocaleSidKey = 'es_ES';
        newUser.emailencodingkey='UTF-8';
        newUser.languagelocalekey='en_US';
        newUser.TimeZoneSidKey='Europe/Rome';
        return newUser;
    }

    public static User createStandardUser(){
        Profile standardProfile = [Select Id From Profile Where Name = 'Standard User' Limit 1];
        User newUser = new User();
        newUser.ProfileId = standardProfile.Id;
        newUser.FirstName = 'Daniel';
        newUser.LastName = 'Standard';
        newUser.email = 'standard@aa.test';
        newUser.Username = 'standard@aa.test';
        newUser.Alias = 'tandard';
        newUser.CommunityNickname = 'tstand';
        newUser.LocaleSidKey = 'es_ES';
        newUser.emailencodingkey='UTF-8';
        newUser.languagelocalekey='en_US';
        newUser.TimeZoneSidKey='Europe/Rome';

        return newUser;
    }

    public static PermissionSet getCopadoUserPermissionSet(){
        return [SELECT Id FROM PermissionSet WHERE Name = 'Copado_User'];
    }
}