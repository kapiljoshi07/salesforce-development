public with sharing class CT_LocationTracingTriggerHandler {
    
    /**
     * Handler methods to perform logic before inserting the records
     * @params: List<Location_Tracing__c>
     * @return: none
     */
    public static void beforeInsert(List<Location_Tracing__c> newLocationTraces){
        List<Location_Tracing__c> duplicates = CT_LocationTracingController.checkDuplicates(newLocationTraces);
        if(duplicates!=null && duplicates.size()>0){
            for(Location_Tracing__c trace:duplicates){
                trace.addError('Duplicate record exists of the person and location for last 10 days');
            }
        }
    }
}