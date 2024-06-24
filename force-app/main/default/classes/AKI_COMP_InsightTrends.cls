/**
 * @description APEX Class for AKILI dashboard to display summarised Akili data.
 * 
 * @author Khakhu Ramakuela
 * @date October 2021
 */
public with sharing class AKI_COMP_InsightTrends {
    
    /**
     * @description This method retrieves the stage name and the number of opportunities for each stage
     * 
     * @param dateRange input to filter chart by date
     * 
     * @return List<AggregateResult>
     */
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getOpportunityState(Integer dateRange){
        if(dateRange==7)
        {
            return [SELECT Opportunity__r.StageName,COUNT(Name) Total FROM Insight__c WHERE Event_Date__c =LAST_N_DAYS:7 AND (Opportunity__r.StageName!=null) WITH SECURITY_ENFORCED GROUP BY Opportunity__r.StageName ];
        }
        if(dateRange==14)
        {
            return [SELECT Opportunity__r.StageName,COUNT(Name) Total FROM Insight__c WHERE Event_Date__c =LAST_N_DAYS:14 AND (Opportunity__r.StageName!=null) WITH SECURITY_ENFORCED GROUP BY Opportunity__r.StageName];
        }
        return [SELECT Opportunity__r.StageName,COUNT(Name) Total FROM Insight__c WHERE Event_Date__c =LAST_N_DAYS:30 AND (Opportunity__r.StageName!=null) WITH SECURITY_ENFORCED GROUP BY Opportunity__r.StageName];

    }

    /**
     * @description This method retrieves snoozed insights grouped by category
     * 
     * @param dateRange input to filter chart by date
     * 
     * @return List<AggregateResult>
     */
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSnoozedInsights(Integer dateRange){
        if(dateRange==7)
        {
            return [SELECT Category__c,COUNT(Name) Snoozed FROM Insight__c WHERE (Event_Date__c = LAST_N_DAYS:7) AND (Is_Snoozed__c = TRUE) AND (Category__c!=null) WITH SECURITY_ENFORCED GROUP BY Category__c];
        }
        if(dateRange==14)
        {
            return [SELECT Category__c,COUNT(Name) Snoozed FROM Insight__c WHERE (Event_Date__c = LAST_N_DAYS:14) AND (Is_Snoozed__c = TRUE) AND (Category__c!=null) WITH SECURITY_ENFORCED GROUP BY Category__c];
        }
         return [SELECT Category__c,COUNT(Name) Snoozed FROM Insight__c WHERE (Event_Date__c = LAST_N_DAYS:30) AND (Is_Snoozed__c = TRUE) AND (Category__c!=null) WITH SECURITY_ENFORCED GROUP BY Category__c];
    }

    /**
     * @description This method retrieves the number of insights per client
     * 
     * @param dateRange input to filter chart by date
     * 
     * @return List<AggregateResult>
     */
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getInsightsPerClient(Integer dateRange){
        if(dateRange==7)
        {
            return [SELECT Client__r.Name,COUNT(Name) InsightPerClient FROM Insight__c WHERE (Event_Date__c = LAST_N_DAYS:7) AND (Client__r.Name != null) WITH SECURITY_ENFORCED GROUP BY Client__r.Name ORDER BY COUNT(NAME) DESC LIMIT 5];
        }
        else if(dateRange==14)
        {
            return [SELECT Client__r.Name,COUNT(Name) InsightPerClient FROM Insight__c WHERE (Event_Date__c = LAST_N_DAYS:14) AND (Client__r.Name != null) WITH SECURITY_ENFORCED GROUP BY Client__r.Name ORDER BY COUNT(NAME) DESC LIMIT 5];
        }
        return [SELECT Client__r.Name,COUNT(Name) InsightPerClient FROM Insight__c WHERE (Event_Date__c = LAST_N_DAYS:30) AND (Client__r.Name != null) WITH SECURITY_ENFORCED GROUP BY Client__r.Name ORDER BY COUNT(NAME) DESC LIMIT 5];
    }

    /**
     * @description This method retrieves the number of insights grouped by category
     * 
     * @return List<AggregateResult>
     */
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getValuableInsights(){//no date value
        return [SELECT Status__c,COUNT(Id) id,COUNT(Name) CountValue FROM Insight__c  WHERE Status__c != null GROUP BY Status__c];
    }
    
}