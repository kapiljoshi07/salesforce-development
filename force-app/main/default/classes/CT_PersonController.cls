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
        Map<String, Object> params = new Map<String, String>{'searchString'=>'%'+searchQuery+'%'};
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
    * @return List<Person__c>
    */
    public static Person__c getPersonById(String personId){
        Map<String, Object> params = new Map<String, String>{'personId'=> personId};
        String query = 'SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c WHERE Id=:personId LIMIT 1';
        List<SObject> sObjectList = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);
        Person__c person = (Person__c)sObjectList.get(0);
        return person;
    }

}