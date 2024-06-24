/**
 * @description       : SFP-19834 Class to make callouts to the Ping
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             :
 * @last modified on  : 02-26-2024
 * @last modified by  : Jaco de Lange
 **/
@SuppressWarnings('PMD')
public without sharing class PP_SRV_PING implements IService {

    private String access_token;
    private string client_Id;
    private String cookie;
    private String flowId;


    /**
    * @description       : Returns instance of service class
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @group             :
    * @last modified on  : 02-26-2024
    * @last modified by  : Jaco de Lange
    **/
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    /**
    * @description       : Interface for Iservice to make callouts for PING registration
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @group             :
    * @last modified on  : 02-26-2024
    * @last modified by  : Jaco de Lange
    **/
    public interface IService {

        /**
         * @description       : Check by email address if the customer is already exist in the system
         * @param             : customerEmail
         * @return            : PP_IntegrationResult
         * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
         * @group             : Cloudsmiths
         * @last modified on  : 02-26-2024
         * @last modified by  : Jaco de Lange
         */
        PP_IntegrationResult searchCustomer(String customerEmail);

        /**
         * @description       : Register user to the Ping
         * @param             : userData
         * @return            : PP_IntegrationResult
         * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
         * @group             : Cloudsmiths
         * @last modified on  : 02-26-2024
         * @last modified by  : Jaco de Lange
         */
        PP_IntegrationResult registerUser(Map<String, String> userData);
    }

    /**
     * @description       : Make callouts and returns result according to the StatusCode
     * @param             : request
     * @param             : checkCode
     * @return            : PP_IntegrationResult
     * @author            : Peter Guest (peter.guest@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    private PP_IntegrationResult doCallout(HttpRequest request, Boolean checkCode) {

        PP_IntegrationResult result = new PP_IntegrationResult();

        try {
            Http http = new Http();
            HttpResponse response = http.send(request);
        
            if(checkCode && response.getStatusCode() != 200) {
                result.resultStatus = PP_IntegrationResult.ERROR;
                result.resultMessage = 'Status Code: '+response.getStatusCode()+ ' Status Message: '+response.getStatus();
            }

            result.setResponse(response);
        }
        catch(Exception e) {
            result.resultStatus = PP_IntegrationResult.FAILED;
            result.resultMessage = 'Exception: '+e.getStackTraceString();
        }
        return result;
    }

    /**
    * @description 
    * @author Peter Guest | 27-07-2023 
    * @param request 
    * @return PP_IntegrationResult 
    **/
    private PP_IntegrationResult doCallout(HttpRequest request) {
        return doCallout(request, true);
    }

    /**
     * @description       : Retrieve Access Token
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @return            : PP_IntegrationResult
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    private PP_IntegrationResult getAccessToken() {

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:PP_Ping_Get_Token/as/token.oauth2');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', 'Application/json');

        String body =   'grant_type=client_credentials'+
                        '&client_id={!$Credential.PP_Ping_Base_Service_Credential.Client_Id}'+
                        '&client_secret={!$Credential.PP_Ping_Base_Service_Credential.Client_Secret}'+
                        '&scope=urn:pingidentity:directory-api';

        request.setBody(body);
        this.client_Id = request.getBody().split('&').get(1).split('=').get(1);

        PP_IntegrationResult callout = doCallout(request);

        if (callout.isSuccess()) {
            PingResult result = (PingResult)JSON.deserialize(callout.getBody(), PingResult.class);
            this.access_token = result.access_token;           
        }

        return callout;
    }

    /**
     * @description       : Check by email address if the customer is already exist in the system
     * @param             : customerEmail
     * @return            : PP_IntegrationResult
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    public PP_IntegrationResult searchCustomer(String customerEmail) {

        PP_IntegrationResult result = getAccessToken();

        if (result.isSuccess()) {

            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:PP_Ping_Directory_Service/directory/v1/ou=People,dc=sbsa,dc=com/subtree?searchScope=wholeSubtree&filter=SB-mail%20eq%20%22'+customerEmail +'%22');
            request.setMethod('GET'); 
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Accept', 'Application/json');
            request.setHeader('Authorization', 'Bearer ' + this.access_token);

            result = doCallout(request);

            if (result.isSuccess()) {            
                result = (PingResult) JSON.deserialize(result.getBody(), PingResult.class);
                result.resultStatus = PP_IntegrationResult.SUCCESS;
            }
        }

        return result;
    }

    /**
     * @description       : Retrieve flow Id before registering user to the Ping
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @return            : PP_IntegrationResult
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    private PP_IntegrationResult retrieveFlowId() {

        String codeVerifier = CMN_UTIL_OAuth.generateRandomCode();

        /* code challenge is first part of the pkce puzzle sent to ping */
        String codeChallenge = CMN_UTIL_OAuth.generateChallenge(codeVerifier);

        HttpRequest request = new HttpRequest();

        String payload = 'client_id={!$Credential.PP_Ping_Base_Service_Credential.Client_Id}'+
        '&response_type=code'+
        '&scope=openid profile email'+
        '&redirect_uri=https://localhost:3000'+
        '&code_challenge='+codeChallenge+
        '&code_challenge_method=S256'+
        '&nonce=fd435ed2-783a-4231-a2ca-39795cbf29ac'+
        '&state=fd435ed2-783a-4231-a2ca-39795cbf29ac'+
        '&response_mode=pi.flow';

        request.setBody(payload);
        request.setEndpoint('callout:PP_Ping_Get_Token/as/authorization.oauth2');
        
        request.setMethod('POST'); 
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        PP_IntegrationResult result = doCallout(request);

        if (result.isSuccess()) {
            this.cookie = result.getHeader('Set-Cookie');
            PingResult flowResult = (PingResult)JSON.deserialize(result.getBody(), PingResult.class);
            this.flowId = flowResult.id;  
            result.resultStatus = PP_IntegrationResult.SUCCESS;
        }

        return result;
    }

    /**
     * @description       : Retrieve flow Id before registering user to the Ping
     * @param             : flowId
     * @param             : cookie
     * @return            : IntegratiPP_IntegrationResultonResult
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    private PP_IntegrationResult initiateRegistration() {

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:PP_Ping_Get_Token/pf-ws/authn/flows/' + this.flowId + '?action=initiateRegistration');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', 'Application/json');
        request.setHeader('X-XSRF-Header', 'pingfederate');
        request.setHeader('Cookie', this.cookie);
 
        PP_IntegrationResult result = doCallout(request);

        if (result.isSuccess()) {
            this.cookie = result.getHeader('Set-Cookie');
        }

        return result;
    }

    /**
     * @description       : Register user to the Ping
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @param             : userData
     * @return            : PP_IntegrationResult
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    public PP_IntegrationResult registerUser(Map<String, String> userData) {

        PP_IntegrationResult result = retrieveFlowId();

        if (result.isSuccess()) {

            result = initiateRegistration(); 

            if (result.isSuccess()) {

                FieldValues values = new FieldValues();
                values.lipFirstName = userData.get('firstName');
                values.lipLastName = userData.get('lastName');
                values.lipCellphoneNumber = userData.get('mobileNumber');
                values.lipmail = userData.get('emailAddress');
                values.lipusername = userData.get('userName');
                values.lipCountryCode = 'South Africa +27';
                values.lipChannel = 'Partner Connect';
                values.lipEmailverificationStatus = 'true';

                UserDetail user = new UserDetail();
                user.password = userData.get('password');
                user.fieldValues = values;

                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:PP_Ping_Get_Token/pf-ws/authn/flows/'+this.flowId+'?action=registerUser');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'Application/json');
                request.setHeader('X-XSRF-Header', 'test');
                request.setHeader('Cookie', this.cookie);
                request.setBody(JSON.serialize(user));

                result = doCallout(request, false);

                if (result.isSuccess()) {

                    if (result.getStatusCode() == 400) {
                        PingResult registerResult = (PingResult) JSON.deserialize(result.getBody(), PingResult.class);
                        result.resultStatus = PP_IntegrationResult.ERROR;
                        result.resultMessage = registerResult.details.get(0).userMessage;
                    } 
                }
            }
        }
        return result;
    }
    /**
     * @description       : Class to return the required attribute of PING
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    public class PingResult extends PP_IntegrationResult {

    /**
     * @description       : Returns Access token for PING registration
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String access_token { get; set; }

    /**
     * @description       : Returns the size of existing customer whether zero or greater than zero
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public Integer size { get; set; }

    /**
     * @description       : Returns the User registration Id
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String id { get; set; }

    /**
     * @description       : Returns the cookie Id
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String cookie { get; set; }

    /**
     * @description       : Variable to return the FieldValues class instance with values
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public List<ResultRegisterUserDetails> details { get; set; }
    }

    /**
     * @description       : Class to store the retuned status code and message
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    public class ResultRegisterUserDetails {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String userMessage;
    }

    /**
     * @description       : Class to store password and user details of the user
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    public class UserDetail {
        
        /**
     * @description       : Returns the password that user uses to register to the Ping
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String password { get; set; }

    /**
     * @description       : Variable to return the FieldValues class object with values
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public FieldValues fieldValues { get; set; }
    }

    /**
     * @description       : Class to store the returned user details
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
    public class FieldValues {

    /**
     * @description       : Variable to return the User Firstname
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String lipFirstName { get; set; }

    /**
     * @description       : Variable to return the User Last name
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String lipLastName { get; set; }

    /**
     * @description       : Variable to return the User phone number
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String lipCellphoneNumber { get; set; }

    /**
     * @description       : Variable to return the User email
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String lipmail { get; set; }

    /**
     * @description       : Variable to return the Username
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String lipusername { get; set; }

    /**
     * @description       : Variable to return the Country code
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String lipCountryCode { get; set; }
    /**
     * @description       : Variable to return the Channel
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        
        public String lipChannel { get; set; }
    /**
     * @description       : Variable to return the User Email verification status 
     * @author            : Peter Guest
     * @group             : Cloudsmiths
     * @last modified on  : 02-26-2024
     * @last modified by  : Jaco de Lange
     */
        public String lipEmailverificationStatus { get; set; }
    }
}