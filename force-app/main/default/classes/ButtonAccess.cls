/*************************************************************************\
    @ Author        :     Vaishali Singh
    @ Date          :     24 Mar 2015
    @ Description   :    Takes care of the access on the add update internal attendee button EN-0658  

    @ Last Modified By      :   Prabhanshu Agrawal
    @ Last Modified On      :   Apr 2015
    @ Last Modified Reason  :   To add access to the CST members of related to Client, EN-0662
****************************************************************************/ 


global class ButtonAccess {
    
    WebService  static boolean checkInternalAttendeeButton(Id currentUserId, Id idEventReport){
        
        List<Call_Report__Share> lstShareRecord = [Select ParentId, UserOrGroupId, AccessLevel 
                                                    from Call_Report__Share where ParentId = :idEventReport And 
                                                    UserOrGroupId = :currentUserId And (AccessLevel = 'All' Or AccessLevel = 'Edit')];
        if(lstShareRecord!=null && lstShareRecord.size()>0)
            return true;
        
        Call_Report__c sObjCallReport = [Select Id, Relate_to_Client__c from Call_Report__c where Id=:idEventReport];
        List<Id> lstUserIds = new List<Id>();
        
        //adding list of CST Members of related to client to give access, EN-0662
        for(Custom_Client_Team__c sobjClientTeamMembers: [Select id, Team_Member__c from Custom_Client_Team__c where Account__c =: sObjCallReport.Relate_to_Client__c]){
            lstUserIds.add(sobjClientTeamMembers.Team_Member__c);    
        }
        
        Set<Id> setConId = new Set<Id>();
        for(Call_Report_Attendees__c sObjAttendeed: [Select id, Contact_id__c from Call_Report_Attendees__c where call_report__c=:idEventReport]){
            setConId.add(sObjAttendeed.Contact_id__c);
        }
        for(User sObjUser: [Select id from User where Contact_Sync_ID__c in:setConId]){
            lstUserIds.add(sObjUser.Id);
        }
        Set<Id> setUserIds = new Set<Id>();
        setUserIds.addAll(lstUserIds);
        if(setUserIds.contains(currentUserId))
            return true;

        Profile profileaccess = [Select PermissionsModifyAllData from Profile Where Id =: UserInfo.getProfileId() limit 1];
        
        if(profileaccess.PermissionsModifyAllData)
        	return true;
        
        if (lstUserIds.size() > 0) {
            return RoleUtility.isManagerOfUsers(lstUserIds, currentUserId);
        } else
            return false;
    }
}