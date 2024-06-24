/**
 * @description       : US: SFP-11298 Add to calendar from email functionality
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-27-2022
 * @last modified by  : TCK
**/
public without sharing class EAP_CTRL_ManageEmailBody {
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return String 
    **/
    @AuraEnabled(cacheable=true)
    public static String getEmailBody(Id eventId) {
        String id;
        id = eventId;
        String event = SEL_EAP_AppEvent.newInstance().selectById(eventId).EAP_Email_Body_Relationship_Manager__c;
        // String emailBody = event.EAP_Email_Body_Relationship_Manager__c;
        event = event.replace('###break###', '\n\r');
        // System.debug(emailBody);
        return event;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @param body 
    * @param meetingList 
    * @param ccEmail 
    * @param bccEmail 
    **/
    @AuraEnabled
    public static void updateEmailBodyAndSendEmail(Id eventId, String body, List<EAP_Meeting__c> meetingList, List<String> ccEmail, List<String> bccEmail) {
        EAP_AppEvent__c event = SEL_EAP_AppEvent.newInstance().selectById(eventId);
        event.EAP_Email_Body_Relationship_Manager__c = body;
        // update event;
        // EAP_CTRL_SendEmailMeetings sendEmail = new EAP_CTRL_SendEmailMeetings();
        if (meetingList.size() == 0) {
            // EAP_CTRL_SendEmailMeetings.sendEmailToRm(eventId, body);
            EAP_CTRL_SendEmailRM controller = new EAP_CTRL_SendEmailRM(eventId, body, ccEmail, bccEmail);
            Database.executeBatch(controller);
        } else {
            EAP_CTRL_SendEmailMeetings controller = new EAP_CTRL_SendEmailMeetings(meetingList, body, ccEmail, bccEmail);
            Database.executeBatch(controller);
            // EAP_CTRL_SendEmailMeetings.sendEmailWithCalendarEvents(meetingList, body);
        }
    }
}