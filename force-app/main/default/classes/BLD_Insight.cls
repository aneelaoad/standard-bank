/**
* @author Chandrasekhar M (chandrasekhar.mokkala@standardbank.co.za)
* @description SFP-22526 - Test setup for Insight
* @date 18 August 2022
* @LastModified August 2023
* @author Mokkala Chandrasekhar (chandrasekhar.mokkala@standardbank.co.za)
* @UserStory SFP-28741
* @LastModifiedReason Added a method to set Persona field value 
*/
@IsTest
public without sharing class BLD_Insight extends ABS_ObjectBuilderBase {
    
    /**
    * @description BLD_Insight
    */
    public BLD_Insight() {
        this(getNewUnitOfWork());
    }
    
    /**
    * @description BLD_Insight
    * @param workUnit
    */
    public BLD_Insight(fflib_SObjectUnitOfWork workUnit) {
        super(Insight__c.SObjectType, workUnit);
    }
    /**
    * @description BLD_Insight
    * @param sObj
    * @param workUnit
    */
    public BLD_Insight(Insight__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }
    /**
    * @description category
    * @param category
    * @return BLD_Insight
    */
    public BLD_Insight category(String category) {
        return(BLD_Insight) setField(Insight__c.Category__c, category);
    }
    /**
    * @description owner
    * @param ownerId
    * @return BLD_Insight
    */
    public BLD_Insight owner(String ownerId) {
        return(BLD_Insight) setField(Insight__c.OwnerId, ownerId);
    }
    /**
    * @description snoozed
    * @param isSnoozed
    * @return BLD_Insight
    */
    public BLD_Insight snoozed(Boolean isSnoozed) {
        return (BLD_Insight) setField(Insight__c.Is_Snoozed__c, isSnoozed);
    }
    /**
    * @description eventDate
    * @param eventDate
    * @return BLD_Insight
    */
    public BLD_Insight eventDate(Date eventDate) {
        return (BLD_Insight) setField(Insight__c.Event_Date__c, eventDate);
    }
    /**
    * @description client
    * @param clientId
    * @return BLD_Insight
    */
    public BLD_Insight client(String clientId) {
        return (BLD_Insight) setField(Insight__c.Client__c, clientId);
    }
    /**
    * @description insight
    * @param insight
    * @return BLD_Insight
    */
    public BLD_Insight insight(String insight) {
        return (BLD_Insight) setField(Insight__c.Insight__c, insight);
    }
    /**
    * @description clientCoordinator
    * @param ccId
    * @return BLD_Insight
    */
    public BLD_Insight clientCoordinator(String ccId) {
        return (BLD_Insight) setField(Insight__c.Client_Coordinator__c, ccId);
    }
    /**
    * @description persona
    * @param personaVlaue
    * @return BLD_Insight
    */
    public BLD_Insight persona(String personaVlaue) {
        return (BLD_Insight) setField(Insight__c.Persona__c, personaVlaue);
    }
    /**
    * @description expiryDate
    * @param expiryDate
    * @return BLD_Insight
    */
    public BLD_Insight expiryDate(Date expiryDate) {
        return (BLD_Insight) setField(Insight__c.Expiry_Date__c, expiryDate);
    }
}