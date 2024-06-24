@isTest
public with sharing class OSB_SRV_FinancialAccSearchHandlerTest
{
    @isTest
    public static void testFinAccExistence()
    {
        Financial_Account__c fa = new Financial_Account__c();
        fa.External_Id__c = '1233211233213';
        
        Account a = new Account();
        a.Name = 'AccForTestingPurposesTM';
        insert a;

        fa.Client__c = a.Id;
        insert fa;

        System.assertEquals(new List<Boolean>{true}, OSB_SRV_FinancialAccSearchHandler.searchFinAcc(new List<String>{'1233211233213'}));
    }
}