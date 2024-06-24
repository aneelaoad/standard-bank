/**
 * @description       : US: SFP-11298 Add to calendar from email functionality
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-27-2022
 * @last modified by  : TCK
**/
public class EAP_CTRL_SendEmailMeetings implements Database.Batchable<String>, Database.Stateful {
    
    String body;
    List<EAP_Meeting__c> meetingList;
    List<String> emailAddressesList = new List<String>();
    List<Id> contactIdList = new List<Id>();
    Id appEventId;
    List<String> contactNames = new List<String>();
    Map<String, String> emailNameMap = new Map<String, String>();
    Map<String, Set<String>> emailMeetingsMap = new Map<String, Set<String>>();
    Map<String, EAP_Meeting__c> meetingMap = new Map<String, EAP_Meeting__c>();
    List<String> ccEmail = new List<String>();
    List<String> bccEmail = new List<String>();

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param meetingListParam 
    * @param bodyParam 
    * @param ccEmailParam 
    * @param bccEmailParam 
    **/
    public EAP_CTRL_SendEmailMeetings(List<EAP_Meeting__c> meetingListParam, String bodyParam, List<String> ccEmailParam, List<String> bccEmailParam){
        meetingList = meetingListParam;
        body = bodyParam;
        ccEmail = ccEmailParam;
        bccEmail = bccEmailParam;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Meeting__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<EAP_Meeting__c> getMeetings(Id eventId){
        String id = eventId;
        // List<EAP_Meeting__c> meetingList = SEL_EAP_Meeting.newInstance().selectByEventId(eventId);
        return SEL_EAP_Meeting.newInstance().selectByEventId(id);
    }

    // List<List<String>> attachmentList = new List<List<String>>();

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param bc 
    * @return Iterable 
    **/
    public Iterable<String> start(Database.BatchableContext bc) {
        List<Id> meetingIds = new List<Id>();
        // Id appEventId;
        // Map<String, EAP_Meeting__c> meetingMap = new Map<String, EAP_Meeting__c>();
        for (EAP_Meeting__c meeting : meetingList) {
            meetingIds.add(meeting.Id);
            meetingMap.put(meeting.Id, meeting);
            appEventId = meeting.EAP_AppEvent__c;
        }
        List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByMeetingIds(meetingIds);
        Set<Id> attendeeIds = new Set<Id>();
        for (EAP_Attendance__c attendance : attendanceList) {
            attendeeIds.add(attendance.EAP_Attendee__c);
        }
        List<EAP_Attendee__c> attendeeList = SEL_EAP_Attendee.newInstance().selectById(attendeeIds);
        Map<String, String> attendeeMap = new Map<String, String>();
        List<String> emailAddressesList = new List<String>();

        Set<Id> contactIds = new Set<Id>();
        List<String> contactNames = new List<String>();
        // Map<String, String> emailNameMap = new Map<String, String>();
        for (EAP_Attendee__c attendee : attendeeList) {
            attendeeMap.put(attendee.Id, attendee.EAP_Contact_Email__c);
            emailAddressesList.add(attendee.EAP_Contact_Email__c);
            contactIds.add(attendee.EAP_Contact__c);
            contactNames.add(attendee.EAP_ContactName__c);
            emailNameMap.put(attendee.EAP_Contact_Email__c, attendee.EAP_ContactName__c);
        }

        // Map<String, Set<String>> emailMeetingsMap = new Map<String, Set<String>>();

        for(EAP_Attendance__c attendance : attendanceList) {
            String email = attendeeMap.get(attendance.EAP_Attendee__c);
            if (emailMeetingsMap.containsKey(email)) {
                Set<String> meetingsFromMap = emailMeetingsMap.get(email);
                meetingsFromMap.add(attendance.EAP_Meeting__c);
                emailMeetingsMap.put(email, meetingsFromMap);
            } else {
                Set<String> meetings = new Set<String>();
                meetings.add(attendance.EAP_Meeting__c);
                emailMeetingsMap.put(email, meetings);
            }
        }
        return emailAddressesList;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param bc 
    * @param emailAddressList 
    **/
    public void execute(Database.BatchableContext bc, List<String> emailAddressList) {
        EAP_AppEvent__c appEvent = SEL_EAP_AppEvent.newInstance().selectById(appEventId);
        
        List<EmailTemplate> templates = SEL_EmailTemplate.newInstance().selectByName('Add to calendar');
        EmailTemplate template = templates[0];
        String templateBody = template.HtmlValue;
        List<Campaign> campaign = SEL_Campaign.newInstance().selectById(appEvent.EAP_Campaign__c);
    
        List <Messaging.SingleEmailmessage> lEmailsToSend = new List<Messaging.SingleEmailmessage>();

        List<OrgWideEmailAddress> lstEmailAddress = SEL_OrgWideEmailAddress.newInstance().selectByAddress('manuel.balbas@the-cocktail.com');
        Id idOrgWideAddress;
        if (!lstEmailAddress.isEmpty()){
            idOrgWideAddress = lstEmailAddress[0].Id;
        }
                    
        for (String emailAddress : emailAddressList) {
            List<List<String>> attachmentList = new List<List<String>>();

            String cName = emailNameMap.get(emailAddress);
            String templateBodyAux = templateBody;

            if (templateBodyAux != null) {
                templateBodyAux = templateBodyAux.replace('###URL-IMAGE-HEADER###', campaign[0].Email_Header_Image_URL__c);
                templateBodyAux = templateBodyAux.replace('###BODY###', body);
                templateBodyAux = templateBodyAux.replace('###ATTENDEE-NAME###', cName);
            }
            
            List<String> emailListAux = new List<String>();
            emailListAux.add(emailAddress);

            Set<String> ids = emailMeetingsMap.get(emailAddress);

            for (String id : ids) {
                EAP_Meeting__c meeting = meetingMap.get(id);
                
                String startDate = meeting.EAP_StartDate__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
                String endDate = meeting.EAP_EndDate__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
                String[] ics = new List<String>
                {'BEGIN:VCALENDAR',
                'VERSION:2.0',
                'PRODID:-//Event Meeting',
                'CALSCALE:GREGORIAN',
                'BEGIN:VEVENT',
                'UID:'+ meeting.Id,
                'DTSTAMP:'+ startDate,
                'DTSTART:' + startDate,
                'DTEND:' + endDate,
                'SUMMARY:' + meeting.Name,
                'DESCRIPTION:' + meeting.EAP_Description__c,
                'END:VEVENT',
                'END:VCALENDAR'};
                attachmentList.add(ics);
            }
            Messaging.SingleEmailMessage email = generateEmail(idOrgWideAddress, emailListAux, templateBodyAux, appEvent.EAP_Campaign__c, appEvent.Name, ccEmail, bccEmail);
            List<Blob> files = generateBlobListForAttachments(attachmentList);
            List<Messaging.EmailFileAttachment> attachmentFileList = new List<Messaging.EmailFileAttachment>();
            for (Blob file : files) {
                Messaging.EmailFileAttachment attachmentFile = new Messaging.EmailFileAttachment();
                attachmentFile.setFileName('ClickToAddToCalendar.ics');
                attachmentFile.setBody(file);
                attachmentFileList.add(attachmentFile);
            }
            email.setFileAttachments(attachmentFileList);
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
     * @description generate blob for attachments
     * @author TCK | 06-14-2022
     * @param attList
     * @return List<Blob>
     **/
    public static List<Blob> generateBlobListForAttachments( List<List<String>> attList) {
        List<Blob> blobList = new List<Blob>();
        for (List<String> att : attList) {
            String attachmentContent = String.join(att, '\n');
            blobList.add(Blob.valueOf(attachmentContent));
        }
        return blobList;
    }

    /**
     * @description generate email
     * @author TCK | 06-14-2022
     * @param idOrgWideAddress
     * @param emailAddresses
     * @param templateBody
     * @param campaignId
     * @param subject
     * @param ccEmail 
     * @param bccEmail 
     * @return Messaging.SingleEmailMessage
     */
    public static Messaging.SingleEmailMessage generateEmail(Id idOrgWideAddress, List<String> emailAddresses, String templateBody, Id campaignId, String subject, List<String> ccEmail, List<String> bccEmail) {
        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        mail.setOrgWideEmailAddressId(idOrgWideAddress);
        mail.setToAddresses(emailAddresses);
        // mail.setTargetObjectId(contactId);
        // System.debug(template.Id);
        // mail.setTemplateId(template.Id);
        mail.setWhatId(campaignId);
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
        // mail.setPlainTextBody('PRUEBA');
        // String subject = 'Testing Add to Calendar Meetings';
        mail.setSubject(subject + ' meetings');
        return mail;
    }
}



    // public Database.QueryLocator start(Database.BatchableContext bc) {
    //     List<Id> meetingIds = new List<Id>();
    //     // Id appEventId;
    //     for (EAP_Meeting__c meeting : meetingList) {
    //         meetingIds.add(meeting.Id);
    //         String startDate = meeting.EAP_StartDate__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
    //         String endDate = meeting.EAP_EndDate__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
    //         String[] ics = new List<String>
    //         {'BEGIN:VCALENDAR',
    //         'VERSION:2.0',
    //         'PRODID:-//Event Meeting',
    //         'CALSCALE:GREGORIAN',
    //         'BEGIN:VEVENT',
    //         'UID:'+ meeting.Id,
    //         'DTSTAMP:'+ startDate,
    //         'DTSTART:' + startDate,
    //         'DTEND:' + endDate,
    //         'SUMMARY:' + meeting.Name,
    //         'DESCRIPTION:' + meeting.EAP_Description__c,
    //         'END:VEVENT',
    //         'END:VCALENDAR'};
    //         attachmentList.add(ics);
    //         appEventId = meeting.EAP_AppEvent__c;
    //     }
    //     // List<EAP_Attendance__c> attendanceList = [SELECT EAP_Attendee__c FROM EAP_Attendance__c WHERE EAP_Meeting__c IN :meetingIds];
    //     System.debug(meetingIds);
    //     List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByMeetingIds(meetingIds);
    //     Set<Id> attendeeIds = new Set<Id>();
    //     for (EAP_Attendance__c attendance : attendanceList) {
    //         attendeeIds.add(attendance.EAP_Attendee__c);
    //     }
    //     List<EAP_Attendee__c> attendeeList = SEL_EAP_Attendee.newInstance().selectById(attendeeIds);
    //     Set<Id> contactIds = new Set<Id>();
    //     for (EAP_Attendee__c attendee : attendeeList) {
    //         contactIds.add(attendee.EAP_Contact__c);
    //         contactNames.add(attendee.EAP_ContactName__c);
    //     }
    //     String contactList = 'SELECT Id, Name, Email FROM Contact WHERE Id IN :contactIds';
    //     return Database.getQueryLocator(contactList);
    // }

    // public void execute(Database.BatchableContext bc, List<Contact> scope) {

    //     for (Contact contact : scope) {
    //         emailAddressesList.add(contact.Email);
    //         contactIdList.add(contact.Id);
    //     }
    //     List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id FROM OrgWideEmailAddress WHERE Address='manuel.balbas@the-cocktail.com'];
    //     Id idOrgWideAddress;
    //     if (!lstEmailAddress.isEmpty()){
    //         idOrgWideAddress = lstEmailAddress[0].Id;
    //     }
    //     EAP_AppEvent__c appEvent = SEL_EAP_AppEvent.newInstance().selectById(appEventId);
    //     // List<EAP_AppEvent__c> appEvent = [SELECT Id, EAP_Campaign__c FROM EAP_AppEvent__c WHERE Id = :appEventId];
    //     EmailTemplate template = [SELECT Id,Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE Name='Add to calendar'];
    //     String templateBody = template.HtmlValue;
    //     List<Campaign> campaign = [SELECT Name, Email_Header_Image_URL__c FROM Campaign WHERE Id = :appEvent.EAP_Campaign__c];
    //     templateBody = templateBody.replace('###URL-IMAGE-HEADER###', campaign[0].Email_Header_Image_URL__c);
    //     templateBody = templateBody.replace('###BODY###', body);
    //     List <Messaging.SingleEmailmessage> lEmailsToSend = new List<Messaging.SingleEmailmessage> ();
        
    //     for (String emailAddress : emailAddressesList) {
    //         List<String> emailListAux = new List<String>();
    //         emailListAux.add(emailAddress);
    //         for (String contactName : contactNames) {
    //             templateBody = templateBody.replace('###ATTENDEE-NAME###', contactName);
    //         }
    //             for (Id contactId : contactIdList) {
    //                 Messaging.SingleEmailMessage email = generateEmail(idOrgWideAddress, emailListAux, templateBody, contactId, appEvent.EAP_Campaign__c, template.Subject);
    //                 List<Blob> files = generateBlobListForAttachments(attachmentList);
    //                 List<Messaging.EmailFileAttachment> attachmentFileList = new List<Messaging.EmailFileAttachment>();
    //                 for (Blob file : files) {
    //                     Messaging.EmailFileAttachment attachmentFile = new Messaging.EmailFileAttachment();
    //                     attachmentFile.setFileName('ClickToAddToCalendar.ics');
    //                     attachmentFile.setBody(file);
    //                     attachmentFileList.add(attachmentFile);
    //                 }
    //                 email.setFileAttachments(attachmentFileList);
    //                 lEmailsToSend.add(email);
    //             }
    //     }
    //     Messaging.sendEmail(lEmailsToSend);
    // }

    // public void finish(Database.BatchableContext bc) {

    // }

    // @AuraEnabled
    // public static void sendEmailWithCalendarEvents(List<EAP_Meeting__c> meetingList, String body) {
    //     List<Id> meetingIds = new List<Id>();
    //     Id appEventId;
    //     Map<String, EAP_Meeting__c> meetingMap = new Map<String, EAP_Meeting__c>();
    //     for (EAP_Meeting__c meeting : meetingList) {
    //         meetingIds.add(meeting.Id);
    //         meetingMap.put(meeting.Id, meeting);
    //         appEventId = meeting.EAP_AppEvent__c;
    //     }
    //     List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByMeetingIds(meetingIds);
    //     Set<Id> attendeeIds = new Set<Id>();
    //     for (EAP_Attendance__c attendance : attendanceList) {
    //         attendeeIds.add(attendance.EAP_Attendee__c);
    //     }
    //     List<EAP_Attendee__c> attendeeList = SEL_EAP_Attendee.newInstance().selectById(attendeeIds);
    //     Map<String, String> attendeeMap = new Map<String, String>();
    //     List<String> emailAddressesList = new List<String>();

    //     Set<Id> contactIds = new Set<Id>();
    //     List<String> contactNames = new List<String>();
    //     Map<String, String> emailNameMap = new Map<String, String>();
    //     for (EAP_Attendee__c attendee : attendeeList) {
    //         attendeeMap.put(attendee.Id, attendee.EAP_Contact_Email__c);
    //         emailAddressesList.add(attendee.EAP_Contact_Email__c);
    //         contactIds.add(attendee.EAP_Contact__c);
    //         contactNames.add(attendee.EAP_ContactName__c);
    //         emailNameMap.put(attendee.EAP_Contact_Email__c, attendee.EAP_ContactName__c);
    //     }

    //     Map<String, Set<String>> emailMeetingsMap = new Map<String, Set<String>>();

    //     for(EAP_Attendance__c attendance : attendanceList) {
    //         String email = attendeeMap.get(attendance.EAP_Attendee__c);
    //         if (emailMeetingsMap.containsKey(email)) {
    //             Set<String> meetingsFromMap = emailMeetingsMap.get(email);
    //             meetingsFromMap.add(attendance.EAP_Meeting__c);
    //             emailMeetingsMap.put(email, meetingsFromMap);
    //         } else {
    //             Set<String> meetings = new Set<String>();
    //             meetings.add(attendance.EAP_Meeting__c);
    //             emailMeetingsMap.put(email, meetings);
    //         }
    //     }
    //     EAP_AppEvent__c appEvent = SEL_EAP_AppEvent.newInstance().selectById(appEventId);
    //     EmailTemplate template = [SELECT Id,Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE Name='Add to calendar'];
    //     String templateBody = template.HtmlValue;
    //     List<Campaign> campaign = [SELECT Name, Email_Header_Image_URL__c FROM Campaign WHERE Id = :appEvent.EAP_Campaign__c];
    //     List <Messaging.SingleEmailmessage> lEmailsToSend = new List<Messaging.SingleEmailmessage>();

    //     List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id FROM OrgWideEmailAddress WHERE Address='manuel.balbas@the-cocktail.com'];
    //     Id idOrgWideAddress;
    //     if (!lstEmailAddress.isEmpty()){
    //         idOrgWideAddress = lstEmailAddress[0].Id;
    //     }
                    
    //     for (String emailAddress : emailAddressesList) {
    //         List<List<String>> attachmentList = new List<List<String>>();

    //         String cName = emailNameMap.get(emailAddress);
    //         String templateBodyAux = templateBody;

    //         templateBodyAux = templateBodyAux.replace('###URL-IMAGE-HEADER###', campaign[0].Email_Header_Image_URL__c);
    //         templateBodyAux = templateBodyAux.replace('###BODY###', body);
    //         templateBodyAux = templateBodyAux.replace('###ATTENDEE-NAME###', cName);
            
    //         List<String> emailListAux = new List<String>();
    //         emailListAux.add(emailAddress);
    //         Set<String> ids = emailMeetingsMap.get(emailAddress);

    //         for (String id : ids) {
    //             EAP_Meeting__c meeting = meetingMap.get(id);
                
    //             String startDate = meeting.EAP_StartDate__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
    //             String endDate = meeting.EAP_EndDate__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
    //             String[] ics = new List<String>
    //             {'BEGIN:VCALENDAR',
    //             'VERSION:2.0',
    //             'PRODID:-//Event Meeting',
    //             'CALSCALE:GREGORIAN',
    //             'BEGIN:VEVENT',
    //             'UID:'+ meeting.Id,
    //             'DTSTAMP:'+ startDate,
    //             'DTSTART:' + startDate,
    //             'DTEND:' + endDate,
    //             'SUMMARY:' + meeting.Name,
    //             'DESCRIPTION:' + meeting.EAP_Description__c,
    //             'END:VEVENT',
    //             'END:VCALENDAR'};
    //             attachmentList.add(ics);
    //         }
    //         Messaging.SingleEmailMessage email = generateEmail(idOrgWideAddress, emailListAux, templateBodyAux, appEvent.EAP_Campaign__c, template.Subject);
    //         List<Blob> files = generateBlobListForAttachments(attachmentList);
    //         List<Messaging.EmailFileAttachment> attachmentFileList = new List<Messaging.EmailFileAttachment>();
    //         for (Blob file : files) {
    //             Messaging.EmailFileAttachment attachmentFile = new Messaging.EmailFileAttachment();
    //             attachmentFile.setFileName('ClickToAddToCalendar.ics');
    //             attachmentFile.setBody(file);
    //             attachmentFileList.add(attachmentFile);
    //         }
    //         email.setFileAttachments(attachmentFileList);
    //         lEmailsToSend.add(email);
    //     }
    //     Messaging.sendEmail(lEmailsToSend);
    // }

    // @AuraEnabled
    // public static void sendEmailToRm(Id eventId, String body) {
    //     List<EAP_Meeting__c> meetingList = SEL_EAP_Meeting.newInstance().selectByEventId(eventId);
    //     List<Id> meetingIds = new List<Id>();
    //     for (EAP_Meeting__c meeting : meetingList) {
    //         meetingIds.add(meeting.Id);
    //     }
    //     List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByMeetingIds(meetingIds);
    //     Set<Id> attendeeIds = new Set<Id>();
    //     for (EAP_Attendance__c attendance : attendanceList) {
    //         attendeeIds.add(attendance.EAP_Attendee__c);
    //     }
    //     List<EAP_Attendee__c> attendeeList = SEL_EAP_Attendee.newInstance().selectById(attendeeIds);
    //     Set<Id> contactIds = new Set<Id>();
    //     List<String> contactNames = new List<String>();
    //     for (EAP_Attendee__c attendee : attendeeList) {
    //         contactIds.add(attendee.EAP_Contact__c);
    //         contactNames.add(attendee.EAP_ContactName__c);
    //     }
    //     List<Contact> contactList = SEL_Contacts.newInstance().selectById(contactIds);
    //     List<String> emailAddressesList = new List<String>();
    //     List<Id> contactIdList = new List<Id>();
    //     for (Contact contactId : contactList) {
    //         contactIdList.add(contactId.Id);
    //     }
    //     List<Relationship_Manager__c> listRm = [SELECT Id, Name, EAP_Relationship_Manager_Email__c FROM Relationship_Manager__c WHERE EAP_Contact__c IN :contactIdList];
    //     List<String> emailAddressesListRm = new List<String>();
    //     List<String> rmNames = new List<String>();
    //     for (Relationship_Manager__c rm : listRm) {
    //         emailAddressesListRm.add(rm.EAP_Relationship_Manager_Email__c);
    //         rmNames.add(rm.Name);
    //     }

    //     List<OrgWideEmailAddress> lstEmailAddress=[SELECT Id FROM OrgWideEmailAddress WHERE Address='manuel.balbas@the-cocktail.com'];
    //     Id idOrgWideAddress;
    //     if (!lstEmailAddress.isEmpty()){
    //         idOrgWideAddress = lstEmailAddress[0].Id;
    //     }

    //     EAP_AppEvent__c appEvent = SEL_EAP_AppEvent.newInstance().selectById(eventId);
    //     EmailTemplate template = [SELECT Id,Subject,Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE Name='Add to calendar'];
    //     String templateBody = template.HtmlValue;
    //     List<Campaign> campaign = [SELECT Name, Email_Header_Image_URL__c FROM Campaign WHERE Id = :appEvent.EAP_Campaign__c];
    //     templateBody = templateBody.replace('###BODY###', body);
    //     templateBody = templateBody.replace('###URL-IMAGE-HEADER###', campaign[0].Email_Header_Image_URL__c);
    //     List <Messaging.SingleEmailmessage> lEmailsToSend = new List<Messaging.SingleEmailmessage>();

    //     for (String emailAddress : emailAddressesListRm) {
    //         List<String> emailListAux = new List<String>();
    //         emailListAux.add(emailAddress);
    //         for (String rmName : rmNames) {
    //             templateBody = templateBody.replace('###ATTENDEE-NAME###', rmName);
    //             for (Id contactId : contactIdList) {
    //                 Messaging.SingleEmailMessage email = generateEmail(idOrgWideAddress, emailListAux, templateBody, contactId, appEvent.EAP_Campaign__c, template.Subject);
    //                 lEmailsToSend.add(email);
    //             }
    //         }
    //     }
    //     Messaging.sendEmail(lEmailsToSend);
    // }