/**
 * Class to send out OSB invite email
 * 
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date April 2020
 * 
 */
public class OSB_ResendOSBInvite {
    private static final String OSB_INITATION_EMAIL_TEMPLATE = 'OSBDpNpOneSpaceInvitation';
    private static final String OSB_EMAIL_BANNER_IMAGE_NAME = 'OSB_Email_Banner_Image';
    private static final String OSB_EMAIL_FOOTER_IMAGE_NAME = 'OSB_Email_Footer_Image';
    private static final String OSB_FIRST_NAME_PLACEHOLDER = '{!RelatedTo.FirstName}';
    private static final String OSB_ACCESS_MANAGER_PLACEHOLDER = 'OSB_ContactAccessManager';
    private static final String OSB_RECORD_ID_PLACEHOLDER = '{!RelatedTo.Id}';

    private static final String OSB_CUSTOM_SETTING_BASE_URL = 'OSB_Base_URL';
    private static final String OSB_CUSTOM_SETTING_EMAIL_BANNER = 'OSB_EmailBanner';
    private static final String OSB_CUSTOM_SETTING_EMAIL_FOOTER = 'OSB_EmailFooter';
    private static final String OSB_CUSTOM_SETTING_EMAIL_ADDRESS = 'OSB_Email_Address';
    private static final String OSB_CUSTOM_SETTING_OSB_INVITE_URL = 'OSB_OneSpace_Invite_Url';

    private static Map<String, String> osbURLs = new Map<String, String>();
    private static OrgWideEmailAddress oneSpaceEmailAddress = new OrgWideEmailAddress();
    
    /**
     * Sends out OneHub invite
     *
     * @param contactList List of Objects of type Contact
     *
     **/
	@InvocableMethod(label='resendOSBInviteEmail')
    public static void resendInvite(List<Contact> contactList){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Messaging.SingleEmailMessage> contactEmails = new List<Messaging.SingleEmailMessage>();
        setCommonVariables(contactList);
        EmailTemplate emailTemplate = UTL_EmailTemplate.getTemplate(OSB_INITATION_EMAIL_TEMPLATE);
        
        for(Contact contact : contactList){       
        	List<String> contactEmailAddresses = new List<String>();
            contactEmailAddresses.add(contact.Email);
            
            String htmlBody = emailTemplate.Markup;
        	htmlBody = htmlBody.replace(OSB_CUSTOM_SETTING_EMAIL_BANNER, osbURLs.get(OSB_CUSTOM_SETTING_EMAIL_BANNER));
            htmlBody = htmlBody.replace(OSB_FIRST_NAME_PLACEHOLDER, contact.FirstName);
            htmlBody = htmlBody.replace(OSB_CUSTOM_SETTING_OSB_INVITE_URL, osbURLs.get(OSB_CUSTOM_SETTING_OSB_INVITE_URL));
            htmlBody = htmlBody.replace(OSB_RECORD_ID_PLACEHOLDER, contact.Id);
            htmlBody = htmlBody.replace(OSB_CUSTOM_SETTING_EMAIL_ADDRESS, osbURLs.get(OSB_CUSTOM_SETTING_EMAIL_ADDRESS));
            htmlBody = htmlBody.replace(OSB_CUSTOM_SETTING_EMAIL_FOOTER, osbURLs.get(OSB_CUSTOM_SETTING_EMAIL_FOOTER));
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setHtmlBody(htmlBody);
            mail.setSubject(emailTemplate.Subject);
            mail.setSaveAsActivity(true);
            mail.setTargetObjectId(contact.Id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setToAddresses(contactEmailAddresses);
            mail.setWhatId(contact.AccountId); 
            mail.setOrgWideEmailAddressId(oneSpaceEmailAddress.Id);
            
            uow.registerEmail(mail);
        }
        
        uow.commitWork();
    }

    /**
     * Sets the values of the variables that will be used by the methods in the class
     *
     * @param contact List of Objects of type Contact
     *
     **/
    public static void setCommonVariables(List<Contact> contactList){
        OSB_ContactCommunication osbCntctComs = new OSB_ContactCommunication();
        List<OSB_URLs__c> osbURLsList = OSB_URLs__c.getall().values();
        
        for(OSB_URLs__c osbURL : osbURLsList){
            osbURLs.put(osbURL.Name, osbURL.Value__c);
        }
        
        oneSpaceEmailAddress = UTL_OrgWideEmailAddress.getAddressRecord(osbURLs.get(OSB_CUSTOM_SETTING_EMAIL_ADDRESS));

        String documentLink = SRV_Document.newInstance().getImageLink(OSB_EMAIL_BANNER_IMAGE_NAME);
        String osbEmailBannerURL = documentLink;
        documentLink = SRV_Document.newInstance().getImageLink(OSB_EMAIL_FOOTER_IMAGE_NAME);
        String osbEmailFooterURL = documentLink;
        osbURLs.put(OSB_CUSTOM_SETTING_EMAIL_BANNER, osbEmailBannerURL);
        osbURLs.put(OSB_CUSTOM_SETTING_EMAIL_FOOTER, osbEmailFooterURL);
    }
}