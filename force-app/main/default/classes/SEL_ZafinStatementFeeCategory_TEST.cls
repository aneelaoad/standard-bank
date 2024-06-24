/***************************************************************************************
* @Name of the Class     :SEL_ZafinStatementFeeCategory_TEST
* @description           :SFP-36983 Test Selector class for SEL_ZafinStatementFeeCategory SObject
* @Author                :Likhitha Karusala
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Likhitha Karusala 
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-33357
***************************************************************************************/
@IsTest
public class SEL_ZafinStatementFeeCategory_TEST {
    static void getSObjectFieldList(){
        SEL_ZafinStatementFeeCategory getobjfields = new SEL_ZafinStatementFeeCategory();
        getobjfields.getSObjectFieldList();
    }
        @IsTest
        static void selectZafinStatementFeeCategory() {
            zafin_rrp__Statement_Fee_Category__c feeCategory = new zafin_rrp__Statement_Fee_Category__c();
            feeCategory.zafin_rrp__Category_Code__c = 'BPlm';
            feeCategory.zafin_rrp__Category_Description__c = 'BPlm';
            feeCategory.zafin_rrp__Category_Name__c = 'BPlm';
            insert feeCategory;
            Test.startTest();
            SEL_ZafinStatementFeeCategory fee = new SEL_ZafinStatementFeeCategory();
            fee.selectZafinStatementFeeCategory();
            Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areNotEqual(result.getCondition(),'null', 'Query contains Id IN: ids');
    }
     @IsTest
    private static void getSObjectFieldListTest(){
        Test.startTest();
        SEL_ZafinStatementFeeCategory app = new SEL_ZafinStatementFeeCategory();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }
}