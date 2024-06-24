/**
*
* @author 		: Chandrasekhar Mokkala(chandrasekhar.mokkala@standardbank.co.za) 
* @date   		: 24 AUG 2023
* @description : SFP-28741 Insight Share Selector Layer class.
*/
public without sharing class SEL_InsightShares extends fflib_SObjectSelector{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SEL_InsightShares');
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
            Insight__Share.Id,
                Insight__Share.RowCause, 
                Insight__Share.UserOrGroupId,
                Insight__Share.ParentId
                };
                    }
    
    /**
    * @description selectById
    * @return Schema.SObjectType
    */
    public Schema.SobjectType getSObjectType(){
        return Insight__Share.SobjectType;
    }
    
    /**
    * @description getInsightSharesByInsightPersonaAsClientAndOwnerId
    * @param ownerId
    * @param personaType
    * @return List<Insight__Share>
    */
    public List<Insight__Share> getInsightSharesByInsightPersonaAndOwnerId(String ownerId,String personaType) {
        LOGGER.info('SEL_InsightShares:getInsightSharesByInsightPersonaAndOwnerId initiated');
        List<Insight__Share> insightShareRecords;
        try{
            String whereCondition = 'UserOrGroupId =:ownerId';
            if(String.isNotBlank(personaType)){
                whereCondition = whereCondition + ' AND Parent.Persona__c =:personaType'; 
            }
            else{
                whereCondition = whereCondition + ' AND Parent.Persona__c !=\'Client\'';
            }
            insightShareRecords =  (List<Insight__Share>)Database.query(
                newQueryFactory().
                setCondition(whereCondition).
                setOrdering('Parent.Optimisation_Ranking__c',fflib_QueryFactory.SortOrder.descending,true).
                toSOQL());
            LOGGER.debug('SEL_InsightShares:getInsightSharesByInsightPersonaAndOwnerId insight share count :'+insightShareRecords.size());
        }catch(QueryException ex){
            LOGGER.debug('SEL_InsightShares:getInsightSharesByInsightPersonaAndOwnerId Exception logged :'+ex.getMessage());
            throw new CustomException(ex.getMessage());
        }
        return insightShareRecords;
    }
    /**
    * @description getInsightSharesByInsightPersonaAndInsightIds
    * @param insightIds
    * @param personaType
    * @return List<Insight__Share>
    */
    public List<Insight__Share> getInsightSharesByInsightPersonaAndInsightIds(Set<String> insightIds,String personaType) {
        LOGGER.info('SEL_InsightShares:getInsightSharesByInsightPersonaAndInsightIds initiated');
        List<Insight__Share> insightShareRecords;
        try{
            String whereCondition = 'ParentId IN:insightIds';
            if(String.isNotBlank(personaType)){
                whereCondition = whereCondition + ' AND Parent.Persona__c =:personaType'; 
            }
            else{
                whereCondition = whereCondition + ' AND Parent.Persona__c !=\'Client\'';
            }
            insightShareRecords = (List<Insight__Share>)Database.query(
                newQueryFactory().
                setCondition(whereCondition).
                toSOQL());
            LOGGER.debug('SEL_InsightShares:getInsightSharesByInsightPersonaAndInsightIds insight share count :'+insightShareRecords.size());
            
        }catch(QueryException ex){
            LOGGER.debug('SEL_InsightShares:getInsightSharesByInsightPersonaAndInsightIds Exception logged :'+ex.getMessage());
            throw new CustomException(ex.getMessage());
        }
        return insightShareRecords;
    }
}