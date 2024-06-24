/**
 * 2017-11-06
 * Rudolf Niehaus - CloudSmiths
**/

@isTest
public class invCaseFlagActionsExt_Test{
    
    @isTest
    static void caseFlagActionsTest() {
        
        //test data
        list<Case> caseList = new list<Case>();
        Case c = new Case();
        c.Subject = 'Test Case';
        c.Description = 'Test case';
        c.Status = 'New';
        Case c2 = new Case();
        c2.Subject = 'Test Case2';
        c2.Description = 'Test case2';
        c2.Status = 'New';
        Case c3 = new Case();
        c3.Subject = 'Test Case3';
        c3.Description = 'Test case3';
        c3.Status = 'New';
        caseList.add(c);
        caseList.add(c2);
        caseList.add(c3);
        insert caseList;
        
        Test.startTest();
        
        invCaseFlagActionsExt.flagCase(caseList[0].Id);
        Case spam = [Select Status From Case Where Id = :caseList[0].Id];
        System.assertEquals('Spam', spam.Status);
        
        invCaseFlagActionsExt.Duplicate(caseList[1].Id);
        Case duplicate = [Select Status From Case Where Id = :caseList[1].Id];
        System.assertEquals('Duplicate', duplicate.Status);
        
        
        invCaseFlagActionsExt.notOrdinary(caseList[2].Id);
        Case notOrdi = [Select Status From Case Where Id = :caseList[2].Id];
        System.assertEquals('Not Ordinary', notOrdi.Status);
        
        Test.stopTest();
    }
}