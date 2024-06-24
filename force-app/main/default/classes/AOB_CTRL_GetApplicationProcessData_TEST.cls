/**
 * @description Get application process data controller test class
 *
 * @see AOB_CTRL_GetApplicationProcessData
 *
 * @author Mthobisi Ndlovu
 *
 * @date April 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
@IsTest
private class AOB_CTRL_GetApplicationProcessData_TEST
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

        Contact newDirector = new Contact();
        newDirector.FirstName = directorDetail.firstName;
        newDirector.LastName = directorDetail.lastName;
        newDirector.Phone = directorDetail.cellphoneNumber;
        newDirector.Email = directorDetail.emailAddress;
        newDirector.FinServ__Citizenship__c = directorDetail.citizenship;
        newDirector.FinServ__CommunicationPreferences__c = directorDetail.preferredCommunicationMethod;
        newDirector.Identity_Number__c = identityNumber;
        newDirector.FinServ__TaxId__c = directorDetail.taxDetails?.taxNumber;
        newDirector.AccountId = client.Id;
        insert newDirector;

        AOB_DTO_StaffAssistedOnboarding.DTO_InflightData inflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
        inflightData.preApplicationResponse = preApplicationResponse;
        inflightData.PreApplication = preApplicationRequest;

        AOB_Application__c application = new AOB_Application__c();
        application.AOB_Client__c = client.Id;
        application.AOB_ExpiryDate__c = System.today().addDays(30);
        application.AOB_inflightData__c = JSON.serialize(inflightData);
        application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
        application.Name = CMN_DAL_SObjectDomain.generateRandomName();
        insert application;
        
        Verification__c verification = AOB_DAL_TestFactory.createVerification(application, CMN_DAL_SObjectDomain.generateRandomName(), AOB_CTRL_Authentication.AUTHENTICATED, client.Id);
        verification.Authenticated__c = System.Label.AOB_Yes;
        verification.Contact__c = newDirector.Id;
        update verification;
    }
    @IsTest
    static void testProcessDataCallout()
    {
        //AOB_API_RetrieveAccessToken callout is made to get a token to be used on the on the AOB_API_ApplicationProcessData callout
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());

        AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

        Test.startTest();
        String response = AOB_CTRL_GetApplicationProcessData.applicationProcessDataCallout(application.Id);
        Test.stopTest();
        Assert.isNotNull(response, 'get application process data response is null');

    }

    /**
     * @description This method tests the exception handling
     */
    @IsTest
    static void testException()
    {
        try
        {
            AOB_CTRL_GetApplicationProcessData.applicationProcessDataCallout(null);
        }
        catch(Exception ex)
        {
            Assert.isNotNull(ex.getMessage(),'Exception not thrown');
        }
    }

    @IsTest
    static void testFailedCallout()
    {
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();
        AOB_API_StaffAssistedOnboarding.isFailedTest = true;
        Test.startTest();
        String response = AOB_CTRL_GetApplicationProcessData.applicationProcessDataCallout(application.Id);
        Test.stopTest();

        Assert.areNotEqual(response, 'Successful', 'callout was successful');
    }

    @IsTest
    static void testAbortedCallout()
    {
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();
        application.AOB_inflightData__c = null;
        update application;

        Test.startTest();
        String response = AOB_CTRL_GetApplicationProcessData.applicationProcessDataCallout(application.Id);
        Test.stopTest();

        Assert.areEqual(response, AOB_API_StaffAssistedOnboarding.ERROR_INFLIGHT_DATA_NOT_FOUND, 'Inflight data was found');
    }
}