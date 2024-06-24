/**
 * Controller class for OSBSignUpRequestPage component
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date April 2020
 *
 **/

/**
 * @author Litha Nosekeleza
 * @date 14/06/2023
 * @added getRelatedAccountDetails method
 */

public without sharing class OSB_RequestPage_CTRL {
     private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OSB_RequestPage_CTRL');
    private static final String FRDM_REGISTRATION_URL = 'FRDM_Registration_URL';

    /**
     * Retrieves document link
     *
     * @param docName name of searched document
     *
     * @return url for accessing searched document
     */
    @AuraEnabled(Cacheable=true)
    public static String getOSBDocumentURL(String docName) {
        return SRV_Document.newInstance().getDocumentLink(docName);
    }

    /**
     * Retrieves user details from contact
     *
     * @return List of contact details
     */
    @AuraEnabled(Cacheable=true)
    public static List<Contact> getUserDetails() {
        List<Contact> userRecord = SEL_Contacts.newInstance()
            .selectByUserId(new Set<Id>{ UserInfo.getUserId() });
         LOGGER.info('OSB_RequestPage_CTRL : getUserDetails Record: '+userRecord);
        return userRecord;
    }

    /**
     * Retrieves account details related to a contact
     *
     * @return List of account details
     */
    @AuraEnabled(Cacheable=true)
    public static List<Account> getRelatedAccountDetails() {
        List<Contact> contact = getUserDetails();
        List<Account> accountRecord = SEL_Accounts.newInstance()
            .selectById(new Set<Id>{ contact[0].AccountId });
        LOGGER.info('OSB_RequestPage_CTRL : getRelatedAccountDetails Record: '+accountRecord);
        return accountRecord;
    }

    /**
     * Retrieves user details from contact
     *
     * @param email ,email from case
     * @param subject ,subject of the case to check for
     *
     * @return List of contact details
     */
    @AuraEnabled(Cacheable=true)
    public static List<Case> caseCheck(String email, String subject) {
        List<Case> caseRecord = SEL_Cases.newInstance()
            .selectBySuppliedEmailAndSubject(
                new Set<String>{ email },
                new Set<String>{ subject }
            );
        LOGGER.info('OSB_RequestPage_CTRL : caseCheck Record: '+caseRecord);
        return caseRecord;
    }

    /**
     * Checks if the current user is logged in to the community
     *
     * @return true if current user is logged in, false if it is a guest user
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean isUserLoggedIn() {
        LOGGER.info('OSB_RequestPage_CTRL : isUserLoggedIn Boolean: '+UTL_User.isLoggedInUser());
        return UTL_User.isLoggedInUser();
    }

    /**
     * Creates Case with CIB Client Case RT from JSON string with Contact Id taken from current user
     *
     * @param caseRecord Case record to be created and hit the URL when solution is FRDM
     * @param urlName url name for the solution
     *
     * @return created Case record
     */
    @AuraEnabled
    public static Case createCaseWithContactId(
        Case caseRecord,
        String urlName
    ) {
        if (urlName == FRDM_REGISTRATION_URL) {
            List<Contact> contacts = SEL_Contacts.newInstance()
                .selectByUserId(new Set<Id>{ UserInfo.getUserId() });
            String urlExtention = OSB_URLs__c.getValues(urlName).Value__c;
            String targetResource =
                urlExtention +
                'first_name=' +
                EncodingUtil.urlEncode(contacts[0].FirstName, 'UTF-8') +
                '&last_name=' +
                EncodingUtil.urlEncode(contacts[0].LastName, 'UTF-8') +
                '&email=' +
                EncodingUtil.urlEncode(contacts[0].Email, 'UTF-8') +
                '&company=' +
                EncodingUtil.urlEncode(
                    contacts[0].OSB_Company_name__c,
                    'UTF-8'
                );
            HttpCalloutExternal(targetResource);
            caseRecord.OwnerId = UTL_Queue.getQueueId(DMN_Queue.ONEHUB_QUEUE);
             LOGGER.info('OSB_RequestPage_CTRL : createCaseWithContactId Value After Sending FRDM Request: '+DMN_Case.createCaseWithUserContactId(caseRecord));
            return DMN_Case.createCaseWithUserContactId(caseRecord);
        } else {
            caseRecord.OwnerId = UTL_Queue.getQueueId(DMN_Queue.ONEHUB_QUEUE);
            LOGGER.info('OSB_RequestPage_CTRL : createCaseWithContactId Value Default: '+DMN_Case.createCaseWithUserContactId(caseRecord));
            return DMN_Case.createCaseWithUserContactId(caseRecord);
        }
    }

   
    /*
     * Gets URL from custom settings in OSB_URLS
     *
     * @param solutionName Solution Name url that is saved in custom settings
     *
     * @return returns relevant URL
     */
    @AuraEnabled(cacheable=true)
    public static String getCustomURL(String solutionName) {
        LOGGER.info('OSB_RequestPage_CTRL : getCustomURL Value: '+ OSB_URLs__c.getValues(solutionName).Value__c);
        return OSB_URLs__c.getValues(solutionName).Value__c;
    }

    /**
     * Hits the endpoint URL to create a record on external system for FRDM
     *
     * @param targetResource Target URL to hit when the solution is FRDM
     *
     * @return response
     */
    public static httpResponse httpCalloutExternal(String targetResource) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(targetResource);
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        LOGGER.info('OSB_RequestPage_CTRL : httpCalloutExternal Response: '+ res);
        return res;
    }

    /**
     * Sends an email to the respective solution owner
     *
     * @param contactRecord Contact record to send to solution
     * @param solutionName specify solution name to send email to
     */
    @AuraEnabled
    public static void sendEmail(Contact contactRecord, String solutionName) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Contact> solContacts = SEL_Contacts.newInstance()
            .selectByUserId(new Set<Id>{ UserInfo.getUserId() });
        OSB_SRV_EmailSender.newInstance()
            .sendSolutionEmail(solContacts, uow, solutionName);
        try {
            uow.commitWork();
        } catch (Exception e) {
            OSB_SRV_ActionFailureHandler.newInstance()
                .handleError(e, OSB_RequestPage_CTRL.class.getName());
            LOGGER.error('OSB_RequestPage_CTRL : SendEmail with  Exception logged: ',e);
        }
    }
}