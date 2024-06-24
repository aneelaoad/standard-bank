/**
*
* @author vipeen Sarode
* @date 08 OCT 2021
* @description Insight Selector Layer class.
*
* ModifiedBy       			ModifiedDate   	Story Number    Description
* Chandrasekhar Mokkala		2nd June 2023	SFP-22526		Smart Nudge: Add Optimisation rank field
* Chandrasekhar Mokkala		23 Aug 2023	    SFP-28741		SmartNudge External Pilot 1a
*/
public with sharing class SEL_Insights extends fflib_SObjectSelector {

    /**
    * @description getSObjectFieldList
    * @return List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            	Insight__c.Id,
                Insight__c.Name, 
                Insight__c.Lead_Date__c,
                Insight__c.Expiry_Date__c, 
                Insight__c.Category__c, 
                Insight__c.External_Lead_ID__c, 
                Insight__c.Sub_Category__c, 
                Insight__c.Comment__c, 
                Insight__c.Event_Date__c, 
                Insight__c.Potential_Insight_Revenue__c, 
                Insight__c.Is_Snoozed__c, 
                Insight__c.Is_Expired__c, 
                Insight__c.Expiring_Soon__c, 
                Insight__c.Next_Steps__c, 
                Insight__c.Insight__c,  
                Insight__c.Client__c, 
                Insight__c.owner.id,
                Insight__c.Client_Coordinator__c,
                Insight__c.Is_Provided_Feedback__c,
                Insight__c.OwnerId,
                Insight__c.Client_Analyst__c,
                Insight__c.CreatedDate,
                Insight__c.Status__c,
                Insight__c.Optimisation_Ranking__c,
                Insight__c.Persona__c    
                };
    }
    
    /**
    * @description selectById
    * @return Schema.SObjectType
    */
    public Schema.SobjectType getSObjectType(){
        return Insight__c.SobjectType;
    }
    
    /**
    * @description getInsightsByIds
    * @param ids set of ids
    * @return List<Insight__c>
    */
    public List<Insight__c> getInsightsByIds(Set<String> ids) {
        return (List<Insight__c>) Database.query(
            newQueryFactory().
            selectField('Client__r.Name').
            selectField('Client__r.Client_Sector__c').
            selectField('Client__r.Description').
            selectField('owner.name').
            selectField('Client_Coordinator__r.name').
            setCondition('Id in :ids').
            toSOQL());
    }
        
    /**
    * @description getInsightsWithDescendingOrder
    * @param cstTeamMemberId
    * @param insightIds
    * @return List<Insight__c>
    */
    public List<Insight__c> getInsightsWithDescendingOrder( Id cstTeamMemberId, Set<Id> insightIds) {
        String whereCondition = 'Persona__c !=\'Client\' AND Event_Date__c = LAST_N_DAYS:90 AND Opportunity__c = null AND Is_Expired__c=false AND Is_Snoozed__c = false AND Is_Provided_Feedback__c=false AND (';
        whereCondition = whereCondition + 'OwnerId =:cstTeamMemberId OR Id IN : insightIds';
        whereCondition = whereCondition + ')';
        
        return (List<Insight__c>) Database.query(
            newQueryFactory().
            selectField('Client__r.Name').
            selectField('Client__r.Description').
            selectField('Client__r.Actual_CY_Revenue__c').
            setCondition(whereCondition).setOrdering('Client__r.Actual_CY_Revenue__c', fflib_QueryFactory.SortOrder.descending).
            toSOQL());
    }
    
    /**
    * @description getInsightsOrderByOptimizationRank
    * @param ownerId
    * @param insightIds
    * @param limitCount
    * @return List<Insight__c>
    */
    public List<Insight__c> getInsightsOrderByOptimizationRank( Id ownerId, Set<Id> insightIds,Integer limitCount) {
        String whereCondition = 'Persona__c =\'Client\' AND Event_Date__c = LAST_N_DAYS:90 AND Opportunity__c = null AND Is_Expired__c=false AND Is_Snoozed__c = false AND Is_Provided_Feedback__c=false AND (';
        if(ownerId != null){
        	whereCondition = whereCondition + 'OwnerId =:ownerId OR Id IN : insightIds';
        }
        else{
        	whereCondition = whereCondition + 'Id IN : insightIds';
        }
        whereCondition = whereCondition + ')';
        
        return (List<Insight__c>) Database.query(
            newQueryFactory().
            selectField('Client__r.Name').
            selectField('Client__r.Description').
            selectField('Client__r.Actual_CY_Revenue__c').
            setCondition(whereCondition).
            setOrdering(Insight__c.Optimisation_Ranking__c,fflib_QueryFactory.SortOrder.descending,true).
            setLimit(limitCount).
            toSOQL());
    }
    
    /**
    * @description  selectInsightsBySearchKey
    * @param searchKey
    * @param category
    * @param subcategory
    * @param client
    * @param myInsightsSelected
    * @param expiringSoonSelected
    * @param snoozedInsightsSelected
    * @return List<Insight__c>
    */
    public List<Insight__c> selectInsightsBySearchKey(String searchKey,String category,String subcategory,String client,Boolean myInsightsSelected,Boolean expiringSoonSelected,Boolean snoozedInsightsSelected) {
        String key;
        String condition = '';
        Id currentUserId = userInfo.getUserId();
        condition+= 'Opportunity__c = null';
        condition+= ' AND Status__c != \'Rejected\' AND Is_Expired__c=false';
        
        if (String.isNotBlank(searchKey)) {
            key = '%' + searchKey + '%';
            condition += ' AND (Category__c LIKE :key OR Client__r.name LIKE :key OR Sub_Category__c LIKE : key)';
        }
        if (String.isNotBlank(category) ) {
            condition += ' AND Category__c =: category';
        }
        if (String.isNotBlank(subcategory) ) {
            condition += ' AND Sub_Category__c =: subcategory';
        }
        if (String.isNotBlank(client) ) {
            condition += ' AND Client__c =: client';
        }
        //add custome filter button action to condition
        if(myInsightsSelected){
            Set<String> isnightIds = new Set<String>();
            for(Insight__Share sharedRecord :  [Select ParentId from Insight__Share Where userOrGroupId =: currentUserId]){
                isnightIds.add(sharedRecord.ParentId);
            }
            condition+= ' AND Is_Snoozed__c = false AND(Client_Coordinator__c = :currentUserId OR OwnerId =:currentUserId OR Id IN : isnightIds)';
        }
        if(expiringSoonSelected){
            condition+= ' AND (Client_Coordinator__c = :currentUserId OR OwnerId =:currentUserId) AND (Expiry_Date__c = NEXT_N_Days:7 OR Expiry_Date__c =TODAY)';
        }
        if(snoozedInsightsSelected){
            condition+= ' AND Is_Snoozed__c = true AND Is_Provided_Feedback__c=false  AND (Client_Coordinator__c = :currentUserId OR OwnerId =:currentUserId)';
        }
                
        fflib_QueryFactory insightQueryFactory = newQueryFactory();
        insightQueryFactory.selectField('Client__r.Name').
            selectField('Client__r.Client_Sector__c').
            selectField('Client__r.Description').
            selectField('owner.name').
            selectField('Client_Coordinator__r.name').
            setCondition(condition).
            setOrdering(Insight__c.Expiry_Date__c,fflib_QueryFactory.SortOrder.ascending).
            setOrdering(Insight__c.Optimisation_Ranking__c,fflib_QueryFactory.SortOrder.descending,true);
        
        insightQueryFactory.subselectQuery('Insight_Actions__r').setCondition('Action_Type__c =\'Rating\'').selectField('Insight_Status__c');
        
        List<Insight__c> insightList = Database.query(insightQueryFactory.toSOQL());   
        
        return insightList;
        
    }
    
    /**
    * @description selectAcitveInsightsByDateAndPersona
    * @param numberOfDays
    * @param personaType
    * @param limitCount
    * @return List<Insight__c>
    */
    public List<Insight__c> selectAcitveInsightsByDateAndPersona(Integer numberOfDays, String personaType,Integer limitCount){
        String whereCondition = 'Event_Date__c = LAST_N_DAYS:'+numberOfDays+' AND Opportunity__c = null AND Is_Expired__c=false AND Is_Snoozed__c = false AND Is_Provided_Feedback__c=false';
        if(String.isNotBlank(personaType)){
            whereCondition = whereCondition + ' AND Persona__c =: personaType';
        }
        else{
            whereCondition = whereCondition + ' AND Persona__c !=\'Client\'';
        }
        return (List<Insight__c>) Database.query(
            newQueryFactory().selectField('Client__r.Name').
            selectField('Client__r.Actual_CY_Revenue__c').
            selectField('Client__r.Description').
            setCondition(whereCondition).setLimit(limitCount).
            toSOQL()
        );
    }
    
    /**
    * @description Select without conditions
    * @return List<Insight__c>
    */
    public List<Insight__c> selectWithoutCondition() {
        return (List<Insight__c>) Database.query(
            newQueryFactory().toSOQL()
        );
    }
    
}