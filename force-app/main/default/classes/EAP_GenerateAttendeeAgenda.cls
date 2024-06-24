/**
 * @description       : SFP-11066 - Generate agenda from a button
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : TCK
**/
public without sharing class EAP_GenerateAttendeeAgenda implements Database.Batchable<sObject>{
    public String eventId;
    private Map<Id, String> attendeeNameMap = new Map<Id, String>();

    /**
    * @description 
    * @author TCK | 10-27-2022 
    * @param eventId 
    **/
    public EAP_GenerateAttendeeAgenda(String eventId) {
        this.eventId = eventId;
    }

    /**
    * @description 
    * @author TCK | 10-27-2022 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> rolInEventList = new List<String>();
        rolInEventList.add(DMN_EAP_Attendee.ROL_INVESTOR);
        rolInEventList.add(DMN_EAP_Attendee.ROL_CORPORATE);
        rolInEventList.add(DMN_EAP_Attendee.ROL_CORPORATE_ASSOCIATED);
        rolInEventList.add(DMN_EAP_Attendee.ROL_POLICY_MAKER);

        String query =  'SELECT Id, Name, EAP_AppEvent__c, EAP_Contact__c, EAP_RoleEvent__c '+
                            'FROM EAP_Attendee__c ' +
                            'WHERE (EAP_AppEvent__c =: eventId) AND (EAP_RoleEvent__c IN :rolInEventList)';
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author TCK | 10-27-2022 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<EAP_Attendee__c> scope){
        List<ContentVersion> contVersionList = new List<ContentVersion>();
        Map<Id, Id> contDocMap = new Map<Id, Id>();
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();

        Set<Id> contactIds = new Set<Id>();
        for (EAP_Attendee__c att : scope) {
            contactIds.add(att.EAP_Contact__c);
        }
        List<Contact> contacts = SEL_Contacts.newInstance().selectById(contactIds);

        Map<Id, String> contactNameMap = new Map<Id, String>();
        for (Contact ct : contacts) {
            contactNameMap.put(ct.Id, ct.Name);
        }

        for (EAP_Attendee__c att: scope) {
            attendeeNameMap.put(att.Id, contactNameMap.get(att.EAP_Contact__c));
        }

        for (EAP_Attendee__c att : scope) {
            String htmlData = generateAgendaPDF(att);
            Blob bdata = Blob.valueof('Test class cannot convert string to pdf');
            if(!Test.isRunningTest()){
                bdata = Blob.toPDF(htmlData);
            }

            //Insert ContentVersion
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S'; 
            cv.PathOnClient = 'EAP_TestAgenda.pdf';
            //C-Content Origin. H-Chatter Origin.
            cv.Origin = 'H';
            cv.OwnerId = UserInfo.getUserId();
            cv.Title = 'Agenda.pdf';
            //File content
            cv.VersionData = bdata;
            contVersionList.add(cv);
        }
        insert contVersionList;
        
        //Get the ContentDocumentId 
        List<ContentVersion>  cvList  = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contVersionList];
        for (ContentVersion cv : cvList) {
            contDocMap.put(cv.Id, cv.ContentDocumentId);
        }

        Integer index = 0;
        for (EAP_Attendee__c att : scope) {
            //Insert ContentDocumentLink
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contDocMap.get(contVersionList.get(index).Id);
            cdl.LinkedEntityId = att.Id;
            //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cdl.ShareType = 'V';
            contentDocumentLinkList.add(cdl);
            index++;
        }
        insert contentDocumentLinkList;

    }

    /**
    * @description 
    * @author TCK | 10-27-2022 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
    }

    /**
    * @description 
    * @author TCK | 10-27-2022 
    * @param att 
    * @return String 
    **/
    @TestVisible
    private String generateAgendaPDF(EAP_Attendee__c att) {

        String imageUrl;
        EAP_AppEvent__c event = SEL_EAP_AppEvent.newInstance().selectById(att.EAP_AppEvent__c);
        Set<Id> attIds = new Set<Id>();
        attIds.add(att.Id);
        List<EAP_Attendee__c> attendee = SEL_EAP_Attendee.newInstance().selectById(attIds);
        Id eventId = attendee[0].EAP_AppEvent__c;
        List<EAP_Document__c> documentList = SEL_EAP_Document.newInstance().selectPresentationByEventId(eventId);
        List<Id> idList = new List<Id>();
        idList.add(documentList[0].Id);
        Map<Id, String> imageMap = EAP_UTIL_EventsApp.getImages(idList);
        if (imageMap.size() > 0) {
            imageUrl = imageMap.values().get(0);
        }


        Set<Id> contactIds = new Set<Id>();
        contactIds.add(att.EAP_Contact__c);
        List<Contact> contacts = SEL_Contacts.newInstance().selectById(contactIds);
        Set<Id> campaignIds = new Set<Id>();
        campaignIds.add(event.EAP_Campaign__c);

        
        List<EAP_Meeting__c> meetings = SEL_EAP_Meeting.newInstance().selectByEventId(eventId);
        List<Id> meetingIds = new List<Id>();
        for (EAP_Meeting__c meeting : meetings) {
            meetingIds.add(meeting.Id);
        }
        List<EAP_Attendee__c> attendeeAuxList = new List<EAP_Attendee__c>();
        attendeeAuxList.add(att);


        List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByMeetingIds(meetingIds);
        List<Id> attendanceAttendeesIds = new List<Id>();
        for (EAP_Attendance__c attendance : attendanceList) {
            attendanceAttendeesIds.add(attendance.EAP_Attendee__c);
        }

        List<EAP_Attendee__c> attendanceAttendees = SEL_EAP_Attendee.newInstance().selectByIds(attendanceAttendeesIds);

        Map<EAP_Attendance__c, List<EAP_Attendee__c>> attendanceAttendeesMap = new Map<EAP_Attendance__c, List<EAP_Attendee__c>>();
        for (EAP_Attendance__c attendance : attendanceList) {
            for (EAP_Attendee__c attendanceAttendee : attendanceAttendees) {
                if (attendance.EAP_Attendee__c == attendanceAttendee.Id) {
                    List<EAP_Attendee__c> attendeeListAux = new List<EAP_Attendee__c>();
                    attendeeListAux.add(attendanceAttendee);
                    attendanceAttendeesMap.put(attendance, attendeeListAux);
                }
            }
        }

        String attendeeName = contacts[0].Name;
        String eventName = event.Name;
        Date eventStartDate = event.EAP_StartEventDate__c;
        Date eventEndDate = event.EAP_EndEventDate__c;

        String formHtmlStart = '<HTML><BODY>';
        String headerImage = '<table border="0" align="center"><thead><tr><td colspan="4"><img src="'+ imageUrl +'"width="57%" style="display:block;"></img></td></tr></thead>';
        String attendeeSalutation = '<tbody><tr><td colspan="4"><p style="text-align:center;">Dear '+ attendeeName +' here is the agenda for the '+ eventName +' event:</p></td></tr><tr><td colspan="4">' + String.valueOf(eventStartDate) + ' - ' + String.valueOf(eventEndDate) + '</td></tr>';
        String meetingsHeader = '<tr><th>Time</th><th>Attending Investors</th><th>Attending Hosts</th><th>Location</th></tr>';
        String closingTags = '</tbody></table>';
        String formHtmlEnd = '</BODY></HTML>';

        String pdfContent = '' + formHtmlStart;
        try {
            pdfContent = pdfContent + headerImage;
            pdfContent = pdfContent + attendeeSalutation;
            pdfContent = pdfContent + meetingsHeader;
            String attendanceHtmlListOpen = '<ul>';
            String attendanceHtmlList = '';
            String attendanceHtmlListClose = '</ul>';
            String hostsHtmlListOpen = '<ul>';
            String hostsHtmlList = '';
            String hostsHtmlListClose = '</ul>';
            Boolean clientPrinted = false;

            for (EAP_Meeting__c meeting : meetings) {
                clientPrinted = false;
                for (EAP_Attendance__c attendance : attendanceList) {
                    if (attendance.EAP_Meeting__c == meeting.Id) {
                        for (EAP_Attendee__c attendanceAttendee : attendanceAttendeesMap.get(attendance)) {
                            if (attendanceAttendee.EAP_RoleEvent__c == DMN_EAP_Attendee.ROL_INVESTOR) {
                                attendanceHtmlList = attendanceHtmlList + '<li>' + attendeeNameMap.get(attendanceAttendee.Id) + '</li>';
                            } else if ((attendanceAttendee.EAP_RoleEvent__c == DMN_EAP_Attendee.ROL_CORPORATE) || (attendanceAttendee.EAP_RoleEvent__c == DMN_EAP_Attendee.ROL_CORPORATE_ASSOCIATED)) {
                                if (!clientPrinted && attendanceAttendee.EAP_AttendeeCompany__c != null) {
                                    hostsHtmlList = hostsHtmlList + '<li>' + attendanceAttendee.EAP_AttendeeCompany__c + '</li>';
                                    clientPrinted = true;
                                }
                                hostsHtmlList = hostsHtmlList + '<li>' + attendeeNameMap.get(attendanceAttendee.Id) + '</li>';
                            } 
                        }
                    }
                }
                String meetingDate = meeting.EAP_StartDate__c.format('dd/MM/yyyy');
                String startTime = meeting.EAP_StartDate__c.format('HH:mm');
                String endTime = meeting.EAP_EndDate__c.format('HH:mm');
                pdfContent = pdfContent + '<tr height="1px"><td colspan="4" bgcolor="MidnightBlue"></td></tr><tr><td><table><tr><td style="text-align:center;">' + meetingDate + '</td></tr><tr><td>' + startTime + ' - ' + endTime + '</td></tr></table></td><td>' + attendanceHtmlListOpen + attendanceHtmlList + attendanceHtmlListClose + '</td></td><td>'+ hostsHtmlListOpen + hostsHtmlList + hostsHtmlListClose +'</td><td>' + meeting.EAP_Location__c + '</td></tr>';

                attendanceHtmlList = '';
                hostsHtmlList = '';
            }

            // pdfContent = pdfContent + meetingListClose;
            pdfContent = pdfContent + closingTags;
            pdfContent = pdfContent + formHtmlEnd;

        } catch(Exception e) {
            pdfContent = pdfContent + '<P>THERE WAS AN ERROR GENERATING PDF: ' + e.getMessage() + '</P>';
            pdfContent = pdfContent + formHtmlEnd;
        }
        return pdfContent;
    }
}