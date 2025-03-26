public with sharing class CT_UpdateLocationStatusBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<String> acceptableHealthStatus = new List<String>{'Red','Yellow','Orange'};
        Date fourteenDaysAgo = System.now().date().addDays(-14);
        String query = 'SELECT Id, Status__c, Status_Update_Date__c FROM Location__c WHERE Health_Status__c IN:acceptableHealthStatus AND Status_Update_Date__c =:fourteenDaysAgo';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Location__c> scope){
        for(Location__c loc: scope){
            loc.Status__c = 'Green';
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC){
        System.debug('Batch Executed');
    }
}