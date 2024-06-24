/********************************************
* @author  		: Chandrasekhar Mokkala(chandrasekhar.mokkala@standardbank.co.za)
* @date    		: 25 SEPT 2023
* @description 	: SFP-28741 - Selector layer for the object Insight_Client_Relationship__c
**/
public with sharing class SEL_InsightClientRelationships extends fflib_SObjectSelector{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SEL_InsightClientRelationships');
	/**
    * @description CustomException
    */
    private class CustomException extends Exception {}

    /**
    * @description getSObjectFieldList
    * @return List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            	Insight_Client_Relationship__c.Id,
                Insight_Client_Relationship__c.Name, 
                Insight_Client_Relationship__c.Contact__c,
                Insight_Client_Relationship__c.Insight__c, 
                Insight_Client_Relationship__c.owner.id
                };
    }
    
    /**
    * @description selectById
    * @return Schema.SObjectType
    */
    public Schema.SobjectType getSObjectType(){
        return Insight_Client_Relationship__c.SobjectType;
    }
    
    /**
    * @description selectActiveInsightClientRelationships
    * @param contactIds 
    * @param numberOfDays
    * @param limitCount
    * @return List<Insight_Client_Relationship__c>
    */
    public List<Insight_Client_Relationship__c> selectActiveInsightClientRelationships(Set<Id> contactIds,Integer numberOfDays, Integer limitCount) {
        String whereCondition = 'Insight__r.Persona__c = \'Client\' AND Insight__r.Event_Date__c = LAST_N_DAYS:'+numberOfDays+' AND Insight__r.Opportunity__c = null AND Insight__r.Is_Expired__c=false AND Insight__r.Is_Snoozed__c = false AND Insight__r.Is_Provided_Feedback__c=false';
        if(!contactIds.isEmpty()){
            whereCondition = whereCondition + ' AND Contact__c IN : contactIds';
        }
        return (List<Insight_Client_Relationship__c>) Database.query(
            newQueryFactory().setCondition(whereCondition).setLimit(limitCount).toSOQL());
    }
}