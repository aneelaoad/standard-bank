/**
 * Builder class for Campaign_Member_Host__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_CampaignMemberHost extends ABS_ObjectBuilderBase {

    private static final String DEF_WAVE = '1';

    public BLD_CampaignMemberHost(fflib_SObjectUnitOfWork uow) {
        super(Campaign_Member_Host__c.SObjectType, uow);
    }

    protected override void setDefaultData() {
        setField(Campaign_Member_Host__c.Campaign_Wave__c, DEF_WAVE);
    }

    public BLD_CampaignMemberHost campaign(BLD_Campaign campaignBuilder) {
        return (BLD_CampaignMemberHost) setRelation(Campaign_Member_Host__c.Campaign__c, campaignBuilder);
    }

    public BLD_CampaignMemberHost member(BLD_Contact contactBuilder) {
        return (BLD_CampaignMemberHost) setRelation(Campaign_Member_Host__c.Member__c, contactBuilder);
    }

    public BLD_CampaignMemberHost addHost(BLD_CampaignHost campHostBld) {
        return (BLD_CampaignMemberHost) addChild(Campaign_Hosts__c.Campaign_Member_Host__c, campHostBld);
    }

}