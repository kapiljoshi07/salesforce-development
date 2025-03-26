public with sharing class CT_PersonTabController {
    
    @AuraEnabled
    public static PersonInformation getUserDetails(String personId){
        PersonInformation personInfo = new PersonInformation();
        try {
            List<People_Tracing__c> traces = CT_PeopleTracingController.getTraces(personId);
            Person__c person = CT_PersonController.getPersonById(personId);

            if(person!=null){
                personInfo.name = person.Name;
                personInfo.token = person.Token__c;
                personInfo.mobile = person.Mobile__c;
                personInfo.lastStatusUpdateDate = person.Status_Update_Date__c;
                personInfo.healthStatus = person.Health_Status__c;
            }

            if(traces!=null && traces.size()>0){
                Set<Id> personIdSet = new Set<Id>();
                personIdSet.add(personId);
                List<CloseContact> ccList = new List<CloseContact>();
                for(People_Tracing__c trace: traces){
                    CloseContact cc = new CloseContact();
                    if(!personIdSet.contains(trace.Person_1__c)){
                        cc.token = trace.Person_1__r.Token__c;
                        cc.name = trace.Person_1__r.Name;
                        cc.status = trace.Person_1__r.Health_Status__c;
                        cc.contactDate = trace.Contact_Date__c;
                    }
                    if(!personIdSet.contains(trace.Person_2__c)){
                        cc.token = trace.Person_2__r.Token__c;
                        cc.name = trace.Person_2__r.Name;
                        cc.status = trace.Person_2__r.Health_Status__c;
                        cc.contactDate = trace.Contact_Date__c;
                    }
                    ccList.add(cc);
                }
                personInfo.closeContacts = ccList;
                personInfo.closeContactsCount = ccList.size();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return personInfo;
    }

    public class PersonInformation{
        @AuraEnabled public String name;
        @AuraEnabled public String healthStatus;
        @AuraEnabled public Date lastStatusUpdateDate;
        @AuraEnabled public String mobile;
        @AuraEnabled public String token;
        @AuraEnabled public Integer closeContactsCount;
        @AuraEnabled public List<CloseContact> closeContacts;
    }

    public class CloseContact{
        @AuraEnabled public String name;
        @AuraEnabled public Date contactDate;
        @AuraEnabled public String status;
        @AuraEnabled public String token;
    }
    
}