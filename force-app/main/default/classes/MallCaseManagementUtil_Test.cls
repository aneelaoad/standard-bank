/**
 * 
 * @description Test class for MallCaseManagementUtil
 * @author Ankit Kumar
 * @since 
 */
@isTest
private class MallCaseManagementUtil_Test
{
	
    @IsTest
    private static void getUserRecordTest()
    {
        String userId = userInfo.getUserId();
        Test.startTest();
        MallCaseManagementUtil.getUserRecord(userId);
        try{
            MallCaseManagementUtil.getUserRecord('0001');
        }catch(Exception e) {
            AuraHandledException aueaEx = MallExceptionUtil.throwAuraException('getUserRecord',e);
            Assert.areEqual(true, aueaEx.getMessage().contains('0001'), 'exception');
        }
        Test.stopTest();
    }
    
    @IsTest
    private static void createCaseRecordTest()
    {
        Account account = new Account();
        account.Name = 'Standard Bank Employees';
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
		account.RecordTypeId = devRecordTypeId;
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Email = 'test@standardbank.co.za';
        contact.AccountId = account.Id;
        insert contact;

        Entitlement entitlementRec = new Entitlement(
            Name = DMN_Entitlement.DEFAULT_ENTITLEMENT_NAME, 
            AccountId = account.Id, 
            StartDate = Date.valueof(System.now().addDays(-2)), 
            EndDate = Date.valueof(System.now().addYears(2))
        );
    
        insert entitlementRec;

        Case caseRecord = new Case();
        caseRecord.Subject = 'Store onboarding application form';
        caseRecord.ContactId = contact.Id;
        caseRecord.Description = 'Store onboarding application form';
   
        Test.startTest();
        string caseId = MallCaseManagementUtil.createCaseRecord(caseRecord);
        Assert.isTrue(String.isNotBlank(caseId),'Case Id should be not null');
        try {
            MallCaseManagementUtil.createCaseRecord(NULL);
        } catch(Exception e) {
            AuraHandledException aueaEx = MallExceptionUtil.throwAuraException('createCaseRecord',e);
            Assert.isTrue(aueaEx != NULL, 'exception expected');  
        }
        Test.stopTest();
    }
}