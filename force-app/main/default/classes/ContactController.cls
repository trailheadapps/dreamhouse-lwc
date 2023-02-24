public class ContactController {
    @AuraEnabled
    public static List<contact> getContacts(string searchKey){
        string key = '%'+ searchKey +'%' ;
        return [SELECT Id,Name FROM Contact WHERE Name LIKE :key ORDER BY Name LIMIT 50];
    }

}