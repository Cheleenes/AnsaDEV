trigger QuoteLineItemTrigger on QuoteLineItem (before insert, after insert) {
    QuoteLineItemHandler handler = new QuoteLineItemHandler();
    if(Trigger.isBefore){
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