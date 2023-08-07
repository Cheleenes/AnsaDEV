public with sharing class AMC_PaintColorPickerController {
    public AMC_PaintColorPickerController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Product_Paint_Color__c> getColors(String productId){//String productId){
        List<Product_Paint_Color__c> retList = [Select Paint_Color__r.Name, Paint_Color__r.Style_Text__c From Product_Paint_Color__c Where Product__c =: productId];
        System.System.debug('retList size: ' + retList.size());
        System.System.debug(retList);
        if(retList.size() > 0){
            return retList;
        }else{
            return null;
        }
        
    }

    /*@AuraEnabled(cacheable=true)
    public static List<Paint_Color__c> getColors(String productId){//String productId){
        List<Paint_Color__c> retList = [Select Name, Style_Text__c From Paint_Color__c];
        System.System.debug('retList size: ' + retList.size());
        System.System.debug(retList);
        if(retList.size() > 0){
            return retList;
        }else{
            return null;
        }
        
    }*/

    @AuraEnabled
    public static void setColor(string colorHex) {
        Id userId = UserInfo.getUserId();
        User thisUser = [Select Id, Color_Hex__c From User Where Id =: userId];
        thisUser.Color_Hex__c = colorHex;
        update thisUser;
    }
}