trigger CT_PersonTrigger on Person__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

  SWITCH ON System.Trigger.operationType{
    WHEN BEFORE_INSERT{
      CT_PersonTriggerHandler.beforeInsert(Trigger.new);
    }WHEN AFTER_INSERT{

    }WHEN BEFORE_UPDATE{
      CT_PersonTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }WHEN AFTER_UPDATE{
      CT_PersonTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }WHEN BEFORE_DELETE{

    }WHEN AFTER_DELETE{

    }WHEN AFTER_UNDELETE{

    }
  }
}