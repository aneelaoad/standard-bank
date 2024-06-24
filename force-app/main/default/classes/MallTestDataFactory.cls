/**
 * 
 * @description MallTestDataFactory
 * @author Ankit Kumar
 * @since 
 */
@IsTest
public class MallTestDataFactory {

  /**
   * 
   * @description createSegments
   * @return List<Tag__c>
   */    
    public static List<Tag__c> createSegments () {
         Tag__c parentTag=new Tag__c(Name='Segment');
         insert parentTag;
 
         List<Tag__c> segments=new List<Tag__c>();
         Tag__c business=new Tag__c(Name='Business', Parent__c=parentTag.Id, Root__c=parentTag.Id);
         segments.add(business);
         insert segments;
         return segments;
    }

   /**
   * 
   * @description Create Category Tags for mall
   * @return List<Tag__c>
   */ 
    public static List<Tag__c> createCategories () {
        Tag__c rootTag=new Tag__c(Name='Category');
        insert rootTag;

        //create categories
        List<Tag__c> categories=new List<Tag__c>();
        Tag__c automotive=new Tag__c(Name='Automative', Parent__c=rootTag.Id, Root__c=rootTag.Id);
        categories.add(automotive);
        insert categories;
        return categories;
    }

   /**
   * 
   * @description Create Country Tags for mall
   * @return List<Tag__c>
   */ 
    public static List<Tag__c> createCountries () {
        Tag__c parentTag=new Tag__c(Name='Country');
        insert parentTag;

        List<Tag__c> countries=new List<Tag__c>();
        Tag__c southAfrica=new Tag__c(Name='South Africa', Parent__c=parentTag.Id, Root__c=parentTag.Id);
        countries.add(southAfrica);

        insert countries;
        return countries;
    }

   /**
   * 
   * @description Create Shops
   * @return List<Provider__c>
   */ 
    public static List<Provider__c> createShops() {
        List<Provider__c> shops=new List<Provider__c>();
        for(Integer i=0;i<2;i++){
            Provider__c shop=new Provider__c(Name='Test '+i);
            shops.add(shop);
        }
        insert shops;
        List<Tag_Provider__c> tagShops=new List<Tag_Provider__c>();
        for(Tag__c tag:[Select Id From Tag__c Where Name in ('Business','South Africa','Automative')]){
            for(Provider__c shop:shops){
                Tag_Provider__c tagShop=new Tag_Provider__c(Provider__c=shop.Id,Tag__c=tag.Id);
                tagShops.add(tagShop);
            }
        }
        insert tagShops;
        return shops;
    }

    /**
     * 
     * @description createOfferings
     * @param providers List<Provider__c>
     * @return List<Offering__c>
     */ 
    public static List<Offering__c> createOfferings(List<Provider__c> providers) {
        List<Offering__c> offerings = new List<Offering__c>();
        Id recordTypeId = Schema.SObjectType.Offering__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        for(Provider__c provider: providers) {
            for(Integer i=0; i < 2; i++){
                offering__c offering = new offering__c( Name = provider.Name + ' Test offering '+ i, Provider__c = provider.Id, Status__c = 'Draft', RecordTypeId = recordTypeId);
                offerings.add(offering);
            }
        }
        insert offerings;
        List<Tag_Offering__c> tagOfferings=new List<Tag_Offering__c>();
        for(Tag__c tag: [Select Id From Tag__c Where Name in ('Business','South Africa','Automative')]){
            for(Offering__c offering : offerings) {
                Tag_Offering__c tagOffering=new Tag_Offering__c(Offering__c = offering.Id,Tag__c = tag.Id);
                tagOfferings.add(tagOffering);
            }
        }
        insert tagOfferings;
        return offerings;
    }

    /**
     * 
     * @description createPromotions
     * @param providers List<Provider__c>
     * @return List<Promotion__c>
     */ 
    public static List<Promotion__c> createPromotions(List<Provider__c> providers) {
        List<Promotion__c> promotions = new List<Promotion__c>();
        for(Provider__c provider: providers) {
            for(Integer i=0; i < 2; i++){
                Promotion__c promotion = new Promotion__c( Name = provider.Name + ' Test promotion '+ i, Provider__c = provider.Id, Image_Path_Desktop__c='https://foo.com');
                promotions.add(promotion);
            }
        }
        insert promotions;
        List<Tag_Promotion__c> tagPromotions=new List<Tag_Promotion__c>();
        for(Tag__c tag: [Select Id From Tag__c Where Name in ('Business','South Africa','Automative')]){
            for(Promotion__c promotion : promotions) {
                Tag_Promotion__c tagPromotion=new Tag_Promotion__c(Promotion__c = promotion.Id,Tag__c = tag.Id);
                tagPromotions.add(tagPromotion);
            }
        }
        insert tagPromotions;
        return promotions;
    }

    /**
     * 
     * @description createEvents
     * @param providers List<Provider__c>
     * @return List<Business_Event__c>
     */ 
    public static List<Business_Event__c> createEvents(List<Provider__c> providers) {
        List<Business_Event__c> events = new List<Business_Event__c>();
        for(Provider__c provider: providers) {
            for(Integer i=0; i < 2; i++){
                Business_Event__c event = new Business_Event__c(Name = provider.Name + ' Test Event '+ i, Provider__c = provider.Id, Start_Date__c= System.now()-10, End_date__c = System.now()+10);
                events.add(event);
            }
        }
        insert events;
        List<Tag_Business_Event__c> tagEvents = new List<Tag_Business_Event__c>();
        for(Tag__c tag: [Select Id From Tag__c Where Name in ('Business','South Africa','Automative')]){
            for(Business_Event__c event : events) {
                Tag_Business_Event__c tagEvent = new Tag_Business_Event__c(Business_Event__c = event.Id,Tag__c = tag.Id);
                tagEvents.add(tagEvent);
            }
        }
        insert tagEvents;
        return events;
    }
    
    /**
     * 
     * @description Create Links
     * @return List<Link__c>
     */ 
    public static List<Link__c> createDeepLinks () {
        //create deep links 
        List<Link__c> deepLinks=new List<Link__c>();
        List<Content_Unit_Translation__c> cuts=new List<Content_Unit_Translation__c>();
        for(Offering__c offering:[Select Id From Offering__c]){
        Link__c link=new Link__c(Offering__c=offering.Id,Desktop_url__c='www.desktopTestUrl.com',Mobile_Url__c='www.mobileTestUrl.com');
        deepLinks.add(link);
        }
        insert deepLinks;
        Tag__c tg1 = new Tag__c();
        tg1.Position__c=1;
        tg1.Name='Language';
        insert tg1;

        Tag__c tag2 = new Tag__c();
        tag2.Root__c = tg1.id;
        tag2.Name = 'en';
        insert tag2;

        for (Link__c link: deepLinks) {
            
            Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
            cut.Link__c = link.Id;
            cut.Language__c = tag2.Id;
            cut.Text__c = 'Test Text';
            cuts.add(cut);
        }
        insert cuts;
        return deepLinks;
    }
    
    /**
     * @description createCommunityUser
     * @param user User
     * @param profileName String
     * @return  user
     */
    public static user createCommunityUser(User user, String profileName) {
        Profile profile = [SELECT Id FROM profile WHERE Name = :profileName];
        UserRole role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert role;

        User u = new User();
        u.FirstName='Test';
        u.LastName = 'User1';
        u.Email = 'testUser1@test.com';
        u.username='testUser1@test.com';
        String portalRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Account portalAccount = new Account( RecordTypeID=portalRecordTypeId );
        portalAccount.Name= u.firstName + ' ' + u.lastName;
        portalAccount.Email_Address__c = u.email;
        insert portalAccount;
            
        Contact c = [SELECT AccountId, Id FROM Contact  WHERE AccountId = :portalAccount.Id ];
        u.contactId = c.id;
        u.IsActive=true;
        u.TimeZoneSidKey='GMT';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId=profile.Id;
        u.LanguageLocaleKey='en_US';
        u.alias='mallUser';
        u.State='Western Cape';
        u.Business_Unit__c='Bank Sector';
        u.Country='South Africa';
        u.City='Cape Town';
        u.User_Division__c='Business Banking';
        u.User_CIB_Global_Area__c='CIBI';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        u.emailEncodingKey = 'ISO-8859-1';
        System.runAs(user) {
            insert u;            
        }
        return u;
    }

    /**
     * @description createPortalUser
     * @param user
     * @return  user
     */
    public static user createPortalUser(User user){
        String externalUserProfile = Label.Mall_Experience_User_Profile;
        Profile profile = [SELECT Id FROM profile WHERE Name = :externalUserProfile];
        
        User u = new User();
        u.FirstName='Test';
        u.LastName = 'User1';
        u.Email = 'testUser1@test.com';
        u.username='testUser1@test.com';
        
        String portalRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Account portalAccount = new Account( RecordTypeID=portalRecordTypeId );
        portalAccount.Name= u.firstName + ' ' + u.lastName;
        portalAccount.Email_Address__c = u.email;
        insert portalAccount;
            
    
        Contact c = [SELECT AccountId, Id FROM Contact  WHERE AccountId = :portalAccount.Id ];
        u.contactId = c.id;
        u.IsActive=true;
        u.TimeZoneSidKey='GMT';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId=profile.Id;
        u.LanguageLocaleKey='en_US';
        u.alias='mallUser';
        u.State='Western Cape';
        u.Business_Unit__c='Bank Sector';
        u.Country='South Africa';
        u.City='Cape Town';
        u.Ping_BPGUID__c= '12345';
        u.User_Division__c='Business Banking';
        u.User_CIB_Global_Area__c='CIBI';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        u.emailEncodingKey = 'ISO-8859-1';
        System.runAs(user) {
            insert u;            
        }
        return u;
    }

    /**
     * 
     * @description createGuestUser
     * @return user
     */
    public static User createGuestUser(){
        String guestUserProfile ='The Mall Profile';
        Profile profile = [SELECT Id FROM profile WHERE Name = :guestUserProfile];
        User u = new User();
        u.firstName='Mall';
        u.LastName='GuestUser';
        u.Email = 'guestUser1@test.com';
        u.username='guestUser1@test.com';
        u.alias='guest';
        u.IsActive=true;
        u.TimeZoneSidKey='GMT';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId=profile.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        return u;
    }
}