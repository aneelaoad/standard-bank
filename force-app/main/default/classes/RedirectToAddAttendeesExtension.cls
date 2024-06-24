/*************************************************************************
    @ Author        :     Petr Svestka
    @ Date          :     June 20, 2016
    @ Test File     :     RedirectToAddAttendeesExtensionTest.cls
    @ Description   :     US-1355 - Ensuring at least 2 Core Team Members exist on Internal Core Meetings

	@ Last Modified By  : Petr Svestka
    @ Last Modified On  : July 7, 2016
    @ Last Modified Reason  : US-1414 - changing the condition when the check on 2 core team members happens
****************************************************************************/
public with sharing class RedirectToAddAttendeesExtension {
    
    private final Call_Report__c er;
    private final ApexPages.StandardController stdCont;
    
    public RedirectToAddAttendeesExtension(ApexPages.StandardController stdCont) {
        this.stdCont = stdCont;
        
        if (ApexPages.CurrentPage().getParameters().containsKey('newId')) {
            List<Call_Report__c> ers = [SELECT id, enforce_core_attendee_validation__c FROM Call_Report__c WHERE id = :ApexPages.CurrentPage().getParameters().get('newId')];
            if (ers.size() != 0) {
                this.er = ers.get(0);
            }
        }
    }
    
    public PageReference redirect() {
        PageReference pageRef;
        
        // combines new logic from  US-1355 and existing logic from Call_Report__c.Add_Update_Internal_Attendees Custom Button
        if (er != null && er.enforce_core_attendee_validation__c == true && ButtonAccess.checkInternalAttendeeButton(UserInfo.getUserId(), er.id)) {
            pageRef = Page.AddInternalAttendee;
            pageRef.getParameters().put('reportid', er.id);
            pageRef.setRedirect(true);
        } else if (er != null) {
            pageRef = new ApexPages.StandardController(er).view();
            pageRef.setRedirect(true);
        }
        
        return pageRef;
    }
}