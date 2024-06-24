/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_StandardPricingLetter_TEST
* @description           :Test Class for sending an email to the client related contact with Client Pricing Letter PDF attachment
* @Author                :Pradeep Kota  
* @Created Date          :12th Feb 2024
/***************************************************************************************
*@Last Modified By  : Pradeep Kota  
*@Last Modified On  : 06 Mar 2024
*@Modification Description : SFP-30097
***************************************************************************************/
@isTest
private class ZAF_CTRL_StandardPricingLetter_TEST {
    /**
  * @description Test setup method to insert all Test data
  */
    @isTest
    static void testSendEmailToController() 
    {
        Account testacc=new Account();
        testacc.name='Test Client';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        Contact conTest = new Contact();
        conTest.Email = 'Test@test.com';
        conTest.AccountId = testacc.Id;
        conTest.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest.LastName = 'Test';
        insert conTest;
        zafin_rrp__Negotiated_Pricing__c zrnp= new zafin_rrp__Negotiated_Pricing__c();	
        zrnp.zafin_rrp__Agreement_Name__c='testing';
        zrnp.zafin_rrp__Arrangement_Type__c='Fee Arrangement';
        zrnp.zafin_rrp__Reporting_Customer__c=testacc.id;
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
        List<contact> result = ZAF_CTRL_StandardPricingLetter.sendEmailToController(acc.Id);
        Test.StopTest();
        Assert.areNotEqual(null,result,'Client Related contacts shown successfully');
    }
     /**
  * @description Test setup method for ZAF_CTRL_StandardPricingLetter.sendCustomEmail
  */
    @isTest
    static void testSendCustomEmail() 
    {
        Account testacc=new Account();
        testacc.name='Test Client';
        testacc.CIF__c = 'Zafin';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        Contact conTest = new Contact();
        conTest.Email = 'customemail@example.com';
        conTest.AccountId = acc.Id;
        conTest.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest.FirstName = 'Test';
        conTest.LastName = 'Test';
        insert conTest;
        Contact conTest1 = new Contact();
        conTest1.Email = 'hello@gmail.com';
        conTest1.AccountId = acc.Id;
        conTest1.Contact_Role_s_at_Client__c ='Group Pricing Contact';
        conTest1.FirstName = 'Test2';
        conTest1.LastName = 'Test';
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
        string feature='adhoc';
        string sector='Corporate';
        Test.startTest();
        String result = ZAF_CTRL_StandardPricingLetter.sendCustomEmail(acc.Id, email,feature,sector);
        Test.stopTest();
        Assert.areEqual('success',result,'Email sent Successfully');
       
    }
    /**
     * @description Test setup method for ZAF_CTRL_StandardPricingLetter.SendFullStandardCustomEmail
     * */
   @isTest
    static void testSendFullStandardCustomEmail() 
    {
         
        Account testacc=new Account();
        testacc.name='Test Client';
        testacc.CIF__c = 'Zafin';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        Contact conTest = new Contact();
        conTest.Email = 'customemail@example.com';
        conTest.AccountId = acc.Id;
        conTest.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest.FirstName = 'Test';
        conTest.LastName = 'Test';
        insert conTest;
        Contact conTest1 = new Contact();
        conTest1.Email = 'hello@gmail.com';
        conTest1.AccountId = acc.Id;
        conTest1.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest1.FirstName = 'Test2';
        conTest1.LastName = 'Test';
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
        string feature ='adhoc';
        string sector ='Corporate';
        Test.startTest();
        String result = ZAF_CTRL_StandardPricingLetter.sendFullStandardCustomEmail(acc.Id,email,feature,sector);
        Test.stopTest();
        Assert.areEqual('success',result,'Email sent Successfully');
        
    }
    
    
      /**
     * @description Test setup method for ZAF_CTRL_StandardPricingLetter.SendFullStandardCustomEmail
     * */
   @isTest
    static void failtestSendFullStandardCustomEmail() 
    {
        Account testacc=new Account();
        testacc.name='Test Client';
        testacc.CIF__c = 'Zafin';
        insert testacc;
        Account acc=[select id, name from Account where name='Test Client'];
        Contact conTest = new Contact();
        conTest.Email = 'customemail@example.com';
        conTest.AccountId = acc.Id;
        conTest.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest.FirstName = 'Test';
        conTest.LastName = 'Test';
        insert conTest;
        Contact conTest1 = new Contact();
        conTest1.Email = 'hello@gmail.com';
        conTest1.AccountId = acc.Id;
        conTest1.Contact_Role_s_at_Client__c ='Pricing Contact';
        conTest1.FirstName = 'Test2';
        conTest1.LastName = 'Test';
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
        string feature ='adhoc';
        string sector ='';
        Test.startTest();
        String result = ZAF_CTRL_StandardPricingLetter.sendFullStandardCustomEmail(acc.Id,email,feature,sector);
        Test.stopTest();
        Assert.areEqual('success',result,'Email sent Successfully');
       
    } 
  
       /**
     * @description Test setup method for ZAF_CTRL_StandardPricingLetter.SendSpecificStandardCustomEmail
     * */
    @isTest
    static void testSendSpecificStandardCustomEmail() 
    {
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
        conTest1.FirstName = 'Test2';
        conTest1.LastName = 'Test2';
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
        string feature ='adhoc';
        string sector ='Corporate';
        Test.startTest();
        String result = ZAF_CTRL_StandardPricingLetter.sendSpecificStandardCustomEmail(acc.Id,email,feature,sector);
        Test.stopTest();
        Assert.areEqual('success',result,'Email sent Successfully');
     
    }
     /**
  * @description Test setup method to insert all Test data
  */
@isTest
    static void testPricingArrangement() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        zafin_rrp__Negotiated_Pricing__c zp1 =  new zafin_rrp__Negotiated_Pricing__c();
        zp1.zafin_rrp__End_Date__c = Date.today();
        zp1.zafin_rrp__Agreement_Name__c = 'Test Aggrement';
        zp1.zafin_rrp__Start_Date__c = Date.today()-7;
        zp1.zafin_rrp__Reporting_Customer__c = testAccount.Id;
        insert zp1;
        ZAF_CTRL_StandardPricingLetter.getThePricingArrangement(testAccount.id);
        Assert.areNotEqual(null,zp1,'Validation successfull');

    }
      /**
  * @description Test setup method to insert all Test data for else Part
  */ 
    @isTest
    static void testPricingArrangement2() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        ZAF_CTRL_StandardPricingLetter.getThePricingArrangement(null);
        Assert.areNotEqual(null,testAccount,'No Validation');

    }
}