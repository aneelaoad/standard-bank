/**
 * Test class for OSB_SRV_OnboardingHandler
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com
 * @date June 2020
 */
@IsTest(IsParallel=true)
private class OSB_SRV_OnboardingHandler_TEST {

    @IsTest
    static void shouldSetOnboardingDate() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Test.startTest();
        OSB_SRV_OnboardingHandler.newInstance().setUserContactOnboardingDate(new Set<Id>{contactId}, uowMock);
        Test.stopTest();
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Contact) argument.capture());
        Contact editedContact = (Contact) argument.getValue();
        System.assertNotEquals(null, editedContact.Onboarding_Tour_Date__c);
    }
}