/**
 * 2017-11-06
 * Rudolf Niehaus - CloudSmiths
**/
@SuppressWarnings('PMD.ClassNamingConventions')
@IsTest
public class invCaseMergeExt_Test {
    
    @isTest
    static void unitTest(){
       
        Id recId = [Select Id From RecordType Where DeveloperName = 'TPS_Client_Case'].Id;
        Id contRecId = [Select Id From RecordType Where DeveloperName = 'SA_Bank_Contact_Record_Type'].Id;
        
        Account acc = new Account();
        acc.Name = 'Standard Bank Employees';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test UAT';
        con.LastName = 'Test UAT';
        con.Email = 'test@uat.com';
        con.RecordTypeId = contRecId;
        con.AccountId = acc.Id;
        insert con;
        
        Case ca = new Case();
        ca.Subject = 'Test Case';
        ca.Description = 'Test case';
        ca.Status = 'New';
        ca.Main_Category__c = 'Accounts';
        ca.Sub_Category__c = 'Billing';
        ca.Resolved_By__c = con.Id;
        ca.RecordTypeId = recId;
        insert ca;
        
        Case cb = new Case();
        cb.Subject = 'Test Case2';
        cb.Description = 'Test case2';
        cb.Status = 'New';
        cb.Main_Category__c = 'Accounts';
        cb.Sub_Category__c = 'Billing';
        cb.ParentId = ca.Id;
        cb.RecordTypeId = recId;
        cb.Resolved_By__c = con.Id;
        insert cb;
        
        Test.startTest();
        try {
            List<Case> relatedCaseList = invCaseMergeExt.getRelatedCase(ca.Id);
            Case mergeCase = invCaseMergeExt.mergeCase(ca.Id,cb.Id);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }
}