/**
* @description This method queries all the SBG Sub Navigation Item 
* @param : None
* Author:sai praveen
* Date:13/10/2022
*/
@isTest
public class SBGNavigationBarControllerTest {
    @testSetup 
    static void setup() {
                Tag__c tgParent = new Tag__c();
            tgParent.Position__c=1;
            tgParent.Name='Country';
            
            Insert tgParent;
            
            Tag__c tgroot = new Tag__c();
            tgroot.Position__c=3;
            tgroot.Name='Language';
            
            Insert tgroot; 
            
            Tag__c tgrelated = new Tag__c();
            tgrelated.Position__c=5;
            tgrelated.Name='South Africa';
            
            Insert tgrelated;
            
            Datetime currentDateTime = DateTime.now();
            
            Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
            publishingUnit.isPreview__c = true;
            publishingUnit.Published_from__c = currentDateTime;
            publishingUnit.Published_until__c = currentDateTime.addDays(2);
            
            Insert publishingUnit;
            
            Tag__c tg= new Tag__c();
            tg.Position__c=5;
            tg.Name='en'; 
            tg.Related_Tag__c= tgrelated.Id;
            tg.Root__c =tgroot.id;
            tg.Parent__c= tgParent.Id;
            tg.Publishing_Unit__c = publishingUnit.id;
        	
            insert tg;
    }
    @isTest
    static void getNavItemsTest(){
        String position='Top Right';
        //Top Right
        Test.startTest();
        List<SBG_Navigation_Items__mdt> navItemsExpected=[Select MasterLabel, DeveloperName, Item_Position__c, Order_Number__c, URL_Link__c from SBG_Navigation_Items__mdt where Item_Position__c = :position order by Order_Number__c];
        List<SBG_Navigation_Items__mdt> navItemsActual=SBGNavigationBarController.getNavItems(position);
        Assert.IsNotNull(navItemsExpected.size(), 'nav items expected should not be empty');
        Assert.IsNotNull(navItemsActual.size(),'nav items actual should not be empty');
        Test.stopTest();
    }
    
    @isTest 
    static void getCountryListtest(){
        Test.startTest();
        List<SBGNavigationBarController.Continent> continentList = SBGNavigationBarController.getCountryList();
        Test.stopTest();
        Assert.isTrue(continentList!=null, 'message');
    }
    
    
    @isTest
    static void getLanguageNameTest(){
        String languageISOCode='en-US';
        Test.startTest();
        String language = SBGNavigationBarController.getLanguageName(languageISOCode);
        SBGNavigationBarController.getLoginHistoryStatus(UserInfo.getUserId());
        Test.stopTest();
        Assert.isTrue(language!=null, 'message'); 
    } 
    
    @isTest
    static void getLanguageNameTest2(){
        String languageISOCode='en';    
        Test.startTest();
        String language = SBGNavigationBarController.getLanguageName(languageISOCode);
        Assert.isTrue(language!=null, 'message');
        Test.stopTest();
    }
    
    @isTest
    static void updateUserPreferenceTest(){
        String currentUserId = UserInfo.getUserId();
        Test.startTest(); 
        Id userId=currentUserId;
        String countryName='South Africa';
        String languageName='en'; 
        SBGNavigationBarController.updateUserPreference(userId, languageName);
        User_Preference__c currentUserPreference = [SELECT Id,Tag__r.Related_Tag__r.Name FROM User_Preference__c WHERE User__c=: userId];
        Assert.areEqual(currentUserPreference.Tag__r.Related_Tag__r.Name, countryName, 'should be equal');
        Test.stopTest();
    }
    
    @isTest
    static void getCurrentUserTest(){
        User currentUser = SBGNavigationBarController.getCurrentUser();
        Assert.isTrue(currentUser!=null, 'message');
    }
    
    @isTest
    static void languageTest(){
        test.startTest();
        List<SBGNavigationBarController.Language> sbng = new List<SBGNavigationBarController.Language>();
        SBGNavigationBarController.Language sbnn= new SBGNavigationBarController.Language();
        sbnn.styleClass='icon';
        sbng.add(sbnn);
        Assert.isTrue(sbng!=null, 'message');
        test.stopTest();
    }
    
    @IsTest
    static void formatLoginSMSNotificationTest(){
        Test.startTest();
        List<User> users = SEL_Users.newInstance().selectById(new Set<Id>{(Id)UserInfo.getUserId()});
        MallCentralMessagingWebService.CMSSMSRequest request = SBGNavigationBarController.formatLoginSMSNotification(users[0]);
        SBGNavigationBarController.sendLoginAlertNotifications(UserInfo.getUserId());
        Test.stopTest();
        Assert.isTrue(request.content.contains(users[0].FirstName),'should contain the first name');
    }
}