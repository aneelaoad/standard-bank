/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_SaveClientPricingLetter_TEST
* @description           :Test Class for ZAF_CTRL_SaveClientPricingLetter
* @Author                :Pradeep Kota  
* @Created Date          :27th Sep 2023
/***************************************************************************************
*@Last Modified By  : Pradeep Kota  
*@Last Modified On  : 15 Mar 2024
*@Modification Description : SFP-30097
***************************************************************************************/
@isTest
public class ZAF_CTRL_SaveClientPricingLetter_TEST {
  /**
  * @description Test setup method to insert all Test data
  */
    @isTest
    static  void downloadTest(){
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
        zrnpFee.zafin_rrp__Fee_Item_Name__c = 'Test Fee';
        zrnpFee.zafin_rrp__Type__c= 'Fixed Fee';
        zrnpFee.zafin_rrp__Negotiated_Pricing__c =zrnp.id;
        insert zrnpFee;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = zrnp.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'I';
        cdl.Visibility ='InternalUsers';
        Insert cdl;        
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('id',String.valueOf(zrnp.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(zrnp);
        ZAF_CTRL_SaveClientPricingLetter savepdf= new ZAF_CTRL_SaveClientPricingLetter(sc);
        PageReference pageRef = Page.ZAF_SaveClientPricingLetterVFPage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(zrnp.id));
		savepdf.downPdf();
        Test.setCurrentPage(pageRef);
        Test.StopTest();
        Assert.areNotEqual(null,savepdf,'Saved the PDF successfully in Documents');
    }
}