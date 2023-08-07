trigger OrderTrigger on Order (before insert, after insert, before update, after update) {
    OrderTriggerHandler handler = new OrderTriggerHandler();
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isInsert){
            handler.handleBeforeInsert(Trigger.new);
        }
    }
    if(Trigger.isAfter){
        OrderTriggerHandler handler = new OrderTriggerHandler();
        if(Trigger.isUpdate){
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isInsert){
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}