public with sharing class CT_PeopleTracingController {
    
    public static List<People_Tracing__c> getTraces(String recordId){
        return [SELECT Id, Contact_Type__c, Contact_Date__c, Person_1__c, Person_2__c FROM People_Tracing__c WHERE (Person_1__c=:recordId OR Person_2__c=:recordId) ORDER BY Contact_Date__c DESC NULLS LAST];
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){
        Set<Id> personSet = new Set<Id>();
        for(People_Tracing__c trace: newPeopleTraces){
            personSet.add(trace.Person_1__c);
            personSet.add(trace.Person_2__c);
        }

        List<People_Tracing__c> existingRecords = [SELECT Id, Contact_Type__c, Contact_Date__c, Person_1__c, Person_2__c FROM People_Tracing__c WHERE Person_1__c IN:personSet OR Person_2__c IN:personSet];

        Map<Id, Set<Id>> personIdToPersonSetMap = new Map<Id, Set<Id>>();

        if(existingRecords!=null && existingRecords.size()>0){
            for(People_Tracing__c trace: existingRecords){
                if(personIdToPersonSetMap.containsKey(trace.Person_1__c)){
                    personIdToPersonSetMap.get(trace.Person_1__c).add(trace.Person_2__c);
                }else{
                    personIdToPersonSetMap.put(trace.Person_1__c, new Set<Id>{trace.Person_2__c});
                }
                if(personIdToPersonSetMap.containsKey(trace.Person_2__c)){
                    personIdToPersonSetMap.get(trace.Person_2__c).add(trace.Person_1__c);
                }else{
                    personIdToPersonSetMap.put(trace.Person_2__c, new Set<Id>{trace.Person_1__c});
                }
            }
        }

        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();
        for(People_Tracing__c trace: newPeopleTraces){
            if(
                (personIdToPersonSetMap.containsKey(trace.Person_1__c) && personIdToPersonSetMap.get(trace.Person_1__c).contains(trace.Person_2__c)) || 
                (personIdToPersonSetMap.containsKey(trace.Person_2__c) && personIdToPersonSetMap.get(trace.Person_2__c).contains(trace.Person_1__c))
            ){
                duplicates.add(trace);
            }
        }
        return duplicates;
    }

}