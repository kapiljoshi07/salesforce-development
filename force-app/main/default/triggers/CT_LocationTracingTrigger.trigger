trigger CT_LocationTracingTrigger on Location_Tracing__c (before insert) {

  switch on Trigger.operationType {
    when BEFORE_INSERT{
      CT_LocationTracingTriggerHandler.beforeInsert(Trigger.new);
    }
    when else {
      
    }
  }
}