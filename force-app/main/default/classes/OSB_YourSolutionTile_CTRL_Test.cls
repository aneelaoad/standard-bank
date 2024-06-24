/** 
 * @description Test class for OSB_YourSolutionTile_CTRL
 *
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date August 2020
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Update to remove test method
 *
 **/
@IsTest
public class OSB_YourSolutionTile_CTRL_Test {
    private static final Boolean STRONGAUTH_FALSE =false;

    
    @IsTest
    static void shouldRemoveUserSubscribedSolution(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        ORG_Application.unitOfWork.setMock(uowMock);

        Id  subscribedSolutionId = fflib_IDGenerator.generate(Subscribed_Solutions__c.SObjectType);
        Subscribed_Solutions__c testerSolution = new Subscribed_Solutions__c(Id=subscribedSolutionId);

        List<Subscribed_Solutions__c> subscribedSolutionList = new List<Subscribed_Solutions__c>{testerSolution};

        Test.startTest();
        OSB_YourSolutionTile_CTRL.removeUserMultipleSubscribedSolution(subscribedSolutionList);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDeleted((List<Subscribed_Solutions__c>) argument.capture());
        List<Subscribed_Solutions__c> subscribedSolution = (List<Subscribed_Solutions__c>) argument.getValue();
        Assert.areEqual(subscribedSolutionId, subscribedSolution[0].Id, 'Subscribed solution has been removed');
    }

    @IsTest
    static void shouldFailRemoveUserSubscribedSolution(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        ORG_Application.unitOfWork.setMock(uowMock);
        
        Id knowledgeId = fflib_IDGenerator.generate(Knowledge__kav.SObjectType);
        Knowledge__kav testerFailSolution = new Knowledge__kav(Id=knowledgeId);

        List<Knowledge__kav> failTestList = new List<Knowledge__kav>{testerFailSolution};

        Test.startTest();
        OSB_YourSolutionTile_CTRL.removeUserMultipleSubscribedSolution(failTestList);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).registerDeleted((List<Subscribed_Solutions__c>) argument.capture());

        Assert.areEqual(0, 0, 'Catch exception should be caught');
    }

    @isTest
    static void checkMfaLogin(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_PingIntegration serviceMock = (OSB_SRV_PingIntegration) mocks.mock(OSB_SRV_PingIntegration.class);
        ORG_Application.service.setMock(OSB_SRV_PingIntegration.IService.class, serviceMock);
        Test.startTest();
        Boolean strongAuth = OSB_YourSolutionTile_CTRL.mfaLogin();
        Test.stopTest();
        Assert.areEqual(strongAuth, strongAuth, 'User did not login with MFA');
    }
}