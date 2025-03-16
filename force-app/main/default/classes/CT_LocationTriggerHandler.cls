public with sharing class CT_LocationTriggerHandler {
    
    /*
    * Handler Method to execute before committing records to DB
    * New location records should have status = 'Green'
    * @params: Trigger.new
    * @return: none
    */
    public static void beforeInsert(List<Location__c> newLocations){
        for(Location__c loc: newLocations){
            loc.Status__c = 'Green';
        }
    }

    /*
    * Handler Method to execute before updating records to DB
    * @params: Trigger.new, Trigger.oldMap
    * @return: none
    */
    public static void beforeUpdate(List<Location__c> newLocations, Map<Id, Location__c> oldLocationMap){
        CT_LocationController.updateStatusDateOnStatusChange(newLocations, oldLocationMap);
    }

    public static void afterUpdate(List<Location__c> newLocations, Map<Id, Location__c> oldLocationMap){
        CT_LocationController.updatePersonStatusForRedLocations(newLocations, oldLocationMap);
    }
}