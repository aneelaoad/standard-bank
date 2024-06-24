/**
 * @description       : 
 * @author            : TCK
 * @group             : 
* @last modified on  : 08-01-2023
* @last modified by  : Tukelo Moseamo
**/
@IsTest
public with sharing class DMN_Profile_TEST {
    /**
    * @description test static values
    **/
    @IsTest
    public static void testConstructedProfile() {
    
        Assert.areEqual('Custom Standard Lightning Client Coverage Exec Mobile User Insights', DMN_Profile.CLIENT_COVERAGE_EXEC_MOBILE_USER_INSIGHTS,'Correct');
        Assert.areEqual('Custom Standard Lightning Client Coverage Mobile User Insights', DMN_Profile.CLIENT_COVERAGE_MOBILE_USER_INSIGHTS,'Correct');
        Assert.areEqual('Custom Standard Lightning Generic Business Unit Mobile User', DMN_Profile.GENERIC_BUSINESS_UNIT_MOBILE_USER,'Correct');
        Assert.areEqual('Custom Standard Lightning Generic Business Unit Mobile User Insights', DMN_Profile.GENERIC_BUSINESS_UNIT_MOBILE_USER_INSIGHTS,'Correct');
        Assert.areEqual('Business Administrator', DMN_Profile.BUSINESS_ADMINISTRATOR,'Correct');
        Assert.areEqual('Custom KYC User Mobile', DMN_Profile.KYC_USER,'Correct');
        Assert.areEqual('Personal Business Banking Custom Std User - Mobile', DMN_Profile.PERSONAL_BUSINESS_BANKING_CUSTOM_STD_USER_MOBILE,'Correct');
        Assert.areEqual('Read Only', DMN_Profile.READ_ONLY,'Correct');
        Assert.areEqual('Custom Read Only Mobile', DMN_Profile.READ_ONLY_MOBILE,'Correct');
        Assert.areEqual('System Administrator', DMN_Profile.SYSTEM_ADMINISTRATOR,'Correct');
        Assert.areEqual('Api User', DMN_Profile.API_USER,'Correct');
        Assert.areEqual('Client Service User', DMN_Profile.CLIENT_SERVICE_USER,'Correct');
        Assert.areEqual('OneHub Community User Login', DMN_Profile.ONE_HUB_COMMUNITY,'Correct');
        Assert.areEqual('OneHub Administrator', DMN_Profile.ONE_HUB_ADMINISTRATOR,'Correct');
        Assert.areEqual('Custom Base Customer Community Plus Login User', DMN_Profile.CUSTOM_BASE_CUSTOMER_COMMUNITY_PLUS_LOGIN_USER,'Correct');
        Assert.areEqual('Commercial Banking Custom Std User', DMN_Profile.COMMERCIAL_BANKING_CUSTOM_STD_USER,'Correct');
        Assert.areEqual('Commercial Banking Custom Std User - Mobile', DMN_Profile.COMMERCIAL_BANKING_CUSTOM_STD_USER_MOBILE,'Correct');
        Assert.areEqual('BCC Custom Std User - Mobile', DMN_Profile.BCC_CUSTOM_STD_USER_MOBILE,'Correct');
        Assert.areEqual('BCC AR Custom Std User - Mobile', DMN_Profile.BCC_AR_CUSTOM_STD_USER_MOBILE,'Correct');
        Assert.areEqual('Events App Community User', DMN_Profile.EVENTS_APP_COMMUNITY,'Correct');
        
    }
    
    /**
    * @description test method for isCommBUser
    * @author Tukelo Moseamo | 07-27-2023 
    **/
    @isTest
    static void testIscommBUser() {
        User testUser = AOB_DAL_TestFactory.createUser('Commercial Banking Custom Std User', true);
        System.runAs(testUser){
            Test.startTest();
            Boolean isCommBUser = DMN_Profile.isCommBUser();
            Boolean isBusinessUser = DMN_Profile.isBusinessUser();
            Test.stopTest();
            Assert.isTrue(isCommBUser, 'user is not commercial Banking');
            Assert.isFalse(isBusinessUser, 'user is Business banking user');
    }
}    
    /**
	* @description test method for isBusinessUser
    * @author Tukelo Moseamo | 07-27-2023 
    **/
    @isTest
    static void testIsBusinessUser() {
        User testUser = AOB_DAL_TestFactory.createUser('BCC Custom Std User - Mobile', true);
        System.runAs(testUser){
            Test.startTest();
            Boolean isBusinessUser = DMN_Profile.isBusinessUser();
            Boolean isCommBUser = DMN_Profile.isCommBUser();
            Test.stopTest();
            Assert.isFalse(isCommBUser, 'user is  commercial Banking user');
            Assert.isTrue(isBusinessUser, 'user is not Business banking user');
        }
    }
    
    /**
    * @description test method for isEnterpriseUser
    * @author Tukelo Moseamo | 07-27-2023 
    **/
    @isTest
    static void testIsEnternpriseUser() {
        User testUser = AOB_DAL_TestFactory.createUser('Personal Business Banking Custom Std User - Mobile', true);
        System.runAs(testUser){
            Test.startTest();
            Boolean isEntUser = DMN_Profile.isEnterpriseUser();
            Boolean isBusinessUser = DMN_Profile.isBusinessUser();
            Test.stopTest();
            Assert.isTrue(isEntUser, 'user is not enterprise user');
            Assert.isFalse(isBusinessUser, 'user is Business banking user');
        }
    }
    
}