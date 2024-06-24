/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-01-2022
 * @last modified by  : TCK
**/
public class EAP_CTRL_AgendaPDF {
    public String imageUrl;
    /**
     * @description       : 
     * @author            : TCK
     * @group             : 
     */    
    public Id eventId;
    public EAP_Attendee__c attendee;
    public Id recordId { get; set; }
    
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public EAP_CTRL_AgendaPDF() {
        recordId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        Set<Id> ids = new Set<Id>();
        ids.add(recordId);
        List<EAP_Attendee__c> attendeeList = SEL_EAP_Attendee.newInstance().selectById(ids);
        eventId = attendeeList[0].EAP_AppEvent__c;
        attendee = attendeeList[0];
    }
    

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return EAP_Attendee__c 
    **/
    public EAP_Attendee__c getAttendee() {
        return attendee;
    }
    
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return String 
    **/
    public String getImage() {
        List<EAP_Document__c> documentList = SEL_EAP_Document.newInstance().selectPresentationByEventId(eventId);
        List<Id> idList = new List<Id>();
        idList.add(documentList[0].Id);
        Map<Id, String> imageMap = EAP_UTIL_EventsApp.getImages(idList);
        if (imageMap.size() > 0) {
            imageUrl = imageMap.values().get(0);
        }
        return imageUrl;
    }
    

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return EAP_AppEvent__c 
    **/
    public EAP_AppEvent__c getEvent() {
        EAP_AppEvent__c event = SEL_EAP_AppEvent.newInstance().selectById(eventId);
        return event;
    }
    

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return List<EAP_Meeting__c> 
    **/
    public List<EAP_Meeting__c> getMeetings() {
        List<Id> idList = new List<Id>();
        idList.add(attendee.Id);
        List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByAttendeeIds(idList);
        Set<Id> meetingIds = new Set<Id>();
        for (EAP_Attendance__c attendance : attendanceList) {
            meetingIds.add(attendance.EAP_Meeting__c);
        }
        List<EAP_Meeting__c> meetingList = SEL_EAP_Meeting.newInstance().selectById(meetingIds);
        return meetingList;
    }
}