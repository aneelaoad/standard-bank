/**
* Class for sending OneHub emails to contacts
*
* @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
* @description This is a controller class to to send out email on Onehub community user sign-up
* @date April 2020
*
* @LastModified August 2023
* @author litha Nosekeleza (litha.Nosekeleza@standardbank.co.za)
* @UserStory SFP-28081
* @LastModifiedReason added removed email sent to contact awaiting approval due to auto approval process
*/
public class OSB_ContactCommunication {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OSB_ContactCommunication');
    private static final String SIGNUP_CONFIRMATION_EMAIL_TEMPLATE = 'OSBDpNpSignUpConfirmation';
    private static final String ACCESS_REQUIRED_EMAIL_TEMPLATE = 'OSBDpNpAccessRequired';
    private static final String ACCESS_DECLINED_EMAIL_TEMPLATE = 'OSBAccessDeclined';
    private static final String ACCESS_APPROVED_EMAIL_TEMPLATE = 'OSBAccessApproved';
    private static final String ACCESS_REMOVED_EMAIL_TEMPLATE = 'OSBDpNpAccessRemoved';
    private static final String ACCESS_DECLINED_DP_NP_EMAIL_TEMPLATE = 'OSBDpNpAccessDeclined';
    private static final String ACCESS_APPROVED_DP_NP_EMAIL_TEMPLATE = 'OSBDpNpAccessApproved';
    private static final String ACCESS_REINVITE_APPROVED_DP_NP_EMAIL_TEMPLATE = 'OSB_DpNp_WelcomeBackAccessApproved';
    @TestVisible private static final String EMAIL_BANNER_IMAGE_NAME = 'OSB_Email_Banner_Image';
    @TestVisible private static final String EMAIL_FOOTER_IMAGE_NAME = 'OSB_Email_Footer_Image';
    private static final String FIRST_NAME_PLACEHOLDER = '{!RelatedTo.FirstName}';
    private static final String FIRST_NAME_PLACEHOLDER_ALT = 'OSB_FirstName';
    private static final String ACCESS_MANAGER_PLACEHOLDER = 'OSB_ContactAccessManager';
    private static final String CUSTOM_SETTING_BASE_URL = 'OSB_Base_URL';
    private static final String CUSTOM_SETTING_EMAIL_BANNER = 'OSB_EmailBanner';
    private static final String CUSTOM_SETTING_EMAIL_FOOTER = 'OSB_EmailFooter';
    private static final String CUSTOM_SETTING_EMAIL_ADDRESS = 'OSB_Email_Address';
    private static final String CUSTOM_SETTING_OSB_URL = 'OSB_Url';
    private static String osbEmailBannerURL;
    private static String osbEmailFooterURL;
    private static Map<String, OSB_URLs__c> osbURLs;
    private static OrgWideEmailAddress oneHubEmailAddress;
    private static Map<Id, Contact> communityAccessManagers;
    private static EmailTemplate emailTemplate;

    /**
     * @description determines which method to call based on the details of the contact and creates a collection of emails to be sent out
     *
     * @param contactList List of Objects of type Contact
     **/
    @InvocableMethod(label='SendSignUpEmails')
    public static void sendOSBEmails(List<Contact> contactList){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        setCommonVariables(contactList);

        for (Contact contact : contactList) {
            if (contact.OSB_Community_Access_Role__c == DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_DP
                    || contact.OSB_Community_Access_Role__c == DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP) {
                if (contact.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED) {
                    uow.registerEmail(createDpNpAccessDeclinedEmail(contact));
                } else if (contact.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED) {
                    if(contact.OSB_Contact_Re_invited__c){
                        uow.registerEmail(createDpNpReinviteAccessApprovedEmail(contact));
                    }
                    else{
                        uow.registerEmail(createDpNpAccessApprovedEmail(contact));
                    }
                } else if (contact.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INACTIVE) {
                    uow.registerEmail(createDpNpAccessRemovedEmail(contact));
                }
            } else if (contact.OSB_Community_Access_Role__c == DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP) {
                if (contact.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED) {
                    uow.registerEmail(createAccessDeclinedEmail(contact));
                } else if (contact.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED) {
                    uow.registerEmail(createAccessApprovedEmail(contact));
                }
            }
        }
        uow.commitWork();
    }
    
    /**
     * @description Creates email to be sent out to contact (AP) when NP/DP has finished signing up and awaiting approval for access
     *
     * @param contact Object of type Contact
     *
     * @return Messaging.SingleEmailMessage
     **/
    private static Messaging.SingleEmailMessage createInviterSignUpEmail(Contact contact){
    	List<String> contactEmails = new List<String>();
        emailTemplate = UTL_EmailTemplate.getTemplate(ACCESS_REQUIRED_EMAIL_TEMPLATE);
        Contact accessManager = communityAccessManagers.get(contact.OSB_Community_Access_Manager__c);
        
        contactEmails.add(accessManager.Email);
        
        String htmlBody = emailTemplate.Markup;
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_BANNER, osbEmailBannerURL);
        htmlBody = htmlBody.replace(ACCESS_MANAGER_PLACEHOLDER, accessManager.FirstName);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_OSB_URL, OSB_ContactCommunication.osbURLs.get(CUSTOM_SETTING_OSB_URL).Value__c);
        htmlBody = htmlBody.replace(FIRST_NAME_PLACEHOLDER, contact.FirstName);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_FOOTER, osbEmailFooterURL);
        Messaging.SingleEmailMessage mail = setupEmail(htmlBody, emailTemplate.Subject, contact.Id, contactEmails,contact.AccountId);
        LOGGER.INFO('OSB_ContactCommunication, createInviterSignUpEmail: ' + mail);
        return mail;
    }
    
    /**
     * @description Creates email to be sent out to contact (DP/NP) whose access has been declined
     *
     * @param contact List of Objects of type Contact
     *
     * @return Messaging.SingleEmailMessage
     **/
    private static Messaging.SingleEmailMessage createAccessDeclinedEmail(Contact contact){
    	List<String> contactEmails = new List<String>();
        emailTemplate = UTL_EmailTemplate.getTemplate(ACCESS_DECLINED_EMAIL_TEMPLATE);
        contactEmails.add(contact.Email);

        String htmlBody = emailTemplate.Markup;
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_BANNER, osbEmailBannerURL);
        htmlBody = htmlBody.replace(FIRST_NAME_PLACEHOLDER, contact.FirstName);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_FOOTER, osbEmailFooterURL);
        Messaging.SingleEmailMessage mail = setupEmail(htmlBody, emailTemplate.Subject, contact.Id, contactEmails,contact.AccountId);
        LOGGER.INFO('OSB_ContactCommunication, createAccessDeclinedEmail: ' + mail);
        return mail;
    }

    /**
     * @description Creates email to be sent out to contact (DP/NP) whose access has been approved
     *
     * @param contact List of Objects of type Contact
     *
     * @return Messaging.SingleEmailMessage
     **/
	private static Messaging.SingleEmailMessage createAccessApprovedEmail(Contact contact){
    	List<String> contactEmails = new List<String>();
        emailTemplate = UTL_EmailTemplate.getTemplate(ACCESS_APPROVED_EMAIL_TEMPLATE);
        contactEmails.add(contact.Email);
    
        String htmlBody = emailTemplate.Markup;
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_BANNER, osbEmailBannerURL);
        htmlBody = htmlBody.replace(FIRST_NAME_PLACEHOLDER, contact.FirstName);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_OSB_URL, OSB_ContactCommunication.osbURLs.get(CUSTOM_SETTING_OSB_URL).Value__c);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_FOOTER, osbEmailFooterURL);
        Messaging.SingleEmailMessage mail = setupEmail(htmlBody, emailTemplate.Subject, contact.Id, contactEmails,contact.AccountId);
        LOGGER.INFO('OSB_ContactCommunication, createAccessApprovedEmail: ' + mail);
        return mail;
    }
    
    /**
     * @description Creates email to be sent out to contact (DP/NP) whose access has been approved
     *
     * @param contact List of Objects of type Contact
     *
     * @return Messaging.SingleEmailMessage
     **/
	private static Messaging.SingleEmailMessage createDpNpAccessApprovedEmail(Contact contact){
    	List<String> contactEmails = new List<String>();
        emailTemplate = UTL_EmailTemplate.getTemplate(ACCESS_APPROVED_DP_NP_EMAIL_TEMPLATE);
        contactEmails.add(contact.Email);
        
        String htmlBody = emailTemplate.Markup;
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_BANNER, osbEmailBannerURL);
        htmlBody = htmlBody.replace(FIRST_NAME_PLACEHOLDER, contact.FirstName);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_OSB_URL, OSB_ContactCommunication.osbURLs.get(CUSTOM_SETTING_OSB_URL).Value__c);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_FOOTER, osbEmailFooterURL);
        
        Messaging.SingleEmailMessage mail = setupEmail(htmlBody, emailTemplate.Subject, contact.Id, contactEmails,contact.AccountId);
        LOGGER.INFO('OSB_ContactCommunication, createDpNpAccessApprovedEmail: ' + mail);
        return mail;
    }
    
    /**
     * @description Creates email to be sent out to contact (DP/NP) whose access has been approved
     *
     * @param contact List of Objects of type Contact
     *
     * @return Messaging.SingleEmailMessage
     **/
	private static Messaging.SingleEmailMessage createDpNpReinviteAccessApprovedEmail(Contact contact){
        List<String> contactEmails = new List<String>();
        emailTemplate = UTL_EmailTemplate.getTemplate(ACCESS_REINVITE_APPROVED_DP_NP_EMAIL_TEMPLATE);
        contactEmails.add(contact.Email);
        
        String htmlBody = emailTemplate.Markup;
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_BANNER, osbEmailBannerURL);
        htmlBody = htmlBody.replace(FIRST_NAME_PLACEHOLDER_ALT, contact.FirstName);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_OSB_URL, OSB_ContactCommunication.osbURLs.get(CUSTOM_SETTING_OSB_URL).Value__c);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_FOOTER, osbEmailFooterURL);
        Messaging.SingleEmailMessage mail = setupEmail(htmlBody, emailTemplate.Subject, contact.Id, contactEmails,contact.AccountId);
        LOGGER.INFO('OSB_ContactCommunication, createDpNpReinviteAccessApprovedEmail: ' + mail);
        return mail;
    }
    
    /**
     * @description Creates email to be sent out to contact (DP/NP) whose access has been declined
     *
     * @param contact List of Objects of type Contact
     *
     * @return Messaging.SingleEmailMessage
     **/
    private static Messaging.SingleEmailMessage createDpNpAccessDeclinedEmail(Contact contact){
    	List<String> contactEmails = new List<String>();
        emailTemplate = UTL_EmailTemplate.getTemplate(ACCESS_DECLINED_DP_NP_EMAIL_TEMPLATE);
        contactEmails.add(contact.Email);

        Contact accessManager = communityAccessManagers.get(contact.OSB_Community_Access_Manager__c);
        
        String accessManagerDetails = accessManager.FirstName + ' ' + accessManager.LastName;
        
        String htmlBody = emailTemplate.Markup;
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_BANNER, osbEmailBannerURL);
        htmlBody = htmlBody.replace(FIRST_NAME_PLACEHOLDER, contact.FirstName);
        htmlBody = htmlBody.replace(ACCESS_MANAGER_PLACEHOLDER, accessManagerDetails);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_FOOTER, osbEmailFooterURL); 
        Messaging.SingleEmailMessage mail = setupEmail(htmlBody, emailTemplate.Subject, contact.Id, contactEmails,contact.AccountId);
        LOGGER.INFO('OSB_ContactCommunication, createDpNpAccessDeclinedEmail: ' + mail);
        return mail;
    }
	
    /**
     * @description Creates email to be sent out to contact (DP/NP) whose access has been revoked
     *
     * @param contact List of Objects of type Contact
     *
     * @return Messaging.SingleEmailMessage
     **/
    private static Messaging.SingleEmailMessage createDpNpAccessRemovedEmail(Contact contact){
    	List<String> contactEmails = new List<String>();
        emailTemplate = UTL_EmailTemplate.getTemplate(ACCESS_REMOVED_EMAIL_TEMPLATE);
        contactEmails.add(contact.Email);
        
        Contact accessManager = OSB_ContactCommunication.communityAccessManagers.get(contact.OSB_Community_Access_Manager__c);
        
        String accessManagerDetails = accessManager.FirstName + ' ' + accessManager.LastName;
        
        String htmlBody = emailTemplate.Markup;
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_BANNER, osbEmailBannerURL);
        htmlBody = htmlBody.replace(FIRST_NAME_PLACEHOLDER, contact.FirstName);
        htmlBody = htmlBody.replace(ACCESS_MANAGER_PLACEHOLDER, accessManagerDetails);
        htmlBody = htmlBody.replace(CUSTOM_SETTING_EMAIL_FOOTER, osbEmailFooterURL);
        Messaging.SingleEmailMessage mail = setupEmail(htmlBody, emailTemplate.Subject, contact.Id, contactEmails,contact.AccountId);
        LOGGER.INFO('OSB_ContactCommunication, createDpNpAccessRemovedEmail: ' + mail);
        return mail;
    }

    /**
     * @description Setup values for email 
     *
     * @param htmlBody Email body in html format as a string
     * @param emailSubject email Subject as a string
     * @param contactId contact Id
     * @param toAddresses List of addresses to which the email is being sent
     * @param whatId Id of record which task must be created against
     * @return EmailMessage
     * 
     **/
    private static Messaging.SingleEmailMessage setupEmail(String htmlBody, String emailSubject, Id contactId, List<String> toAddresses, Id whatId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setHtmlBody(htmlBody);
        mail.setSubject(emailSubject);
        mail.setSaveAsActivity(true);
        mail.setTargetObjectId(contactId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setToAddresses(toAddresses);
        mail.setWhatId(whatId); 
        mail.setOrgWideEmailAddressId(oneHubEmailAddress.Id);
		LOGGER.INFO('OSB_ContactCommunication, setupEmail: ' + mail);
        return mail;
    }
    
    /**
     * @description Sets the values of the variables that will be used by the methods in the class 
     *
     * @param contactList 
     *
     **/
    private static void setCommonVariables(List<Contact> contactList){
        osbURLs = OSB_URLs__c.getall();
        oneHubEmailAddress = UTL_OrgWideEmailAddress.getAddressRecord(osbURLs.get(CUSTOM_SETTING_EMAIL_ADDRESS).Value__c);

        Set<Id> accessManagerIds = new Set<Id>();
        for(Contact contact : contactList){
            if ((contact.OSB_Community_Access_Role__c == DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_DP
                    || contact.OSB_Community_Access_Role__c == DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP)
                    && (contact.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_PENDING_APPROVAL
                        || contact.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED
                        || contact.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INACTIVE)) {
                accessManagerIds.add(contact.OSB_Community_Access_Manager__c);
            }
        }
        if(!accessManagerIds.isEmpty()) {
            communityAccessManagers = new Map<Id, Contact>(SEL_Contacts.newInstance().selectByIdWoSharing(accessManagerIds));
        }

        UTL_EmailTemplate.getTemplates(new Set<String>{
                SIGNUP_CONFIRMATION_EMAIL_TEMPLATE,
                ACCESS_REQUIRED_EMAIL_TEMPLATE,
                ACCESS_DECLINED_EMAIL_TEMPLATE,
                ACCESS_APPROVED_EMAIL_TEMPLATE,
                ACCESS_REMOVED_EMAIL_TEMPLATE
        });

        String documentLink = SRV_Document.newInstance().getImageLink(EMAIL_BANNER_IMAGE_NAME);
        osbEmailBannerURL = documentLink;
        documentLink = SRV_Document.newInstance().getImageLink(EMAIL_FOOTER_IMAGE_NAME);
        osbEmailFooterURL = documentLink;
    }
}