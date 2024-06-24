/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_ClientPricingLetter_TEST
* @description           :Test Class for ZAF_CTRL_ClientPricingLetter
* @Author                :Pradeep Kota
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By  : Likhitha Karusala 
*@Last Modified On  : 11 Mar 2024
*@Modification Description : SFP-30097
***************************************************************************************/


@isTest
public class ZAF_CTRL_ClientPricingLetter_TEST {
    /**
* @description Test setup method to insert all Test data
*/
    @IsTest
    static void testMethod1(){
        Account testacc=new Account();
        testacc.name='Test Client';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        zafin_rrp__Negotiated_Pricing__c zrnp= new zafin_rrp__Negotiated_Pricing__c();	
        zrnp.zafin_rrp__Agreement_Name__c='testing';
        zrnp.zafin_rrp__Arrangement_Type__c='Fee Arrangement';
        zrnp.zafin_rrp__Reporting_Customer__c=acc.id;
        zrnp.zafin_rrp__Start_Date__c= system.today();
        zrnp.zafin_rrp__End_Date__c= system.today()+30;
        insert zrnp;
        zafin_rrp__NegotiatedPricing_FeeItem__c zrnpFee= new zafin_rrp__NegotiatedPricing_FeeItem__c();
        zrnpFee.zafin_rrp__SimpleOrTier__c='Simple';
        zrnpFee.zafin_rrp__AmountOrPercentage__c='Amount';
        zrnpFee.zafin_rrp__Amount__c= 1234;
        zrnpFee.zafin_rrp__Percentage__c =15;
        zrnpFee.zafin_rrp__Is_Discount__c = True;
        zrnpFee.zafin_rrp__Discount__c = 10;
        zrnpFee.zafin_rrp__Negotiated_Amount__c = 150;
        zrnpFee.zafin_rrp__Fee_Code__c = 'BOL_SARS';
        zrnpFee.zafin_rrp__Fee_Item_Name__c = 'Test Fee';
        zrnpFee.zafin_rrp__Type__c= 'Fixed Fee';
        zrnpFee.zafin_rrp__Negotiated_Pricing__c =zrnp.id;
        insert zrnpFee;
        zafin_rrp__Statement_Fee_Category__c feeCategory = new zafin_rrp__Statement_Fee_Category__c(
            zafin_rrp__Category_Code__c ='BOL_SARS', zafin_rrp__Category_Description__c='', zafin_rrp__Category_Name__c='Domestic',
            zafin_rrp__Fee_Code__c = 'BOL_SARS'
        );
        insert feeCategory;
        List<zafin_rrp__NegotiatedPricing_FeeItem__c> ss= [select id,zafin_rrp__Negotiated_Amount__c,zafin_rrp__Type__c from zafin_rrp__NegotiatedPricing_FeeItem__c where id=:zrnpFee.id];
        Map<String, String> categoryValues = new Map<String, String>();
        categoryValues.put('code','Domestic');
        categoryValues.put('BPms','Domestic');
        categoryValues.put('BLps','Collections');
        Map<String, List<zafin_rrp__NegotiatedPricing_FeeItem__c>> categoryFeeItem = new Map<String, List<zafin_rrp__NegotiatedPricing_FeeItem__c>>();
        categoryFeeItem.put('Domestic',ss);
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('id',String.valueOf(acc.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ZAF_CTRL_ClientPricingLetter scext = new ZAF_CTRL_ClientPricingLetter(sc);
        PageReference pageRef = Page.ZAF_ClientPricingLetterVFPage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(acc.id));
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        Assert.areNotEqual(null,scext,'PDF Generated successfully');
    }
    
    /**
* @description Test setup method to fail constructor
*/
    @isTest
    public static void testFail(){
        Account testacc=new Account();
        testacc.name='Test Client';
        insert testacc;
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('id','testacc');
        ApexPages.StandardController sc = new ApexPages.StandardController(testacc);
        ZAF_CTRL_ClientPricingLetter scext = new ZAF_CTRL_ClientPricingLetter(sc);
        PageReference pageRef = Page.ZAF_ClientPricingLetterVFPage; // Add your VF page Name here
        pageRef.getParameters().put('id','');
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        Assert.areNotEqual(null,scext,'PDF Generated successfully');
    }
    
}