/**
 * Selector layer class for Campaign_Member_Host__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date June 2020
 */
public inherited sharing class SEL_CampaignMemberHosts extends fflib_SObjectSelector {

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_CampaignMemberHosts newInstance() {
        return (SEL_CampaignMemberHosts) ORG_Application.selector.newInstance(Campaign_Member_Host__c.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     */
    public SObjectType getSObjectType() {
        return Campaign_Member_Host__c.SObjectType;
    }

    /**
    * @description Returns list of SObjectField
    * @return list of SObjectField
    */

    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Campaign_Member_Host__c.Id,
            Campaign_Member_Host__c.Attendance_Status__c,
            Campaign_Member_Host__c.Campaign_Wave__c,
            Campaign_Member_Host__c.Member_Id__c,
            Campaign_Member_Host__c.Member_Status__c,
            Campaign_Member_Host__c.Campaign__c,
            Campaign_Member_Host__c.Member__c
        };
    }

    /**
    * @description Returns list of Campaign_Member_Host__c
    * @param Set<Id> memberIds
    * @return list of Campaign_Member_Host__c
    */
    public List<Campaign_Member_Host__c> selectByMember(Set<Id> memberIds) {
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
            .setCondition('Member__c IN :memberIds');
        return Database.query(factory.toSOQL());
    }
    
    /**
    * @description Returns list of MemberWithMemberHost
    * @param Set<Id> memberIds
    * @return list of MemberWithMemberHost
    */
    public List<Campaign_Member_Host__c> selectByMemberWithMemberHost(Set<Id> memberIds) {
        fflib_QueryFactory factory = newQueryFactory()
            .selectField('Id')
            .selectField('Campaign__c')
            .selectField('Member__c')
            .setCondition('Id IN :memberIds');
        fflib_QueryFactory campHostFactory = factory.subSelectQuery('Campaign_Hosts__r')
             .selectField('Id')
             .selectField('Bank_Contact__c')
             .selectField('Host_Id__c')
             .selectField('Campaign_Member_Host__c');
        return Database.query(factory.toSOQL());
    }

     /**
    * @description Returns list of Campaign_Member_Host__c
    * @param list<string> members,String currentId
    * @return list of Campaign_Member_Host__c
    */
    public List<Campaign_Member_Host__c> selectByIdandCampaignId(List<String> members, String currentId, Integer limitSize) {
        fflib_QueryFactory factory = newQueryFactory()
        .selectField('Member__r.Account.Actual_CY_Revenue__c')
        .selectField('Member__r.Account.Client_Sector__c')
        .selectField('Member__r.Account.Account_Owner__c')
        .selectField('Member__r.Account.owner.Email')
        .selectField('Member__r.Account.OwnerId')
        .selectField('Member__r.CIF_Number__c')
        .selectField('Member__r.Account.CIB_Target_Client__c')
        .selectField('Member__r.Client_Group_Parent__c')
        .selectField('Member__r.Group_Parent_CIF_Number__c')
        .selectField('Member__r.Shirt_Size__c')
        .selectField('Member__r.Religion__c')
        .selectField('Member__r.sa_Preferred_Language__c')
        .selectField('Member__r.Phone')
        .selectField('Member__r.Number_of_Children__c')
        .selectField('Member__r.MobilePhone')
        .selectField('Member__r.Golf_Handicap__c')
        .selectField('Member__r.FAIS_Representative__c')
        .selectField('Member__r.Disabilities__c')
        .selectField('Member__r.Dietary_Requirements__c')
        .selectField('Member__r.Contact_Category__c')
        .selectField('Member__r.Allergies__c')
        .selectField('Member__r.Name')
        .selectField('Member__r.FirstName')
        .selectField('Member__r.LastName')
        .selectField('Member__r.Email')
        .selectField('Member__r.Account.Name')
        .selectField('Member__r.Title')
        .selectField('Member__r.User_Division_Sync__c')
        .selectField('Member__r.User_Business_Unit_Sync__c')
        .setCondition('Id IN :members AND Campaign__c = :currentId')
        .addOrdering('Member__r.Name', fflib_QueryFactory.SortOrder.ASCENDING)
        .setLimit(limitSize);

        return Database.query(factory.toSOQL());
    }

}