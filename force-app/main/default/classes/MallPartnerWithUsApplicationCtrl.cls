/**
 * 
 * @description MallPartnerWithUsApplicationCtrl
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallPartnerWithUsApplicationCtrl {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('MallPartnerWithUsApplicationCtrl');
    /**
     * 
     * @description getUserRecord
     * @param userId String
     * @return  `User`
     */
    @AuraEnabled
    public static User getUserRecord(String userId) {
        try{
            List<User> users = SEL_Users.newInstance().selectById(new Set<Id>{(Id)userId});

            return (!users.isEmpty() ? users[0] : NULL);
        } catch(Exception e) {
            throw throwAuraException('getUserRecord', e);
        }
    }

    /**
     * 
     * @description createCaseRecord
     * @param case Case
     * @return  `String`
     */
    @AuraEnabled
    public static String createCaseRecord(Case caseRecord){
        try {
            String caseId;
            HTTPResponse responseCaseCreation = MallPartnerWithUsApplicationCtrl.sendHTTPRequest(JSON.serialize(caseRecord));
            if(responseCaseCreation.getStatusCode() == 201) {  
                map<string,Object> resultMap = (map<string,Object>)JSON.deserializeUntyped(responseCaseCreation.getBody()); 
                caseId = (String)resultMap.get('id');        
            }
            return caseId;
        } catch (Exception e) {
            throw throwAuraException('createCaseRecord', e);
        }
    } 

    /**
     * 
     * @description sendHTTPRequest
     * @param body String
     * @return  `HTTPResponse`
     */
     public static HTTPResponse sendHTTPRequest(String body) {
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:Salesforce_REST_API_Access/services/data/v56.0/sobjects/Case/');            
            request.setBody(body); 
            request.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HTTPResponse response = http.send(request);
            return response;
        } catch(Exception e) {
            throw throwAuraException('sendHTTPRequest', e);
        }
    }

    /**
   * 
   * @description Method to return Exception for each catch block
   * @param message String 
   * @param e Exception
   * @return  `AuraHandledException`
   */
  @TestVisible
  private static AuraHandledException throwAuraException(String message, Exception e) {
    LOGGER.error(message, e);
    AuraHandledException auraException = new AuraHandledException(e.getMessage());
    auraException.setMessage(e.getMessage());
    return auraException;
  }
}