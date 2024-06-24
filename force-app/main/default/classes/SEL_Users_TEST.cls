/**
 * @description Test class for SEL_Users
 *
 * @author Ayush Garg (ayusgarg@deloitte.com)
 *
 * @date August 2020
 * Modifications Log
 * Ver   Date        Author   Modification
 * 1.0   05-19-2023  Tukelo Moseamo SFP-25090
 */
@IsTest(IsParallel=true)
private class SEL_Users_TEST
{
    
    @IsTest
	static void shouldSelectByUserName()
	{
        Test.startTest();
        SEL_Users.newInstance().selectByUserName(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Username IN :userNames'), 'Different condition than expected');
    }

    @IsTest
	static void shouldSelectWithAeNumber()
	{
        Test.startTest();
        SEL_Users.newInstance().selectWithAeNumber();
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('AE_Number__c != null'), 'Different condition than expected');
    }
    
    @IsTest
	static void shouldSelectByContactId()
	{
        Test.startTest();
        SEL_Users.newInstance().selectByContactId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('ContactId IN :ids'), 'Different condition than expected');
    }

    @IsTest
	static void shouldselectByIsActiveAndProfileNameWoSharing()
	{
        Test.startTest();
        SEL_Users.newInstance().selectByIsActiveAndProfileNameWoSharing(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Profile.Name IN :profileNames'), 'Different condition than expected');
    }
    
    @IsTest
	static void shouldSelectByIdWoSharing()
	{
        Test.startTest();
        SEL_Users.newInstance().selectByIdWoSharing(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN :ids'), 'Different condition than expected');
    } 
    
    @IsTest
	static void shouldSelectByPingUUID()
	{
        Test.startTest();
        SEL_Users.newInstance().selectByPingUUID(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Ping_UUID__c IN: idSet'), 'Different condition than expected');
    }
    
    @IsTest
	static void shouldSelectByName()
	{
        Test.startTest();
        SEL_Users.newInstance().selectByName(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Name IN :names'), 'Different condition than expected');
    }
    
    @IsTest
	static void shouldSelectByEmail()
	{
        Test.startTest();
        SEL_Users.newInstance().selectByEmail(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Email IN :emails'), 'Different condition than expected');
    }
    
    @IsTest
	static void shouldSelectWithContactFieldsById()
	{
        Test.startTest();
        SEL_Users.newInstance().selectWithContactFieldsById(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN :ids'), 'Different condition than expected');
	}

	@IsTest
	static void selectByUserCIBGlobalAndEmail()
	{
		Test.startTest();
		SEL_Users.newInstance().selectByUserCIBGlobalAndEmail('', new Set<String>());
		Test.stopTest();
		fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('User_CIB_Global_Area__c =: userCIBGlobal'), 'Different condition than expected');
	}

	@IsTest
	static void shouldSelectByAeNumber()
	{
		Test.startTest();
		SEL_Users.newInstance().selectByAENumber(new Set<String>());
		Test.stopTest();
		fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('AE_Number__c = :aeNumber'), 'Different condition than expected');
	}

	@IsTest
	static void testSelectUsersWithProfileByIds()
	{
		Test.startTest();
		SEL_Users.newInstance().selectUsersWithProfileByIds(new Set<Id>());
		Test.stopTest();
		fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN :ids'), 'Different condition than expected');
	}

	@IsTest
	static void testSelectByIdWithRoleName()
	{
		Test.startTest();
		SEL_Users.newInstance().selectByIdWithRoleName(new Set<Id>());
		Test.stopTest();
		fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN :ids'), 'Different condition than expected');
	}

	
	@IsTest
	static void testSelectByContactSyncId()
	{
		Test.startTest();
		SEL_Users.newInstance().selectByContactSyncId(new Set<Id>());
		Test.stopTest();
		fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
		Assert.isTrue(result.getCondition().containsIgnoreCase('Contact_Sync_ID__c IN :ids'), 'Different condition than expected');
	}
        @IsTest
    static void shouldselectWithContactSyncFieldByIds() {
        Test.startTest();
        SEL_Users.newInstance().selectWithContactSyncFieldByIds(new List<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN: id'),'Different condition than expected');
    }
         @IsTest
    static void shouldselectWithContactSyncFieldById() {
        Test.startTest();
        SEL_Users.newInstance().selectWithContactSyncFieldById('');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id =: id'),'Different condition than expected');
    }
           @IsTest
    static void shouldselectByContactSyncId() {
        Test.startTest();
        SEL_Users.newInstance().selectByContactSyncId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Contact_Sync_ID__c IN :ids'),'Different condition than expected');
    }
               @IsTest
    static void shouldselectByContactIds() {
        Test.startTest();
        SEL_Users.newInstance().selectByContactIds(new List<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Contact_Sync_ID__c IN :ids'),'Different condition than expected');
    }
                   @IsTest
    static void shouldselectUsersWithProfileByIds() {
        Test.startTest();
        SEL_Users.newInstance().selectUsersWithProfileByIds(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :ids'),'Different condition than expected');
    }
                       @IsTest
    static void shouldselectByIdWithRoleName() {
        Test.startTest();
        SEL_Users.newInstance().selectByIdWithRoleName(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :ids'),'Different condition than expected');
    }
    
    
}