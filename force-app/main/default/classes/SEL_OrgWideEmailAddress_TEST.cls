/*****************************************************************************************
 *@Name of the Class: SEL_OrgWideEmailAddress_TEST
 *@Description      : SFP-11298 Add to calendar from email functionality
 *@Author           : Likhitha Karusala
 *@Created Date     : 06-13-2022
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097 Added Methods on SEL_OrgWideEmailAddress 
 ******************************************************************************************/
@IsTest
private class SEL_OrgWideEmailAddress_TEST {
     /**
    * @description shouldSelectByAddress queried by address string
    */
    @IsTest
    static void shouldSelectByAddress() {
        String address;
        Test.startTest();
        SEL_OrgWideEmailAddress.newInstance().selectByAddress(address);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Address =: address'),true, 'Query contains Address =: address');
    }
     /**
    * @description shouldselectByDisplayName queried by display name 
    */
        @IsTest
    static void shouldselectByDisplayName() {
        String displayName= [select id,Address, DisplayName from OrgWideEmailAddress where DisplayName = :ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_PRICING_AND_BILLING].DisplayName;
        Test.startTest();
        SEL_OrgWideEmailAddress.newInstance().selectByDisplayName(displayName);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('DisplayName =: displayName'),true, 'Query contains DisplayName =: displayName');
    }
}