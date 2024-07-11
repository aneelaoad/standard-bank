/***************************************************************************************
@Author            : Narendra Teja
@Date              : May 29th 2023
@Name of the Class : AOB_API_HttpWfrNotify
@description       : The REST Web Service to update the WFR Status on the Verification from BPM
@Last Modified By  : Narendra 
@Last Modified On  : 03 July 2024
@Modification Description : SFP-39934
***************************************************************************************/
global with sharing class AOB_API_HttpWfrNotify extends CMN_API_HttpBaseInbound {
    
    public static final String SERVICE_NAME = AOB_API_HttpWfrNotify.class.getName();
    private static final String SUCCESS_MESSAGE = AOB_Constants.WFR_STATUS_SUCCESS_MESSAGE;
    private static final String VERIFICATION_NOT_FOUND = AOB_Constants.WFR_STATUS_VERIFICATION_NOT_FOUND;
    private static final String APPLICATION_NOT_FOUND = 'Application Not Found';
    private static final String VERIFICATION_PASSED = 'Verification Passed';
    private static final String ERROR_MESSAGE = AOB_Constants.WFR_STATUS_ERROR_MESSAGE;
    private static final String EXTERNAL_USER_PROFILE = AOB_Utils.getAppSettingByLabel(AOB_Constants.PROFILE);  
    /**
      * @description An override of the initialise base method
      */
    protected override void initialise() {
        super.initialise();      
    }
    /**
    * @description An override of base method which adds parsing of the inbound requestBody into baseRequestDTO
    */
    @TestVisible protected virtual override void processRequest(){     
        super.processRequest();        
        String requestBody = requestBody;

        try{
            String applicationId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
         	AOB_DTO_HttpWfrNotify.WfrNotify dtData = (AOB_DTO_HttpWfrNotify.WfrNotify)System.JSON.deserialize(requestBody, AOB_DTO_HttpWfrNotify.WfrNotify.class);
            if(applicationId != null){
                List<AOB_Application__c> app = [SELECT Id FROM AOB_Application__c WHERE Id = :applicationId limit 1];
                if(app.size() != 0){
                    List<Verification__c> verification = [SELECT Id, AOB_WFR_Status__c, AOB_WFR_ErrorCode__c, AOB_WFR_Message__c FROM Verification__c WHERE Application__c = :applicationId ORDER BY CreatedDate DESC];
                    if(verification.size() > 0){
                        verification[0].AOB_WFR_Status__c = dtData.wfrStatus;
                        verification[0].AOB_WFR_ErrorCode__c = dtData.wfrMessage;
                        verification[0].AOB_WFR_Message__c = 'Inbound Message :'+dtData.wfrErrorCode;
                        if(dtData.wfrStatus == VERIFICATION_PASSED){
                            callCompleteAoIDV(applicationId,verification[0]);
                        }else{
                            update verification;
                        } 
                        response.responseBody = Blob.valueOf('{"Id":"' + app[0].Id +'","code":"' + 200 + '","message":"' + SUCCESS_MESSAGE + '"} ');
                    }else{
                        response.responseBody = Blob.valueOf('{"Id":"' + app[0].Id +'","code":"' + 200 + '","message":"' + VERIFICATION_NOT_FOUND + '"} ');
                    }
                } 
                else{
                    Blob.valueOf('{"Id":"' + app[0].Id +'","code":"' + 200 + '","message":"' + APPLICATION_NOT_FOUND + '"} ');
                } 
            } else {
                response.responseBody = Blob.valueOf('"code":"' + 401 + '","message":" missing data"} ');
            }
        }catch(Exception e){
            response.responseBody = Blob.valueOf('{"code":"' + 404 + '","message":"' + e.getMessage() + '"} ');
            CMN_UTIL_Logger.error(e.getMessage(), SERVICE_NAME);
        }
    }  
    /**
    * @description mock process request URL
    * @param request this is the full http request structure
    */
    public static void processRequestMock(RestRequest request){     
        String requestBody = request.requestBody.toString();
        RestResponse response = new RestResponse();
        String wfrStatus;
        String wfrMessage;

        try{
        	String applicationId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        	AOB_DTO_HttpWfrNotify.WfrNotify dtData = (AOB_DTO_HttpWfrNotify.WfrNotify)System.JSON.deserialize(requestBody, AOB_DTO_HttpWfrNotify.WfrNotify.class);
            
            if(applicationId != null){
                Verification__c app = new Verification__c();
                if(dtData.wfrStatus != null) {
                    wfrStatus = dtData.wfrStatus;
                    app.AOB_WFR_Status__c  = wfrStatus;
                }
                if(dtData.wfrMessage != null) {
                    wfrMessage = dtData.wfrMessage;
                    app.AOB_WFR_Message__c = wfrMessage;
                }
                response.responseBody = Blob.valueOf('{"Id":"' + app.Id +'","code":"' + 200 + '","message":"' + SUCCESS_MESSAGE + '"} ');
            }
        }catch(Exception e){
            response.responseBody = Blob.valueOf('{"code":"' + 404 + '","message":"' + e.getMessage() + '"} ');
            CMN_UTIL_Logger.error(e.getMessage(), SERVICE_NAME);
        }
    }
    /**
    * @description mock process request URL to test exceptions
    * @param request this is the full http request structure
    */
    public static void processRequestMockException(RestRequest request){     
        String requestBody = request.requestBody.toString();
        RestResponse response = new RestResponse();
        String wfrStatus;
        String wfrMessage;

        try{
        	String applicationId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        	AOB_DTO_HttpWfrNotify.WfrNotify dtData = (AOB_DTO_HttpWfrNotify.WfrNotify)System.JSON.deserialize(requestBody, AOB_DTO_HttpWfrNotify.WfrNotify.class);
        
            if(applicationId != null){
                Verification__c app = new Verification__c();
                if(dtData.wfrStatus != null) {
                    wfrStatus = 'Exception Occurred';
                    app.AOB_WFR_Status__c  = wfrStatus;
                }
                if(dtData.wfrMessage != null) {
                    wfrMessage = 'Exception Occurred';
                    app.AOB_WFR_Message__c = wfrMessage;
                }
                response.responseBody = Blob.valueOf('"code":"' + 401 + '","message":" exception occurred"} ');
            }
        }catch(Exception e){
            response.responseBody = Blob.valueOf('{"code":"' + 404 + '","message":"' + e.getMessage() + '"} ');
            CMN_UTIL_Logger.error(e.getMessage(), SERVICE_NAME);
        }
    }   

    /**
    * @description mock process request URL to test exceptions
    * @param applicationId String
    * @param verificationRecord Verification__c
    */
    public static void callCompleteAoIDV(String applicationId, Verification__c verificationRecord){ 
        String totalResponse;
        AOB_API_CompleteAO_IDV customerServiceCall = new AOB_API_CompleteAO_IDV(applicationId);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CompleteAO_IDV.SERVICE_NAME);
        customerServiceCall.process(obj); 
        insert obj;
        verificationRecord.AOB_WFR_Message__c = verificationRecord.AOB_WFR_Message__c+' OutboundMessage:'+customerServiceCall.getResponseStatusCode() + 'WebServiceID:'+obj.Id;
        update verificationRecord;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
    } 
}