/**
* @description       : Test class for AOB_Internal_API_CreateContract
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 07-20-2023
* @last modified by  : Tukelo Moseamo
* Modifications Log
* Ver   Date         Author           Modification: SFP-25088
* 1.0   05-12-2023   Tukelo Moseamo   Initial Version
**/
@isTest
public class AOB_Internal_API_GetDocument_TEST {
     public static String inflight =  '{"createContractResponse":{"orchestrationHeaderResponse":{"responseTimeStamp":"2023-07-12","responseStatus":{"statusDescription":"Successful",'
            +'"statusCode":"200","severity":"Info","serverStatusCode":"3"},"requestTimeStamp":"2023-07-12","errorResponse":null,"correlationId":"9cc3e68b-0407-4da6-9bca-804ee0180bcf",'
            +'"channelId":"SALESFORCE STAFF-ASSISTED"},"contracts":[{"itemId":"0","documentName":"Mandate","documentId":"B0304C89-0000-CB10-B5DF-65FBB9CD36A0","documentCode":"MANDT"}]}'
            +',"preApplicationResponse":{"applicationResponseDetails":{"digitalOfferID":"0045412110","maintenanceOfferID":"0600050302","processExpiryDate":"2023-07-03","processID":""},'
            +'"cipcRegisteredDetails":{"businessDetails":{"businessBPGUID":"23980269-0e44-1edd-b7b9-ba68146bb941","businessBPID":"0535736197","businessCity":"","businessName":'
            +'"Monica PTY","businessProvince":"","businessRegistrationNumber":"6006180508088","businessStatus":"","businessTurnover":"2000000","businessType":"SOLE PROPRIETORSHIP",'
            +'"entityClassification":"","kycAddress":{"city":"","country":"","district":"","line1":"","line2":"","line3":"","line4":"","postalCode":"","province":""},"soleShareholdingInd"'
            +':false},"directorDetails":[{"assets":null,"authorizedToApply":true,"bpGuid":null,"bpId":"0437256283","cellphoneNumber":"0119884836","citizenship":"","digitalId":null,'
            +'"directorAddress":{"addressLine1":"","addressLine2":"","addressLine3":"","addressLine4":"","cityDistrict":null,"country":"","countyDistrict":"","postalCode":"","province"'
            +':""},"emailAddress":"","employDetails":{"industry":"","jobTitle":"","occupationStatus":""},"firstName":"MZ","grossMonthlyIncome":null,"identificationCountryCode":"ZA",'
            +'"identificationNumber":"6006180508088","identificationType":"","isInitiator":false,"lastName":"NGOMANI","liabilities":null,"loggedInUser":true,"mainApplicant":true,"nationality":'
            +'null,"pipDetails":{"publicOfficial":false,"publicOfficialRelatedDetails":{"name":"","relatedToPublicOfficial":false,"surname":"","typeOfRelationship":""}},"preferredCommunic'
            +'ationMethod":"","relationships":{"relationshipTypeCode":""},"status":"ACTIVE","taxDetails":{"provisionalTaxPayerInd":"","taxNumber":"","taxType":""},"totalMonthlyExpenses":null}]},'
            +'"orchestrationHeaderResponse":{"channelId":"SALESFORCE STAFF-ASSISTED","correlationId":"ecc4bdf0-d770-eefc-f309-9e426a96bfcb","instanceId":"","requestTimeStamp":"2023-06-26",'
            +'"respondToAddress":"A244555","responseStatus":{"serverStatusCode":"3","severity":"Info","statusCode":"200","statusDescription":"Successful"},"responseTimeStamp":"2023-06-26"}}}';
    @isTest
    private static void testDocumentAPIPositive() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createAppWithContractInflightKey();        
        AOB_Application__c app = new AOB_Application__c();
        app.Id = applicationId;
        app.AOB_inflightData__c = inflight;
        update app;
        
        Test.startTest();
        AOB_Internal_API_GetDocument customerServiceCall = new AOB_Internal_API_GetDocument(applicationId, '0');
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_GetDocument.SERVICE_NAME);
        obj.CMN_TriggeringObjectId__c = applicationId;
        customerServiceCall.process(obj);
        insert obj;
        Test.stopTest();
        Assert.areEqual(customerServiceCall.callResult.statusCode, String.valueOf(CMN_API_HttpBase.HTTP_OK), 'callout was not successful');
    }
}