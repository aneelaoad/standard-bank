/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-21-2022
 * @last modified by  : TCK
**/
public class EAP_CTRL_SendEmailRM implements Database.Batchable<sObject>, Database.Stateful {

    Id eventId;
    String body;
    Id idOrgWideAddress;
    Set<Id> contactIdList = new Set<Id>();
    List<String> ccEmail = new List<String>();
    List<String> bccEmail = new List<String>();
    Map <Id, Id> contactDocumentMap = new Map<Id, Id>(); //Contact, ContentDocument
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventIdParam 
    * @param bodyParam 
    **/
    public EAP_CTRL_SendEmailRM(Id eventIdParam, String bodyParam, List<String> ccEmailParam, List<String> bccEmailParam) {
        eventId = eventIdParam;
        body = bodyParam;
        ccEmail = ccEmailParam;
        bccEmail = bccEmailParam;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryMeetings = 'SELECT Id FROM EAP_Meeting__c WHERE EAP_AppEvent__c =: eventId';
        return Database.getQueryLocator(queryMeetings);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<EAP_Meeting__c> scope) {
        List<Id> meetingIds = new List<Id>();
        for (EAP_Meeting__c meeting : scope) {
            meetingIds.add(meeting.Id);
        }

        List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByMeetingIds(meetingIds);
        Set<Id> attendeeIds = new Set<Id>();
        for (EAP_Attendance__c attendance : attendanceList) {
            attendeeIds.add(attendance.EAP_Attendee__c);
        }

        Map<Id, EAP_Attendee__c> attendeeMap = new Map<ID, EAP_Attendee__c>(SEL_EAP_Attendee.newInstance().selectById(attendeeIds));
        List<ContentDocumentLink> contentDocLinkList = SEL_ContentDocumentLink.newInstance().selectByLinkedEntityId(attendeeIds);
        for (ContentDocumentLink cdl : contentDocLinkList) {
            contactDocumentMap.put(attendeeMap.get(cdl.LinkedEntityId).EAP_Contact__c, cdl.ContentDocumentId);
        }

        Set<Id> attendeeWithDocumentIds = new Set<Id>();
        Set<Id> cdSet = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocLinkList) {
            attendeeWithDocumentIds.add(cdl.LinkedEntityId);
            cdSet.add(cdl.ContentDocumentId);
        }

        List<EAP_Attendee__c> attendeeWithDocumentList = SEL_EAP_Attendee.newInstance().selectById(attendeeWithDocumentIds);

        List<ContentVersion> cvList = SEL_ContentVersion.newInstance().selectByContentDocumentId(cdSet);
        Map<Id, Id> cd_cvMap = new Map<Id, Id>(); // ContentDocument, ContentVersion
        for (ContentVersion cv : cvList) {
            cd_cvMap.put(cv.ContentDocumentId, cv.Id);
        }
        
        Set<Id> contactIds = new Set<Id>();
        for (EAP_Attendee__c attendee : attendeeWithDocumentList) {
            contactIds.add(attendee.EAP_Contact__c);
        }

        List<Contact> contactList = SEL_Contacts.newInstance().selectById(contactIds);
        for (Contact contactId : contactList) {
            contactIdList.add(contactId.Id);
        }

        List<Relationship_Manager__c> rms = SEL_Relationship_Manager.newInstance().selectByContactId(contactIdList);

        EAP_AppEvent__c appEvent = SEL_EAP_AppEvent.newInstance().selectById(eventId);
        User eventManagerUser = SEL_Users.newInstance().selectById(new Set<Id>{appEvent.OwnerId}).get(0);

        List<EmailTemplate> templates = SEL_EmailTemplate.newInstance().selectByName(DMN_EmailTemplates.RELATIONSHIP_MANAGER_EMAIL);
        EmailTemplate template = templates.get(0);
        String templateBody = template.HtmlValue;
        List<Campaign> campaign = SEL_Campaign.newInstance().selectById(appEvent.EAP_Campaign__c);
        if (templateBody != null) {
            templateBody = templateBody.replace('###BODY###', body);
            templateBody = templateBody.replace('###URL-IMAGE-HEADER###', campaign.get(0).Email_Header_Image_URL__c);
        }
        List <Messaging.SingleEmailmessage> lEmailsToSend = new List<Messaging.SingleEmailmessage>();

        for (Relationship_Manager__c rm : rms) {
            List<String> emailListAux = new List<String>();
            emailListAux.add(rm.EAP_Relationship_Manager_Email__c);
            String thisTemplateBody = '';
            if (templateBody != null) {
               thisTemplateBody = templateBody.replace('###ATTENDEE-NAME###', rm.EAP_User__r.Name);
            }
            Messaging.SingleEmailMessage email = generateEmail(eventManagerUser, emailListAux, thisTemplateBody, appEvent.EAP_Campaign__c, appEvent.Name, ccEmail, bccEmail, cd_cvMap.get(contactDocumentMap.get(rm.EAP_Contact__c)));
            lEmailsToSend.add(email);
        }
        
        Messaging.sendEmail(lEmailsToSend);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param bc 
    **/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {

    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param idOrgWideAddress 
    * @param emailAddresses 
    * @param templateBody 
    * @param campaignId 
    * @param subject 
    * @return Messaging.SingleEmailMessage 
    **/
    public static Messaging.SingleEmailMessage generateEmail(User eventManager, List<String> emailAddresses, String templateBody, Id campaignId, String subject, List<String> ccEmail, List<String> bccEmail, Id cvId) {
        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        mail.setSenderDisplayName(eventManager.Name);
        mail.setReplyTo(eventManager.Email);
        mail.setToAddresses(emailAddresses);
        mail.setWhatId(campaignId);
        mail.setEntityAttachments(new List<Id>{cvId});

        if (templateBody != null) {
            mail.setHtmlBody(templateBody);
        } else {
            mail.setHtmlBody('');
        }
        
        if (!ccEmail.isEmpty() && ccEmail != null) {
            mail.setCcAddresses(ccEmail);
        }

        if (!bccEmail.isEmpty() && bccEmail != null) {
            mail.setBccAddresses(bccEmail);
        }
        
        mail.setSubject(subject);
        return mail;
    }
}