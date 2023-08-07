@isTest (SeeAllData=false)
public class ANSA_CaseWeb_AssignmentRulesTest {
	 @isTest
    static void COL_CaseWeb_AssignmentRulesTest() {
        
        User userToCreate = [SELECT id FROM User WHERE IsActive=True AND (profile.name='System Administrator' or profile.name='Administrador del sistema') Limit 1];
        
        Case caseToCreate = new Case();
        List<id> Ids = new List<Id>();

        caseToCreate.ownerId= userToCreate.id;
        caseToCreate.Subject='TEST';
        caseToCreate.Description='Test Descripción';
        caseToCreate.Status='Open';
        caseToCreate.Origin = 'Email';
        caseToCreate.CurrencyIsoCode = 'BBD';
        insert caseToCreate;
        
        Test.startTest();
        Ids.add(caseToCreate.id);
        ANSA_CaseWeb_AssignmentRules.assignCase(Ids);
        Test.stopTest();

        List<Case> caseList = new List<Case>([SELECT Id, OwnerId FROM Case]);
        System.assert(caseList.isEmpty() != true);
    }
}