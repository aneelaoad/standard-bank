/**
 * Selector layer class for Campaign_Hosts__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date June 2020
 */
public inherited sharing class SEL_CampaignHosts extends fflib_SObjectSelector {

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_CampaignHosts newInstance() {
        return (SEL_CampaignHosts) ORG_Application.selector.newInstance(Campaign_Hosts__c.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     */
    public SObjectType getSObjectType() {
        return Campaign_Hosts__c.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            	Campaign_Hosts__c.Bank_Contact__c,
                Campaign_Hosts__c.Campaign_Member_Host__c 
        };
    }

    public List<Campaign_Hosts__c> selectByBankContact(Set<Id> contactIds) {
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
            .setCondition('Bank_Contact__c IN :contactIds');
        return Database.query(factory.toSOQL());
    }

    /**
    * @description 
    * @author Vipeen | 15-08-2023
    * @param Member IDS  
    * @return List<Campaign_Hosts__c> 
    **/
    public List<Campaign_Hosts__c> getMemhostList(Set<Id> memIds) {
         fflib_QueryFactory factory = newQueryFactory(false, false, true)
        .selectField('Bank_Contact__r.FirstName')
        .selectField('Bank_Contact__r.LastName')
        .selectField('Bank_Contact__r.Email')
        .selectField('Bank_Contact__r.User_Division_Sync__c')
        .selectField('Bank_Contact__r.User_Business_Unit_Sync__c')
        .selectField('Bank_Contact__c')
        .selectField('Bank_Contact__r.Name')
        .selectField('Campaign_Member_Host__c')
        .setCondition('Campaign_Member_Host__c IN : memIds')
        .addOrdering('Campaign_Member_Host__c', fflib_QueryFactory.SortOrder.ASCENDING);

        return Database.query(factory.toSOQL());

    }

}