/*****************************************************************************************
 *@Name of the Class: SEL_Contacts_TEST
 *@Description      : SFP-30097 Test class for SEL_Contacts
 *@Author           : Youssef Ibrahim (yibrahim@deloittece.com)
 *@Created Date     : December 2020
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@description : SFP-30097
 ******************************************************************************************/
@IsTest
private class SEL_Contacts_TEST {

    @IsTest
    static void shouldSelectWithoutCondition() {
        SEL_Contacts.newInstance().selectWithoutCondition(5);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getLimit(), 5, 'Different limit than expected');
    }

    @IsTest
    static void shouldSelectById() {
        SEL_Contacts.newInstance().selectById(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN: idSet'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByPingUUID() {
        SEL_Contacts.newInstance().selectByPingUUID(new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Ping_Id__c IN: idSet'), 'Different condition than expected');
    }
    
    @IsTest
    static void shouldSelectByEmail() {
        SEL_Contacts.newInstance().selectByEmail(new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Email in :emailAddresses'), true,'should be true');
    }

    @IsTest
    static void shouldSelectAuthorisedPersonByAccountId() {
        SEL_Contacts.newInstance().selectAuthorisedPersonByAccountId(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Contact_Role_s_at_' +
                'Client__c includes (\'Authorised Person\') and AccountId in :idSet'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectKYCContactByAccountId() {
        SEL_Contacts.newInstance().selectKYCContactByAccountId(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Contact_Role_s_at_Client__c' +
                ' includes (\'KYC Contact\',\'GROUP KYC Contact\') and AccountId in :idSet'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByUserId() {
        SEL_Contacts.newInstance().selectByUserId(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN (SELECT ContactId FROM ' +
                'User WHERE Id IN :ids)'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByEmailIdentityPassport() {
        SEL_Contacts.newInstance().selectByEmailIdentityPassport(new Set<String>(),
                new Set<String>(), new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Email IN :emails AND (Identity_Number__c IN' +
                ' :idNumbers OR OSB_Passport_Number__c IN :passportNumbers)'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByIdentityNumber() {
        SEL_Contacts.newInstance().selectByIdentityNumber(new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Identity_Number__c IN: IdentityNumbers'), 'Different condition than expected');
    }
    
        @IsTest
    static void shouldselectByExternalIdentifiers() {
        SEL_Contacts.newInstance().selectByExternalIdentifiers(new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('ExternalIdentifier__c IN: externalIds'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByOneHubManager() {
        SEL_Contacts.newInstance().selectByOneHubManager(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('OSB_Community_Access_Manager__c in :idSet'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByFirstNameLastNameEmail() {
        SEL_Contacts.newInstance().selectByFirstNameLastNameEmail(new Set<String>(), new Set<String>(), new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('(FirstName IN: firstNames AND LastName' +
                ' IN: lastNames AND Email IN: emails)'), 'Different condition than expected');
    }

    @IsTest
    static void shouldselectByEmailAccessStatus() {
        SEL_Contacts.newInstance().selectByEmailAccessStatus(new Set<String>(), new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Email IN :emails AND OSB_Community_Access_Status__c IN :status'),false,'should be false');
    }

    @IsTest
    static void shouldSelectByNameEmailPingId() {
        SEL_Contacts.newInstance().selectByNameEmailPingId(new Set<String>(), new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Name IN: names AND Email IN:' +
                ' emails AND Ping_Id__c !=null '), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByIndustryUserId() {
        SEL_Contacts.newInstance().selectByIndustryUserId(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN (SELECT ContactId ' +
                'FROM User WHERE Id IN :ids) AND Company_Industry__c !=null'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByIdWoSharing() {
        SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN: idSet'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByIdentityNumberWoSharing() {
        SEL_Contacts.newInstance().selectByIdentityNumberWoSharing(new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Identity_Number__c IN: IdentityNumbers'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByUserIdWoSharing() {
        SEL_Contacts.newInstance().selectByUserIdWoSharing(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN (SELECT ContactId FROM ' +
                'User WHERE Id IN :ids)'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByIndustryUserIdWoSharing() {
        SEL_Contacts.newInstance().selectByIndustryUserIdWoSharing(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN (SELECT ContactId FROM User WHERE Id ' +
                'IN :ids) AND Company_Industry__c !=null'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByNameEmailPingIdWoSharing() {
        SEL_Contacts.newInstance().selectByNameEmailPingIdWoSharing(new Set<String>(), new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Name IN: names AND Email IN: emails ' +
                'AND Ping_Id__c !=null '), 'Different condition than expected');
    }
    @IsTest
    static void shouldSelectByClientId() {
        Test.startTest();
        SEL_Contacts.newInstance().selectByClientId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('AccountId IN: clientId'), 'Different condition than expected');
    }
    @IsTest
    static void shouldSelectByOnboardAppId() {
        Test.startTest();
        SEL_Contacts.newInstance().selectByOnboardAppId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN (SELECT Authorised_Person__c FROM Application_Document__c WHERE '+
                'Onboarding_Application__c IN:onboardId '), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByIdForRegistration() {
        Test.startTest();
        SEL_Contacts.newInstance().selectByIdForRegistration(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN: idSet'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByEmailOrPingId() {
        Test.startTest();
        SEL_Contacts.newInstance().selectByEmailOrPingId(new Set<String>(), new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Email IN: emails OR Ping_Id__c IN: pingIds'), 'Different condition than expected');
    }

    @IsTest
    static void shouldSelectByIdWithInterests() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Contact bldContact = (Contact) new BLD_Contact(uow).getRecord();
        uow.commitWork();

        Test.startTest();
        SEL_Contacts.newInstance().selectByIdWithInterests(bldContact.Id);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id =: ids'), 'Different condition than expected');
	}

	@isTest
	static void selectByIdforConsentFlowTest() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Contact bldContact = (Contact) new BLD_Contact(uow).getRecord();
		uow.commitWork();

		Test.startTest();
		Assert.isFalse(SEL_Contacts.newInstance().selectByIdforConsentFlow(new List<Id> { bldContact.Id }).isEmpty(),'should be false');
		Test.stopTest();
    }
    
	@isTest
	static void selectContactByContactRoleTest() {
           Account testacc=new Account();
        testacc.name='Test Client';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        
        Contact conTest = new Contact();
        conTest.Email = 'Test@test.com';
        conTest.AccountId = acc.Id;
        conTest.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest.LastName = 'Test';
        insert conTest;
        SEL_Contacts contact = new SEL_Contacts();
        contact.selectContactByContactRole(acc.Id);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Contact_Role_s_at_Client__c includes (\'Pricing Contact\',\'Group Pricing Contact\') and  AccountId =:clientAccount and Inactive__c = false'), 'Query contains correct condition');
    }
    
    	@isTest
	static void selectContactByContactEmailTest() {
           Account testacc=new Account();
        testacc.name='Test Client';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        
        Contact conTest = new Contact();
        conTest.Email = 'Test@test.com';
        conTest.AccountId = acc.Id;
        conTest.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest.LastName = 'Test';
        insert conTest;
        SEL_Contacts contact = new SEL_Contacts();
        contact.selectContactByEmail(acc.Id ,conTest.Email);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isFalse(result.getCondition().containsIgnoreCase('Contact_Role_s_at_Client__c includes (\'Pricing Contact\',\'Group Pricing Contact\') and  AccountId =:clientAccount and Inactive__c = false'), 'Query contains correct condition');
    }
    
}