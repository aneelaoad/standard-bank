/***************************************************************************************
* @Name of the Class     :SEL_ZafinNegotiatedPricing
* @description           :SFP-36983 Selector class for zafin_rrp__Negotiated_Pricing__c SObject
* @Author                :Likhitha Karusala 
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Likhitha Karusala  
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/
@IsTest
public class SEL_ZafinNegotiatedPricing_TEST {
        @IsTest
        static void selectZafinNegotiationPricingById() {
        Id pricingId;
        Test.startTest();
        SEL_ZafinNegotiatedPricing negotiated = new SEL_ZafinNegotiatedPricing();
        negotiated.selectZafinNegotiationPricingById(pricingId);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory; 
        Assert.areNotEqual(result.getCondition(),'null', 'Query contains zafin_rrp__Reporting_Customer__c = :recordId');
    }
        @IsTest
        static void selectZafinNegotiationPricingByRecordId() {
        Account testacc=new Account();
        testacc.name='Test Client';
        testacc.CIF__c = '234';
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
        Test.startTest();
        SEL_ZafinNegotiatedPricing negotiatedRec = new SEL_ZafinNegotiatedPricing();
        negotiatedRec.selectZafinNegotiationPricingByRecordId(zrnp.Id);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areNotEqual(result.getCondition(),'null', 'Query contains id = :recordId');
    }
       @IsTest
        static void selectZafinNegotiationByRecordId() {
        Account testacc=new Account();
        testacc.name='Test Client';
        testacc.CIF__c = '234';
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
        Test.startTest();
        SEL_ZafinNegotiatedPricing negotiatedRec = new SEL_ZafinNegotiatedPricing();
        negotiatedRec.selectZafinNegotiationByRecordId(zrnp.Id);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areNotEqual(result.getCondition(),'null', 'Query contains id = :recordId');
    }
}