/**
 * 
 * @description Test Class for MallQuickLinksController
 * @author Manasi Londhe
 */


 @isTest
 public with sharing class MallQuickLinksControllerTest {
 
    @TestSetup
    static void makeData(){
         List<Tag__c> categories=MallTestDataFactory.createCategories();
         Tag__c langTag = new Tag__c();
         langTag.Position__c=1;
         langTag.Name='Language';
         insert langTag;
 
         Tag__c engTag = new Tag__c();
         engTag.Root__c = langTag.id;
         engTag.Name = 'en';
         insert engTag;
        
        //insert publishing unit
        Publishing_unit__c pu=new Publishing_unit__c(isPublished__c=true,Published_From__c=System.today(),Published_Until__c=(System.today()).AddDays(1));
        insert pu;
 
        List<Offering__c> offeringsToInsert=new List<Offering__c>();
         for(Provider__c store:MallTestDataFactory.createShops()){
             Offering__c service=new Offering__c(name='test service',Publishing_unit__c=pu.Id, Status__c = 'Published');
             offeringsToInsert.add(service);
         }
         insert offeringsToInsert;
 
 
         List<Content_Unit_Translation__c> translationsToInsert=new List<Content_Unit_Translation__c>();
         List<Tag_Offering__c> tagOfferingsToInsert=new List<Tag_Offering__c>();
         List<Link__c> linksToInsert=new List<Link__c>();  
         List<Shortcut__c> shortcutsToInsert=new List<Shortcut__c>(); 
 
         //insert content unit
         Content_Unit__c icon=new Content_Unit__c(hasImage__c=true);
         insert icon;
         Content_Unit_Translation__c iconTranslation=new Content_Unit_Translation__c(Content_Unit__c=icon.Id,Language__c=engTag.Id);
         translationsToInsert.add(iconTranslation); 
 
         for(Offering__c service : offeringsToInsert){
             Content_Unit_Translation__c translation=new Content_Unit_Translation__c(Product__c=service.Id,Title__c=service.name,Language__c=engTag.Id);
             translationsToInsert.add(translation);
             Tag_Offering__c tagOffering=new Tag_Offering__c(Tag__c=categories[0].Id,Offering__c=service.Id);
             tagOfferingsToInsert.add(tagOffering);
             Link__c link=new Link__c(name='test link',Offering__c=offeringsToInsert[0].Id,Icon__c=icon.Id);
             linksToInsert.add(link);
         }
 
         insert tagOfferingsToInsert;
         insert linksToInsert;
 
         for(Link__c link:linksToInsert){
             Content_Unit_Translation__c translation=new Content_Unit_Translation__c(Link__c=link.Id,Title__c='test link',Language__c=engTag.Id);
             translationsToInsert.add(translation);
             Shortcut__c shortcut=new Shortcut__c(Link__c=link.Id,User__c=UserInfo.getUserId());
             shortcutsToInsert.add(shortcut);
         }
 
         insert translationsToInsert;
         insert shortcutsToInsert;
     }
 
 
     @istest
     static void getQuickLinksTest(){
         List<MallQuickLinksController.DashboardQuicklinkData> result=MallQuickLinksController.getQuickLinks();
          Assert.areEqual(2,result.size(), '2 quick links expected');
     }
     
     
    @IsTest
    static void testUpdateQuickLinks() {
        Test.startTest();
        List<Link__c> links = SEL_Links.newInstance().selectByCustomFilterCondition('ID != NULL');
        List<String> linkIds = new List<String>();
        linkIds.add(links.get(0).Id);
        MallQuickLinksController.updateQuickLinks(linkIds);
        List<Shortcut__c> shortcuts = SEL_Shortcuts.newInstance().selectByCustomFilterCondition('Link__c != NULL');
        Assert.areEqual(1, shortcuts.size(), 'shortcuts expected');
        Test.stopTest();
    }

    @IsTest
    static void testDeleteQuickLinks() {
        Test.startTest();
        List<Link__c> links = SEL_Links.newInstance().selectByCustomFilterCondition('ID != NULL');
        List<String> linkIds = new List<String>();
        linkIds.add(links.get(0).Id);
        MallQuickLinksController.deleteQuickLinks(linkIds);
        List<Shortcut__c> shortcuts = SEL_Shortcuts.newInstance().selectByCustomFilterCondition('Link__c != NULL');
        Assert.areNotEqual(0, shortcuts.size(), 'shortcuts expected');
        Test.stopTest();
    }
 }