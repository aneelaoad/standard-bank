/**
* Test class for IBot_LiveChatTranscriptTriggerHelper
* SFP-4835 
*
* @author Sharath Chandra (sharath.chintalapati@standardbank.co.za)
* @date October 2021
*/
@isTest
private class TestIBot_LiveChatTranscriptTriggerHelper {
    
    @testsetup static void createTestData() {
        
        Account acct = new Account();
        acct.Name = 'testAcct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        cont.Outlook_Exchange_System_ID__c ='test';
        insert cont;
        entitlement e = new entitlement(name = 'FR240mins : Mon - Fri (8h00 - 17h00)',
                                        accountId = acct.id);
        insert e;
        
        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.ChatKey__c = 'testkey';
        insert newCase;
    }
    
    @isTest static void testMethod1() {
        Case newCase = [Select Id from Case limit 1];
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        String chatButton = 'CIBSA_GM_MySupport';
        LiveChatButton mySupportChatButton = [SELECT Id, DeveloperName, MasterLabel FROM LiveChatButton where developerName =:chatButton];
	    List<LiveChatTranscript> lctToInsert = new List<LiveChatTranscript>();
        List<LiveChatTranscript> lctToUpdate = new List<LiveChatTranscript>();
        
        Test.startTest();
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript();
        liveChatTranscript.LiveChatVisitorID = liveChatVisitor.Id;
        liveChatTranscript.ChatKey = 'testkey';
        liveChatTranscript.Body = 'TestBody';
        liveChatTranscript.LiveChatButtonId =mySupportChatButton.Id; 
        lctToInsert.add(liveChatTranscript);
        insert lctToInsert;
        
        IBot_LiveChatTranscriptTriggerHelper.handleAfterInsert(lctToInsert);
        liveChatTranscript.Body = 'Testbodystring';
        liveChatTranscript.status = 'Completed';
        lctToUpdate.add(liveChatTranscript);
        update lctToUpdate;
        IBot_LiveChatTranscriptTriggerHelper.handleAfterUpdate(lctToUpdate);
        
        Test.stopTest();
        
        List<Case> caseList = new SEL_Cases().selectTheCaseById(newCase.Id);
        Case cases = caseList.get(0);
        System.assertEquals(cases.Live_Chat_Transcript__c, liveChatTranscript.Id);
    }
}