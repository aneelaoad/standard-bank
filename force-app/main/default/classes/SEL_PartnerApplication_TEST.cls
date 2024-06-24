/**
 * @description       : Test class for SEL_PartnerApplication
 * @author            : Jaco de Lange
 * @last modified on  : 01-25-2024
 * @last modified by  : Jaco de Lange
**/
@isTest(IsParallel=true)
private class SEL_PartnerApplication_TEST {

    @IsTest
    static void selPrimaryContactId(){
        Test.startTest();
        SEL_PartnerApplication.newInstance().selectByPrimaryContactId (new Set<id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('PP_PrimaryContact__c IN: idSet'), 'Not expected condition');    
    }
    @IsTest
    static void selById(){
        Test.startTest();
        SEL_PartnerApplication.newInstance().selectById (new Set<id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN: idSet'), 'Not expected condition');    
    }
    @IsTest
    static void selByEmailPrimaryContactId(){
        Test.startTest();
        SEL_PartnerApplication.newInstance().selectByEmailPrimaryContactId(new Set<String>(), '', '');
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('PP_PrimaryContact__r.Email IN: emails'), 'Not expected condition');    
    }
}