/**
 * @description Selector class for Resourcing Object
 *
 * @author Konrad Bruszewski
 * @date July 2021
 */
public with sharing class SEL_Resourcing extends fflib_SObjectSelector {

    /**
     * Returns the list of Resourcing fields
     *
     * @return List of fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Resourcing__c.Compound_Key__c,
            Resourcing__c.CreatedById,
            Resourcing__c.CreatedDate,
            Resourcing__c.Description__c,
            Resourcing__c.Id,
            Resourcing__c.Intensity_Forecast__c,
            Resourcing__c.LastModifiedById,
            Resourcing__c.LastModifiedDate,
            Resourcing__c.Month__c,
            Resourcing__c.Name,
            Resourcing__c.Opportunity__c,
            Resourcing__c.Opportunity_Type__c,
            Resourcing__c.Previous_Week_Resourcing__c,
            Resourcing__c.Resource__c,
            Resourcing__c.Resourcing_Type__c,
            Resourcing__c.Time_Spent__c,
            Resourcing__c.Week_End_Date__c,
            Resourcing__c.Week_Of_The_Year__c,
            Resourcing__c.Week_Start_Date__c
        };
    }

    /**
     * Returns SObject type
     *
     * @return SObject type
     */
    public Schema.SObjectType getSObjectType() {
        return Resourcing__c.sObjectType;
    }

    /**
     * Returns query locator for the given condition
     *
     * @param condition  String with query condition
     *
     * @return query locator
     */
    public String getQueryWithCustomCondition(String condition) {
        return newQueryFactory().setCondition(condition).toSOQL();
    }

    /**
     * Returns Resourcing records for given opportunities and week end date.
     *
     * @param oppIds - opportunities ids
     * @param weekEnd - Week_End_Date__c
     *
     * @return List of Resourcing records
     */
    public List<Resourcing__c> selectByOpportunityAndWeekEndDate(Set<Id> oppIds, Date weekEnd) {
        return (List<Resourcing__c>) Database.query(
            newQueryFactory()
                .setCondition('Opportunity__c IN :oppIds AND Week_End_Date__c = :weekEnd')
                .toSOQL()
        );
    }

    /**
     * Select resourcing by Week_End_Date__c and Resource role Ids records. Group results by Resource Id.
     *
     * @param weekEnd
     * @param roleIds
     *
     * @return List<AggregateResultWrapper>
     */
    public List<AggregateResultWrapper> selectByWeekEndDateAndRolesGroupByResource(Date weekEnd, Set<String> roleIds){
        List<AggregateResultWrapper> result = new List<SEL_Resourcing.AggregateResultWrapper>();
        
        List<AggregateResult> aggregateResults = [SELECT Resource__c FROM Resourcing__c WHERE Week_End_Date__c = :weekEnd AND Resource__r.UserRoleId IN :roleIds GROUP BY Resource__c];
        for (AggregateResult aggregateResult : aggregateResults) {
            result.add(new AggregateResultWrapper(aggregateResult.getPopulatedFieldsAsMap()));
        }
        return result;
    }

    /**
     * Select records by opportunity Ids, Resource Ids and Week End Dates
     *
     * @param oppIds
     * @param initiatives
     * @param userIds
     * @param weekEndDates
     *
     * @return List<Resourcing__c>
     */
    public List<Resourcing__c> selectByOpportunityAndInitiativeAndResourceAndWeekEndDate(Set<Id> oppIds, Set<String> resourcingSources, Set<Id> userIds, Set<Date> weekEndDates) {
        return (List<Resourcing__c>) Database.query(
            newQueryFactory()
                .setCondition('Opportunity__c IN :oppIds AND Resourcing_Type__c IN :resourcingSources AND Resource__c IN :userIds AND Week_End_Date__c IN :weekEndDates')
                .toSOQL()
        );
    }

    /**
     * @description Wrapper class for AggregateResult, to allow mocking of aggregate SOQL queries.
     */
    public class AggregateResultWrapper {
        public Map<String, Object> populatedFields;

        /**
         * Constructor
         *
         * @param populatedFields - Map of populated fields from AggregateResult
         */
        public AggregateResultWrapper(Map<String, Object> populatedFields) {
            this.populatedFields = populatedFields;
        }
    }
}