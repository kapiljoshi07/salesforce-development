public with sharing class CT_LocationTabController {
    
    @AuraEnabled
    public static LocationInformation getLocationDetails(String locationId){
        System.debug('Inside Server Side Controller');
        LocationInformation locationInfo = new LocationInformation();
        try {
            List<Location_Tracing__c> traces = CT_LocationTracingController.getVisitors(locationId);
            Location__c location = CT_LocationController.getLocationById(locationId);

            if(location!=null){
                locationInfo.name = location.Name;
                locationInfo.pincode = location.Pincode__c;
                locationInfo.lastStatusUpdateDate = location.Status_Update_Date__c;
                locationInfo.redScore = (Integer)location.Red_Score__c;
                locationInfo.status = location.Status__c;
            }

            List<Visitor> visitors = new List<Visitor>();
            if(traces!=null && traces.size()>0){
                
                for(Location_Tracing__c trace: traces){
                    Visitor visitor = new Visitor();
                    visitor.status = trace.Person__r.Health_Status__c;
                    visitor.token = trace.Person__r.Token__c;
                    visitor.visitDate = trace.Visit_Date__c;
                    visitors.add(visitor);
                }
            }

            locationInfo.visitors = visitors;
            locationInfo.visitorCount = visitors.size();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug(locationInfo);
        return locationInfo;
    }

    public class LocationInformation{
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public String pincode;
        @AuraEnabled public Integer redScore;
        @AuraEnabled public Date lastStatusUpdateDate;
        @AuraEnabled public Integer visitorCount;
        @AuraEnabled public List<Visitor> visitors;
    }

    public class Visitor{
        @AuraEnabled public String token;
        @AuraEnabled public String status;
        @AuraEnabled public Date visitDate;
    }
}