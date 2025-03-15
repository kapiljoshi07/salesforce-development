public with sharing class CT_PersonController {
    
    /*
    * Generates unique token using mobile number
    * Uses 'MD5' algorithm to generate one-way hash
    * @param String mobile
    * @return String token
    */
    public static String getToken(String mobileNumber){
        Blob mobAsBlob = Blob.valueOf(mobileNumber);
        Blob hash = Crypto.generateDigest('MD5', mobAsBlob);
        String token = EncodingUtil.base64Encode(hash);
        return token;
    }

    /*
    * Retreives a list of 100 Person records
    * The list is sorted by Status Update Date in descending order
    * @param null
    * @return List<Person__c>
    */
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /*
    * Retreives a list Person records whose Name/Mobile/Token matches the search query
    * The list is sorted by Status Update Date in descending order
    * @param String search query
    * @return Person__c
    */
    public static List<Person__c> searchPeople(String searchQuery){
        Map<String, Object> params = new Map<String, Object>{'searchString'=>'%'+searchQuery+'%'};
        String query = 'SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c WHERE (Mobile__c LIKE:searchString OR Name LIKE:searchString OR Token__c LIKE:searchString) ORDER BY Status_Update_Date__c DESC NULLS LAST';
        List<SObject> sObjectList = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        List<Person__c> personsList = new List<Person__c>();
        for(SObject sobj: sObjectList){
            personsList.add((Person__c)sobj);
        }
        return personsList;
    }

    /*
    * Retreives a Person record which matches id passed as the search query
    * @param String search query
    * @return Person__c
    */
    public static Person__c getPersonById(String personId){
        Map<String, Object> params = new Map<String, Object>{'personId'=> personId};
        String query = 'SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c WHERE Id=:personId LIMIT 1';
        List<SObject> sObjectList = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        Person__c person = new Person__c();
        if(sObjectList!=null && sObjectList.size()>0){
            person = (Person__c)sObjectList.get(0);
        }
        return person;
    }

    /*
    * Returns map of Health Status and number of people in each health status
    * @params: null
    * @return: Map<String, Integer>
    */
    public static Map<String, Integer> getHealthStatusCount(){
        AggregateResult[] aggResArray = [SELECT Health_Status__c, Count(Id) numOfPpl FROM Person__c GROUP BY Health_Status__c];
        Map<String,Integer> healthStatusWithNumOfPplMap = new Map<String,Integer>();
        if(aggResArray!=null&&aggResArray.size()>0){
            for(AggregateResult aggRes: aggResArray){
                healthStatusWithNumOfPplMap.put((String)aggRes.get('Health_Status__c'),(Integer)aggRes.get('numOfPpl'));
            }
        }
        return healthStatusWithNumOfPplMap;
    }

    /*
    * Updates Status_Update_Date__c to today if Health Status of person changes
    * @params: List<Person__c>
    * @return: none
    */
    public static void updateStatusDateOnStatusChange(List<Person__c> newPersons, Map<Id,Person__c> oldPersonMap){
        for(Person__c person: newPersons){
            if(person.Health_Status__c != oldPersonMap.get(person.id).Health_Status__c){
                person.Status_Update_Date__c = System.now().date();
            }
        }
    }

    /**
     * Updates the Health Status and Red Score of locations On Health Status Update
     * @params: Trigger.new, Trigger.oldMap
     * @return: npne
     */
    public static void updateLocationScoreAndStatus(List<Person__c> persons, Map<Id, Person__c> oldPersonMap){
        
        //To Update the Health Status of Cohabitants (Orange), Neighbours (Yellow), Primary Contact (Orange) & Secondary Contact (Yellow)
        Set<Id> redStatusPersonIds = new Set<Id>();
        for(Person__c person: persons){
            if(person.Health_Status__c != oldPersonMap.get(person.Id).Health_Status__c && person.Health_Status__c == 'Red'){
                redStatusPersonIds.add(person.Id);
            }
        }
        Set<Id> processedIds = new Set<Id>();
        processedIds.addAll(redStatusPersonIds);
        Set<Id> orangeStatusPersonIds = new Set<Id>();
        orangeStatusPersonIds.addAll(CT_PersonController.getCohabitants(redStatusPersonIds, processedIds));
        processedIds.addAll(orangeStatusPersonIds);
        orangeStatusPersonIds.addAll(CT_PersonController.getPrimaryContacts(redStatusPersonIds, processedIds));
        processedIds.addAll(orangeStatusPersonIds);
        Set<Id> yellowStatusPersonIds = new Set<Id>();
        yellowStatusPersonIds.addAll(CT_PersonController.getNeighbours(redStatusPersonIds, processedIds));
        processedIds.addAll(yellowStatusPersonIds);
        yellowStatusPersonIds.addAll(CT_PersonController.getSecondaryContacts(redStatusPersonIds, processedIds));
        processedIds.addAll(yellowStatusPersonIds);

        List<Person__c> personsToUpdate = new List<Person__c>();
        for(Id personId: orangeStatusPersonIds){
            personsToUpdate.add(new Person__c(Id=personId, Health_Status__c='Orange'));
        }
        for(Id personId: yellowStatusPersonIds){
            personsToUpdate.add(new Person__c(Id=personId, Health_Status__c='Yellow'));
        }
        
        if(personsToUpdate!=null && personsToUpdate.size()>0){
            update personsToUpdate;
        }

        //To update the red score and status of location
        Set<Id> statusChangePersonIdSet = new Set<Id>();
        for(Person__c person: persons){
            if(person.Health_Status__c != oldPersonMap.get(person.Id).Health_Status__c){
                statusChangePersonIdSet.add(person.Id);
            }
        }
        List<Location_Tracing__c> locationTraces = CT_LocationTracingController.getLocationTracingsByPersonId(statusChangePersonIdSet);
        if(locationTraces!=null && locationTraces.size()>0){
            Set<Id> locationIds = new Set<Id>();
            for(Location_Tracing__c trace: locationTraces){
                locationIds.add(trace.Location__c);
            }
            CT_LocationController.updateRedScoreOnLocations(locationIds);
        }

    }

    /*
    * Returns set of Cohabitants id of the passed person ids excluding the already processed ids
    * @params: Set<Id>, Set<Id>
    * @return: Set<Id>
    */
    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> processedIds){
        Set<String> healthStatuses = new Set<String>();
        healthStatuses.add('Red');
        healthStatuses.add('Orange');
        String query = 'SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c WHERE (Person_1__c IN:personIds OR Person_2__c IN:personIds) AND (Person_1__c NOT IN:processedIds OR Person_2__c NOT IN:processedIds) AND Contact_Type__c =\'Cohabitant\' AND (Person_1__r.Health_Status__c NOT IN: healthStatuses OR Person_2__r.Health_Status__c NOT IN: healthStatuses)';
        Map<String, Object> params = new Map<String, Object>{'personIds'=>personIds, 'healthStatuses'=>healthStatuses, 'processedIds'=>processedIds};
        List<People_Tracing__c> traces = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        Set<Id> cohabitants = new Set<Id>();
        for(People_Tracing__c trace: traces){
            if(personIds.contains(trace.Person_1__c)){
                cohabitants.add(trace.Person_2__c);
            }else{
                cohabitants.add(trace.Person_1__c);
            }
        }
        return cohabitants;
    }

    /*
    * Returns set of Neighbour ids of the passed person ids.
    * @params: Set<Id>
    * @return: Set<Id>
    */
    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> processedIds){
        Set<String> healthStatuses = new Set<String>();
        healthStatuses.add('Red');
        healthStatuses.add('Orange');
        healthStatuses.add('Yellow');
        String query = 'SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c WHERE (Person_1__c IN:personIds OR Person_2__c IN:personIds) AND (Person_1__c NOT IN:processedIds OR Person_2__c NOT IN:processedIds) AND Contact_Type__c =\'Neighbour\' AND (Person_1__r.Health_Status__c NOT IN: healthStatuses OR Person_2__r.Health_Status__c NOT IN: healthStatuses)';
        Map<String, Object> params = new Map<String, Object>{'personIds'=>personIds, 'healthStatuses'=>healthStatuses, 'processedIds'=>processedIds};
        List<People_Tracing__c> traces = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        Set<Id> neighbours = new Set<Id>();
        for(People_Tracing__c trace: traces){
            if(personIds.contains(trace.Person_1__c)){
                neighbours.add(trace.Person_2__c);
            }else{
                neighbours.add(trace.Person_1__c);
            }
        }
        return neighbours;
    }

    /*
    * Returns set of Primary Contact ids of the passed person ids.
    * @params: Set<Id>
    * @return: Set<Id>
    */
    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> processedIds){
        Set<String> healthStatuses = new Set<String>();
        healthStatuses.add('Red');
        healthStatuses.add('Orange');
        String query = 'SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c WHERE (Person_1__c IN:personIds OR Person_2__c IN:personIds) AND (Person_1__c NOT IN:processedIds OR Person_2__c NOT IN:processedIds) AND Contact_Type__c =\'Other\' AND (Person_1__r.Health_Status__c NOT IN: healthStatuses OR Person_2__r.Health_Status__c NOT IN: healthStatuses) AND Contact_Date__c = LAST_n_DAYS:10';
        Map<String, Object> params = new Map<String, Object>{'personIds'=>personIds, 'healthStatuses'=>healthStatuses, 'processedIds'=>processedIds};
        List<People_Tracing__c> traces = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        Set<Id> primaryContacts = new Set<Id>();
        for(People_Tracing__c trace: traces){
            if(personIds.contains(trace.Person_1__c)){
                primaryContacts.add(trace.Person_2__c);
            }else{
                primaryContacts.add(trace.Person_1__c);
            }
        }
        return primaryContacts;
    }

    /*
    * Returns set of Primary Contact ids of the passed person ids.
    * @params: Set<Id>
    * @return: Set<Id>
    */
    public static Set<Id> getSecondaryContacts(Set<Id> personIds, Set<Id> processedIds){
        Set<Id> primaryContactIds = CT_PersonController.getPrimaryContacts(personIds, processedIds);
        Set<String> healthStatuses = new Set<String>();
        healthStatuses.add('Red');
        healthStatuses.add('Orange');
        String query = 'SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c WHERE (Person_1__c IN:primaryContactIds OR Person_2__c IN:primaryContactIds) AND (Person_1__c NOT IN:processedIds OR Person_2__c NOT IN:processedIds) AND Contact_Type__c =\'Other\' AND (Person_1__r.Health_Status__c NOT IN: healthStatuses OR Person_2__r.Health_Status__c NOT IN: healthStatuses) AND Contact_Date__c = LAST_n_DAYS:10';
        Map<String, Object> params = new Map<String, Object>{'primaryContactIds'=>primaryContactIds, 'healthStatuses'=>healthStatuses, 'processedIds'=>processedIds};
        List<People_Tracing__c> traces = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        Set<Id> secondaryContacts = new Set<Id>();
        for(People_Tracing__c trace: traces){
            if(primaryContactIds.contains(trace.Person_1__c)){
                secondaryContacts.add(trace.Person_2__c);
            }else{
                secondaryContacts.add(trace.Person_1__c);
            }
        }
        return secondaryContacts;
    }

}