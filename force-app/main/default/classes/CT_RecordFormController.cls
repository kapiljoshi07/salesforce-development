public with sharing class CT_RecordFormController {
    
    @AuraEnabled
    public static string updateStatusToRed(String personId){
        try {
            System.debug('Person Id: '+personId);
            Person__c person = new Person__c(Id=personId, Health_Status__c = 'Red');
            update person;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}