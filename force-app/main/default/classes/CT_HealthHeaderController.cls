public with sharing class CT_HealthHeaderController {
    
    @AuraEnabled
    public static Map<String, Integer> getPersonHealthStatusCount(){
        try {
            return CT_PersonController.getHealthStatusCount();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Integer> getLocationHealthStatusCount(){
        try {
            return CT_LocationController.getStatusCount();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}