/**
 * @description MallSendEmailService
 * @author Maham Hassan
 * @since
 */
public with sharing class MallSendEmailService {
    /*@description: custom label to store default from email*/
    private static final String DEFAULT_FROM_EMAIL = System.Label.Default_From_Mail;
   
    /**
    * 
    * @description createEmailsForContactsBasedOnEmailTemplate
    * @param contactIds List String
    * @param emailTemplateName String
    */
    public static void createEmailsForContactsBasedOnEmailTemplate(List<String> contactIds, String emailTemplateName) {
        List<Contact> contacts = new List<Contact>();
        Set<Id> contactIdSet = new Set<Id>();
        contactIdSet.addAll((List<Id>)contactIds);
        contacts = SEL_Contacts.newInstance().selectById(contactIdSet);

        EmailTemplate emailTemplate =new EmailTemplate();
        List<EmailTemplate> emailTemplates = SEL_EmailTemplate.newInstance().selectByName(emailTemplateName);
        
        if(emailTemplates.size()>0) {
            emailTemplate = emailTemplates[0];
            Set<Id> contactIdsSet = new Set<Id>();
            contactIdsSet.addAll((List<Id>)contactIds);
            List<User> users = SEL_Users.newInstance().selectByContactId(contactIdsSet);
            Map<String, User> mapContactIdVsUser = new Map<String, User>();
    
            for(User user: users) {
                if(String.IsNotBlank(user.ContactId)) {
                    mapContactIdVsUser.put(user.ContactId, user);
                }
            }
            sendEmailToContactsBasedOnEmailTemplateName(contacts, emailTemplate, mapContactIdVsUser); 
        }  
    }

    /**
    * 
    * @description sendEmailToContactsBasedOnEmailTemplateName
    * @param contacts List Contact
    * @param emailTemplate String
    * @param mapContactIdVsUser Map of String and User Object 
    */
    public static void sendEmailToContactsBasedOnEmailTemplateName(List<Contact> contacts, EmailTemplate emailTemplate, Map<String, User> mapContactIdVsUser) {
        try{
            List<Country_Information__mdt> countriesInformation= Country_Information__mdt.getAll().values();
            Map<String, Country_Information__mdt> mapCountryVsCountryInfo = new Map<String, Country_Information__mdt>();
            for(Country_Information__mdt countryInformation: countriesInformation) {
                mapCountryVsCountryInfo.put(countryInformation.Country_Name__c, countryInformation);
            }
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(Contact contact: contacts){
                Messaging.SingleEmailMessage email= new Messaging.SingleEmailMessage();
                email.setTemplateId(emailTemplate.Id);
                email.setTargetObjectId(contact.Id);
                email.setToAddresses(new List<String>{contact.Email});
                email.setTreatTargetObjectAsRecipient(true);
                email.setWhatId(contact.AccountId);
                email.setSenderDisplayName(DEFAULT_FROM_EMAIL);
                if(mapContactIdVsUser.containsKey(contact.Id) && String.IsNotBlank(mapContactIdVsUser.get(contact.Id).User_Franco__c)) {
                    email.setSenderDisplayName(mapCountryVsCountryInfo.containsKey(mapContactIdVsUser.get(contact.Id).User_Franco__c)?mapCountryVsCountryInfo.get(mapContactIdVsUser.get(contact.Id).User_Franco__c).Contact_Us_Email__c: DEFAULT_FROM_EMAIL);            
                }
                emails.add(email);
            }
            if(emailTemplate !=NULL && emails.size() > 0) {
                if ((Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) && (!Test.isRunningTest())) {
                    Messaging.sendemail(emails,true);
                }
            }
        }
        catch(exception ex){ 
            MallExceptionUtil.LOGGER.error('MallSendEmailService.sendEmailToContactsBasedOnEmailTemplateName', ex); 
            throw MallExceptionUtil.throwAuraException('MallSendEmailService.sendEmailToContactsBasedOnEmailTemplateName', ex);
        }
    }

    /**
    * 
    * @description createEmailsForUsersBasedOnEmailTemplate
    * @param userIds List<String>
    * @param emailTemplateDeveloperName String
    */
    public static void createEmailsForUsersBasedOnEmailTemplate(List<String> userIds, String emailTemplateDeveloperName) {
        EmailTemplate emailTemplate =new EmailTemplate();
        List<EmailTemplate> emailTemplates = SEL_EmailTemplate.newInstance().selectByDeveloperName(emailTemplateDeveloperName);
        
        if(emailTemplates.size()>0) {
            Set<Id> userIdsSet = new Set<Id>();
            userIdsSet.addAll((List<Id>)userIds);
            emailTemplate = emailTemplates[0];
            List<User> users = SEL_Users.newInstance().selectById(userIdsSet);
            sendEmailToUsersBasedOnEmailTemplateName(users, emailTemplate);
        }
    }

    /**
    * 
    * @description sendEmailToUsersBasedOnEmailTemplateName
    * @param users List User
    * @param emailTemplate String
    */
    public static void sendEmailToUsersBasedOnEmailTemplateName(List<User> users, EmailTemplate emailTemplate) {
        try{
            List<Country_Information__mdt> countriesInformation= Country_Information__mdt.getAll().values();
            Map<String, Country_Information__mdt> mapCountryVsCountryInfo = new Map<String, Country_Information__mdt>();
            for(Country_Information__mdt countryInformation: countriesInformation) {
                mapCountryVsCountryInfo.put(countryInformation.Country_Name__c, countryInformation);
            }
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(User user: users){
                Messaging.SingleEmailMessage email= new Messaging.SingleEmailMessage();
                email.setTemplateId(emailTemplate.Id);
                email.setTargetObjectId(user.Id);
                email.setToAddresses(new List<String>{user.Email});
                email.setTreatTargetObjectAsRecipient(true);
                email.setSaveAsActivity(false);
                email.setSenderDisplayName(DEFAULT_FROM_EMAIL);
                if(String.IsNotBlank(user.User_Franco__c)) {
                    email.setSenderDisplayName(mapCountryVsCountryInfo.containsKey(user.User_Franco__c)?mapCountryVsCountryInfo.get(user.User_Franco__c).Contact_Us_Email__c: DEFAULT_FROM_EMAIL);            
                }
                emails.add(email);
            }
        
            if(emailTemplate !=NULL && emails.size() > 0) {
                if ((Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) && (!Test.isRunningTest())) {
                    Messaging.sendemail(emails,true);
                }
            } 
        }
        catch(exception ex){ 
            MallExceptionUtil.LOGGER.error('MallSendEmailService.sendEmailToUsersBasedOnEmailTemplateName', ex);
            throw MallExceptionUtil.throwAuraException('MallSendEmailService.sendEmailToUsersBasedOnEmailTemplateName', ex);
        }
    }
}