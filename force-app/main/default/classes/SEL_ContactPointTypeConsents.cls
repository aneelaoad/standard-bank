public inherited sharing class SEL_ContactPointTypeConsents  extends fflib_SObjectSelector {
	 /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public Schema.SObjectType getSObjectType(){
        return ContactPointTypeConsent.SObjectType;
    }

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
    */
    public static SEL_ContactPointTypeConsents newInstance() {
        return (SEL_ContactPointTypeConsents) ORG_Application.selector.newInstance(ContactPointTypeConsent.SObjectType);
    }
    
	
    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ContactPointTypeConsent.Id,
            ContactPointTypeConsent.Name,
            ContactPointTypeConsent.PartyId,
            ContactPointTypeConsent.ContactPointType,
            ContactPointTypeConsent.Name,
            ContactPointTypeConsent.DataUsePurposeId,
            ContactPointTypeConsent.PrivacyConsentStatus,
            ContactPointTypeConsent.EffectiveFrom,
            ContactPointTypeConsent.EffectiveTo,
            ContactPointTypeConsent.CaptureDate,
            ContactPointTypeConsent.CaptureContactPointType,
            ContactPointTypeConsent.CaptureContactPointType,
            ContactPointTypeConsent.CaptureSource,
            ContactPointTypeConsent.DoubleConsentCaptureDate,
            ContactPointTypeConsent.AccountId__c,
            ContactPointTypeConsent.UniqueKey__c,
            ContactPointTypeConsent.EngagementChannelTypeId
        };      
	}        
    /**
     * @description Returns records where name is param
     *
     * @param name - User-division field  
     * @return List of ContactPointTypeConsent records
    */   
    
    public List<ContactPointTypeConsent> selectActiveContactPointTypeConsent(Set<Id> indIds, String DIRECT_MARKETING) {      
        return (List<ContactPointTypeConsent>) Database.query(
            newQueryFactory()
                .setCondition('PartyId in :indIds AND DataUsePurpose.Name=:DIRECT_MARKETING AND ((EffectiveTo!=null AND EffectiveFrom<=TODAY AND EffectiveTo>=TODAY) OR (EffectiveTo=null AND EffectiveFrom<=TODAY)) ')       
                .toSOQL()
        );
    }
    
    /**
     * @description Returns records for consent management filtered by Individual Ids, Campaign Types and effective date range
     *
     * @param individualIds - Individual Ids 
     * @param campaingTypes - Campaing  Types
     * @return AggregateResult of ContactPointTypeConsent records
    */
    public List<AggregateResult> selectOptedOutContactPointTypeConsent(Set<Id> individualIds, Set<String> campaingTypes) {                    
       return [
           SELECT Count(Id) amount,PartyId
           FROM   ContactPointTypeConsent
           WHERE  DataUsePurpose.Name IN :campaingTypes
               AND PartyId IN :individualIds
               AND PrivacyConsentStatus ='OptOut'
           	   AND ( (EffectiveTo!= null AND EffectiveFrom <=Today AND EffectiveTo >=Today ) OR (EffectiveTo= null AND EffectiveFrom <=Today) OR (EffectiveFrom=null) )
           GROUP BY PartyId having COUNT(Id)>0
       ]; 
    }       
}