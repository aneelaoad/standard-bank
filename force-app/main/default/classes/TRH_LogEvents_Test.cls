/**
 * Test class for TRH_LogEvents
 * <br/> US-4824
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
@isTest
private class TRH_LogEvents_Test {

    @isTest
    private static void shouldCreateLogWhenEventThrown() {
        Log_Event__e eventRecord = (Log_Event__e) new BLD_LogEvent().getRecord();
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        uow.registerPublishBeforeTransaction(eventRecord);

        Test.startTest();
        uow.commitWork();
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Log__c].size());
    }

    @isTest
    private static void shouldCreateLogAndHaveFieldsMappedWhenEventThrown() {
        Log_Event__e eventRecord = (Log_Event__e) new BLD_LogEvent()
                .area('Area')
                .source('Source')
                .message('message')
                .stackTrace('stack trace')
                .type('ERROR')
                .getRecord();
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        uow.registerPublishBeforeTransaction(eventRecord);

        Test.startTest();
        uow.commitWork();
        Test.stopTest();

        Log__c actual = [SELECT Id, Area__c, Context_User__c, Message__c, Source__c, Stack_trace__c, Type__c FROM Log__c];
        System.assertEquals(eventRecord.Area__c, actual.Area__c);
        System.assertEquals(eventRecord.Context_User__c, actual.Context_User__c);
        System.assertEquals(eventRecord.Message__c, actual.Message__c);
        System.assertEquals(eventRecord.Source__c, actual.Source__c);
        System.assertEquals(eventRecord.Stack_trace__c, actual.Stack_trace__c);
        System.assertEquals(eventRecord.Type__c, actual.Type__c);
    }
}