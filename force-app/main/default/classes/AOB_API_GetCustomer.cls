/***************************************************************************************
@Author            : Dayakar
@Date              : Nov 23th 2022
@Name of the Class : AOB_API_GetCustomer
@description       : Class used to Perform an API call to persist user info in SAP
@Last Modified By  : Dayakar 
@Last Modified On  : 19 APRIL 2024
@Modification Description : SFP-37349
***************************************************************************************/
public class AOB_API_GetCustomer extends AOB_API_RestBaseOutboundPing {
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';   
    private String QUERY_PARAMETERS;
    
    /**
     * @description constructor used to make sure a token will be provided to authenticate to the API call
     * @param uuid 
     */
    public AOB_API_GetCustomer(String uuid)
    {
        this.accessToken =  AOB_Utils.getAccessToken();
        this.QUERY_PARAMETERS = uuid;
    }
    
    public static final String SERVICE_NAME = AOB_API_GetCustomer.class.getName();

    /**
     * @description The name of your service to be used when looking up custom settings for you service
     *
     * @return SERVICE_NAME
     */
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }


    public override String getResponseBody()
    {
        return response.getBody();
    }

    
    /**
     * @description The name of the parameters passed, in this case the uuid
     *
     * @return QUERY_PARAMETERS
     */
    @TestVisible
    protected override String getQueryParameters()
    {
        return QUERY_PARAMETERS;
    }
    
    /**
     * @description Override to set your request and response DTO types and any other globals you may have
     */
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();

    }

    private class DTO_Request extends CMN_DTO_JsonBase
    {
        /**
       * @description populates triggering object
       * @param triggeringObjectId
       */
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);
        }
    }

    /**
     * @description Will serialize requestDTO after its been populated.
     *
     * @return result
     */
    protected virtual override String getBody()
    {
        super.getBody();

    
        return null;
    }

    /**
     * @description Overriding parent class method to use the right API Method
     * @return String
     */
     @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_GET;
    }
      
    /**
     * @description Overriding parent class method to use the right API Method
     */
    @TestVisible
    protected virtual override void setHeaders() 
    {
       setServiceSettings();
       request.setMethod(HTTP_VERB_GET);
       request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
       request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
       request.setHeader(HTTP_HEADER_CLIENT_ID, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientId}');
        request.setHeader(HTTP_HEADER_CLIENT_SECRET, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientSecret}');
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }         
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
        request.setHeader(HTTP_HEADER_CHANNELID,settings.AOB_Channel__c);
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer '+this.accessToken);      
        request.setTimeout(120000);  
     }

    /**
     * @description Method is use to return the endpoint URL using in HTTP response.
     *
     * @return endpoint
     */
    @TestVisible
    protected override String getWebServiceEndPoint()
    {
        String endPoint;
        
        string path = String.isNotBlank(this.QUERY_PARAMETERS) ? '/' + this.QUERY_PARAMETERS : CMN_UTIL_String.EMPTY;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c + path : CMN_UTIL_String.EMPTY;
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                        String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
                            }
            );
        }
        
        return endPoint;
    }

    
     /**
     * @description Call the parent objects' method to ensure we get code coverage
     *
     * @return CMN_API_HttpBaseOutboundMock
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        return new AOB_GetCustomer();
    }
    /**
     * @description Overriding parent class method to indicate that triggering object is not needed
     * @return Boolean
     */
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }

    /**
     * @description Wrapper class for http response
     */
    public class DTO_Response extends CMN_DTO_JsonBase
    {
         /**
        * @description response
        * @return String
        */
        @AuraEnabled
        public string response { get; set; }

        /**
         * @description The Type of the DTO used when deserializing the class
         *
         * @return Class of the DTO
         */
        protected override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }
    
     /**
    * @description Mock class for Test classes
    */
    public class AOB_GetCustomer extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse ='{"customer":{"uuid":"e3417649-3147-1eee-a6e1-2225626b710d","customer_type":"2","customer_typeX":"ENTERPRISE","orgDetails":{"legalName":"pravesh new business","companyName":"pravesh new business","legalForm":"006","legalFormX":"SOLE PROPRIETORSHIP","orgEstablishDt":"2023-12-15","numEmployees":"0000000","fiscalYearEnd":"2024-02-29"},"tax":[{"taxType":"AF2","taxTypeX":"Afghanistan : VAT Number","taxNumber":"66856"}],"identifications":[{"type":"11","typeX":"ENTERPRISE IDENTITY NUMBER","number":"8003035085089","issuingCountry":"ZA","issuedDate":"2023-12-15","expirationDate":"9999-12-31"}],"contacts":[{"type":"PHONE","value":"0844662927","countryCode":"ZA","preferredInd":"true","contactPeriod":"03","contactPeriodX":"ANYTIME","obsoleteInd":"false","phoneType":"2","startDate":"2023-12-15","endDate":"9999-12-31"},{"type":"EMAIL","value":"praveshgordhan@gmail.com","preferredInd":"true","obsoleteInd":"false","startDate":"2023-12-15","endDate":"9999-12-31"}],"addresses":[{"uuid":"b5219570-7fcb-1ede-a6e1-6dfc2279c9f4","type":[{"addressType":"05","addressTypeX":"KYC","startDate":"2023-12-15","endDate":"9999-12-31"}],"line3":"Ragian street","district":"sandton","city":"Africa estate","province":"ZAF.EC","provinceX":"EASTERN CAPE","postalCode":"3445","countryCode":"ZA","startDate":"2023-12-15","endDate":"9999-12-31"},{"uuid":"b5219570-7fcb-1ede-a6e1-6dfc227a09f4","type":[{"addressType":"03","addressTypeX":"LEGAL","startDate":"2023-12-15","endDate":"9999-12-31"}],"line3":"Ragian street","district":"sandton","city":"Africa estate","province":"ZAF.EC","provinceX":"EASTERN CAPE","postalCode":"3445","countryCode":"ZA","startDate":"2023-12-15","endDate":"9999-12-31"}],"sourceOfFunds":[{"sourceFundType":"0016","sourceFundTypeX":"BEE Transaction","sourceFundAmount":"5467.0","currency":"ZAR"}],"statuses":[{"status":"72","desc":"FINANCIAL INSTITUTION","effDate":"2023-12-15","expDate":"9999-12-31"}],"prefLanguage":"EN","mktgSegment":"400","mktgSegmentX":"ENTERPRISE DIRECT","customerRole":[{"role":"CRM000","roleX":"SOLD TO PARTY","startDate":"2023-12-15","endDate":"9999-12-31"},{"role":"BUP014","roleX":"CUSTOMER","startDate":"2023-12-15","endDate":"9999-12-31"}],"responsibleBranch":"0005541","authorizationGroup":"SBSA","marketingConsents":[{"consentCode":"01","consentCodeX":"EXTERNAL MARKETING","consentStatus":"false"},{"consentCode":"02","consentCodeX":"MARKETING RESEARCH","consentStatus":"true"},{"consentCode":"04","consentCodeX":"SHARE CUSTOMER DATA","consentStatus":"true"},{"consentCode":"23","consentCodeX":"CROSS BORDER SHARING","consentStatus":"false"},{"consentCode":"26","consentCodeX":"SMS CONSENT","consentStatus":"true"},{"consentCode":"25","consentCodeX":"EMAIL CONSENT","consentStatus":"true"},{"consentCode":"27","consentCodeX":"STAFF ATTESTATION","consentStatus":"true"},{"consentCode":"28","consentCodeX":"TELE-SALES CONSENT","consentStatus":"true"},{"consentCode":"08","consentCodeX":"CREDIT CHECK CONSENT","consentStatus":"true"},{"consentCode":"07","consentCodeX":"IDENTITY & FRAUD CHECK","consentStatus":"true"}],"industrialSectors":[{"industrialSector":"01403","industrialSectorX":"AGRICULTURE SERVICE ACTIVITIES","industrialClassificationSystem":"0003","industrialClassificationSystemX":"ISIC CODE - PRIMARY"},{"industrialSector":"23","industrialSectorX":"SA RES UNINCORPORATED BUSINESS","industrialClassificationSystem":"0004","industrialClassificationSystemX":"FORM 50 CODES"},{"industrialSector":"842","industrialSectorX":"BUSINESS SERVICES (C)","industrialClassificationSystem":"0005","industrialClassificationSystemX":"RESERVE BANK CODES"},{"industrialSector":"18","industrialSectorX":"Alternative Medical Service Providers","industrialClassificationSystem":"0008","industrialClassificationSystemX":"NATURE OF BUSINESS"}],"lastUpdateDt":"2023-12-18","complianceRoles":[{"compRole":"02","compRoleX":"CUSTOMER","complianceStatus":"Y","complianceStatusX":"COMPLETE","verifiedBy":"KYC_ENGINE"}]}}';
        
    /*
    * @description creates a mock response for http calls
    * @param  request
    * @param response
    */
        protected override void setResponse(
            HttpRequest request,
            HttpResponse response
        )
        {
            
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }

}