public with sharing class CT_LocationTracingController {
    
    /*
    * Retreives a list of 100 Location Tracing records
    * The list is sorted by Visit Date in descending order
    * @param String Location id
    * @return List<Location_Tracing__c>
    */
    public static List<Location_Tracing__c> getVisitors(String locationId){
        return [SELECT Id, Name, Person__c, Location__c, Visit_Date__c FROM Location_Tracing__c WHERE Location__c =:locationId ORDER BY Visit_Date__c DESC NULLS LAST LIMIT 100];
    }

    /*
    * Retreives a list of Location Tracing records where Person matches the passed set of id 
    * This list contains only those records where visit date < Last 10 days
    * @param Set<id>
    * @return List<Location_Tracing__c>
    */
    public static List<Location_Tracing__c> getLocationTracingsByPersonId(Set<Id> personIdSet){
        Map<String, Object> params = new Map<String, Object>{'personIdSet'=>personIdSet};
        String query = 'SELECT Id, Name, Person__c, Location__c, Visit_Date__c FROM Location_Tracing__c WHERE Person__c IN:personIdSet AND Visit_Date__c =LAST_n_DAYS:10';
        List<SObject> sObjectList = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        List<Location_Tracing__c> locationTracingList = new List<Location_Tracing__c>();
        if(sObjectList!=null  && sObjectList.size()>0){
            for(SObject sobj: sObjectList){
                locationTracingList.add((Location_Tracing__c)sobj);
            }
        }
        return locationTracingList;
    }

    /*
    * Retreives a list of Location Tracing records where location matches the passed set of id and Person health status is Green
    * This list contains only those records where visit date < Last 10 days
    * @param Set<id>
    * @return List<Location_Tracing__c>
    */
    public static List<Location_Tracing__c> getLocationTracingsByLocationId(Set<Id> locationIdSet){
        Map<String, Object> params = new Map<String, Object>{'locationIdSet'=>locationIdSet};
        String query = 'SELECT Id, Name, Person__c,Person__r.Health_Status__c, Location__c, Visit_Date__c FROM Location_Tracing__c WHERE Location__c IN:locationIdSet AND Person__r.Health_Status__c=\'Green\'  AND Visit_Date__c =LAST_n_DAYS:10';
        List<SObject> sObjectList = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        List<Location_Tracing__c> locationTracingList = new List<Location_Tracing__c>();
        if(sObjectList!=null  && sObjectList.size()>0){
            for(SObject sobj: sObjectList){
                locationTracingList.add((Location_Tracing__c)sobj);
            }
        }
        return locationTracingList;
    }

    /*
    * Accepts a list of location tracing records and find duplicates
    * @param List<Location_Tracing__c>
    * @return List<Location_Tracing__c>
    */
    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTracings){
        Set<Id> locationsSet = new Set<Id>();
        Set<Id> personsSet = new Set<Id>();
        for(Location_Tracing__c trace: newLocationTracings){
            locationsSet.add(trace.Location__c);
            personsSet.add(trace.Person__c);
        }

        System.debug('locationsSet: '+locationsSet);
        System.debug('personsSet: '+personsSet);

        List<Location_Tracing__c> existingTraceRecords = [SELECT Id, Location__c, Person__c FROM Location_Tracing__c WHERE Location__c IN:locationsSet AND Person__c IN: personsSet];

        Map<Id, Set<Id>> locationIdToPersonSetMap = new Map<Id, Set<Id>>();
        if(existingTraceRecords!=null && existingTraceRecords.size()>0){
            System.debug('Records Existing');
            for(Location_Tracing__c trace: existingTraceRecords){
                if(locationIdToPersonSetMap.containsKey(trace.Location__c)){
                    locationIdToPersonSetMap.get(trace.Location__c).add(trace.Location__c);
                }else{
                    locationIdToPersonSetMap.put(trace.Location__c, new Set<Id>{trace.Person__c});
                }
            }
        }

        System.debug('locationIdToPersonSetMap '+locationIdToPersonSetMap);
        
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
        for(Location_Tracing__c trace: newLocationTracings){
            if(locationIdToPersonSetMap.containsKey(trace.Location__c) && locationIdToPersonSetMap.get(trace.Location__c).contains(trace.Person__c)){
                System.debug('Found Duplicate');
                duplicates.add(trace);
            }
        }
        System.debug('duplicates '+duplicates);
        return duplicates;
    }

}