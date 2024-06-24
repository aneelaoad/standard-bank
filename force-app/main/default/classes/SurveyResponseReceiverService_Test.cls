/***
@ Func Area     	:  CTI Softphone Integration
@ Author        	:  Created by Mykhailo
@ Date          	:  10.09.2019
@ User Story        :  US-4200 IVR Client survey responses
@ Description 	    :  Store survey data when invoked by external system into Survey_Response__c
@ Modified          : Emmanuel Mulea(Nocks)
***/

@IsTest
private class SurveyResponseReceiverService_Test {

    @IsTest
    static void testBlankQuestionError() {
        String returnResult = SurveyResponseReceiverService.createSurveyResponse('', 9, '5001x000003hcXeAAI', null);
        System.assertEquals('Question field can not be empty or null', returnResult);
    }
    @IsTest
    static void testQuestionIsNullError() {
        String returnResult = SurveyResponseReceiverService.createSurveyResponse(null, 9, '5001x000003hcXeAAI', null);
        System.assertEquals('Question field can not be empty or null', returnResult);
    }
    @IsTest
    static void testNpsAnswerLengthError() {
        String returnResult = SurveyResponseReceiverService.createSurveyResponse('How do you do?', 12, '5001x000003hcXeAAI', null);
        System.assertEquals('NPS Answer max length is 1 character', returnResult);
    }
    @IsTest
    static void testNpsAnswerIsNullError() {
        String returnResult = SurveyResponseReceiverService.createSurveyResponse('How do you do?', null, '5001x000003hcXeAAI', null);
        System.assertEquals('NPS Answer field can not be null', returnResult);
    }

    @IsTest
    static void testNoCaseWithSuchIdFoundError() {
        String returnResult = SurveyResponseReceiverService.createSurveyResponse('How do you do?', 9, '5001x000003hcXeAAI', null);
        System.assertEquals('Case with such Id (5001x000003hcXeAAI) doesn\'t exist', returnResult);
    }
    @IsTest
    static void testNoClientWithSuchIdFoundError() {
        String returnResult = SurveyResponseReceiverService.createSurveyResponse('How do you do?', 9, null, '0011x00000Sw17gAAB');
        System.assertEquals('Contact with such Id (0011x00000Sw17gAAB) doesn\'t exist', returnResult);
    }
    @IsTest
    static void testSuccessfulSureveyResponseCreation() {
        Case newCase = new Case(Status = 'New', Main_Category__c='Data Managment', Origin = 'Client Email');
        Account  newAccount = new Account(name='test');
        insert newAccount;
        Contact newContact = new Contact(lastName='test',email='trest@test.com',AccountId=newAccount.id);
        insert newContact;
        insert newCase;
        Case[] allCases = [SELECT Id From Case];
//        System.debug('SELECTING CASES FROM TEST');
//        System.debug(allCases);
//        System.debug(allCases[0].Id);
        String returnResult = SurveyResponseReceiverService.createSurveyResponse('How do you do?', 9, allCases[0].Id, newContact.id);
        System.assertEquals('New Survey Response was successfully added', returnResult.split(':')[0]);
    }

}