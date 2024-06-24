/**
* Created by Tinashe M Shoko @khonology on 13/07/2018.
* US-3054
*
* 	@Last Modified By   : Dzianisik Maksim
*	@Last Modified on   : Sep. 2021
*	@description        : SFP-6290 Updated for working with Insurance ERS
*/

public with sharing class EstimatedRevenueScheduleController {
    
    // method for fetching Estimated revenue schedule records list for a given Product
    /**
     * @param recordId Id
     * @param limitRecs Integer
     * @description unknown
     * @return List<Estimated_Revenue_Schedule__c>
     */
    @AuraEnabled
    public static List<Estimated_Revenue_Schedule__c> fetchLimitedSchedule(Id recordId, Integer limitRecs)
    {
        return [
                SELECT Id, Name, Fee_Amount__c, Estimated_Revenue_Date__c, Product__c, Risk_Weighted_Value__c,
                        Show_Estimated_Revenue_Schedule__c, CurrencyIsoCode, Updated_by_LEX__c, Commission_Amount__c,
                        RecordType.DeveloperName
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :recordId
                ORDER BY Estimated_Revenue_Date__c
                LIMIT 3
        ];
    }
    
    // method for fetching Estimated revenue schedule records list for a given Product
    /**
     * @param recordId Id
     * @description unknown
     * @return List<Estimated_Revenue_Schedule__c>
     */
    @AuraEnabled
    public static List<Estimated_Revenue_Schedule__c> fetchSchedule(id recordId)
    {
        List < Estimated_Revenue_Schedule__c > returnList = new List < Estimated_Revenue_Schedule__c > ();
        List < Estimated_Revenue_Schedule__c > lstOfSchedule = [
                SELECT Id, Name, Fee_Amount__c, Estimated_Revenue_Date__c, Product__c, Risk_Weighted_Value__c,
                        Show_Estimated_Revenue_Schedule__c, CurrencyIsoCode, Updated_by_LEX__c,
                        RecordType.DeveloperName, Margin_Amount__c, Estimated_Product_Revenue__c,
                        Commission_Amount__c, Estimated_Revenue__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :recordId
                ORDER BY Estimated_Revenue_Date__c
        ];
        for (Estimated_Revenue_Schedule__c sch : lstOfSchedule) {
            returnList.add(sch);
        }
        
        return returnList;
    }
    
    //Get count of the Estimated revenue Schedule  records
    /**
     * @param recordId Id
     * @description unknown
     * @return Integer
     */
    @AuraEnabled
    public static Integer getEstimatedRevenueScheduleCount(id recordId)
    {
        integer recCount = database.countQuery('select count() from Estimated_Revenue_Schedule__c where Product__c = :recordId');                
        return recCount;
    }
    
    //Get Current Year Revenues
    /**
     * @param recordId Id
     * @description unknown
     * @return Double
     */
    @AuraEnabled
    public static double getCurrentYearFees(id recordId)
    {
        double fees = 0;
        integer currentYear = System.today().Year();
        List < Estimated_Revenue_Schedule__c > returnList = new List < Estimated_Revenue_Schedule__c > ();
        List < Estimated_Revenue_Schedule__c > lstOfSchedule = 
            [
                select Fee_Amount__c, Estimated_Revenue_Date__c
                from Estimated_Revenue_Schedule__c
                where Product__c =: recordId 
                and CALENDAR_YEAR(Estimated_Revenue_Date__c) =: currentYear
            ];
        
        for (Estimated_Revenue_Schedule__c sch: lstOfSchedule) {
            fees = fees + sch.Fee_Amount__c;
        }
        
        return fees;
    }
    
    //Get Total Revenues
    /**
     * @param recordId Id
     * @description unknown
     * @return Double
     */
    @AuraEnabled
    public static double getTotalFees(id recordId)
    {
        double fees = 0;
        List < Estimated_Revenue_Schedule__c > returnList = new List < Estimated_Revenue_Schedule__c > ();
        List < Estimated_Revenue_Schedule__c > lstOfSchedule = 
            [
                select Fee_Amount__c, Estimated_Revenue_Date__c
                from Estimated_Revenue_Schedule__c
                where Product__c =: recordId 
            ];
        
        for (Estimated_Revenue_Schedule__c sch: lstOfSchedule) {
            fees = fees + sch.Fee_Amount__c;
        }
        
        return fees;
    }
    
    //Get Total Risk Weighted Values
    /**
     * @param recordId Id
     * @description unknown
     * @return Double
     */
    @AuraEnabled
    public static double getRiskWeightedValue(id recordId)
    {
        double fees = 0;
        List < SB_Product__c > returnList = new List < SB_Product__c > ();
        List < SB_Product__c > lstOfSchedule = 
            [
                select Risk_Weighted_Value__c
                from SB_Product__c
                where Id =: recordId 
            ];
        
        for (SB_Product__c sch: lstOfSchedule) {
            fees = sch.Risk_Weighted_Value__c;
        }
        
        return fees;
    }
    
    //Get Product URL for crumbs
    /**
     * @param recordId Id
     * @description unknown
     * @return String
     */
    @AuraEnabled
    public static String getProductURL(id recordId)
    {
        String pURL;
        List < SB_Product__c > returnList = new List < SB_Product__c > ();
        List < SB_Product__c > lstOfSchedule = 
            [
                select Show_SB_Product__c
                from SB_Product__c
                where id =: recordId 
            ];
        
        for (SB_Product__c sch: lstOfSchedule) {
            returnList.add(sch);
            pURL = sch.Show_SB_Product__c;
        }
        
        return pURL;
    }
    
    //Get Product Name for crumbs
    /**
     * @param recordId Id
     * @description unknown
     * @return String
     */
    @AuraEnabled
    public static String getProductName(id recordId)
    {
        String pURL;
        List < SB_Product__c > returnList = new List < SB_Product__c > ();
        List < SB_Product__c > lstOfSchedule = 
            [
                select Name
                from SB_Product__c
                where id =: recordId 
            ];
        
        for (SB_Product__c sch: lstOfSchedule) {
            returnList.add(sch);
            pURL = sch.Name;
        }
        
        return pURL;
    }

    /**
     * @param recordId Id
     * @description return the Product information for Aura component
     * @return SB_Product__c
     */
    @AuraEnabled
    public static SB_Product__c getProduct(Id recordId) {
        return [
                SELECT
                        Name, Current_Year_Fees__c, Current_Year_Margin__c,
                        Current_Year_Product_Revenue_Text__c, Total_Fees__c,
                        Total_Margin__c, Total_Product_Revenue_Text__c,
                        CurrencyIsoCode, Current_Year_Commission__c, Total_Commission__c,
                        Insurance_Total_Revenue_Amount__c, Insurance_Current_Year_Revenue__c
                FROM SB_Product__c
                WHERE Id = :recordId
        ];
    }

    // method for update records after inline editing
    /**
     * @param lstSchedule List<Estimated_Revenue_Schedule__c>
     * @description unknown
     * @return List <Estimated_Revenue_Schedule__c>
     */
    @AuraEnabled
    public static List <Estimated_Revenue_Schedule__c> saveSchedule(List<Estimated_Revenue_Schedule__c> lstSchedule) {
        //EstRevSch_Updated__c
        for (Estimated_Revenue_Schedule__c sch: lstSchedule) {
            SB_Product__c sb_rec = [SELECT Risk_Weighted_Value__c FROM SB_Product__c WHERE id = :sch.Product__c limit 1];
            sch.Risk_Weighted_Value__c = (sch.Fee_Amount__c * sb_rec.Risk_Weighted_Value__c)/100;
            sch.Updated_by_LEX__c = true;
        }
        update lstSchedule;
        return lstSchedule;
    }
    
    // method for update records after inline editing - Est Rev Sched checkbox
    /**
     * @param recordId Id
     * @description unknown
     */
    @AuraEnabled
    public static void updateSchedule(id recordId) {
        //EstRevSch_Updated__c
        try {
            SB_Product__c sb_rec = [SELECT id, Current_Year_Fees__c,total_fees__c, EstRevSch_Updated__c FROM SB_Product__c WHERE id = :recordId limit 1];
            sb_rec.Total_Fees__c = getTotalFees(recordId);
            sb_rec.Current_Year_Fees__c = getCurrentYearFees(recordId);
            sb_rec.EstRevSch_Updated__c=true;
            update sb_rec;
        } catch(Exception e) {
            System.debug('An exception occured in updating EstRevSch_Updated__c');
        }
        return;
    }
    
    // method for fetch picklist values dynamic  
    //    @AuraEnabled
    //  public static List < String > getselectOptions(sObject objObject, string fld) {
    //    system.debug('objObject --->' + objObject);
    //  system.debug('fld --->' + fld);
    //List < String > allOpts = new list < String > ();
    // Get the object type of the SObject.
    //Schema.sObjectType objType = objObject.getSObjectType();
    
    // Describe the SObject using its object type.
    //Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    
    // Get a map of fields for the SObject
    //map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
    
    // Get the list of picklist values for this field.
    //list < Schema.PicklistEntry > values =
    //  fieldMap.get(fld).getDescribe().getPickListValues();
    
    // Add these values to the selectoption list.
    //for (Schema.PicklistEntry a: values) {
    //  allOpts.add(a.getValue());
    // }
    //system.debug('allOpts ---->' + allOpts);
    //allOpts.sort();
    //  return allOpts;
    //}
}