public with sharing class CT_PeopleTracingTriggerHandler {
    
    /**
     * Handler methods to perform logic before inserting the records
     * @params: List<People_Tracing__c>
     * @return: none
     */
    public static void beforeInsert(List<People_Tracing__c> newPeopleTraces){
        List<People_Tracing__c> duplicates = CT_PeopleTracingController.checkDuplicates(newPeopleTraces);
        if(duplicates.size()>0 && duplicates!=null){
            for(People_Tracing__c trace: duplicates){
                trace.addError('Duplicate record exists for the two people');
            }
        }
    }

    /**
     * Handler methods to perform logic after inserting the records
     * @params: List<People_Tracing__c>
     * @return: none
     */
    public static void afterInsert(List<People_Tracing__c> newPeopleTraces){

    }
}