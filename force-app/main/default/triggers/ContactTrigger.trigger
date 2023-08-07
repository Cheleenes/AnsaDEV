trigger ContactTrigger on Contact (after insert, after update) {
    ContactTriggerHandler handler = new ContactTriggerHandler();
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.handleAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}