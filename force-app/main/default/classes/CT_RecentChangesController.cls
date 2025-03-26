public with sharing class CT_RecentChangesController {
    
    @AuraEnabled
    public static List<Person__c> getPersonRecentChanges(){
        try {
            System.debug('Inside getPersonRecentChanges');
            return CT_PersonController.getRecentHealthChanges();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Location__c> getLocationRecentChanges(){
        try {
            System.debug('Inside getPersonRecentChanges');
            return CT_LocationController.getRecentStatusChanges();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Person__c> getPersons(String searchQuery){
        try {
            return CT_PersonController.searchPeople(searchQuery);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Location__c> getLocations(String searchQuery){
        try {
            return CT_LocationController.searchLocations(searchQuery);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}