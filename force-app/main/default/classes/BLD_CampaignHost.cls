/**
 * Builder class for Campaign_Hosts__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_CampaignHost extends ABS_ObjectBuilderBase {

    public BLD_CampaignHost(fflib_SObjectUnitOfWork uow) {
        super(Campaign_Hosts__c.SObjectType, uow);
    }

    public BLD_CampaignHost bankContact(BLD_Contact contactBuilder) {
        return (BLD_CampaignHost) setRelation(Campaign_Hosts__c.Bank_Contact__c, contactBuilder);
    }

    public BLD_CampaignHost memberHost(BLD_CampaignMemberHost memberHostBuilder) {
        return (BLD_CampaignHost) setRelation(Campaign_Hosts__c.Campaign_Member_Host__c, memberHostBuilder);
    }

    public BLD_CampaignHost memberHostId(Id campaignMemberHostId) {
        return (BLD_CampaignHost) setField(Campaign_Hosts__c.Campaign_Member_Host__c, campaignMemberHostId);
    }

}