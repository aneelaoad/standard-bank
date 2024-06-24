/**
* @author Chandrasekhar M (chandrasekhar.mokkala@standardbank.co.za)
* @description SFP-28741 - Test setup for Insight Client Relationship
* @date 18 August 2022
***/
@IsTest
public with sharing class BLD_InsightClientRelationship extends ABS_ObjectBuilderBase{
	/**
    * @description BLD_InsightClientRelationship
    */
    public BLD_InsightClientRelationship() {
        this(getNewUnitOfWork());
    }
    
    /**
    * @description BLD_InsightClientRelationship
    * @param workUnit
    */
    public BLD_InsightClientRelationship(fflib_SObjectUnitOfWork workUnit) {
        super(Insight_Client_Relationship__c.SObjectType, workUnit);
    }
    /**
    * @description BLD_InsightClientRelationship
    * @param sObj
    * @param workUnit
    */
    public BLD_InsightClientRelationship(Insight_Client_Relationship__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }
    /**
    * @description client
    * @param contactId
    * @return BLD_InsightClientRelationship
    */
    public BLD_InsightClientRelationship setContact(String contactId) {
        return(BLD_InsightClientRelationship) setField(Insight_Client_Relationship__c.Contact__c, contactId);
    }
    /**
    * @description insight
    * @param insightId
    * @return BLD_InsightClientRelationship
    */
    public BLD_InsightClientRelationship setInsight(String insightId) {
        return(BLD_InsightClientRelationship) setField(Insight_Client_Relationship__c.Insight__c, insightId);
    }
}