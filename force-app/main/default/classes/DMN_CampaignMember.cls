/**
 * @description CampaignMember SObject Domain Class
 *
 * @author		Michal Pesko (mpesko@deloittece.com)
 * @date		December 2020
 *
 * @Last Modified By    : Dzianisik Maksim
 * @Last Modified Date  : Feb 2024
 * @description         : SFP-36101 Added logic for handling OptedOut Contact and showing custom error
 */
public inherited sharing class DMN_CampaignMember {

    public static final String ATT_STATUS_ATTENDED = 'Attended';
    public static final String ATT_STATUS_NO_SHOW = 'No Show';
    public static final String ATT_STATUS_WALK_IN = 'Walk In';
    public static final String FN_ATTENDANCE_STATUS = 'Attendance_Status__c';
    public static final String FN_STATUS = 'Status';
    public static final String OBJ_NAME = 'CampaignMember';
    public static final String INVITATION_STATUS_ACCEPTED = 'Accepted';
    public static final String STATUS_ACCEPTED = 'Accepted';
    public static final String STATUS_DECLINED = 'Declined';
    public static final String STATUS_NOT_SENT = 'Not Sent';
    public static final String STATUS_RESPONDED = 'Responded';
    public static final String STATUS_SENT = 'Sent';
    public static final String STATUS_SENT_REMINDER = 'Sent Reminder';
    public static final String STATUS_TEMP = 'Temp Status';

    @TestVisible
    private static final String OPTED_OUT_ERROR = 'Please note that certain selected members have not been added to the campaign as they’ve opted out of Direct Marketing communication.';

    /**
    * @description Function that create an Attendee when campaign member status is accepted
    * @author TCK | 07-01-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void createAttendeeFromUpdate(Map<Id, CampaignMember> id2NewRecords, Map<Id, CampaignMember> id2OldRecords) {
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        List<Id> campaignIdList = new List<Id>();

        for (CampaignMember cm: id2NewRecords.values()) {
            if ((cm.Invitation_Response__c != id2OldRecords.get(cm.Id).Invitation_Response__c) && (cm.Invitation_Response__c == INVITATION_STATUS_ACCEPTED)) {
                campaignIdList.add(cm.CampaignId);
                campaignMemberList.add(cm);
            }
        }
        if (campaignMemberList.size() > 0) {
            insertAttendees(campaignMemberList, campaignIdList);
        } 
    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @param id2NewRecords 
    **/
    public static void createAttendeeFromInsert(Map<Id, CampaignMember> id2NewRecords) {
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        List<Id> campaignIdList = new List<Id>();


        for (CampaignMember cm: id2NewRecords.values()) {
            if (cm.Invitation_Response__c == INVITATION_STATUS_ACCEPTED) {
                campaignIdList.add(cm.CampaignId);
                campaignMemberList.add(cm);
            }
        }

        if (campaignMemberList.size() > 0) {
            insertAttendees(campaignMemberList, campaignIdList);
        } 
    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @param campaignMemberList 
    * @param campaignIdList 
    **/
    public static void insertAttendees(List<CampaignMember> campaignMemberList, List<Id> campaignIdList) {
        List<Id> contactIdList = new List<Id>();
        List<EAP_Attendee__c> attendeeList = new List<EAP_Attendee__c>();
        List<Campaign> campaignList = new List<Campaign>();
        List<EAP_AppEvent__c> eventList = new List<EAP_AppEvent__c>();
        List<String> eventNameList = new List<String>();
        Map<Id, EAP_AppEvent__c> campaignEventMap = new Map<Id, EAP_AppEvent__c>();
        List<String> categories = new List<String>();
        categories.add(DMN_Campaign.CATEGORY_APP_EVENT);

        campaignList = SEL_Campaign.newInstance().selectByIdAndCampaignCategory(campaignIdList, categories);
        campaignIdList.clear();
        for (Campaign camp: campaignList) {
            campaignIdList.add(camp.Id);
        }

        eventList = SEL_EAP_AppEvent.newInstance().selectByCampaign(campaignIdList);
        for (EAP_AppEvent__c ev : eventList) {
            campaignEventMap.put(ev.EAP_Campaign__c, ev);
            eventNameList.add(String.valueOf(ev.Id));
        }


        for (CampaignMember cm: campaignMemberList) {
            if ((cm.Invitation_Response__c == INVITATION_STATUS_ACCEPTED) && (campaignEventMap.get(cm.CampaignId) != null)) {
                EAP_Attendee__c attendee = new EAP_Attendee__c(Name = cm.FirstName + ' ' + cm.LastName +' - '+ campaignEventMap.get(cm.CampaignId).Name,
                                                            EAP_Contact__c = cm.ContactId,
                                                            EAP_RoleEvent__c = cm.EAP_Role_In_Event__c,
                                                            EAP_AppEvent__c = campaignEventMap.get(cm.CampaignId).Id);
                attendeeList.add(attendee);
                contactIdList.add(cm.ContactId);
            }
        }

        insert attendeeList;
    }

    /**
     * @param newRecords Trigger.new
     * @description handle OptedOut Contact and show custom Error Message
     */
    public static void handleOptedOutMembers(List<CampaignMember> newRecords) {

        Map<Id, CampaignMember> memberId2CampaignMember = new Map<Id, CampaignMember>();
        Map<Id, Set<Id>> individualId2MemberIds = new Map<Id, Set<Id>>();
        Map<Id, Id> contactId2campaignMemberId = new Map<Id, Id>();
        Set<String> campaignTypes = new Set<String>();
        Set<Id> campaignId = new Set<Id>();
        String idPrefix = '00v0000000';
        Integer i = 10000;

        for (CampaignMember tempMember : newRecords) {
            tempMember.Id = idPrefix + i++;
            memberId2CampaignMember.put(tempMember.Id, tempMember);
            campaignId.add(tempMember.CampaignId);
            contactId2campaignMemberId.put(tempMember.ContactId, tempMember.Id);
        }

        List<Campaign> campaigns = SEL_Campaign.newInstance().selectByIds(campaignId);

        for (Campaign tempCampaign : campaigns) {
            campaignTypes.add(tempCampaign.Type);
        }

        for (Contact tempContact : new InnerHelper().getContactsWithoutSharing(contactId2campaignMemberId.keySet())) {
            Id memberId = contactId2campaignMemberId.get(tempContact.Id);
            if (individualId2MemberIds.containsKey(tempContact.IndividualId)) {
                individualId2MemberIds.get(tempContact.IndividualId).add(memberId);
            } else {
                individualId2MemberIds.put(tempContact.IndividualId, new Set<Id>{
                        memberId
                });
            }
        }

        if (individualId2MemberIds.size() > 0) {

            Set<Id> optedOutMembers = new InnerHelper().getContactPointTypeConsent(individualId2MemberIds, campaignTypes);

            for (Id memberId : optedOutMembers) {
                memberId2CampaignMember.get(memberId).addError(OPTED_OUT_ERROR);
            }
        }
    }

    /**
     * @description     : SFP-36101 inner helper class
     * @author          : Dzianisik Maksim
     * @date            : Feb 2024
     */
    private without sharing class InnerHelper {

        /**
         * @param individualId2MemberIds Map<Id, Set<Id>>
         * @param campaignTypes Set<String>
         *
         * @return Set<Id>
         * @description select necessary ContactPointTypeConsents without sharing
         */
        private Set<Id> getContactPointTypeConsent(Map<Id, Set<Id>> individualId2MemberIds, Set<String> campaignTypes) {
            Set<Id> result = new Set<Id>();
            for (AggregateResult ar : new SEL_ContactPointTypeConsents().selectOptedOutContactPointTypeConsent(individualId2MemberIds.keySet(), campaignTypes)) {
                result.addAll(individualId2MemberIds.get(String.valueOf(ar.get('PartyId'))));
            }
            return result;
        }

        /**
         * @param contactIds Set<Id>
         *
         * @return List<Contact>
         * @description some users may not have access to Contact.IndividualId
         */
        private List<Contact> getContactsWithoutSharing(Set<Id> contactIds) {
            return SEL_Contacts.newInstance().selectById(contactIds);
        }
    }
}