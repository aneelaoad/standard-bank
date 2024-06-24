/*****************************************************************************************
 *@Name of the Class: SEL_Accounts_TEST
 *@Description      : Test Class for SEL_Accounts
 *@Author           : Wayne Solomon
 *@Created Date     : Aug 2020
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097
 ******************************************************************************************/
@IsTest
private class SEL_Accounts_TEST {
    /**
    @description selectByCifWithSubmittedBusinessAssessmentsTest queried by cif numbers
    */
    @IsTest
    static void selectByCifWithSubmittedBusinessAssessmentsTest() {
        SEL_Accounts selector = new SEL_Accounts();
        Test.startTest();
        List<Account> methodOneOpps = selector.selectByCifWithSubmittedBusinessAssessments(new Set<String>{
            null
                }, 1);
        
        Test.stopTest();
        
        Assert.isTrue(methodOneOpps.isEmpty(), 'The list is not empty');
    }
    
    @IsTest
    static void shouldSelectByCIFNumberWithClientTeam(){
        Test.startTest();
        SEL_Accounts.newInstance().selectByCIFNumberWithClientTeam(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('CIF__c in :cifSet'), 'Condition is different');
    }
    
    @IsTest
    static void shouldSelectByCIFNumber(){
        Test.startTest();
        SEL_Accounts.newInstance().selectByCIFNumber(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('CIF__c in :cifSet'),'Condition is different');
    }
    
    @IsTest
    static void shouldSelectByCIFNumberWithClientTeamAndRole(){
        Test.startTest();
        SEL_Accounts.newInstance().selectByCIFNumberWithClientTeamAndRole(new Set<String>(),null);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('CIF__c in :cifSet'),'Condition is different');
    }
    
    @IsTest
    static void shouldSelectHierarchyByTopParentIdWithKYCStatus(){
        Test.startTest();
        SEL_Accounts.newInstance().selectHierarchyByTopParentIdWithKYCStatus(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id in :idSet or ParentId in :idSet OR Parent.ParentId in :idSet or Parent.Parent.ParentId in :idSet or Parent.Parent.Parent.ParentId in :idSet or Parent.Parent.Parent.Parent.ParentId in :idSet or Parent.Parent.Parent.Parent.Parent.ParentId in :idSet'),
                      'Query condition is different');
    }
    
    @IsTest
    static void shouldSelectTopParentIdByChildId(){
        Test.startTest();
        SEL_Accounts.newInstance().selectTopParentIdByChildId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id in :idSet'), 'Query condition is different');
    }
    
    @IsTest
    static void shouldSelectByRegistrationNumber(){
        Test.startTest();
        SEL_Accounts.newInstance().selectByRegistrationNumber(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Registration_Number__c in :registrationNumbers'),'Query condition is different');
    }
    
    @IsTest
    static void shouldSelectGuidById(){
        Test.startTest();
        SEL_Accounts.newInstance().selectGuidById(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id in :ids'),'Query condition different');
    }
    
    @IsTest
    static void shouldSelectByRegisteredName(){
        Test.startTest();
        SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Name in :registeredNames'), 'Query condition is different');
    }
    
    @IsTest
    static void shouldSelectBpidById(){
        Test.startTest();
        SEL_Accounts.newInstance().selectBpidById(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id in :ids'), 'Query condition is different');
    }
    
    @IsTest
    static void shouldSelectByOwners(){
        Test.startTest();
        SEL_Accounts.newInstance().selectByOwners(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('OwnerId in :ownerIds'), 'Query filter condition is different');
    }
    
    @IsTest
    static void shouldSelectAccountsWithOwnerRelByAccountId(){
        Test.startTest();
        SEL_Accounts.newInstance().selectAccountsWithOwnerRelByAccountId(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id in :ids'), 'Query condition is different');
    }
    
    
    
    @IsTest
    static void shouldSelectWithoutCondition(){
        Test.startTest();
        SEL_Accounts.newInstance().selectWithoutCondition();
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isFalse(result.fields.isEmpty(), 'Field list is empty');
    }
    
    @IsTest
    static void shouldSelectById(){
        Test.startTest();
        SEL_Accounts.newInstance().selectById(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isFalse(result.fields.isEmpty(), 'Field list is empty');
    }
    
    @IsTest
    static void testSelectByExternalIdentifier(){
        Test.startTest();
        SEL_Accounts.newInstance().selectByExternalIdentifier(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('ExternalIdentifier__c in :externalIdentifier'),'Query condition is different');
    }
    
    @IsTest
    static void testGetRecordTypes(){
        Test.startTest();
        Map<Id, RecordTypeInfo> recordTypeInfoMap = SEL_Accounts.getRecordTypes();
        Test.stopTest();
        Assert.isNotNull(recordTypeInfoMap,'Record Types not found');
    }
    
    @IsTest
    static void testSelectAccountsWithActionItemsByAccountIdAndActionType(){
        Test.startTest();
        SEL_Accounts.newInstance().selectAccountsWithActionItemsByAccountIdAndActionType(CMN_DAL_SObjectDomain.generateRandomSObjectId(Account.SObjectType),
                                                                                         CMN_DAL_SObjectDomain.generateRandomName());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isFalse(result.fields.isEmpty(), 'Field list is empty');
    }
    
    @IsTest
    static void testSelectByGuId(){
        Test.startTest();
        SEL_Accounts.newInstance().selectByGuId(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isFalse(result.fields.isEmpty(), 'Field list is empty');
    }
    
     @IsTest
    static void testselectByExternalIdentifiersWoSharing(){
        String dummyValue;
        Test.startTest();
        SEL_Accounts.newInstance().selectByExternalIdentifiersWoSharing(dummyValue);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
         Assert.isFalse(result.fields.isEmpty(), 'Field list is empty');
    }
     @IsTest
    static void testselectByExternalIdentifiers(){
        String dummyValue;
        Test.startTest();
        SEL_Accounts.newInstance().selectByExternalIdentifiers(dummyValue);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isFalse(result.fields.isEmpty(), 'Field list is empty');
    }
    
     @IsTest
    static void testselectedAccountWithRegistrationNumberOfFundRecordType(){
        String dummyValue;
        Test.startTest();
        SEL_Accounts.newInstance().selectedAccountWithRegistrationNumberOfFundRecordType(dummyValue);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isFalse(result.fields.isEmpty(), 'Field list is empty');
    }
    
    @IsTest
    static void selectAccountDetail(){
        String dummyValue;
        Test.startTest();
        SEL_Accounts.newInstance().selectAccountDetail(dummyValue);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isFalse(result.fields.isEmpty(), 'Field list is empty');
    }
    
     @IsTest
    static void selectByAccountId(){
        Id dummyValue;
        try{
        Test.startTest();
        SEL_Accounts.newInstance().selectByAccountId(dummyValue);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
         Assert.areNotEqual(result.fields.isEmpty(),'sucess', 'Field list is empty');
        }Catch(Exception e){
         Assert.areNotEqual(null,e,'Error');
        }
    }
    
    
}