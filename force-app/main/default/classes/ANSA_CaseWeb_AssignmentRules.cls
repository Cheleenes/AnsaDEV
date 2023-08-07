public class ANSA_CaseWeb_AssignmentRules {
    @InvocableMethod
    public static void assignCase(List<Id> CaseIds){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = TRUE;
        List<Case> toAssign = [SELECT Id, OwnerId FROM Case WHERE Id = :CaseIds];
        Database.update(toAssign,dmo);
    }
    
}