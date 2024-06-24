/**
 * 
 * @description Test clss for MallUserPreferencesManagement
 * @see MallUserPreferencesManagement
 * @author Ankit Kumar
 * @since 
 */

@IsTest
private with sharing class MallUserPreferencesManagement_Test {
    @testSetup static void setup() {
        //Create language setup
        Publishing_Unit__c pu = new Publishing_Unit__c();
        pu.Published_from__c = system.today()-2;
        pu.Published_until__c = system.today()+2;
        pu.IsPublished__c = true;
        insert pu;  

        Tag__c tgLang = new Tag__c();
        tgLang.Position__c=1;
        tgLang.Name='Language';
        Insert tgLang;
    
        Tag__c tgEn = new Tag__c();
        tgEn.Position__c=1;
        tgEn.Name='en';
        tgEn.Root__c = tgLang.Id;
        tgEn.Parent__c=tgLang.id;
        Insert tgEn;

        Tag__c tgPt = new Tag__c();
        tgPt.Position__c=1;
        tgPt.Name='pt';
        tgPt.Root__c = tgLang.Id;
        tgPt.Parent__c=tgLang.id;
        Insert tgPt;

        tgLang.Publishing_Unit__c = pu.Id;
        tgEn.Publishing_Unit__c = pu.Id;
        tgPt.Publishing_Unit__c = pu.Id;
        List<Tag__c> tagsToUpdate = new List<Tag__c>{tgLang, tgEn, tgPt};
        update tagsToUpdate;
    }

    @IsTest
    private static void testGetUserPreferences() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            Test.startTest();
            MallUserPreferencesManagement.UserPreference preference = MallUserPreferencesManagement.getUserPreferences();
            Assert.isTrue(preference.userLanguage == MallUserPreferencesManagement.DEFAULT_CONTENT_LANGUAGE_ISO, 'should be equal');
            Test.stopTest();
        }
    }

    @IsTest
    private static void testSetUserPreferences() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        Test.startTest();
        String languageCode = MallUserPreferencesManagement.setUserPreferences(MallUserPreferencesManagement.DEFAULT_CONTENT_LANGUAGE_ISO, userRec.Id);
        Assert.isTrue(languageCode == MallUserPreferencesManagement.DEFAULT_CONTENT_LANGUAGE_ISO, 'should be equal');
        languageCode = MallUserPreferencesManagement.setUserPreferences('pt', userRec.Id);
        Assert.isTrue(languageCode == 'pt', 'should be equal');
        Test.stopTest();
    }
}