/***************************************************************************************
* @Name of the Class     :SEL_ZafinFeeItem_TEST
* @description           :SFP-36983 Selector class for zafin_rrp__Fee_Item__c SObject
* @Author                :Likhitha Karusala
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Likhitha Karusala 
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/
@IsTest
public class SEL_ZafinFeeItem_TEST {
    @IsTest
    static void selectZafinFeeItemAll() {
        zafin_rrp__Plan__c plan = new zafin_rrp__Plan__c();
        plan.zafin_rrp__Currency_Code__c='Ind';
        plan.zafin_rrp__Plan_Code__c='code';
        insert plan;
        zafin_rrp__Fee_Item__c negotiated = new zafin_rrp__Fee_Item__c();
        negotiated.zafin_rrp__Fee_Item_Code__c='BCV';
        negotiated.zafin_rrp__Fee_Code__c='CVV';
        negotiated.zafin_rrp__Amount__c=32;
        negotiated.zafin_rrp__Fee_Item_Name__c='BOX';
        negotiated.zafin_rrp__Plan__c=plan.Id;
        insert negotiated;
        List<zafin_rrp__Fee_Item__c> feeitemresult = new SEL_ZafinFeeItem().selectZafinFeeItemAll();
        Test.startTest();
        Test.stopTest();
        Assert.areNotEqual(0,feeitemresult.size(),'msg');
    }
    @IsTest
    static void selectZafinFeeItemByProductIds() {
        List<zafin_rrp__Product__c> productList = new List<zafin_rrp__Product__c>();
        zafin_rrp__Product__c product1 = new zafin_rrp__Product__c();
        product1.zafin_rrp__Fee_Negotiable__c=true;
        product1.zafin_rrp__FeePlan_Code__c='feeplancode';
        product1.zafin_rrp__FeePlan_Name__c='Test';
        productList.add(product1);
        zafin_rrp__Product__c product2 = new zafin_rrp__Product__c();
        product2.zafin_rrp__Fee_Negotiable__c=true;
        product2.zafin_rrp__FeePlan_Code__c='feeplancode1';
        product2.zafin_rrp__FeePlan_Name__c='Test2';
        productList.add(product2);
        insert productList;
        zafin_rrp__Plan__c plan = new zafin_rrp__Plan__c();
        plan.zafin_rrp__Currency_Code__c='Ind';
        plan.zafin_rrp__Plan_Code__c='code';
        plan.zafin_rrp__Zafin_Product__c=productList[0].id;
        insert plan;
        zafin_rrp__Fee_Item__c negotiated = new zafin_rrp__Fee_Item__c();
        negotiated.zafin_rrp__Fee_Item_Code__c='BCV';
        negotiated.zafin_rrp__Fee_Code__c='CVV';
        negotiated.zafin_rrp__Amount__c=32;
        negotiated.zafin_rrp__Fee_Item_Name__c='BOX';
        negotiated.zafin_rrp__Plan__c=plan.Id;
        insert negotiated; 
        Set<Id> testProductIds = new Set<Id>(); 
        testProductIds.add(productList[0].id);
        Test.startTest();
        SEL_ZafinFeeItem negotiatedRec = new SEL_ZafinFeeItem();
        negotiatedRec.selectZafinFeeItemByProductIds(testProductIds);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areNotEqual(result.getCondition(),'null', 'Query contains zafin_rrp__Plan__r.zafin_rrp__Zafin_Product__c IN :recordId');
    }
}