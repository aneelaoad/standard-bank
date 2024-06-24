@IsTest
public with sharing class EmailMessageTriggerTest {

    @IsTest
    static void shouldSendEmailFromCase(){

        Case testCase = new Case();
        testCase.CCC_Final_Email_Sent__c = false;
        testCase.Status = 'Comments Completed';
        testCase.Main_Category__c = 'Payments';
        testCase.Sub_Category__c = 'Recall of Funds';
        insert testCase;

        EmailMessage emailMessage = new EmailMessage();
        emailMessage.ParentId = testCase.Id;
        Test.startTest();
        insert emailMessage;
        Test.stopTest();
        Case afterTestCase = [SELECT CCC_Final_Email_Sent__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(true, afterTestCase.CCC_Final_Email_Sent__c);
    }

}