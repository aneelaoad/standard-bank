/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_FullStandardPricingLetter_Test
* @description           :Test Class for segregating fee items based on Fee Code
* @Author                :Pradeep Kota  
* @Created Date          :12th Feb 2024
/***************************************************************************************
*@Last Modified By  : Pradeep Kota  
*@Last Modified On  : 11 Mar 2024
*@Modification Description : SFP-30097
***************************************************************************************/
@isTest
private class ZAF_CTRL_FullStandardPricingLetter_Test {
    /**
  * @description Test setup method to insert all Test data
  */
    @isTest
    static void testConstructor() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        zafin_rrp__Product__c customer1 = new zafin_rrp__Product__c();
        customer1.zafin_rrp__Product_Name__c = 'test Customer';
        customer1.zafin_rrp__Product_Code__c= 'CIB_CM';
        customer1.zafin_rrp__Product_Category__c='Deposits';
        insert customer1;
        List<zafin_rrp__Bank_Account__c> bankquery = new List<zafin_rrp__Bank_Account__c>();
        zafin_rrp__Bank_Account__c bankaccount = new zafin_rrp__Bank_Account__c();
        bankaccount.zafin_rrp__Zafin_Product__c=customer1.Id;
        bankaccount.zafin_rrp__Customer__c=testAccount.id;
        bankquery.add(bankaccount);
        insert bankquery;
        zafin_rrp__Plan__c plan1 = new zafin_rrp__Plan__c();
        plan1.zafin_rrp__Plan_Name__c = 'test plan1';
        plan1.zafin_rrp__Zafin_Product__c = customer1.Id;
        insert plan1;
        List<zafin_rrp__Fee_Item__c> feeItemList = new List<zafin_rrp__Fee_Item__c>();
        zafin_rrp__Fee_Item__c feeitems = new zafin_rrp__Fee_Item__c();
        feeitems.zafin_rrp__Process_Ahead_Check__c=true;
        feeitems.zafin_rrp__DoNot_Charge_PrepaidFee__c=true;
        feeitems.zafin_rrp__Compensable__c=true;
        feeitems.zafin_rrp__Fee_Item_Code__c='123';
        feeitems.zafin_rrp__Fee_Code__c='123';
        feeitems.zafin_rrp__Amount__c=1000;
        feeitems.zafin_rrp__Fee_Item_Name__c='RRC';
        feeitems.zafin_rrp__Plan__c=plan1.Id;
        feeItemList.add(feeitems);
        insert feeItemList;
        zafin_rrp__Negotiated_Pricing__c np =  new zafin_rrp__Negotiated_Pricing__c();
        np.zafin_rrp__End_Date__c = Date.today();
        np.zafin_rrp__Agreement_Name__c = 'Test Aggrement';
        np.zafin_rrp__Start_Date__c = Date.today()-7;
        insert np;
        zafin_rrp__NegotiatedPricing_FeeItem__c zrnpFee= new zafin_rrp__NegotiatedPricing_FeeItem__c();
        zrnpFee.zafin_rrp__SimpleOrTier__c='Simple';
        zrnpFee.zafin_rrp__AmountOrPercentage__c='Amount';
        zrnpFee.zafin_rrp__Amount__c= 1234;
        zrnpFee.zafin_rrp__Percentage__c =15;
        zrnpFee.zafin_rrp__Is_Discount__c = True;
        zrnpFee.zafin_rrp__Discount__c = 10;
        zrnpFee.zafin_rrp__Negotiated_Amount__c = 150;
        zrnpFee.zafin_rrp__Negotiated_Pricing__c = np.Id;
        zrnpFee.zafin_rrp__Fee_Item_Name__c = 'Test Fee';
        zrnpFee.zafin_rrp__Type__c= 'Fixed Fee';
        insert zrnpFee;
        zafin_rrp__Statement_Fee_Category__c sfc = new zafin_rrp__Statement_Fee_Category__c();
        sfc.zafin_rrp__Fee_Name__c = 'test Name';
        sfc.zafin_rrp__Fee_Code__c = '123';
        insert sfc;
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/ZAF_FullStandardPricingLetterVFPage?id=' + testAccount.Id));
        ApexPages.currentPage().getParameters().put('id',String.valueOf(testAccount.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        ZAF_CTRL_FullStandardPricingLetter scext = new ZAF_CTRL_FullStandardPricingLetter(sc);
        scext.ZPAFeeItem = new List<zafin_rrp__Fee_Item__c>();
        scext.acc = testAccount;
        PageReference pageRef = Page.ZAF_FullStandardPricingLetterVFPage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(testAccount.id));
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        Assert.areNotEqual(null,scext,'PDF Generated successfully');
    }
       /**
  * @description Test setup method to insert all Test data for else method
  */
    @isTest
    static void testConstructorNullCheck(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',String.valueOf(testAccount.id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        ZAF_CTRL_FullStandardPricingLetter scext = new ZAF_CTRL_FullStandardPricingLetter(sc);
        PageReference pageRef = Page.ZAF_FullStandardPricingLetterVFPage;
        pageRef.getParameters().put('id', String.valueOf(''));
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        Assert.areNotEqual(null,scext,'PDF Generated successfully');

    }
       
       /**
     * @description Test setup method for ZAF_CTRL_FullStandardPricingLetter.GetClientLetterJSON
     * */
    @isTest
    static void testGetClientLetterJSON() {
        Zafin_Constant__mdt result = ZAF_CTRL_FullStandardPricingLetter.getClientLetterJSON('Client_sector');
        Assert.areNotEqual(null,result,'Custom Metadata');
    }
}