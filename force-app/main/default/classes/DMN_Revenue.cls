/**
 * Campaign SObject Domain Class
 *
 * @author		Michal Pesko (mpesko@deloittece.com)
 * @date		October 2021
 *
* MODIFICATION LOG
* Version         	Developer         	 Date               	Description
*-------------------------------------------------------------------------------------------
*  1.0              Michal Pesko      	20 October 2021          Initial Creation  
*  2.0				Vipeen Sarode		10 March 2021			Bulkified the code, removed the selector class
																Instance from loops, corrected methods
*******************************************************************************************/
public with sharing class DMN_Revenue {

    /**
     * @description Calculating all revenues for Global Client Revenue
     * @param newRevenues - List of changed revenues
     */
     public static void calculateRevenuesAndBalances(List<FinServ__Revenue__c> newRevenues) {
        Set<Id> crtClientRevenueIds = New Set<Id>();
        
        for (FinServ__Revenue__c revenue : newRevenues) {
            if (revenue.CRT_ClientRevenue__c != null) {
                crtClientRevenueIds.add(revenue.CRT_ClientRevenue__c);
            }
        }
        
        Map<Id,Global_Client_Revenue__c> globalClientRevenueMap = getGlobalClientById(crtClientRevenueIds);
        Map<Id,List<FinServ__Revenue__c>> revenuesForGlobalClientCurrYear = getRevenuesByGlobalClientForCurrentYear(crtClientRevenueIds);
        Map<Id,List<FinServ__Revenue__c>> revenuesForClientForPastYear = getRevenuesByGlobalClientForPastYear(crtClientRevenueIds);
        
        for(FinServ__Revenue__c revenue : newRevenues){
            if (revenue.CRT_ClientRevenue__c != null) {
                if(revenuesForClientForPastYear.get(revenue.CRT_ClientRevenue__c) != null){
                    Global_Client_Revenue__c globalClientRevenueRec = calculateClientRevenueBalancesForPastYear(globalClientRevenueMap.get(revenue.CRT_ClientRevenue__c), revenuesForClientForPastYear.get(revenue.CRT_ClientRevenue__c));
                    globalClientRevenueMap.put(globalClientRevenueRec.Id, globalClientRevenueRec);
                } 
                if(revenuesForGlobalClientCurrYear.get(revenue.CRT_ClientRevenue__c) != null){
                    Global_Client_Revenue__c globalClientRevenueRec =  calculateClientRevenueBalances(globalClientRevenueMap.get(revenue.CRT_ClientRevenue__c), revenuesForGlobalClientCurrYear.get(revenue.CRT_ClientRevenue__c));
                    globalClientRevenueMap.put(globalClientRevenueRec.Id, globalClientRevenueRec);
                }
            }
        }
                
        if(!globalClientRevenueMap.isEmpty()){
            update globalClientRevenueMap.values();
        }                
    }
    
    /**
     * @description Calculating all revenues for Global Client Revenue
     * @param newRevenues - List of changed revenues
     */
    private static Global_Client_Revenue__c calculateClientRevenueBalances(Global_Client_Revenue__c clientRevenue, List<FinServ__Revenue__c> revenues) {
        clientRevenue.CRT_ActualRevenueYTDZAR__c = 0;
        clientRevenue.CRT_ActualRevenueYTDLCY__c = 0;
        clientRevenue.CRT_AverageDebitBalanceYTDZAR__c = 0;
        clientRevenue.CRT_AverageDebitBalanceYTDLCY__c = 0;
        clientRevenue.CRT_AverageCreditBalanceYTDZAR__c = 0;
        clientRevenue.CRT_AverageCreditBalanceYTDLCY__c = 0;

        Double maxMonthNumberCr = 0;
        Double maxMonthNumberDr = 0;

        for (FinServ__Revenue__c revenue : revenues) {
            if(revenue.CRT_ActualRevenueLCY__c != null) {
                clientRevenue.CRT_ActualRevenueYTDLCY__c += revenue.CRT_ActualRevenueLCY__c;
            }
            if(revenue.CRT_ActualRevenueZAR__c != null) {
                clientRevenue.CRT_ActualRevenueYTDZAR__c += revenue.CRT_ActualRevenueZAR__c;
            }
            if (revenue.CRT_ProductDRCRIndicator__c == 'DR') {
                if(revenue.CRT_AverageBalanceLCY__c != null) {
                    clientRevenue.CRT_AverageDebitBalanceYTDLCY__c += revenue.CRT_AverageBalanceLCY__c;
                }
                if(revenue.CRT_AverageBalanceZAR__c != null) {
                    clientRevenue.CRT_AverageDebitBalanceYTDZAR__c += revenue.CRT_AverageBalanceZAR__c;
                }

                if(revenue.CRT_ReportingMonth__c != null && maxMonthNumberDr < revenue.CRT_ReportingMonth__c){
                    maxMonthNumberDr = revenue.CRT_ReportingMonth__c;
                }
            }
            if (revenue.CRT_ProductDRCRIndicator__c == 'CR') {
                if(revenue.CRT_AverageBalanceLCY__c != null) {
                    clientRevenue.CRT_AverageCreditBalanceYTDLCY__c += revenue.CRT_AverageBalanceLCY__c;
                }
                if(revenue.CRT_AverageBalanceZAR__c != null) {
                    clientRevenue.CRT_AverageCreditBalanceYTDZAR__c += revenue.CRT_AverageBalanceZAR__c;
                }
                if(revenue.CRT_ReportingMonth__c != null && maxMonthNumberCr < revenue.CRT_ReportingMonth__c){
                    maxMonthNumberCr = revenue.CRT_ReportingMonth__c;
                }
            }
        }
        if(maxMonthNumberDr != null && maxMonthNumberDr != 0){
            clientRevenue.CRT_AverageDebitBalanceYTDZAR__c /= maxMonthNumberDr;
            clientRevenue.CRT_AverageDebitBalanceYTDLCY__c /= maxMonthNumberDr;
        }
        if(maxMonthNumberCr != null && maxMonthNumberCr != 0){
            clientRevenue.CRT_AverageCreditBalanceYTDZAR__c /= maxMonthNumberCr;
            clientRevenue.CRT_AverageCreditBalanceYTDLCY__c /= maxMonthNumberCr;
        }
        return clientRevenue;
    }

    /**
     * @description - Changing Currency ISO code of revenue to Local Currency
     * @param revenues - List of changed revenues
     */
    public static void changeCurrencyIsoCode(List<FinServ__Revenue__c> revenues){
        Set<Id> ids = new Set<Id>();
        for(FinServ__Revenue__c revenue: revenues){
            if(revenue.CRT_LocalCurrencyLCY__c != null && revenue.CRT_LocalCurrencyLCY__c != revenue.CurrencyIsoCode) {
                ids.add(revenue.Id);
            }
        }
        List<FinServ__Revenue__c> revenuesToUpdate = [SELECT Id, CurrencyIsoCode, CRT_LocalCurrencyLCY__c FROM FinServ__Revenue__c WHERE Id IN :ids];
        List<FinServ__Revenue__c> revenuesToUpdate2 = new List<FinServ__Revenue__c>();

        for(FinServ__Revenue__c revenue: revenuesToUpdate){
            if(revenue.CRT_LocalCurrencyLCY__c != null && revenue.CRT_LocalCurrencyLCY__c != revenue.CurrencyIsoCode) {
                revenue.CurrencyIsoCode = revenue.CRT_LocalCurrencyLCY__c;
                revenuesToUpdate2.add(revenue);
            }
        }
        if(!revenuesToUpdate2.isEmpty()) {
            update revenuesToUpdate2;
        }
    }

    private static Global_Client_Revenue__c calculateClientRevenueBalancesForPastYear(Global_Client_Revenue__c clientRevenue, List<FinServ__Revenue__c> revenues) {
        clientRevenue.CRT_ActualRevenuePYLCY__c = 0;
        clientRevenue.CRT_ActualRevenuePYZAR__c = 0;
        clientRevenue.CRT_AverageCreditBalancePYLCY__c = 0;
        clientRevenue.CRT_AverageCreditBalancePYZAR__c = 0;
        clientRevenue.CRT_AverageDebitBalancePYLCY__c = 0;
        clientRevenue.CRT_AverageDebitBalancePYZAR__c = 0;

        Double maxMonthNumberCr = 0;
        Double maxMonthNumberDr = 0;
        for (FinServ__Revenue__c revenue : revenues) {           
            if(revenue.CRT_ActualRevenueLCY__c != null) {
                clientRevenue.CRT_ActualRevenuePYLCY__c += revenue.CRT_ActualRevenueLCY__c;
            }
            if(revenue.CRT_ActualRevenueZAR__c != null) {
                clientRevenue.CRT_ActualRevenuePYZAR__c += revenue.CRT_ActualRevenueZAR__c;
            }
            if (revenue.CRT_ProductDRCRIndicator__c == 'DR') {
                if(revenue.CRT_AverageBalanceLCY__c != null) {
                    clientRevenue.CRT_AverageDebitBalancePYLCY__c += revenue.CRT_AverageBalanceLCY__c;
                }
                if(revenue.CRT_AverageBalanceZAR__c != null) {
                    clientRevenue.CRT_AverageDebitBalancePYZAR__c += revenue.CRT_AverageBalanceZAR__c;
                }
                if(revenue.CRT_ReportingMonth__c != null && maxMonthNumberDr < revenue.CRT_ReportingMonth__c){
                    maxMonthNumberDr = revenue.CRT_ReportingMonth__c;
                }
            }
            if (revenue.CRT_ProductDRCRIndicator__c == 'CR') {
                if(revenue.CRT_AverageBalanceLCY__c != null) {
                    clientRevenue.CRT_AverageCreditBalancePYLCY__c += revenue.CRT_AverageBalanceLCY__c;
                }
                if(revenue.CRT_AverageBalanceZAR__c != null) {
                    clientRevenue.CRT_AverageCreditBalancePYZAR__c += revenue.CRT_AverageBalanceZAR__c;
                }

                if(revenue.CRT_ReportingMonth__c != null && maxMonthNumberCr < revenue.CRT_ReportingMonth__c){
                    maxMonthNumberCr = revenue.CRT_ReportingMonth__c;
                }
            }
        }
        if(maxMonthNumberDr != null && maxMonthNumberDr != 0) {
            clientRevenue.CRT_AverageDebitBalancePYLCY__c /= maxMonthNumberDr;
            clientRevenue.CRT_AverageDebitBalancePYZAR__c /= maxMonthNumberDr;
        }
        if(maxMonthNumberCr != null && maxMonthNumberCr != 0) {
            clientRevenue.CRT_AverageCreditBalancePYLCY__c /= maxMonthNumberCr;
            clientRevenue.CRT_AverageCreditBalancePYZAR__c /= maxMonthNumberCr;
        }

        return clientRevenue;
    }

    private static Map<Id,Global_Client_Revenue__c> getGlobalClientById(Set<Id> ids) {
        Map<Id,Global_Client_Revenue__c> gcrMap = New Map<Id,Global_Client_Revenue__c>();
        List<Global_Client_Revenue__c> gcrList = SEL_GlobalClientRevenue.newInstance().selectById(ids);
        for(Global_Client_Revenue__c gcrRec : gcrList){
            gcrMap.put(gcrRec.Id, gcrRec);
        }
        return gcrMap;
    }

    private static Map<Id,List<FinServ__Revenue__c>> getRevenuesByGlobalClientForCurrentYear(Set<Id> ids) {
        String currentYear = String.valueOf(Date.today().year());
        Map<Id,List<FinServ__Revenue__c>> currYearRevforGlobalClient = new Map<Id,List<FinServ__Revenue__c>>();
        List<FinServ__Revenue__c> revenuesForGlobalClient = SEL_Revenue.newInstance().selectByGlobalClientAndYear(ids, currentYear);
        for(FinServ__Revenue__c revRec : revenuesForGlobalClient){
            if(currYearRevforGlobalClient.containsKey(revRec.CRT_ClientRevenue__c)) {
                List<FinServ__Revenue__c> revRecList = currYearRevforGlobalClient.get(revRec.CRT_ClientRevenue__c);
                revRecList.add(revRec);
                currYearRevforGlobalClient.put(revRec.CRT_ClientRevenue__c, revRecList);
            }else{
                currYearRevforGlobalClient.put(revRec.CRT_ClientRevenue__c, new List<FinServ__Revenue__c> { revRec });
            }
        }
        
        return currYearRevforGlobalClient;
    }

    private static Map<Id,List<FinServ__Revenue__c>> getRevenuesByGlobalClientForPastYear(Set<Id> ids) {
        String pastYear = String.valueOf(Date.today().year() - 1);                
        Map<Id,List<FinServ__Revenue__c>> currYearRevforGlobalClient = new Map<Id,List<FinServ__Revenue__c>>();
        List<FinServ__Revenue__c> revenuesForGlobalClient = SEL_Revenue.newInstance().selectByGlobalClientAndYear(ids, pastYear);
        for(FinServ__Revenue__c revRec : revenuesForGlobalClient){
            if(currYearRevforGlobalClient.containsKey(revRec.CRT_ClientRevenue__c)) {
                List<FinServ__Revenue__c> revRecList = currYearRevforGlobalClient.get(revRec.CRT_ClientRevenue__c);
                revRecList.add(revRec);
                currYearRevforGlobalClient.put(revRec.CRT_ClientRevenue__c, revRecList);
            }else{
                currYearRevforGlobalClient.put(revRec.CRT_ClientRevenue__c, new List<FinServ__Revenue__c> { revRec });
            }
        }
        
        return currYearRevforGlobalClient;
    }
}