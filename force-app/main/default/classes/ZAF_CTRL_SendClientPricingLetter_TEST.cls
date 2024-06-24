/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_SendClientPricingLetter_TEST
* @description           :Test Class for ZAF_CTRL_SendClientPricingLetter
* @Author                :Pradeep Kota  
* @Created Date          :26 Aug 2023
/***************************************************************************************
*@Last Modified By  : Pradeep Kota  
*@Last Modified On  : 26 Oct 2023
*@Modification Description : SFP-30098
***************************************************************************************/
@isTest
public class ZAF_CTRL_SendClientPricingLetter_TEST {
  /**
  * @description Test setup method to insert all Test data
  */
    @isTest
    static void testmethod1(){
        Account testacc=new Account();
        testacc.name='Test Client';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        Contact conTest = new Contact();
        conTest.Email = 'Test@test.com';
        conTest.AccountId = acc.Id;
        conTest.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest.LastName = 'Test';
        insert conTest;
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
        Test.StartTest(); 
        List<contact> result = ZAF_CTRL_SendClientPricingLetter.sendEmailToController(zrnp.Id);
        Test.StopTest();
        Assert.areNotEqual(null,result,'Client Related contacts shown successfully');
    }
  /**
  * @description Test setup method for ZAF_CTRL_SendClientPricingLetter.sendCustomEmail
  */
    @isTest
    static void testSendCustomEmail() {
        
        Account testacc=new Account();
        testacc.name='Test Client';
        testacc.CIF__c = 'Zafin';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        Contact conTest = new Contact();
        conTest.Email = 'customemail@example.com';
        conTest.AccountId = acc.Id;
        conTest.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest.LastName = 'Test';
        conTest.FirstName = 'Test';
        insert conTest;
        Contact conTest1 = new Contact();
        conTest1.Email = 'hello@gmail.com';
        conTest1.AccountId = acc.Id;
        conTest1.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest1.LastName = 'Test2';
        conTest1.FirstName = 'Test2';
        insert conTest1;
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
        System.runAs(new User(Id = UserInfo.getUserId())) {
            EmailTemplate eml = new EmailTemplate(Subject='hello',Description ='client pricing letter',name ='Client pricing Letter 2023',HtmlValue = 'dear {!zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Agreement_Name__c}',developerName = 'test', Body='thank u',isActive = true,TemplateType = 'text', FolderId = UserInfo.getUserId());
            insert eml;
        }
        List<String> email = new List<String> {'customemail@example.com','hello@gmail.com'};
        Test.startTest();
        String result = ZAF_CTRL_SendClientPricingLetter.sendCustomEmail(zrnp.Id,email);
        Test.stopTest();
       Assert.areNotEqual('Success',result,'Email sent Successfully');
    }
}