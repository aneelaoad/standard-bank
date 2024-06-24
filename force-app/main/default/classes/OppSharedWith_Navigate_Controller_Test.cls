@isTest 
public with sharing class OppSharedWith_Navigate_Controller_Test {
    
    public static testMethod void startTest() {
        Test.startTest();
        OppSharedWith_Navigate_Controller controller = new OppSharedWith_Navigate_Controller();
        system.assert(controller.navigateToPage() != null);
        Test.stopTest();
    }
    
}