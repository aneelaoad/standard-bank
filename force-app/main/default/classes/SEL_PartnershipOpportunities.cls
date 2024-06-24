/**
* Selector class for PP_PartnerOpportunities__c SObject
* User Story : SFP-4879
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
public inherited sharing class SEL_PartnershipOpportunities extends fflib_SObjectSelector {
    
    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     * @return SEL_PartnershipOpportunities class instance
     */ 
	public static SEL_PartnershipOpportunities newInstance() {
        return (SEL_PartnershipOpportunities) ORG_Application.selector.newInstance(PP_PartnershipOpportunity__c.SObjectType);
    }
    
     /**
     * Returns the SObject fields on this sObject
     * @return PP_PartnershipOpportunity__c  fields list
     */
	public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                PP_PartnershipOpportunity__c.Id,
                PP_PartnershipOpportunity__c.Name,
			    PP_PartnershipOpportunity__c.PP_Content__c, 
                PP_PartnershipOpportunity__c.PP_Status__c,
                PP_PartnershipOpportunity__c.PP_Country__c,
                PP_PartnershipOpportunity__c.PP_Industry__c,
                PP_PartnershipOpportunity__c.PP_PublishStartDate__c,
                PP_PartnershipOpportunity__c.PP_PublishEndDate__c,
                PP_PartnershipOpportunity__c.PP_Summary__c,
                PP_PartnershipOpportunity__c.PP_Featured__c,
                PP_PartnershipOpportunity__c.PP_Image__c,    
                PP_PartnershipOpportunity__c.LastModifiedDate
        };
    }
    
    
    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     * @return PP_PartnershipOpportunity__c  object type
     */
    public Schema.SObjectType getSObjectType() {
        return PP_PartnershipOpportunity__c.SObjectType;
    }
    
     /**
     * Select PP_PartnershipOpportunity__c filtered by Featured and recordTypeIds
     * 
     * @param recordTypeIds
     * @return PP_PartnershipOpportunity__c 
     */
    public PP_PartnershipOpportunity__c getSingleFeaturedPartnershipOpportunity() {
        String status = DMN_PartnershipOpportunities.STATUS_APPROVED;
        return (PP_PartnershipOpportunity__c) Database.query(
             newQueryFactory(false, false, true)
            .setCondition('PP_Featured__c = true AND PP_Status__c =: status AND PP_PublishEndDate__c  >= Today')
            .removeOrderings()
            .addOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1)
            .toSOQL()
        );
    }
    
    /**
     * Select PP_PartnershipOpportunity__c Pulished Partnership Opportunities
     *
     * @param recordTypeIds record type ids
     * @return List<PP_PartnershipOpportunity__c>
     */
    public List<PP_PartnershipOpportunity__c> getPublishedPartnershipOpportunity() {
        String status = DMN_PartnershipOpportunities.STATUS_APPROVED;
        return (List<PP_PartnershipOpportunity__c>) Database.query(
             newQueryFactory(false, false, true)
            .setCondition('PP_Status__c =: status AND PP_PublishEndDate__c  >= Today')
            .removeOrderings()
            .addOrdering('PP_PublishStartDate__c', fflib_QueryFactory.SortOrder.DESCENDING)
            .toSOQL()
        );
    }
    
    

}