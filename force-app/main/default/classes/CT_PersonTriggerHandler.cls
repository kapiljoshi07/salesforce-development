public with sharing class CT_PersonTriggerHandler {
    
    /*
    * Handler Method to execute before committing records to DB
    * New person records should have health status = 'Green'
    * New person records should have a token
    * @params: Trigger.new
    * @return: none
    */
    public static void beforeInsert(List<Person__c> newPersons){
        for(Person__c person: newPersons){
            person.Health_Status__c = 'Green';
            person.Token__c = CT_PersonController.getToken(person.Mobile__c);
        }
    }

    /*
    * Handler Method to execute before updating records to DB
    * @params: Trigger.new, Trigger.oldMap
    * @return: none
    */
    public static void beforeUpdate(List<Person__c> newPersons, Map<Id, Person__c> oldPersonMap){
        CT_PersonController.updateStatusDateOnStatusChange(newPersons, oldPersonMap);
    }

    /*
    * Handler Method to execute after updating records
    * @params: Trigger.new, Trigger.oldMap
    * @return: none
    */
    public static void afterUpdate(List<Person__c> newPersons, Map<Id, Person__c> oldPersonMap){
        CT_PersonController.updateLocationScoreAndStatus(newPersons, oldPersonMap);
    }
}