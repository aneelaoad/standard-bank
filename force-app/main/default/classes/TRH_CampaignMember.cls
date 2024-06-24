/**
 * @description       : SFP-10915 - Automatic App Attendee creation
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : TCK
 *
 * @last modified on  : Feb 2024
 * @last modified by  : Dzianisik Maksim
 * @description       : SFP-36101 Added handleBeforeInsert logic
**/
public with sharing class TRH_CampaignMember extends ABS_TriggerHandlerBase {
    private Map<Id, CampaignMember> id2OldRecords{
        get{
            if(Trigger.old == null){ return null; }
            return new Map<Id, CampaignMember>((CampaignMember[])Trigger.old);
        }
    }

    private Map<Id, CampaignMember> id2NewRecords {
        get {
            if (Trigger.newMap == null) { return null; }
            return (Map<Id, CampaignMember>) Trigger.newMap;
        }
    }

    private List<CampaignMember> newRecords {
        get {
            if (Trigger.new == null) {
                return null;
            }
            return (List<CampaignMember>) Trigger.new;
        }
    }

    public override void handleBeforeInsert() {
        DMN_CampaignMember.handleOptedOutMembers(newRecords);
    }

    public override void handleAfterUpdate(){
        DMN_CampaignMember.createAttendeeFromUpdate(id2NewRecords, id2OldRecords);
    }
}