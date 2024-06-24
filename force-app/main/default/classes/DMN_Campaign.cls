/**
 * Campaign SObject Domain Class
 *
 * @author		Michal Pesko (mpesko@deloittece.com)
 * @date		December 2020
 */
public inherited sharing class DMN_Campaign {

    public static final String CATEGORY_GROUP_EVENT = '4 - Group Event';
    public static final String CATEGORY_OPERATIONAL_MAILER = 'Operational Mailer';
    public static final String CATEGORY_PA_EVENT = '7 - PA Event';
    public static final String CATEGORY_APP_EVENT = '8 - App Event';
    public static final String CATEGORY_MM_EVENT = '9 - Matchmaking Event';
    public static final String CATEGORY_SURVEY = 'Survey';
    public static final String OBJ_NAME = 'Campaign';
    public static Boolean isFirstTime = true;

    /**
    * @description Method to add Campaign Member statuses depending on Campaign Category
    *
    * @param campaigns - List of campaigns
    */
    public static void addCampaignMemberStatuses(List<Campaign> campaigns) {
        List<CampaignMemberStatus> statusesToInsert = new List<CampaignMemberStatus>();

        Set<Id> campIds = new Set<Id>();

        for (Integer i = 0, j = campaigns.size(); i < j; i++) {
            Campaign campRec = campaigns[i];
            if (campRec.Campaign_Category__c == CATEGORY_SURVEY) {
                campIds.add(campRec.Id);
                CampaignMemberStatus defaultStatus = createStatus(campRec.Id, DMN_CampaignMember.STATUS_NOT_SENT, false);
                defaultStatus.IsDefault = true;
                statusesToInsert.add(defaultStatus);
                statusesToInsert.add(createStatus(campRec.Id, DMN_CampaignMember.STATUS_SENT, false));
                statusesToInsert.add(createStatus(campRec.Id, DMN_CampaignMember.STATUS_RESPONDED, true));

            } else if (campRec.Campaign_Category__c == CATEGORY_PA_EVENT) {
                campIds.add(campRec.Id);
                CampaignMemberStatus defaultStatus = createStatus(campRec.Id, DMN_CampaignMember.STATUS_NOT_SENT, false);
                defaultStatus.IsDefault = true;
                statusesToInsert.add(defaultStatus);
                statusesToInsert.add(createStatus(campRec.Id, DMN_CampaignMember.STATUS_SENT, false));
                statusesToInsert.add(createStatus(campRec.Id, DMN_CampaignMember.STATUS_SENT_REMINDER, false));
                statusesToInsert.add(createStatus(campRec.Id, DMN_CampaignMember.STATUS_ACCEPTED, true));
                statusesToInsert.add(createStatus(campRec.Id, DMN_CampaignMember.STATUS_DECLINED, true));
            } else if (campRec.Campaign_Category__c == CATEGORY_OPERATIONAL_MAILER) {
                campIds.add(campRec.Id);
                CampaignMemberStatus defaultStatus = createStatus(campRec.Id, DMN_CampaignMember.STATUS_NOT_SENT, false);
                defaultStatus.IsDefault = true;
                statusesToInsert.add(defaultStatus);
                statusesToInsert.add(createStatus(campRec.Id, DMN_CampaignMember.STATUS_SENT, true));
            } else {
                statusesToInsert.add(createStatus(campRec.Id, DMN_CampaignMember.STATUS_ACCEPTED, true));
                statusesToInsert.add(createStatus(campRec.Id, DMN_CampaignMember.STATUS_DECLINED, true));
            }
        }

        if(!campIds.isEmpty()) {
            setTempDefaultStatuses(campIds);
            clearCampaignMemberStatuses(campIds);
        }

        if (!statusesToInsert.isEmpty()) {
            insert statusesToInsert;
            clearTempCampaignMemberStatuses(campIds);
        }
    }

    /**
    * @description 
    * @author TCK | 07-28-2022 
    * @param campaignId 
    * @param status 
    * @param hasResponded 
    * @return CampaignMemberStatus 
    **/
    private static CampaignMemberStatus createStatus(Id campaignId, String status, Boolean hasResponded) {
        return new CampaignMemberStatus(
                CampaignId = campaignId,
                HasResponded = hasResponded,
                Label = status,
                IsDefault = false
        );
    }

    /**
    * @description 
    * @author TCK | 07-28-2022 
    * @param campaignIds 
    **/
    private static void clearCampaignMemberStatuses(Set<Id> campaignIds) {
        List<CampaignMemberStatus> campaignMemberStatuses = [SELECT Id FROM CampaignMemberStatus
        WHERE Label!=:DMN_CampaignMember.STATUS_TEMP AND CampaignId IN :campaignIds];
        delete campaignMemberStatuses;
    }

    /**
    * @description 
    * @author TCK | 07-28-2022 
    * @param campaignIds 
    **/
    private static void clearTempCampaignMemberStatuses(Set<Id> campaignIds){
        List<CampaignMemberStatus> campaignMemberStatuses = [SELECT Id FROM CampaignMemberStatus
        WHERE Label=:DMN_CampaignMember.STATUS_TEMP AND CampaignId IN :campaignIds];
        delete campaignMemberStatuses;
    }

    /**
    * @description 
    * @author TCK | 07-28-2022 
    * @param campaignIds 
    **/
    private static void setTempDefaultStatuses(Set<Id> campaignIds) {
        List<CampaignMemberStatus> statusesToUpsert = [SELECT Id, IsDefault, CampaignId FROM CampaignMemberStatus
        WHERE IsDefault = TRUE AND CampaignId IN :campaignIds];
        Set<CampaignMemberStatus> tempStatuses = new Set<CampaignMemberStatus>();
        for (CampaignMemberStatus oldDefaultStatus: statusesToUpsert){
            oldDefaultStatus.IsDefault = false;
            CampaignMemberStatus defaultStatus = createStatus(oldDefaultStatus.CampaignId, DMN_CampaignMember.STATUS_TEMP, true);
            defaultStatus.IsDefault = true;
            tempStatuses.add(defaultStatus);
        }
        statusesToUpsert.addAll(tempStatuses);
        upsert statusesToUpsert;
    }

    /**
    * @description Method to Update 'Deploy to MC Shadow' and Status for all Campaign Members
    * SFP-7843: 'Deploy to Marketing Cloud Shadow' field
    *
    * @param campaignsMap    - Map of Ids and campaigns
    * @param oldCampaignsMap - Map of Ids and campaigns
    */
    public static void updateCampaignMemberFields(Map<Id,Campaign> campaignsMap,Map<Id,Campaign> oldCampaignsMap){
        Set<Id> ids = new Set<Id>();
        for(Campaign campaign: campaignsMap.values()){
            if(oldCampaignsMap.get(campaign.Id).Deploy_to_MC__c != campaign.Deploy_to_MC__c || oldCampaignsMap.get(campaign.Id).Status != campaign.Status
            || oldCampaignsMap.get(campaign.Id).EAP_Corporate_Invitation_Sent__c != campaign.EAP_Corporate_Invitation_Sent__c || oldCampaignsMap.get(campaign.Id).EAP_Investor_Invitation_Sent__c != campaign.EAP_Investor_Invitation_Sent__c){
                ids.add(campaign.Id);
            }
        }
        List<CampaignMember> campaignM = new List<CampaignMember>();

        if(!ids.isEmpty()){

            List<CampaignMember> campaignMembers =  SEL_CampaignMember.newInstance().selectByCampaign(ids);
            List<CampaignMember> cmToUpdate = new List<CampaignMember>();
            for (CampaignMember cm : campaignMembers) {
                Boolean changeCampignMember = false;
                if(cm.Deploy_to_Marketing_Cloud_Shadow__c != campaignsMap.get(cm.CampaignId).Deploy_to_MC__c){
                cm.Deploy_to_Marketing_Cloud_Shadow__c = campaignsMap.get(cm.CampaignId).Deploy_to_MC__c;
                    changeCampignMember = true;
            }
                if(cm.Campaign_Status__c != campaignsMap.get(cm.CampaignId).Status){
                    cm.Campaign_Status__c = campaignsMap.get(cm.CampaignId).Status;
                    changeCampignMember = true;
                }

                if(cm.EAP_Role_In_Event__c == 'Corporate' && cm.EAP_Corporate_Invitation_Sent_Shadow__c != campaignsMap.get(cm.CampaignId).EAP_Corporate_Invitation_Sent__c){
                    cm.EAP_Corporate_Invitation_Sent_Shadow__c = campaignsMap.get(cm.CampaignId).EAP_Corporate_Invitation_Sent__c;
                    changeCampignMember = true;
                }
                if(cm.EAP_Role_In_Event__c == 'Investor' && cm.EAP_Investor_Invitation_Sent_Shadow__c != campaignsMap.get(cm.CampaignId).EAP_Investor_Invitation_Sent__c){
                    cm.EAP_Investor_Invitation_Sent_Shadow__c = campaignsMap.get(cm.CampaignId).EAP_Investor_Invitation_Sent__c;
                    changeCampignMember = true;
                }
                if(changeCampignMember){
                    cmToUpdate.add(cm);
                }
            }
            update cmToUpdate;
        }
    }

    /**
    * @description Method to assign an App Event to Campaign when correct Category
    * 
    * @param List<Campaign> campaigns 
    **/
    public static void createAppEvent(List<Campaign> campaigns){
        List<EAP_AppEvent__c> listEvents = new List<EAP_AppEvent__c>();
        for (Campaign cmp: campaigns) {
            if (cmp.Campaign_Category__c == CATEGORY_APP_EVENT || cmp.Campaign_Category__c == CATEGORY_MM_EVENT) {
                Datetime startEvent = Datetime.newInstance(cmp.EAP_Event_Start_Date__c, cmp.EAP_Event_Start_Time__c);
                Datetime endEvent = Datetime.newInstance(cmp.EAP_Event_End_Date__c, cmp.EAP_Event_End_Time__c);
                EAP_AppEvent__c event = new EAP_AppEvent__c(EAP_Campaign__c = cmp.Id, Name = cmp.Event_Name__c, EAP_Status__c = cmp.Status, EAP_StartDate__c = startEvent, EAP_EndDate__c = endEvent);
                listEvents.add(event);
            }
        }
        insert listEvents;
    }

    /**
     * @description       : 
     * @author            : TCK
     * @group             : 
     * @last modified on  : 09-08-2022
     * @last modified by  : TCK
    **/
    public static void createLocalTimeRecord(Map<Id, Campaign> id2NewRecords,Map<Id, Campaign> id2OldRecords) {
        Id campaignId;
        Date endEventDate;
        for(Campaign campaign : id2NewRecords.values()) {
            campaignId = campaign.Id;
            endEventDate = campaign.EAP_Event_End_Date__c;
        }
        if (endEventDate != null) {
            new WithoutSharing().calculateLocalTime(campaignId);
        }
    }

    private without sharing class WithoutSharing {

        /**
         * @description       : 
         * @author            : TCK
         * @group             : 
         * @last modified on  : 09-08-2022
         * @last modified by  : TCK
        **/
        private void calculateLocalTime(Id campaignId) {
            if (DMN_Campaign.isFirstTime) {
                DMN_Campaign.isFirstTime = false;
                List<Campaign> campaignList = SEL_Campaign.newInstance().selectById(campaignId);
                Campaign campaign = campaignList[0];
                String tzName = TimeZone.getTimeZone(UserInfo.getTimeZone().getID()).getDisplayName();
                Integer userTz = Integer.valueOf(tzName.substring(5, 7));
                Date startEventDate = campaign.EAP_Event_Start_Date__c;
                Date endEventDate = campaign.EAP_Event_End_Date__c;
                Time start = campaign.EAP_Event_Start_Time__c;
                Time endTime = campaign.EAP_Event_End_Time__c;
                Integer hoursToAdd = 0;
                String timezone = campaign.EAP_Event_GMT_Timezone__c;
                Integer hours = Integer.valueOf(timezone.substring(1));

                campaign.EAP_Event_Start_Date_Local_Time__c = Datetime.newInstance(startEventDate, start);
                campaign.EAP_Event_End_Date_Local_Time__c = Datetime.newInstance(endEventDate, endTime);
        
                if (tzName.contains('+') && timezone.contains('+')) {
                    hoursToAdd = (userTz - hours);
                    campaign.EAP_Event_Start_Date_Local_Time__c = campaign.EAP_Event_Start_Date_Local_Time__c.addHours(hoursToAdd);
                    campaign.EAP_Event_End_Date_Local_Time__c = campaign.EAP_Event_End_Date_Local_Time__c.addHours(hoursToAdd);
                } else if (tzName.contains('-') && timezone.contains('-')) {
                    hoursToAdd = (-userTz + (hours));
                    campaign.EAP_Event_Start_Date_Local_Time__c = campaign.EAP_Event_Start_Date_Local_Time__c.addHours(hoursToAdd);
                    campaign.EAP_Event_End_Date_Local_Time__c = campaign.EAP_Event_End_Date_Local_Time__c.addHours(hoursToAdd);
                } else if (tzName.contains('+') && timezone.contains('-')) {
                    hoursToAdd = userTz + hours;
                    campaign.EAP_Event_Start_Date_Local_Time__c = campaign.EAP_Event_Start_Date_Local_Time__c.addHours(hoursToAdd);
                    campaign.EAP_Event_End_Date_Local_Time__c = campaign.EAP_Event_End_Date_Local_Time__c.addHours(hoursToAdd);
                } else if (tzName.contains('-') && timezone.contains('+')) {
                    hoursToAdd = userTz + hours;
                    campaign.EAP_Event_Start_Date_Local_Time__c = campaign.EAP_Event_Start_Date_Local_Time__c.addHours(-hoursToAdd);
                    campaign.EAP_Event_End_Date_Local_Time__c = campaign.EAP_Event_End_Date_Local_Time__c.addHours(-hoursToAdd);
                }
        
                try {
                    update campaign;
                } catch (DmlException e) {
                    SRV_Logger.newInstance().log(e, DMN_Log.AREA_EVENTSAPP, DMN_Campaign.class.getName());
                }
            }
        }
    }
}