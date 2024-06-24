/**
 * 2017-11-06
 * Rudolf Niehaus - CloudSmiths
**/
@SuppressWarnings('PMD.ClassNamingConventions')
@IsTest
public class invCaseSplitExt_Test {
    
    @isTest
    static void unitTest(){
        
        list<Case> caseList = new list<Case>();
        Case ca = new Case();
        ca.Subject = 'Test Case';
        ca.Description = 'Test case';
        ca.Status = 'New';
        Case cb = new Case();
        cb.Subject = 'Test Case2';
        cb.Description = 'Test case2';
        cb.Status = 'New';
        caseList.add(ca);
        caseList.add(cb);
        insert caseList;

        Test.startTest();
        
       
        Case c1 = invCaseSplitExt.getCase1();
      
        c1.Subject = 'New Case Split';
        c1.Status = 'New';
        insert c1;

        try {
            c1 = invCaseSplitExt.saveCase(c1, caseList[0].Id);
            Boolean b = invCaseSplitExt.getRenderIF(caseList[0].Id);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();

    }
}