/**
 * Selector layer class for CampaignMember SObject
 *
 * @author Sergio Moradas (The Cocktail)
 * @date October 2021
 */
public inherited sharing class SEL_CampaignMember extends fflib_SObjectSelector {

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return returns instance of SEL_CampaignMember
     */
    public static SEL_CampaignMember newInstance() {
        return (SEL_CampaignMember) ORG_Application.selector.newInstance(CampaignMember.SObjectType);
    }

    /**
    * Return sObject type of current selector
    *
    * @return SEL_CampaignMember Schema.SObjectType
    */
    public SObjectType getSObjectType() {
        return CampaignMember.SObjectType;
    }

    /**
    * Return list of standard selector fields
    *
    * @return standard list of selector fields
    */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CampaignMember.Id,
            CampaignMember.CampaignId,
            CampaignMember.Campaign_Status__c,
            CampaignMember.ContactId,
            CampaignMember.Deploy_to_Marketing_Cloud_Shadow__c,
            CampaignMember.EAP_Corporate_Invitation_Sent_Shadow__c,
            CampaignMember.EAP_Investor_Invitation_Sent_Shadow__c,
            CampaignMember.EAP_Role_In_Event__c
        };
    }
    
    /**
    * Return list of CampaignMember filter by CampaignId
    *
    * @param campaignIds ids list of campaigns
    * @return List<CampaignMember> 
    */
    public List<CampaignMember> selectByCampaign(Set<Id> campaignIds) {
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
            .setCondition('CampaignId IN :campaignIds');
        return Database.query(factory.toSOQL());
    }

    /**
    * Return list of CampaignMember filter by CampaignMemberIds
    *
    * @param campaignIds ids list of campaign members
    * @return List<CampaignMember> 
    */    
    public List<CampaignMember> selectByIds(Set<Id> campaignMemberIds) {
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
            .selectFields(new Set<String> { 
                'Campaign.Type', 
                'CampaignId',
                'ContactId',
                'Contact.IndividualId',
                'Contact.AccountId'
            })
            .setCondition('Id IN :campaignMemberIds');
        return Database.query(factory.toSOQL());
    }
}