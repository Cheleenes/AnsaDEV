trigger AccountTrigger on Account (after update, after insert) {
    if(Trigger.isAfter){
        AccountTriggerHandler handler = new AccountTriggerHandler();
        System.debug('triggeraa');
        if(Trigger.isInsert){
            System.debug('triggerbb');
            handler.handleAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            System.debug('triggercc');
            handler.handleAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
    }
}