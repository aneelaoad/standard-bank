/**
*
* @author Emmanuel Mulea Nocks(BlueSky)
* @date June 2020
* @description This class does the integration between ESB Gateway and Salesforce
*/
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class DigiSignConsent {

    private static final String URL_POST_CONSENT = '/digital-signature/digital-signatures';
    private static final String URL_POST_RESEND_CONSENT = '/digital-signature/signatory-invitations';
    private static final String URL_AUTH = '/sysauth/oauth2/token';
    private static final String URL_POST_CONSENT_STATUS ='/digital-signature/approval-statuses';
    private static final Set<String> CLIENT_ROLES = new Set<String>{DMN_Contact.CONTACT_ROLE_KYC_CONTACT, DMN_Contact.CONTACT_ROLE_AUTHORISED_PERSON
        ,DMN_Contact.CONTACT_ROLE_DIRECT_SHAREHOLDER,DMN_Contact.CONTACT_ROLE_INDIRECT_SHAREHOLDER};
    private static final String SCOPE = 'retail customer prod';
    private static final String EMAIL_ERROR_TEMP = DMN_EmailTemplates.EMAIL_ERROR_TEMP;
    private static final String ROLE_ERROR_MSG = 'There is no KYC Contact and Authorized Person contacts selected';
    private static final String BASSIC_ERROR_MSG = '{0} was unsuccessful,the error has been reported to CRM helpdesk or contact the administrator.';
    private static final  String BASE_URL = Url.getSalesforceBaseUrl().toExternalForm();
    private static final String CERTICATE_NAME = 'Digisign';
    private static final String DMN_URL = 'callout:DigiSignConsent';
    private static final String CRM_HELPDESK_PARAMETER_NAME = 'CRMHelpdeskEmail';
    private static final String API_REQUEST_REPORT_ERROR_PARAMETER_NAME = 'API_Request_Consent_Errors';
    private static final String POST_METHOD = 'POST';
    @TestVisible
    private static final OAuth_ESB_Gateway.IService REQUEST_OAUTH = OAuth_ESB_Gateway.newInstance();

    /**
    * Get Contact by client ID and contact Roles
    *
    * @param accId Id
    * @param requestType String
    * @return filteredList
    */
    @AuraEnabled
    public static List<Contact> getContactsByClientIdAndRoles(Id accId,String requestType){
        List<String> roleList = new List<String>();
        List<Contact> filteredList = new List<Contact>();
        SEL_Contacts selCon = SEL_Contacts.newInstance();
        
        try{
            SEL_OnboardingApplications onBoardApp = SEL_OnboardingApplications.newInstance();
            List<Onboarding_Application__c> onboardList = onBoardApp.selectByClientIdAndRequestType(accId,requestType);
            if(!onboardList.isEmpty()){

                    List<Contact> conList = selCon.selectByOnboardAppId(new Set<Id>{onboardList[0].Id});
                    return conList;
            }
            else{
                List<Contact> conList = selCon.selectByClientId(new Set<Id>{accId});
                
                for(Contact con :conList){
                    
                    roleList = splitString(con.Contact_Role_s_at_Client__c,';');
                    if(containsAtLeastOneRole(roleList)) {
                        filteredList.add(con);
                    }
                }   
            }
            
            return filteredList;
        }
        catch(Exception e){
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_COMMB, DigiSignConsent.class.getName());
            throw new AuraHandledException(e.getMessage());
            
        }
    }

    /**
    * Check if a contact contains at least one Role
    *
    * @param toBeChecked List<String>
    *
    * @return Boolean
    */
    private static Boolean containsAtLeastOneRole(List<String> toBeChecked){
        
        for(String eachRole:toBeChecked){       
            if(CLIENT_ROLES.contains(eachRole)) {
                return true;
            }
        }
        return false;
    }


    /**
    * Split String by a specific delimiter
    *
    * @param value String
    * @param delimiter String
    * @return signed token
    */
    private static List<String> splitString(String value,string delimiter){
        
        List<String> roleList = new List<String>();
        if(String.isNotBlank(value)){
            roleList = value.split(delimiter);
        }
        return roleList;
    }


    /**
    * Check if we have at least KYC Contact and Authorised Person in conList
    *
    * @param conList List<DigiSignRequestData.SignatoryContact>
    *
    * @return Boolean
    */
    private static Boolean validateCotactRoles(List<DigiSignRequestData.SignatoryContact> conList){

        List<String> minRoles = new List<String>{'KYC Contact','Authorised Person'};
        Boolean isKYC = false;
        Boolean isAuth = false;
        List<String> roleList = new List<String>();
        for(DigiSignRequestData.SignatoryContact con :conList) {
            roleList = splitString(con.contactRoleClient,'/');
            for(String eachRole:roleList){

                if(minRoles[0].trim()==eachRole){
                    isKYC=true;
                }
                else if(minRoles[1].trim()==eachRole){
                    isAuth=true;
                }
            }
        }
        return (isAuth&&isKYC);
    }


    /**
    * Get Onboarding_Application records by client ID
    *
    * @param accId Id
    *
    * @return JSON.serialize(results)
    */
    @AuraEnabled
    public static  List<OnboardWrapper> getOnboardingWithRelatedRec(Id accId){

        List<OnboardWrapper> results = new List<OnboardWrapper>();
        Set<Id> onboardIds = new Set<Id>();
        SEL_OnboardingApplications onBoardApp =  SEL_OnboardingApplications.newInstance();
        SEL_ApplicationDocuments  applicationDoc = SEL_ApplicationDocuments.newInstance();
        List<Onboarding_Application__c> onboardList = onBoardApp.selectByClientId(new Set<Id>{accId});

        for(Onboarding_Application__c appd:onboardList){
            onboardIds.add(appd.Id);
        }

        List<Application_Document__c> appDocList = applicationDoc.selectByOnboardApplicationId(onboardIds);

        for(Onboarding_Application__c onb:onboardList){

            OnboardWrapper onboardWrapperTemp = new OnboardWrapper();
            List<Application_Document__c> appDocListTemp = new List<Application_Document__c>();
            for(Application_Document__c appdoc:appDocList){

                if(onb.Id==appdoc.Onboarding_Application__c){
                    appDocListTemp.add(appdoc);
                }
            }
            onboardWrapperTemp.appDocList = appDocListTemp;
            onboardWrapperTemp.onboardApp = onb;
            results.add(onboardWrapperTemp);
        }

        return results;
    }


    /**
    * Create request consent
    *
    * @param selectedContactList String
    * @param clientId String
    * @param requestType String
    * @return JSON.serialize(newWrapperList);
    */
    @AuraEnabled
    public static String  createRequestConsent(String selectedContactList, String clientId, String requestType){

        try{
            List<DigiSignRequestData.SignatoryContact> wrapperList = (List<DigiSignRequestData.SignatoryContact>) JSON.deserialize(selectedContactList, List<DigiSignRequestData.SignatoryContact>.class);
            if(validateCotactRoles(wrapperList)) {
                return createApplication(wrapperList, clientId,requestType);
            }
            else {
                throw new DigiSignConsent_Exception(ROLE_ERROR_MSG);
            }

        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());

        }
    }

    /**
    * AuraEnabled method that is been call from frontend to initiate a callout
    *
    * @param selectedContactList String
    * @param clientId String
    * @return SUCCESS or error message
    */
    @AuraEnabled
    public static String requestConsentCallout(String selectedContactList, String clientId){

        List<DigiSignRequestData.SignatoryContact> wrapperList = (List<DigiSignRequestData.SignatoryContact>) JSON.deserialize(selectedContactList, List<DigiSignRequestData.SignatoryContact>.class);

        try{

            digiSignCallOut(wrapperList,clientId);
            return 'SUCCESS';
        }
        catch(Exception e){

            rollBackCommittedData(wrapperList[0].onboardingAppId);
            return e.getMessage();
        }
    }

    /**
    * Rollback if there is a failure on the http request
    *
    * @param onboardingAppId Id which is the Id of Onboarding Application object
    */
    private static void rollBackCommittedData(Id onboardingAppId){


        List<SObject> recordList = new List<SObject>();
        List<Application_Document__c> applicationDocList = SEL_ApplicationDocuments.newInstance().selectByOnboardApplicationId(new Set<Id>{onboardingAppId});
        List<Onboarding_Application__c> onboardApp = SEL_OnboardingApplications.newInstance().selectById(new Set<Id>{onboardingAppId});
        recordList.addAll(onboardApp);
        recordList.addAll(applicationDocList);
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        uow.registerPermanentlyDeleted(recordList);
        uow.commitWork();
    }

    /**
    * Creates Onboarding_Application__c and Application_Document__c
    *
    * @param wrapperList List<DigiSignRequestData.SignatoryContact>
    * @param clientId String
    * @param requestType String
    *
    * @return JSON.serialize(newWrapperList)
    */
    private static String createApplication(List<DigiSignRequestData.SignatoryContact> wrapperList, String clientId, String requestType){

        List<Application_Document__c> applicantList = new List<Application_Document__c>();
        List<DigiSignRequestData.SignatoryContact> newWrapperList = new List<DigiSignRequestData.SignatoryContact>();
        Map<String,DigiSignRequestData.SignatoryContact> mapSignatoryContact = new Map<String,DigiSignRequestData.SignatoryContact>();
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        Onboarding_Application__c onboardApp = new Onboarding_Application__c(
            Requested_By__c = UserInfo.getName(),
            Request_Type__c = requestType,
            Client__c = clientId,
            Status__c = DMN_OnboardingApplications.STATUS_PENDING,
            RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_OnboardingApplications.OBJECT_NAME, DMN_OnboardingApplications.RT_COMMB_REQUEST_CONSENT)
        );
        uow.registerNew(onboardApp);

        for (DigiSignRequestData.SignatoryContact con : wrapperList) {
            Application_Document__c appDoc = new Application_Document__c(
                Authorised_Person__c = con.Id,
                Document_Status__c = DMN_OnboardingApplications.STATUS_PENDING,
                FileNet_Id__c = DMN_ApplicationDocuments.DEFAULT_FILE_NET_ID
            );
            Contact updateContactData = new Contact(Id=con.Id,MobilePhone=con.mobileNumber);
            applicantList.add(appDoc);
            mapSignatoryContact.put(con.Id,con);
            uow.registerNew(appDoc, Application_Document__c.Onboarding_Application__c, onboardApp);
            uow.registerDirty(updateContactData);
        }
        uow.commitWork();
        for(Application_Document__c appD :applicantList){
            DigiSignRequestData.SignatoryContact con = mapSignatoryContact.get(appD.Authorised_Person__c);
            con.signatoryGuid = appD.Id;
            con.onboardingAppId = appD.Onboarding_Application__c;
            newWrapperList.add(con);
        }
        return JSON.serialize(newWrapperList);

    }

    /**
    * Check if Consent was requested for a specific client Id
    *
    * @param accId Id
    * @param requestType String
    * @return Boolean
    */
    @AuraEnabled
    public static  Boolean isConsentSent(Id accId,String requestType) {
        List<Onboarding_Application__c> onboardList = SEL_OnboardingApplications.newInstance().selectByClientIdAndRequestType(accId,requestType);
        
        return !onboardList.isEmpty();
    }

    /**
    * Handles uncaught errors
    *
    * @param resp String
    */
    private static void handleUncaughtError(String resp){
        if(String.isNotBlank(resp)){
            if(resp.contains('httpCode')){
                RequestConsentErrorCode.CallOutErrorWrapper res = (RequestConsentErrorCode.CallOutErrorWrapper) JSON.deserialize(resp, RequestConsentErrorCode.CallOutErrorWrapper.class);
                string errorMsg = RequestConsentErrorCode.getcalloutError(res);
                throw new DigiSignConsent_Exception(errorMsg);

            }
        }
        else{
            throw new DigiSignConsent_Exception(String.format(BASSIC_ERROR_MSG, new List<String>{'Request'}));
        }

    }

    /**
    * resend an invite for a specific person
    *
    * @param docId String
    * @param clientId String
    * @param requestType String
    * @return Status code
    */
    @AuraEnabled
    public static Integer resendInvite(String docId, String clientId, String requestType){
        HttpResponse res;
        try{
            List<Onboarding_Application__c> onboardList = new SEL_OnboardingApplications().selectByClientIdAndRequestType(clientId,requestType);
            ResendInvite bodyObject = new ResendInvite();
            bodyObject.requestcorrelationidentifier = onboardList[0].Id;
            bodyObject.signatoryidentificationdocumentnumber = docId;
            String body = JSON.serialize(bodyObject);
            OAuth_ESB_Gateway.RequestBuilder builder = buildRequest(POST_METHOD,URL_POST_RESEND_CONSENT);
            HttpRequest req = builder.req;
            req.setBody(body);
            res = builder.oauth.sendRequest(req);
            if(res.getStatusCode()!=200) {
                handleUncaughtError(res.getBody());
            }

            return res.getStatusCode();
        }
        catch(CalloutException e){
            String fullMsg = RequestConsentErrorCode.getcalloutError(e,res);
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_COMMB, DigiSignConsent.class.getName(),new List<String>{fullMsg});
            sendCalloutExceptionEmail(clientId, fullMsg);
            throw new AuraHandledException(String.format(BASSIC_ERROR_MSG, new List<String>{'Resend compliance consent'}));
        }
        catch(Exception e){
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_COMMB, DigiSignConsent.class.getName());
            sendCalloutExceptionEmail(clientId, e.getMessage());
            throw new AuraHandledException(String.format(BASSIC_ERROR_MSG, new List<String>{'Resend compliance consent'}));
        }
    }

    /**
    * Get signatory status from digiSign
    *
    * @param clientId String
    */
    @AuraEnabled
    public static void getSignatoryStatus(String clientId){

        HttpResponse res;
        try{
            List<Onboarding_Application__c> onboardList = new SEL_OnboardingApplications().selectByClientIdWherePending(new Set<Id>{clientId});
            CheckStatus bodyObject = new CheckStatus();
            bodyObject.requestcorrelationidentifier = onboardList[0].Id;
            String body = JSON.serialize(bodyObject);
            OAuth_ESB_Gateway.RequestBuilder builder = buildRequest(POST_METHOD,URL_POST_CONSENT_STATUS);
            HttpRequest req = builder.req;
            req.setBody(body);
            res = builder.oauth.sendRequest(req);
			updateSignatoriesStatus(res.getBody());
            handleUncaughtError(res.getBody());
        }
        catch(CalloutException e){
            String fullMsg = RequestConsentErrorCode.getcalloutError(e,res);
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_COMMB, DigiSignConsent.class.getName(),new list<String>{fullMsg});
            sendCalloutExceptionEmail(clientId, fullMsg);
            throw new AuraHandledException(String.format(BASSIC_ERROR_MSG, new List<String>{'Check for compliance consent status'}));
        }
        catch(Exception e){
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_COMMB, DigiSignConsent.class.getName());
            sendCalloutExceptionEmail(clientId, e.getMessage());
            throw new AuraHandledException(String.format(BASSIC_ERROR_MSG, new List<String>{'Check for compliance consent status'}));
        }

    }


    /**
    * Update signatories statuses
    *
    * @param body String
    */
    private static void updateSignatoriesStatus(String body){
        List<Application_Document__c> docList = new List<Application_Document__c>();
        if(String.isNotBlank(body)){
            SearchResponse resWrapper = (SearchResponse) JSON.deserialize(body, SearchResponse.class);
            for(TaskInformation task: resWrapper.searchApproverResponse.taskInformation){
                String docId = task.digiSignInformation.signatoryInformation.signatory[0].signatoryGuid;
                String status = task.digiSignInformation.signatoryInformation.signatory[0].signatoryApprovalStatus;
                Application_Document__c doc = new Application_Document__c(Id=docId,Document_status__c=status);
                docList.add(doc);
            }
            update docList;
        }
        else{

            throw new DigiSignConsent_Exception(String.format(BASSIC_ERROR_MSG, new List<String>{'Request'}));
        }
    }

    /**
    * Make a callout to start digiSign process
    *
    * @param  signList List<DigiSignRequestData.SignatoryContact>
    * @param clientId String
    */
    private static void digiSignCallOut(List<DigiSignRequestData.SignatoryContact> signList,String clientId){
        HttpResponse res;
        try{
            DigitalSignatureRequest.DigitalSignatureRequest_Z bodyData = DigiSignRequestData.digiSignInformation(signList,clientId);
            OAuth_ESB_Gateway.RequestBuilder builder = buildRequest(POST_METHOD,URL_POST_CONSENT);
            HttpRequest req = builder.req;
            req.setBody(JSON.serializePretty(bodyData));
            res = builder.oauth.sendRequest(req);
            handleUncaughtError(res.getBody());
        }
        catch(CalloutException e){
            String msg = e.getMessage();
            Integer errorCode = res.getStatusCode();
            String definition = RequestConsentErrorCode.getDefinition(errorCode);
            String description = RequestConsentErrorCode.getDescription(errorCode);
            String fullMsg = 'Error Message: '+msg+'Error Code: '+errorCode+'Code Definition :'+definition+'Code Descriotion:'+
                description;
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_COMMB, DigiSignConsent.class.getName(),new List<String>{fullMsg});
            sendCalloutExceptionEmail(clientId, fullMsg);
            throw new DigiSignConsent_Exception(String.format(e.getMessage(), new List<String>{'Request to send compliance consent'}));
        }
        catch(Exception e){
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_COMMB, DigiSignConsent.class.getName());
            sendCalloutExceptionEmail(clientId, e.getMessage());
            throw new DigiSignConsent_Exception(String.format(e.getMessage(), new List<String>{'Request to send compliance consent'}));
        }

    }


    /**
    * Send callout exception email
    *
    * @param accId String
    * @param logMessage String
    */
    public static void sendCalloutExceptionEmail(String accId, String logMessage){

        SB_Parameters__c crmHelpdeskEmail = SB_Parameters__c.getValues(CRM_HELPDESK_PARAMETER_NAME);
        String toAddress;
        if(crmHelpdeskEmail!=null && !isSandbox()){
            toAddress = crmHelpdeskEmail.Value__c;
        }

        String reportAPIName = SB_Parameters__c.getValues(API_REQUEST_REPORT_ERROR_PARAMETER_NAME).Value__c;
        try{
            String reportId  = SEL_Report.newInstance().selectByDevName(new Set<String>{reportAPIName})[0].Id;
            String reportUrl = BASE_URL+'/'+reportId;
            Messaging.SingleEmailMessage email;
            SEL_Accounts selAcc = new SEL_Accounts();
            List<Account> clientList = selAcc.selectById(new Set<Id>{accId});
            EmailTemplate emailTemplate = UTL_EmailTemplate.getTemplate(EMAIL_ERROR_TEMP);
            if(clientList.isEmpty()){
                throw new DigiSignConsent_Exception('There is no Client with Id:' + accId);
            }

            email = new Messaging.SingleEmailMessage();
            List<String> bodyMergeFields = new List<String>();
            bodyMergeFields.add(clientList[0].Name);
            bodyMergeFields.add(clientList[0].Id);
            bodyMergeFields.add(UserInfo.getName());
            bodyMergeFields.add(logMessage);
            bodyMergeFields.add(reportUrl);
            String emailBody = String.format(emailTemplate.Body, bodyMergeFields);
            String subject = String.format(emailTemplate.Subject, new List<String>{clientList[0].Name});
            email.setSubject(subject);
            email.setPlainTextBody(emailBody);
            email.setToAddresses(new String[]{toAddress});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        }
        catch(Exception e){
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_COMMB, DigiSignConsent.class.getName());
        }
    }
    /**
    * @description Exception handler for OnboardWrapper class
    */
    public  class OnboardWrapper{

        @AuraEnabled
        public List<Application_Document__c> appDocList;
        @AuraEnabled
        public Onboarding_Application__c onboardApp;
    }
    /**
    * @description Exception handler for DigiSignConsent class
    */
    public class DigiSignConsent_Exception extends Exception { }

    /**
    * Http request builder
    *
    * @param method String
    * @param endpoint String
    * @return reqBuild
    */
    private static OAuth_ESB_Gateway.RequestBuilder buildRequest(String method, String endpoint){
        REQUEST_OAUTH.OAuth_ESB_Gateway(CERTICATE_NAME,DMN_URL,URL_AUTH);
        OAuth_ESB_Gateway.RequestBuilder reqBuild = REQUEST_OAUTH.getRequestWithToken(SCOPE,REQUEST_OAUTH);
        reqBuild.req.setEndpoint(DMN_URL+endpoint);
        reqBuild.req.setMethod(method);
        return reqBuild;
    }

    /**
    * Check if is sandbox
    *
    * @return Boolean
    */
    private static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    /**
    * @description Exception handler for DigiSignConsent class
    */
    public class CheckStatus{
        public String requestcorrelationidentifier;
    }

    /**
    * @description Inner class to wrap ResendInvite Object
    */
    public class ResendInvite{
        public String requestcorrelationidentifier;
        public String signatoryidentificationdocumentnumber;
    }

    /**
    * @description Inner class to wrap DigiSignInformation Object
    */
    public class DigiSignInformation {
        public SignatoryInformation signatoryInformation;
    }

    /**
    * @description Inner class to wrap TaskInformation Object
    */
    public class TaskInformation {
        public String uniqueInstanceIdentifier;
        public String subjectOfTask;
        public DigiSignInformation digiSignInformation;
        public String unqiueTaskIdentifier;
    }

    /**
    * @description Inner class to wrap Signatory Object
    */
    public class Signatory {
        public String signatoryApprovalStatus;
        public String signatoryFirstName;
        public String signatoryLastName;
        public String signatoryIdentificationDocumentType;
        public String signatoryIdentificationDocumentNumber;
        public Boolean originatorIndicator;
        public String signatoryGuid;
        public String typeOfApproval;
    }

    /**
    * @description Inner class to wrap SearchResponse Object
    */
     public class SearchResponse {
       public SearchApproverResponse searchApproverResponse;
     }

    /**
    * @description Inner class to wrap SignatoryInformation Object
    */
    public class SignatoryInformation {
        public List<Signatory> signatory;
    }

    /**
    * @description Inner class to wrap SearchApproverResponse Object
    */
    public class SearchApproverResponse {
        public List<TaskInformation> taskInformation;
    }
}