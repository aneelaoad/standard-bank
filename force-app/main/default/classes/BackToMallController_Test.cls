/**
 * 
 * @description Controller Class for Back To Mall 
 * @author Maham Hasan
 * @since 
 */
@isTest
public with sharing class BackToMallController_Test {

    @TestSetup
    static void createData(){
        MallTestDataFactory.createGuestUser();
    }
    
    @isTest
    public static void testMallUser() {
        Mall_SSO_Configuration__mdt mallSSOConfig = Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration');
        String mallHomePage=mallSSOConfig.Mall_Home_Page__c;
        Test.startTest();
        Cache.Session.put('redirectTolastVisitedPage',true);
        Cache.Session.put('lastVisitedPage',mallHomePage);
        BackToMallController backToMall=new BackToMallController();
        Test.stopTest();
        Assert.areEqual(mallHomePage,backToMall.targetUrl,'should be equal');
    }

    @isTest
    public static void testGuestUser(){
        Mall_SSO_Configuration__mdt mallSSOConfig = Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration');
        String mallHomePage=mallSSOConfig.Mall_Home_Page__c;
        List<User> guestUser=[Select Id From User Where Profile.Name='The Mall Profile'];
        Cache.Session.put('redirectTolastVisitedPage',true);
        Cache.Session.put('lastVisitedPage',mallHomePage);
        Test.startTest();
        BackToMallController backToMall;
        System.runAs(guestUser[0]){
            backToMall=new BackToMallController();
        }
        Assert.areEqual(mallHomePage,backToMall.targetUrl,'should be equal');
        Test.stopTest();
    }
}