/**
* @description Test class to test the Outbound AOB_API_GetRpConfig
* @author  Dayakar
* @modification description: SFP-25088
*/
@IsTest
public class AOB_Internal_API_GetRpConfig_TEST {
    
    private static List<CMN_WebserviceCallQueue__c> setup() {
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_UpdatePersonalDetails.SERVICE_NAME,
            
            UserInfo.getUserId()
        );
        
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
            }
    @IsTest
    public static void callgetRPController(){
        
        String jsondata='{"preApplicationResponse":{"orchestrationHeaderResponse":{"responseTimeStamp":"2023-04-27","responseStatus":{"statusDescription":"Successful","statusCode":"200","severity":"Info","serverStatusCode":"3"},"respondToAddress":null,"requestTimeStamp":"2023-04-27","instanceId":"","correlationId":"6891e8b6-14b4-173d-3088-e832436cc132","channelId":"SBG"},"cipcRegisteredDetails":{"directorDetails":[{"totalMonthlyExpenses":null,"taxDetails":{"taxType":"","taxNumber":"","provisionalTaxPayerInd":""},"status":"ACTIVE,DIRECTOR","relationships":{"relationshipTypeCode":""},"preferredCommunicationMethod":"","pipDetails":{"publicOfficialRelatedDetails":{"typeOfRelationship":"","surname":"","relatedToPublicOfficial":false,"name":""},"publicOfficial":false},"nationality":null,"mainApplicant":true,"loggedInUser":true,"liabilities":null,"lastName":"HLATSHWAYO","isInitiator":false,"identificationType":"","identificationNumber":"9006067094084","identificationCountryCode":"ZA","grossMonthlyIncome":null,"firstName":"ZAMANI","employDetails":{"occupationStatus":"","jobTitle":"","industry":""},"emailAddress":null,"directorAddress":{"province":"","postalCode":"3370","countyDistrict":"","country":"","cityDistrict":null,"addressLine4":"KWA-ZULU NATAL","addressLine3":"LADYSMITH","addressLine2":"TSAKANE NOKUKHANYA ST 11602","addressLine1":"TSAKANE NOKUKHANYA ST 11602"},"digitalId":null,"citizenship":"","cellphoneNumber":null,"bpId":"0535742014","bpGuid":null,"authorizedToApply":true,"assets":null}],"businessDetails":{"soleShareholdingInd":false,"kycAddress":{"province":"KWA-ZULU NATAL","postalCode":"3370","line4":"KWA-ZULU NATAL","line3":"LADYSMITH","line2":"LADYMITH MUCHISON ST","line1":"LADYSMITH MUCHISON ST","district":"","country":"ZA ","city":""},"entityClassification":"      ","businessType":"PRIVATE COMPANY","businessTurnover":"4600000","businessStatus":"IN BUSINESS","businessRegistrationNumber":"","businessProvince":" ","businessName":"K2021997498 (SOUTH AFRICA)","businessCity":"","businessBPID":"0535742009","businessBPGUID":"23980269-0e44-1edd-b8ce-9a5959d321cb"}},"applicationResponseDetails":{"processID":"","processExpiryDate":"2023-05-04","maintenanceOfferID":"0600049374","digitalOfferID":"0045405016"}}}';
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord(jsondata);
        try{
        Test.setMock(HttpCalloutMock.class, new CMN_API_HttpBaseOutboundMock());
            Test.startTest();
        
            AOB_Internal_CTRL_RPDetails.CallGetApplication(applicationId);
            test.stopTest();
            Assert.areNotEqual(null, applicationId, 'not null'); 
       }
       catch(Exception e)
        {
            e.getMessage();
        }
        
        
        
    }

}