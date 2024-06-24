/**
 * @description Builder class for CampaignMember SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_CampaignMember extends ABS_ObjectBuilderBase {

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @param uow 
    **/
    public BLD_CampaignMember(fflib_SObjectUnitOfWork uow) {
        super(CampaignMember.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @param campaignBuilder 
    * @return BLD_CampaignMember 
    **/
    public BLD_CampaignMember campaign(BLD_Campaign campaignBuilder) {
        return (BLD_CampaignMember) setRelation(CampaignMember.CampaignId, campaignBuilder);
    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @param campaignId 
    * @return BLD_CampaignMember 
    **/
    public BLD_CampaignMember campaign(String campaignId) {
        return (BLD_CampaignMember) setField(CampaignMember.CampaignId, campaignId);
    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @param contactBuilder 
    * @return BLD_CampaignMember 
    **/
    public BLD_CampaignMember contact(BLD_Contact contactBuilder) {
        return (BLD_CampaignMember) setRelation(CampaignMember.ContactId, contactBuilder);
    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @param contactId 
    * @return BLD_CampaignMember 
    **/
    public BLD_CampaignMember contact(String contactId) {
        return (BLD_CampaignMember) setField(CampaignMember.ContactId, contactId);
    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @param status 
    * @return BLD_CampaignMember 
    **/
    public BLD_CampaignMember status(String status) {
        return (BLD_CampaignMember) setField(CampaignMember.Status, status);
    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @param wave 
    * @return BLD_CampaignMember 
    **/
    public BLD_CampaignMember wave(String wave) {
        return (BLD_CampaignMember) setField(CampaignMember.Campaign_Wave__c, wave);
    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    * @return BLD_CampaignMember 
    **/
    public BLD_CampaignMember invitationResponseAccepted() {
        return (BLD_CampaignMember) setField(CampaignMember.Invitation_Response__c, DMN_CampaignMember.INVITATION_STATUS_ACCEPTED);
    }

}