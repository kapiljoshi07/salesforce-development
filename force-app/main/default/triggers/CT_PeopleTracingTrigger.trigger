trigger CT_PeopleTracingTrigger on People_Tracing__c (before insert, after insert, before update, after update) {

  switch on Trigger.operationType {
    when BEFORE_INSERT{
      CT_PeopleTracingTriggerHandler.beforeInsert(Trigger.new);
    }
    when AFTER_INSERT{
      //CT_PeopleTracingTriggerHandler.afterInsert(Trigger.new, Trigger.oldMap);
    }
    when else{

    }
  }
}