/**
* @description       : SFP-25090 - Test class for AOB_Internal_SRV_SetDigital
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 04-03-2023
* @last modified by  : Tukelo Moseamo
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-10-2023   Tukelo Moseamo   Initial Version
**/ 
@isTest
public class AOB_Internal_SRV_SetDigital_TEST {

    @isTest
    private static void testCallStaffAssistSetDigitalAPI() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createAppWithInflightKey();
        AOB_Application__c app = [SELECT Id,AOB_inflightData__c FROM AOB_Application__c WHERE Id = :applicationId];
        app.AOB_inflightData__c = getInflight();
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace('"{"0016":"2000"}"', '"{\\"0016\\":\\"2000\\"}"');
                                                                  
        update app;
        Test.startTest();
        Integer response = AOB_Internal_SRV_SetDigital.callStaffAssistSetDigitalAPI(applicationId);
        Test.stopTest();
        Assert.areEqual(response, CMN_API_HttpBase.HTTP_OK, 'Callout was successful');
    }
    
    @isTest
    private static void testCallStaffAssistSetDigitalAPINegative() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createAppWithInflightKey();
        try {
            Integer response = AOB_Internal_SRV_SetDigital.callStaffAssistSetDigitalAPI(applicationId);
        	Assert.areEqual(response, CMN_UTIL_String.EMPTY, 'Class fails and response remains empty');
        }
        catch(Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'Error message is populated');
        } 
    }
    
    /**
     * @description get inflight data 
     * @return a string version of inflight data
     * 
     */
    public static String getInflight() {
      return  '{"ContractDocument":[{"documentId":"0d19cdd31f4a4ea4874602d38954ee82","documentName":"Mandate","documentCode":'+
          '"MANDT","itemId":"0"},{"documentId":"4065ee6a235a482c8814c337cafdb7e4","documentName":"Terms and Conditions for Business '+
          'Cheque Accounts","documentCode":"GENTC","itemId":"100"},{"documentId":"f1a321fad0604f93a9175bb7083c172f","documentName":'+
          '"Terms and Conditions for Business Marketlink","documentCode":"COTCS","itemId":"500"},{"documentId":"a9ca1be5e5d04ae8a50f6bc516ce85ce",'+
          '"documentName":"Contract","documentCode":"CONTR","itemId":"600"},{"documentId":"ba313c78ee1e46788a9dfe2c581246b9","documentName":'+
          '"Contract","documentCode":"CONTR","itemId":"700"}],"Available Bundles":{"4488":true,"ZPOB":true,"ZPSS":true},"Company Financial Details":'+
          '{"undefined":"","BUSINESS FUNDING":"{\"0016\":\"2000\"}","FOREIGN TAX RESIDENCY":"false","ENTITY CLASSIFICATION":"FI"},'+
          '"Company Details":{"PREFERRED BRANCH":"3028","COUNTRY OF REGISTRATION":"AL","INDUSTRY CLASSIFICATION":"91110","NATURE OF'+
          ' THE BUSINESS":"26","EMAIL ADDRESS":"suuub@cocm.com","CELLPHONE":"0784125863"},"Residential Address":{"PostalCode":"8129","city"'+
          ':"Joburg","province":"ZAF.EC","suburb":"Sandton","Street":"30 Baker"},"preApplicationResponse":{"orchestrationHeaderResponse":'+
          '{"responseTimeStamp":"2023-05-16","responseStatus":{"statusDescription":"Successful","statusCode":"200","severity":"Info",'+
          '"serverStatusCode":"3"},"respondToAddress":null,"requestTimeStamp":"2023-05-16","instanceId":"","correlationId":'+
          '"6298cd5b-8e1c-d085-7c3f-3337729983ba","channelId":"SBG"},"cipcRegisteredDetails":{"directorDetails":[{"totalMonthlyExpenses"'+
          ':null,"taxDetails":{"taxType":"","taxNumber":"","provisionalTaxPayerInd":""},"status":"ACTIVE,DIRECTOR","relationships":'+
          '{"relationshipTypeCode":""},"preferredCommunicationMethod":"","pipDetails":{"publicOfficialRelatedDetails":{"typeOfRelationship":'+
          '"","surname":"","relatedToPublicOfficial":false,"name":""},"publicOfficial":false},"nationality":null,"mainApplicant":true,'+
          '"loggedInUser":true,"liabilities":null,"lastName":"VERMAAK","isInitiator":false,"identificationType":"","identificationNumber":'+
          '"9302190171083","identificationCountryCode":"ZA","grossMonthlyIncome":null,"firstName":"KATHY NICOLENE","employDetails":'+
          '{"occupationStatus":"","jobTitle":"","industry":""},"emailAddress":null,"directorAddress":{"province":"","postalCode":"1559",'+
          '"countyDistrict":"","country":"","cityDistrict":null,"addressLine4":"GAUTENG","addressLine3":"SPRINGS","addressLine2":"EDELWEISS",'+
          '"addressLine1":"29 IMPALA DRIVE"},"digitalId":null,"citizenship":"","cellphoneNumber":null,"bpId":"0214011910","bpGuid":null,'+
          '"authorizedToApply":true,"assets":null}],"businessDetails":{"soleShareholdingInd":false,"kycAddress":{"province":"GAUTENG",'+
          '"postalCode":"1559","line4":"GAUTENG","line3":"SPRINGS","line2":"EDELWEISS","line1":"29 IMPALA DRIVE","district":"","country":'+
          '"ZA ","city":""},"entityClassification":"      ","businessType":"PRIVATE COMPANY","businessTurnover":"2332000","businessStatus":'+
          '"IN BUSINESS","businessRegistrationNumber":"2021/843301/07","businessProvince":" ","businessName":"VH VOLUME ATION","businessCity":'+
          '"","businessBPID":"0535744849","businessBPGUID":"23980269-0e44-1edd-b984-1ffce6bff814"}},"applicationResponseDetails":{"processID":'+
          '"","processExpiryDate":"2023-05-23","maintenanceOfferID":"0600049687","digitalOfferID":"0045407728"}},"PreApplication":{"Surname":'+
          '"ssyusysy","soleOwner":"false","productNumber":"4648","pricingOption":"ZMMB","PhoneNumber":"0784125863","Name":"testst","IdNum":'+
          '"9302190171083","EmailAddress":"suuub@cocm.com","consent":true,"businessType":"PRIVATE COMPANY","businessTurnover":"2332000",'+
          '"businessProvince":"ZAF.EC","businessName":"tetsys pty","appName":"MYMOBIZ"},"getApplicationProcessDataResponse":'+
          '{"orchestrationHeaderResponse":{"responseTimeStamp":"2023-05-16","responseStatus":{"statusDescription":"Successful",'+
          '"statusCode":"200","severity":"Info","serverStatusCode":"3"},"respondToAddress":"","requestTimeStamp":"2023-05-16","instanceId"'+
          ':"1778601","errorResponse":null,"correlationId":"e3fcf24a-a012-4f17-86c6-2fbd40535a78","channelId":"SF"},"directorDetails":'+
          '[{"totalMonthlyExpenses":"0","taxDetails":{"taxType":"","taxNumber":"","provisionalTaxPayerInd":""},"status":"","relationships"'+
          ':{"relationshipTypeCode":""},"preferredCommunicationMethod":"","pipDetails":{"publicOfficialRelatedDetails":{"typeOfRelationship":'+
          '"","surname":"","relatedToPublicOfficial":false,"name":""},"publicOfficial":false},"nationality":"","mainApplicant":false,"loggedInUser"'+
          ':false,"liabilities":"0","lastName":"JANSEN","isInitiator":false,"identificationType":"","identificationNumber":"9302190171083",'+
          '"identificationCountryCode":"","grossMonthlyIncome":"0","firstName":"KATHY","employDetails":{"occupationStatus":"","jobTitle":"",'+
          '"industry":""},"emailAddress":"","directorAddress":{"province":"","postalCode":"","countyDistrict":"","country":"","cityDistrict":'+
          '"","addressLine4":"","addressLine3":"","addressLine2":"","addressLine1":""},"digitalId":"0","citizenship":"","cellphoneNumber":"0117407280"'+
          ',"bpId":"0214011910","bpGuid":"45530bbe-c616-0164-0000-00000ab6f567","authorizedToApply":false,"assets":"0"}],"businessDetails":'+
          '{"taxNumber":[{"taxType":"","taxNumber":"","reasonNoTaxNum":""}],"sourceOfFunds":[{"sourceFundType":"","sourceFundAmount":"",'+
          '"currency_z":null}],"soleShareholdingInd":false,"prefferedBranch":"","natureOfBusiness":"","marketingConsent":[{"consentStatus":'+
          'false,"consentCode":""}],"kycAddress":{"province":"","postalCode":"","line4":"","line3":"","line2":"","line1":"","district":"",'+
          '"country":"","city":""},"industryClassification":"","idType":"","fiscalMonthEnd":"","entityClassification":"","email":"","countryOfRegistration"'+
          ':"ZA","cellPhone":"","businessType":"ZFS003","businessTurnover":0,"businessStatus":"","businessRegistrationNumber":"2021/843301/07",'+
          '"businessProvince":"","businessName":"VH VOLUME ATION","businessCity":"","businessBPID":"0535744849","businessBPGUID":'+
          '"23980269-0e44-1edd-b984-1ffce6bff814","beeCode":""}},"businessAOResponse":{"orchestrationHeaderResponse":{"responseTimeStamp":"2023-05-16"'+
          ',"responseStatus":{"statusDescription":"Successful","statusCode":"200","severity":"Info","serverStatusCode":"3"},"respondToAddress":null,'+
          '"requestTimeStamp":"2023-05-16","instanceId":"1778601","correlationId":"16b8a1fa-68b7-4ded-805d-e5a883aa4d81","channelId":"SF"}},'+
          '"Personal Details":{"Nationality":"AF","PublicOfficial":"false","Related":"false"},"Employment Details":{"Employed":"false","TaxResident":'+
          '"false"},"Company Trading Address":{"AddressValue":{"Street":"30 Baker","suburb":"Sandton","province":"ZAF.EC","city":"Joburg","PostalCode"'+
          ':"8129"},"AddressType":"Same"},"Marketing Consent":{"chequeCardSelected":"true"},"Notifications":{"NotifiedMean":"EMAIL","depositInfo":'+
          '"true"},"Card Selection":{"chequeCardSelected":"true"}}';
    }
}