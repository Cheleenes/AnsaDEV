trigger CartItemTrigger on CartItem (before insert) {
    
    if(Trigger.isBefore){
        ANSA_CartItemTriggerHandler handler = new ANSA_CartItemTriggerHandler();
        if(Trigger.isInsert){
            handler.handleBeforeInsert(Trigger.new);
        }
    }

}