/**
 * 
 * @description MallEmailTemplateContentHelperTest
 * @author Maham Hassan
 * @since
 */
@isTest
public with sharing class MallEmailTemplateContentHelperTest {
    @testSetup static void setup() {
        Publishing_Unit__c pu = new Publishing_Unit__c();
        pu.Published_from__c = system.today();
        pu.Published_until__c = system.today()+2;
        pu.IsPublished__c = true;
        insert pu;  

        Provider__c provider = new Provider__c();
        provider.Name = 'Test Provider';
        provider.Publishing_Unit__c = pu.Id;
        
        insert provider;
    
        Promotion__c promotion1= new Promotion__c();
        promotion1.Name='Test1';
        promotion1.Provider__c=provider.id;
        promotion1.Publishing_Unit__c=pu.Id;
        promotion1.Image_Path_Desktop__c = '/mall/s/';
        insert promotion1;

        promotion1.Publishing_Unit__c = pu.Id;
        update pu;
    }

    @isTest
    static void mallEmailContentHelperTest() {   
        Test.startTest();
        MallEmailTemplateContent mallEmailTemplateContent = new MallEmailTemplateContent();
        mallEmailTemplateContent.rowNumber = 1;
        MallEmailTemplateContent.newContents = new List<mallEmailTemplateContent.MallNewContent>();
        MallEmailTemplateContent.MallNewContent m = new mallEmailTemplateContent.MallNewContent();
        m.imageUrl = 'test';
        m.name = 'test';
        m.navUrl = 'test';
        MallEmailTemplateContent.newContents.add(m);
        Assert.areNotEqual(null, mallEmailTemplateContent, 'should not be null');
        new MallEmailTemplateContentHelper().formatContentForRows(MallEmailTemplateContent.newContents);
        new MallEmailTemplateContentHelper().getBaseUrl();
        Test.stopTest();
    }
}