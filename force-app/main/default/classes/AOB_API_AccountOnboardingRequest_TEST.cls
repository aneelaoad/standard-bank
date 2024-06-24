/**
 * @description Execute account onboarding request outbound webservice API test class
 *
 * @see AOB_API_AccountOnboardingRequest
 *
 * @author Mthobisi Ndlovu
 *
 * @date May 2023
 * 
 * @Modification Description : SFP-25088
 */
@IsTest
private class AOB_API_AccountOnboardingRequest_TEST
{

    /**
     * @description method to setup test data
     */
    @TestSetup
    static void testSetup()
    {
        String identityNumber = CMN_DAL_SObjectDomain.generateRandomNumber(13);
        AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse = AOB_DAL_TestFactory.generatePreApplicationResponse();
        AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication preApplicationRequest = AOB_DAL_TestFactory.generateApplicationInflightData();
        preApplicationRequest.IdNum = identityNumber;

        Id prospectClientRecTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, 'Prospect');

        AOB_DTO_StaffAOResponse.DTO_BusinessDetail businessDetail = preApplicationResponse?.cipcRegisteredDetails?.businessDetails;
        List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorDetails = preApplicationResponse?.cipcRegisteredDetails?.directorDetails;
        AOB_DTO_StaffAOResponse.DTO_DirectorDetail directorDetail = directorDetails[0];

        Account client = new Account();
        client.RecordTypeId = prospectClientRecTypeId;
        client.Name = businessDetail?.businessName;
        client.BillingStreet = businessDetail?.kycAddress?.line1;
        client.BillingCity = businessDetail?.kycAddress?.city;
        client.BillingCountry = businessDetail?.kycAddress?.country;
        client.BillingState = businessDetail?.kycAddress?.province;
        client.BillingPostalCode = businessDetail?.kycAddress?.postalCode;
        client.Correspondence_City__c = businessDetail?.businessCity;
        client.Registration_Number__c = businessDetail?.businessRegistrationNumber;
        client.BPID__c = businessDetail?.businessBPID;
        client.GUID__c = businessDetail?.businessBPGUID;
        client.Status__c = businessDetail?.businessStatus;
        client.Business_Classification__c = businessDetail?.entityClassification;
        insert client;

        Contact director = new Contact();
        director.FirstName = directorDetail.firstName;
        director.LastName = directorDetail.lastName;
        director.Phone = directorDetail.cellphoneNumber;
        director.Email = directorDetail.emailAddress;
        director.FinServ__Citizenship__c = directorDetail.citizenship;
        director.FinServ__CommunicationPreferences__c = directorDetail.preferredCommunicationMethod;
        director.Identity_Number__c = identityNumber;
        director.FinServ__TaxId__c = directorDetail.taxDetails?.taxNumber;
        director.BPID__c = directorDetail.bpId;
        director.AccountId = client.Id;
        insert director;

        AOB_DTO_StaffAssistedOnboarding.DTO_InflightData inflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
        inflightData.preApplicationResponse = preApplicationResponse;
        inflightData.PreApplication = preApplicationRequest;

        AOB_Application__c application = new AOB_Application__c();
        application.AOB_Client__c = client.Id;
        application.AOB_ProcessId__c = CMN_DAL_SObjectDomain.generateRandomNumber(5);
        application.AOB_SalesObjectId__c = CMN_DAL_SObjectDomain.generateRandomNumber(5);
        application.AOB_ExpiryDate__c = System.today().addDays(30);
        application.AOB_inflightData__c = JSON.serialize(inflightData);
        application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
        application.Name = CMN_DAL_SObjectDomain.generateRandomName();
        insert application;
        
        Verification__c verification = AOB_DAL_TestFactory.createVerification(application, CMN_DAL_SObjectDomain.generateRandomName(), AOB_CTRL_Authentication.AUTHENTICATED, client.Id);
        verification.Authenticated__c = System.Label.AOB_Yes;
        verification.Contact__c = director.Id;
        update verification;
    }
    /**
     * @description Method tests the execute account onboarding callout
     */
    @IsTest
    static void testExecuteAccountOnboardingCallout()
    {
        //AOB_API_RetrieveAccessToken callout is made to get a token to be used on the on the AOB_API_AccountOnboardingRequest callout
        Test.setMock(
                HttpCalloutMock.class,
                new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock()
        );

        AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

        Test.startTest();
        AOB_API_AccountOnboardingRequest callout = new AOB_API_AccountOnboardingRequest();
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_AccountOnboardingRequest.SERVICE_NAME, application.Id);
        callout.process(queueItem);
        insert queueItem;

        Test.stopTest();
        Assert.isNotNull(callout.callResult.responseBody, 'response is null');

    }

    /**
     * @description Method tests the failed response callout
     */
    @IsTest
    static void testFailedCallout()
    {
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();
        AOB_API_StaffAssistedOnboarding.isFailedTest = true;
        Test.startTest();
        AOB_API_AccountOnboardingRequest callout = new AOB_API_AccountOnboardingRequest();
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_AccountOnboardingRequest.SERVICE_NAME, application.Id);
        callout.process(queueItem);
        insert queueItem; Test.stopTest();
        AOB_API_AccountOnboardingRequest.DTO_Response response = (AOB_API_AccountOnboardingRequest.DTO_Response)callout.baseResponseDTO;
        Assert.isNotNull(response.executeAccountOnboardingResponse.orchestrationHeaderResponse.errorResponse,'Error response is null');
    }

    /**
     * @description Method tests an aborted callout
     */
    @IsTest
    static void testAbortedCallout()
    {
        Test.setMock(
                HttpCalloutMock.class,
                new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock()
        );
        AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();
        application.AOB_SalesObjectId__c = null;
        application.AOB_inflightData__c = null;
        update application;

        Test.startTest();
        AOB_API_AccountOnboardingRequest callout = new AOB_API_AccountOnboardingRequest();
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_AccountOnboardingRequest.SERVICE_NAME, application.Id);
        callout.process(queueItem);
        insert queueItem;
        Boolean aborted = callout.abortRequest();
        Test.stopTest();
        Assert.areEqual(true, aborted,'callout was not aborted');
    }
}