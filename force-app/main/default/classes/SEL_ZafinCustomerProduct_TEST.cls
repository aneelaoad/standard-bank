/***************************************************************************************
* @Name of the Class     :SEL_ZafinCustomerProduct_TEST
* @description           :SFP-36983 Test Selector class for SEL_ZafinFeeItem SObject
* @Author                :Pradeep Kota 
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Pradeep Kota 
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/
@isTest
public class SEL_ZafinCustomerProduct_TEST {
    @isTest
    static void selectZafinCustomerProduct(){
        SEL_ZafinCustomerProduct zcp = new SEL_ZafinCustomerProduct();
        List<zafin_rrp__Bank_Account__c> queryList=zcp.selectZafinCustomerProduct();
        Assert.areEqual(0, queryList.size(), 'msg' );
    }
    @isTest
    static void selectZafinCustomerProductById(){
        Id recordId;
        SEL_ZafinCustomerProduct zcp = new SEL_ZafinCustomerProduct();
        zcp.selectZafinCustomerProductById(recordId); 
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('zafin_rrp__Customer__r.id = :recordId'), true,'success');
    }
}