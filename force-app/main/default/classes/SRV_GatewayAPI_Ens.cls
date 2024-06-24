/**
 * A class that implements HTTP service to integrate SF data with the ENS(Risk App Store APIs).
 *
 * @author Nikita
 * @date 2023-01-30
 *
 */
public with sharing class SRV_GatewayAPI_Ens {
    private static final STRING CERTIFICATE_NAME      = 'ENS_Cert';
    private static final String NAMED_CREDENTIAL_NAME = 'Ens_esb_Proxy_Service';
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SRV_GatewayAPI_Ens');
    
    private static String certificate {
        private set;
            get {
                if (certificate == null) {
                    certificate = [SELECT Id, Body__c FROM Certificate__mdt WHERE DeveloperName = :CERTIFICATE_NAME LIMIT 1].Body__c;
                }
                return certificate;
            }
    }

    private static ENS_Integration_Info__c ensIntegrationInfo {
        private set;
        get {
            if (ensIntegrationInfo == null) {
                ensIntegrationInfo = ENS_Integration_Info__c.getInstance();
            }
            return ensIntegrationInfo;
        }
    }

    private static Azure_ENS__c azureEns {
        private set;
        get {
            if (azureEns == null) {
                azureEns = Azure_ENS__c.getInstance();
            }
            return azureEns;
        }
    }	
    public Map<String, String> postAssessmentData(List<Business_Assessment__c> bAssessments) {
        Map<String, String> result = new Map<String, String>();
        Map<Id, Business_Assessment__c> bAssesmentToId = new Map<Id, Business_Assessment__c> (bAssessments);
        HttpRequest request = new HttpRequest();
        List<ENSChecksResult> results;
                
        try {
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-fapi-interaction-id', new Uuid().getValue());
            request.setHeader('x-client-certificate', certificate);
            request.setHeader('Ocp-Apim-Subscription', ensIntegrationInfo.Ocp_Apim_Subscription__c);
            request.setHeader('x-ras-token', getENSAuthToken());	//Azure token
            request.setHeader('Authorization', 'Bearer ' + getESBAuthToken());
            request.setBody(prepareBody(bAssesmentToId.values()));
            request.setMethod('POST');
            request.setTimeout(120000);
			String resEndPoint = Test.isRunningTest()
                ? 'testHostUrl' + ensIntegrationInfo.Post_Assessment_URL__c
                : [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = :NAMED_CREDENTIAL_NAME LIMIT 1].Endpoint + ensIntegrationInfo.Post_Assessment_URL__c;
            request.setEndpoint(resEndPoint);
      
                HTTPResponse response = new Http().send(request);
                if (response.getStatusCode() == 200) {
                    updateInsertedRecords(bAssesmentToId.keySet());
                    result.put('success', 'Records had been successfully posted!');
                    return result;
                } else {
                    results = (List<ENSChecksResult>) JSON.deserializeStrict(response.getBody(), List<ENSChecksResult>.class);
                    for (ENSChecksResult wrapper : results) {
                        if (String.isNotBlank(wrapper.errorPayload)) {
                            System.debug('wrapper.errorPayload: ' + wrapper.errorPayload);
                            bAssesmentToId.remove(wrapper.id);
                        }
                    }
                    if (!bAssesmentToId.values().isEmpty()) {
                        request.setBody(prepareBody(bAssesmentToId.values()));
                        response = new Http().send(request);
                        if (response.getStatusCode() == 200) {
                            updateInsertedRecords(bAssesmentToId.keySet());
                            result.put('success', 'Records had been successfully posted!');
                            return result;
                        } else {
                            results = (List<ENSChecksResult>) JSON.deserializeStrict(response.getBody(), List<ENSChecksResult>.class);
                            for (ENSChecksResult wrapper : results) {
                                LOGGER.error(wrapper.errorPayload, new String[] { SRV_GatewayAPI_Ens.class.getName() });
                                result.put('error', wrapper.errorPayload);
                            }
                        }
                    } else {
                        results = (List<ENSChecksResult>) JSON.deserializeStrict(response.getBody(), List<ENSChecksResult>.class);
                        for (ENSChecksResult wrapper : results) {
                            LOGGER.error(wrapper.errorPayload, new String[] { SRV_GatewayAPI_Ens.class.getName() });
                            result.put('error', wrapper.errorPayload);
                        }
                    }
                }
            
        } catch (IB_SRV_GatewayAPI_Exception e) {
            LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { SRV_GatewayAPI_Ens.class.getName() });
            result.put('error', e.getMessage());
        } catch (Exception e) {
            LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { SRV_GatewayAPI_Ens.class.getName() });
            result.put('error', e.getMessage());
        }
        return result;
    }
    
    public interface IService {
        Map<String, String> postAssessmentData(List<Business_Assessment__c> bAssessments);
    }

    public static IService newInstance() {
        return(IService) ORG_Application.service.newInstance(IService.class);
    }

    /**
     * A method that initiates GET HTTP callout to the external API system to get an access token.
     *
     * @param HttpRequest - The HttpRequest that will be send to service to get an access token.
     *
     * @return an access token.
     */
    private String getToken(HttpRequest request) {
        OAuthResponse newToken = authenticate(request);
        if (newToken == null) {
            throw new IB_SRV_GatewayAPI_Exception('Authentication is temporary unavailable');
        }
        
        return newToken.access_token;
    }

    /**
     * A method that initiates GET HTTP callout to the external API system to get an access token.
     *
     * @param HttpRequest - The HttpRequest that will be send to service to get an access token.
     *
     * @return wrapper class that contains parsed response body returned by an authentication request.
     * Consists of information that is returned by APIs.
     */
    private OAuthResponse authenticate(HttpRequest request) {
        try {
            HttpResponse res = new Http().send(request);
            if (res.getStatusCode() == 200) {
                OAuthResponse response = (OAuthResponse) JSON.deserialize(res.getBody(), OAuthResponse.class);                                
                return response;
            } else {
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                LOGGER.error(
                    'Failed SRV_GatewayAPI_Ens.authenticate(),\n Error description' + String.valueOf(response.get('error_description')),
                    new String[] { SRV_GatewayAPI_Ens.class.getName() }
                );
                return null;
            }
        } catch (Exception e) {
            LOGGER.fatal('Failed SRV_GatewayAPI_Ens.authenticate(),\n StackTraceString:' + e.getStackTraceString() + '\n getMessage:' + e.getMessage());
            return null;
        }
    }

    /**
     * A method that gets an access token for the ESB proxy service.
     *
     * @return an access token for the ESB proxy service.
     */
    private String getESBAuthToken() {
        return getToken(getESBAuthRequest());
    }

    /**
     * A method that gets an access token for the ESB proxy service.
     *
     * @return a Http request than need to be send to the ESB proxy service for the authentication.
     */
    private HttpRequest getESBAuthRequest() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Ens_esb_Proxy_Service' + ensIntegrationInfo.ESB_Token_URL__c);
        request.setHeader('Authorization', 'Basic {!$Credential.AuthorizationHeaderValue}');
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('x-client-certificate', certificate);
        request.setBody(ensIntegrationInfo.ESB_Grant_Type__c);
        return request;
    }

    /**
     * A method that gets an access token for the Risk App Store service.
     *
     * @return an access token for the Risk App Store service.
     */
    private String getENSAuthToken(){
        return getToken(getENSAuthRequest());
    }
    
    /**
     * @description: Prepare required JSON format
     * 	 
	 * @param: scope: List of records Busines_Assessments__c 
	 * @return: Serialized list of records in a wrapper class
     * */
    @TestVisible
    private String prepareBody(List<Business_Assessment__c> basToPublish) {
        try {
            BusinessAssessmentWrap[] baList= new List<BusinessAssessmentWrap>();
            for (Business_Assessment__c baToPublish: basToPublish) {
                baList.add(new BusinessAssessmentWrap(
                    String.valueOf(baToPublish.Id),
                    String.valueOf(baToPublish.Account__r.CIF__c),
                    String.valueOf(baToPublish.Name)
                ));
            }        
            return JSON.serialize(baList);
        } catch (Exception e) {
            LOGGER.fatal('Failed Ens_BATCH_SyncJob.prepareBody(),\n StackTraceString:' + e.getStackTraceString() + '\n getMessage:' + e.getMessage());
            return null;
        }
    }
    
    /**
     * A method that gets an access token for ENS(Risk App Store) APIs.
     *
     * @return a Http request than need to be send to ENS(Risk App Store) APIs for the authentication.
     */
    private HttpRequest getENSAuthRequest() {
        HttpRequest request = new HttpRequest();                
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setBody(String.format('client_Id={0}&client_Secret={1}&grant_type={2}', new List<String> {
            azureEns.Consumer_Key__c,
            azureEns.Consumer_Secret__c,
            azureEns.Grant_Type__c
        }));   
        request.setEndpoint(azureEns.Token_Endpoint_URL__c);
        return request;
    }

    /**
     * A method that updates BA record if they were successfully inserted in the ENS tool.
     **/    
    private void updateInsertedRecords(Set<Id> bAssessmentIds) {
        List<Business_Assessment__c> recordsToUpdate = new List<Business_Assessment__c>();
        
        for (Id baId: bAssessmentIds) {
            recordsToUpdate.add(new Business_Assessment__c(
                Id 			  = baId,
                ENS_status__c = 'Published'
            ));
        }
        
        update recordsToUpdate;
    }

    public class IB_SRV_GatewayAPI_Exception extends Exception { }

    private class OAuthResponse {
        public String token_type;
        public String access_token;
        public String expires_in;
        public String consented_on;
        public String scope;
    }    
	/**
     * @description: Wrapper class for preparing callout JSON body  	
     * */
    public class BusinessAssessmentWrap {
        public Id id           { get; set; }
        public String cif      { get; set; }
        public String baNumber { get; set; }
        public BusinessAssessmentWrap(Id recordId, String groupParentCIFNumber, String baNumber) {
            this.id       = recordId;
            this.cif      = groupParentCIFNumber;
            this.baNumber = baNumber;
        }
    }

    public class ENSChecksResult {
        public Integer statusCode  { get; set; }
        public String errorPayload { get; set; }
        public String id           { get; set; }
        public String cif          { get; set; }
        public Integer linkedId    { get; set; }
    }
}