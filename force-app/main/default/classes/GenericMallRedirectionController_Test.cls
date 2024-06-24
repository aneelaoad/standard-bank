@isTest
public with sharing class GenericMallRedirectionController_Test {
    @TestSetup
    static void makeData(){
        MallTestDataFactory.createGuestUser();
    }

    @isTest
    public static void testHandleRedirection(){
        Mall_SSO_Configuration__mdt mallSSOConfig = Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration');
        List<User> guestUser=[Select Id From User Where Profile.Name='The Mall Profile'];
        String result;
        System.runAs(guestUser[0]){
            result=GenericMallRedirectionController.handleRedirection('test');
        }
        Assert.areEqual(mallSSOConfig.Mall_SSO_Provider_No_Prompt__c,result,'message');

        //run as loggedinUser
        result=GenericMallRedirectionController.handleRedirection('test');
        Assert.areEqual(null,result,'message');
    }
    
    
    @IsTest
    static void getPingSettingsTest(){
        List<User> guestUser=[Select Id From User Where Profile.Name='The Mall Profile'];
        Mall_SSO_Configuration__mdt result;
        System.runAs(guestUser[0]){
            result=GenericMallRedirectionController.getPingSettings();
        }
        Assert.areNotEqual(result, null,'Ping Settings should not be null');
     }
}