public with sharing class CT_LocationController {

    public static void updateStatusDateOnStatusChange(List<Location__c> newLocations, Map<Id,Location__c> oldLocationMap){
        for(Location__c loc: newLocations){
            if(loc.Status__c != oldLocationMap.get(loc.Id).Status__c){
                loc.Status_Update_Date__c = System.now().date();
            }
        }
    }
    
    /*
    * Retreives a list of 100 Location records
    * The list is sorted by Status Update Date in descending order
    * @param null
    * @return List<Location__c>
    */
    public static List<Location__c> getRecentStatusChanges(){
        return [SELECT Id, Name, Status__c, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c FROM Location__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /*
    * Retreives a list Location records whose Name/Pincode/Address matches the search query
    * The list is sorted by Status Update Date in descending order
    * @param String search query
    * @return Location__c
    */
    public static List<Location__c> searchLocations(String searchQuery){
        Map<String, Object> params = new Map<String, Object>{'searchString'=>'%'+searchQuery+'%'};
        String query = 'SELECT Id, Name, Status__c, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c FROM Location__c WHERE (Pincode__c LIKE:searchString OR Name LIKE:searchString OR Address__c LIKE:searchString) ORDER BY Status_Update_Date__c DESC NULLS LAST';
        List<SObject> sObjectList = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        List<Location__c> locationsList = new List<Location__c>();
        if(sObjectList.size()>0 && sObjectList!=null){
            for(SObject sobj: sObjectList){
                locationsList.add((Location__c)sobj);
            }
        }
        return locationsList;
    }

    /*
    * Retreives a Location record which matches id passed as the search query
    * @param String search query
    * @return Location__c
    */
    public static Location__c getLocationById(String locationId){
        Map<String, Object> params = new Map<String, Object>{'locationId'=> locationId};
        String query = 'SELECT Id, Name, Status__c, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c FROM Location__c WHERE Id=:locationId LIMIT 1';
        List<SObject> sObjectList = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        Location__c location = new Location__c();
        if(sObjectList!=null && sObjectList.size()>0){
            location = (Location__c)sObjectList.get(0);
        }
        return location;
    }

    /* 
    * Returns number of location in each status
    * @params: null
    @ @return: Map<String,Integer>
    */
    public static Map<String, Integer> getStatusCount(){
        Map<String, Integer> mapOfStatusAndNumOfLoc = new Map<String, Integer>();
        for(AggregateResult aggRes: [SELECT Status__c, Count(Id) FROM Location__c GROUP BY Status__c]){
            mapOfStatusAndNumOfLoc.put((String)aggRes.get('Status__c'), (Integer)aggRes.get('expr0'));
        }
        return mapOfStatusAndNumOfLoc;
    }

    /**
     * Aggregates passed location ids where person health Status is 'Red' and calculates the red score and status and update the passed location ids
     * @params: Set<Id>  
     * @return: none
     */
    public static void updateRedScoreOnLocations(Set<Id> locationIds){
        System.debug('INSIDE updateRedScoreOnLocations');
        List<Location__c> locationsToUpdate = new List<Location__c>();
        String query = 'SELECT Location__c, Count(Id) FROM Location_Tracing__c WHERE Person__r.Health_Status__c = \'Red\' AND Visit_Date__c = LAST_n_DAYS:10 AND Location__c IN:locationIds GROUP BY Location__c';
        Map<String, Object> params = new Map<String, Object>{'locationIds'=>locationIds};
        AggregateResult[] aggResArray = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        for(AggregateResult aggRes: aggResArray){
            String locationId = (String)aggRes.get('Location__c');
            Integer redScore = (Integer)aggRes.get('expr0');
            String status = CT_LocationController.calcStatus(redScore);
            locationsToUpdate.add(new Location__c(Id=locationId, Status__c=status,Red_Score__c=redScore));
        }
        if(locationsToUpdate!=null && locationsToUpdate.size()>0){
            System.debug(locationsToUpdate);
            update locationsToUpdate;
        }
    }

    private static String calcStatus(Integer redScore){
        return redScore>10 ? 'Red' : redScore>5 ? 'Orange' : redScore>0 ? 'Yellow' : 'Green';
    }
}