trigger OrderItemTrigger on OrderItem (before update, before insert, after insert) {
    OrderItemTriggerHandler handler = new OrderItemTriggerHandler();
        if(Trigger.isBefore){
            if(Trigger.isUpdate){
                handler.handleBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
            }
            if(Trigger.isInsert){
                handler.handleBeforeInsert(Trigger.new);
            }
        }
    
    	if(Trigger.isAfter){
            if(Trigger.isInsert){
                handler.handleAfterInsert(Trigger.new);
            }
        }
}