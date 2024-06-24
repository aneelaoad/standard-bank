/* @Class Name   : SA_StdBank_AutoUpdClIndustry_Test_Proper
 * @Description  : Test class for AccountTriggerHandler_trgr.cls (method updateIndustryDescription)
 * @Created By   : Jana Cechova
 * @Created On   : 21 Mar 2016 
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------
 * ---------------------------------------------------------------------------------------------------
*/
@isTest
private class SA_StdBank_AutoUpdClIndustry_Test_Proper {

    /*
    * After update Industry Code on Account we are expecting that after fire trigger for update Industry Description, field SA_Industry_Description__c will be populated based on SA_Industry_Mapping__c for each existin Account.
    * For example:
    * We have 20 Account and 20 SA_Industry_Mapping__c (each SA_Industry_Mapping__c contains SA_1Digit_ISIC_Desc__c) if:
    *   a) Industry Code will be updated with value '' we are expecting that SA_Industry_Description__c will be populaed with 'Missing CIF ISIC code'.
    *   b) Industry Code will be updated with value '!@#$%^&*' we are expecting that SA_Industry_Description__c will be populaed with 'Missing ISIC mapping'.
    *   c) Industry Code will be updated with value '1' we are expecting that SA_Industry_Description__c will be populaed with value which is in SA_1Digit_ISIC_Desc__c on position 1.
    *   d) Industry Code will be updated with value null  we are expecting that SA_Industry_Description__c will be populaed with 'Missing CIF ISIC code'.
    *   e) Industry Code will be updated with value 'test'  we are expecting that SA_Industry_Description__c will be populaed with 'Missing ISIC mapping'.
    *   f) Industry Code will be updated with value '23'  we are expecting that SA_Industry_Description__c will be populaed with 'Missing ISIC mapping'.
    *   g) Industry Code will be updated with value '23test'  we are expecting that SA_Industry_Description__c will be populaed with 'Missing ISIC mapping'.
    *   h) Industry Code will be updated with value '2' we are expecting that SA_Industry_Description__c will be populaed with value which is in SA_1Digit_ISIC_Desc__c on position 2.
    */
    static testMethod void AutoUpdateClientIndustryDescription_Test() {
        List<ISIC_Mapping_Client_Sector__c> isicCodes = new List<ISIC_Mapping_Client_Sector__c>();
        ISIC_Mapping_Client_Sector__c isic = new ISIC_Mapping_Client_Sector__c(Name = '1', Client_Sub_Sector__c = 'Agriculture', Client_Sector__c = 'Consumer', CIF_ISIC_Description__c = 'Agriculture, Hunting And Forestry');
        ISIC_Mapping_Client_Sector__c isic2 = new ISIC_Mapping_Client_Sector__c(Name = '2', Client_Sub_Sector__c = 'Agriculture', Client_Sector__c = 'Consumer', CIF_ISIC_Description__c = 'Fishing');
        isicCodes.add(isic);
        isicCodes.add(isic2);
        insert isicCodes;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        List<Account> olstAccount = new List<Account>();
        for (Integer i = 0; i < 8; i++) {
            olstAccount.add(
                (Account) new BLD_Account(uow).useChild().getRecord()
            );
        }
        uow.commitWork();
        
        list<Account>  accountsToAssert = [Select id, Industry_Code__c, SA_Industry_Description__c from Account where id IN: olstAccount order by id];

        // Check Accounts after insert
        for(Account acct: accountsToAssert){
            system.assertEquals(null, acct.Industry_Code__c,'Industry Code is not null uncorrectly.');
            system.assertNotEquals(null, acct.SA_Industry_Description__c, 'SA Industry Description is null uncorrectly.');
        }
        
        // Update values in Industry Code
        // a)
        olstAccount[0].Industry_Code__c = '';
        // b)
        olstAccount[1].Industry_Code__c = '!@#$%^&*';
        // c)
        olstAccount[2].Industry_Code__c = '1';
        // d)
        olstAccount[3].Industry_Code__c = null;
        // e)
        olstAccount[4].Industry_Code__c = 'test';
        // f)
        olstAccount[5].Industry_Code__c = '23';
        // g)
        olstAccount[6].Industry_Code__c = '23test';
        // h)
        olstAccount[7].Industry_Code__c = '2';
        
        //system.debug(GOVERNOR_LIMITS); 
        system.debug(LoggingLevel.ERROR, 'SOQL query usage before startTest() AutoUpdateClientIndustryDescription_Test() unit test: ' + Limits.getQueries());
        system.debug(LoggingLevel.ERROR, 'DML rows query before startTest() AutoUpdateClientIndustryDescription_Test() unit test: ' + Limits.getDMLRows());
        system.Test.startTest();
        
        // Update Accounts
        update olstAccount; 
        
        list<Account>  accountsToAsserts = [Select id, Industry_Code__c, SA_Industry_Description__c from Account where id IN: olstAccount order by id];
        system.debug(logginglevel.error, 'After' + accountsToAsserts);
        
        //system.debug(GOVERNOR_LIMITS);
        system.debug(LoggingLevel.ERROR, 'SOQL query usage before stopTest() AutoUpdateClientIndustryDescription_Test() unit test: ' + Limits.getQueries());
        system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() AutoUpdateClientIndustryDescription_Test() unit test: ' + Limits.getDMLRows());
        system.Test.stopTest();
        
        // Check Account after update
        list<Account> accountsToAssert2 = [Select id, Industry_Code__c, SA_Industry_Description__c from Account where id IN: olstAccount];
        system.assertEquals('Missing CIF ISIC code', accountsToAssert2[0].SA_Industry_Description__c, 'SA Industry Description was populated uncorrectly.');
        system.assertEquals('Missing ISIC mapping', accountsToAssert2[1].SA_Industry_Description__c, 'SA Industry Description was populated uncorrectly.');
        system.assertEquals('Agriculture, Hunting And Forestry', accountsToAssert2[2].SA_Industry_Description__c, 'SA Industry Description was populated uncorrectly.');
        system.assertEquals('Missing CIF ISIC code', accountsToAssert2[3].SA_Industry_Description__c, 'SA Industry Description was populated uncorrectly.');
        system.assertEquals('Missing ISIC mapping', accountsToAssert2[4].SA_Industry_Description__c, 'SA Industry Description was populated uncorrectly.');
        system.assertEquals('Missing ISIC mapping', accountsToAssert2[5].SA_Industry_Description__c, 'SA Industry Description was populated uncorrectly.');
        system.assertEquals('Missing ISIC mapping', accountsToAssert2[6].SA_Industry_Description__c, 'SA Industry Description was populated uncorrectly.');
        system.assertEquals('Fishing', accountsToAssert2[7].SA_Industry_Description__c, 'SA Industry Description was populated uncorrectly.');
        
     }
}