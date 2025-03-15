trigger CT_LocationTrigger on Location__c (before insert, after insert, before update, after update) {

  SWITCH ON System.Trigger.operationType{
    WHEN BEFORE_INSERT{
      CT_LocationTriggerHandler.beforeInsert(Trigger.new);
    }WHEN AFTER_INSERT{

    }WHEN BEFORE_UPDATE{
      CT_LocationTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }WHEN AFTER_UPDATE{
      CT_LocationTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }WHEN BEFORE_DELETE{

    }WHEN AFTER_DELETE{

    }WHEN AFTER_UNDELETE{

    }
  }

}