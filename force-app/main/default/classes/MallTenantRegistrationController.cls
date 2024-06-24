/**
 * 
 * @description MallTenantRegistrationController
 * @author Maham Hasan
 * @since 
 */
public with sharing class MallTenantRegistrationController {

   @TestVisible
   private static final String TENANT_INVITATION_EMAIL_TEMPLATE = 'BCB Platform: Tenant Registration Invitation Notification';

   /**
    * 
    * @description getContactsByProviderId
    * @param providerId String
    * @return List<Contact>
    */
    @AuraEnabled (Cacheable=true)
    public static List<Contact> getContactsByProviderId(String providerId){
        try {
            List<Provider__c> providers = SEL_Providers.newInstance().selectByIds(new Set<Id>{(Id)providerId});
            if(providers != NULL && providers.size() > 0) {
                List<Contact> contacts = new List<Contact>();
                contacts = SEL_Contacts.newInstance().selectByClientId(new Set<Id>{(Id)providers[0].Related_Client__c});
                return contacts;
            } 
            return NULL;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallTenantRegistrationController.getContactsByProviderId', e);
        }
    }

    /**
     * 
     * @description  updateTenantRegistrationEmailFlag
     * @param contacts List<Contact>
     * @return List<Contact>
     */
    @AuraEnabled
    public static List<Contact> updateTenantRegistrationEmailFlag(List<Contact> contacts) {
        try {
            update contacts;
            return contacts;

        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallTenantRegistrationController.updateTenantRegistrationEmailFlag', e);
        }
    }

    /**
     * 
     * @description sendEmail
     * @param contactIds List<String>
     */
    @InvocableMethod(label='Send Email' description='Send Email based on a template')
    public static void sendEmail(List<String> contactIds) {
        List<Contact> contacts = new List<Contact>();
        Set<Id> contactIdsSet = new Set<Id>();
        contactIdsSet.addAll((List<Id>)contactIds);
        contacts = SEL_Contacts.newInstance().selectById(contactIdsSet);
        Contact contact = new Contact();
        if(contacts.size() > 0) {
            contact = contacts[0];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(contact.Id);
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            EmailTemplate emailTemplate =new EmailTemplate();
            String emailTemplateName = TENANT_INVITATION_EMAIL_TEMPLATE;
            List<EmailTemplate> emailTemplates = SEL_EmailTemplate.newInstance().selectByName(emailTemplateName);
            if(emailTemplates.size() > 0) {
                emailTemplate = emailTemplates[0];
                message.setTemplateID(emailTemplate.Id);
                message.setWhatId(contact.AccountId);
                message.toAddresses = new String[] {contact.Email};
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                if ((Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) && (!Test.isRunningTest())) {
                    Messaging.sendEmail(messages);
                }
            }
            
        } 
    }
}