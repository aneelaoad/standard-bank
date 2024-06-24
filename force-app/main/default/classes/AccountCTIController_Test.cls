/***
@ Func Area     	:  CTI Softphone Integration
@ Author        	:  Created by Nocks Mulae
@ Date          	:  06.11.2019
@ User Story        :  US-4459 Implementing Thinkconnect CTI softphone 
@ Description 	    :  Invokes account ID recieved in URL
***/

@isTest
public class AccountCTIController_Test {

    @TestSetup
    static void setupMethod(){
        
        Account acc = new Account(name = 'test');
        insert acc;
        Contact con = new contact(lastName='test',AccountId=acc.id);
        insert con;
    }
    
    @isTest
    static void positiveTest(){
        
        //get the contact created on setupMethod
        Contact con = [SELECT id FROM CONTACT];
        Test.startTest();
            PageReference pageRef = Page.AccountCTISearchandRedirect;
            Test.setCurrentPageReference(pageRef); 
            pageRef.getParameters().put('recordId', con.id);
            AccountCTIController aCTI  = new AccountCTIController();
            aCTI.redirectToAccount();
        	system.assert(pageRef.getParameters().get('recordId')==con.id, 'recordId is set');
        Test.stopTest();
        
    }
    
    @isTest
    static void negativeTest(){
        
        //get the contact created on setupMethod
        Test.startTest();
            PageReference pageRef = Page.AccountCTISearchandRedirect;
            Test.setCurrentPageReference(pageRef); 
            pageRef.getParameters().put('recordId', '');//sending wrong id
            AccountCTIController aCTI  = new AccountCTIController();
            aCTI.redirectToAccount();
        	system.assert(pageRef.getParameters().get('recordId')=='', 'recordId is set');
        Test.stopTest();
    }
}