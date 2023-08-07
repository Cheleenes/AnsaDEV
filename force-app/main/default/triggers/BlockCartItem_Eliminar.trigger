trigger BlockCartItem_Eliminar on CartItem (before delete, before update, before insert) {
    Id Id_Perfil = userinfo.getProfileId();
    String profilename=[Select Id, Name from Profile where Id=:Id_Perfil].Name; 
    CartItemTriggerHandler handler = new CartItemTriggerHandler();
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
            System.debug('Checking for update permission...');
            for (CartItem a : Trigger.new){
                System.debug('a.validation: ' + a.AMC_Validation__c);
                System.debug('old quiantity: ' + Trigger.oldMAp.get(a.Id).Quantity);
                System.debug('new quiantity: ' + Trigger.newMAp.get(a.Id).Quantity);
                IF((profilename =='Customer Community Plus User' || profilename =='Customer Community Plus User B2B') && !a.AMC_Validation__c && a.AMC_Pallet__c && (a.SalesPrice != null || a.SalesPrice != 0))
                {
                    System.debug('CartItem not updated: ' + a.Name);
                    a.addError('Test'); 
                }else{
                    System.debug('CartItem updated: ' + a.Name);
                    if((Trigger.newMap.get(a.Id).Quantity != Trigger.oldMAp.get(a.Id).Quantity)){
                        a.AMC_Validation__c = false;
                    }
                }
            }
        }
        
        if(Trigger.isInsert){
            handler.handleBeforeInsert(Trigger.new);
        }
        
        
        if(Trigger.isDelete){
            System.debug('Checking for delete permission...');
            for (CartItem a : Trigger.old){
                System.debug('a.validation: ' + a.AMC_Validation__c);
                IF(profilename =='Customer Community Plus User' && !a.AMC_Validation__c && a.AMC_Pallet__c)
                {
                    System.debug('CartItem not deleted: ' + a.Name);
                    a.addError('Test');           
                }else{
                    System.debug('CartItem deleted: ' + a.Name);
                }
            }
            handler.handleBeforeDelete(Trigger.old);
        }
        
    }
}