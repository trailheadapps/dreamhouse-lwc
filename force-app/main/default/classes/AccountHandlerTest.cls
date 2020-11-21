@isTest
public class AccountHandlerTest {
    @isTest Public static void TestInsert(){
        Account tAcc=new Account(name='Test Account');
        
        test.startTest();
        Insert tAcc;
        test.stopTest();
        
        Account insertedAcc = [SELECT Id, Name, Description FROM Account Where Id=:tAcc.Id];
        system.assertEquals('Test Account', insertedAcc.Name);
        system.assertEquals('New Description from Trigger', insertedAcc.description);
        
        task tAccTask = [SELECT Id, subject FROM Task WHERE whatid=:tAcc.id];
        system.assertEquals('Task for a new Account', tAccTask.subject);
    }
}