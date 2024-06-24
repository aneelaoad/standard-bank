/*****************************************************************************************************\
    @ Func Area     : Client, Client Overview, CRT Data Feed for Global Client Revenue
    @ Author        : Caro Reinecke
    @ Date          : 11/02/2013
    @ Test File     : TestClientOverview.cls
    @ Description   : Controller Class for the CAMGlobalClientRevenue component used in the Client Overview    
    
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : Mar 2013
    @ Modification Description : Enh# 119 Client overview phase 2.2 Added revenue snapshot date   
    
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 17 April 2013
    @ Modification Description : EN-0165 : The rounding of the revenue data from CRT doesn't exactly match the CRT file as 
                                           some of the numbers fall off when rounded.
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : May 2014
    @ Modification Description : CP Dashboard : Added the record type in the query
                                                Update the API version to 30

    @ Last Modified By  : Dzianisik Maksim
    @ Last Modified On  : Sep 2023
    @ Modification Description : SFP-29513 : Updated calculation for Trading_Division__c ='TPS' - added logic for 'TRANSACTION BANKING' value
******************************************************************************************************/

@SuppressWarnings('PMD.ExcessivePublicCount')
global with sharing class CAMGlobalClientRevenue_comp {
    /**
     * @description constructor
     */
    public CAMGlobalClientRevenue_comp () { 
        this.totalTPSCurrentYearUSD  = 0;
        this.totalTPSCurrentYearZAR  = 0;
        this.totalTPSPreviousYearUSD = 0;
        this.totalTPSPreviousYearZAR = 0;
        
        this.totalIBCurrentYearZAR = 0;
        this.totalIBCurrentYearUSD  = 0;
        this.totalIBPreviousYearUSD = 0;
        this.totalIBPreviousYearZAR =0;
        
        this.totalOtherCurrentYearUSD = 0;
        this.totalOtherCurrentYearZAR = 0;
        this.totalOtherPreviousYearUSD = 0;
        this.totalOtherPreviousYearZAR = 0;
        
        this.totalGMCurrentYearZAR = 0;
        this.totalGMCurrentYearUSD  = 0;
        this.totalGMPreviousYearUSD = 0;
        this.totalGMPreviousYearZAR =0;
        
         //NK
            this.actualOtherCureentYearZARVAR = 0 ;
            this.actualGMCureentYearZARVAR = 0 ;
            this.actualIBCureentYearZARVAR = 0 ;
            this.actualTPSCureentYearZARVAR = 0 ;
            
            this.actualOtherCurrentYearUSDVAR = 0 ;
            this.actualGMCurrentYearUSDVAR = 0 ;
            this.actualIBCurrentYearUSDVAR = 0 ;
            this.actualTPSCurrentYearUSDVAR = 0 ;
            
            this.actualOtherPreviousYearZARVAR = 0 ;
            this.actualGMPreviousYearZARVAR = 0 ;
            this.actualIBPreviousYearZARVAR = 0 ;
            this.actualTPSPreviousYearZARVAR = 0 ;
            
            this.actualOtherPreviousYearUSDVAR = 0 ;
            this.actualGMPreviousYearUSDVAR = 0 ;
            this.actualIBPreviousYearUSDVAR = 0 ;
            this.actualTPSPreviousYearUSDVAR = 0 ;

        
        this.totalBudgetZAR = 0;
        this.totalBudgetUSD = 0;
    }


    /**
     * @param controller
     * @description standard constructor for visualforce page
     */
    public CAMGlobalClientRevenue_comp (ApexPages.StandardController controller) { 
        this.totalTPSCurrentYearUSD  = 0;
        this.totalTPSCurrentYearZAR  = 0;
        this.totalTPSPreviousYearUSD = 0;
        this.totalTPSPreviousYearZAR = 0;
        
        this.totalIBCurrentYearZAR = 0;
        this.totalIBCurrentYearUSD  = 0;
        this.totalIBPreviousYearUSD = 0;
        this.totalIBPreviousYearZAR =0;
        
        this.totalOtherCurrentYearUSD = 0;
        this.totalOtherCurrentYearZAR = 0;
        this.totalOtherPreviousYearUSD = 0;
        this.totalOtherPreviousYearZAR = 0;
        
        this.totalGMCurrentYearZAR = 0;
        this.totalGMCurrentYearUSD  = 0;
        this.totalGMPreviousYearUSD = 0;
        this.totalGMPreviousYearZAR =0;
        
         //NK
            this.actualOtherCureentYearZARVAR = 0 ;
            this.actualGMCureentYearZARVAR = 0 ;
            this.actualIBCureentYearZARVAR = 0 ;
            this.actualTPSCureentYearZARVAR = 0 ;
            
            this.actualOtherCurrentYearUSDVAR = 0 ;
            this.actualGMCurrentYearUSDVAR = 0 ;
            this.actualIBCurrentYearUSDVAR = 0 ;
            this.actualTPSCurrentYearUSDVAR = 0 ;
            
            this.actualOtherPreviousYearZARVAR = 0 ;
            this.actualGMPreviousYearZARVAR = 0 ;
            this.actualIBPreviousYearZARVAR = 0 ;
            this.actualTPSPreviousYearZARVAR = 0 ;
            
            this.actualOtherPreviousYearUSDVAR = 0 ;
            this.actualGMPreviousYearUSDVAR = 0 ;
            this.actualIBPreviousYearUSDVAR = 0 ;
            this.actualTPSPreviousYearUSDVAR = 0 ;
            
            overviewClientId = ApexPages.currentPage().getParameters().get('id');

        
        this.totalBudgetZAR = 0;
        this.totalBudgetUSD = 0;
    }
    
    //Variables
    public String overviewClientId{get;set;}
    
    public long totalTPSPreviousYearZAR { get; set; } 
    public long totalTPSPreviousYearUSD { get; set; }
    public long totalTPSCurrentYearZAR { get; set; } 
    public long totalTPSCurrentYearUSD { get; set; } 
                      
    public long totalIBCurrentYearZAR { get; set; }
    public long totalIBCurrentYearUSD { get; set; }
    public long totalIBPreviousYearZAR { get; set; }
    public long totalIBPreviousYearUSD { get; set; }
    
    public long totalGMCurrentYearZAR { get; set; }
    public long totalGMCurrentYearUSD { get; set; }
    public long totalGMPreviousYearZAR { get; set; }
    public long totalGMPreviousYearUSD { get; set; }
    
    public long totalOtherCurrentYearZAR { get; set; }
    public long totalOtherCurrentYearUSD { get; set; }
    public long totalOtherPreviousYearZAR { get; set; }
    public long totalOtherPreviousYearUSD { get; set; }
    
    //NK
    public long actualOtherCureentYearZARVAR { get; set; } 
    public long actualGMCureentYearZARVAR { get; set; } 
    public long actualIBCureentYearZARVAR { get; set; } 
    public long actualTPSCureentYearZARVAR { get; set; } 
    
    public long actualOtherCurrentYearUSDVAR { get; set; }
    public long actualGMCurrentYearUSDVAR { get; set; }
    public long actualIBCurrentYearUSDVAR { get; set; }
    public long actualTPSCurrentYearUSDVAR { get; set; }
    
    public long actualOtherPreviousYearZARVAR { get; set; }
    public long actualGMPreviousYearZARVAR { get; set; }
    public long actualIBPreviousYearZARVAR { get; set; }
    public long actualTPSPreviousYearZARVAR { get; set; }
    
    public long actualOtherPreviousYearUSDVAR { get; set; }
    public long actualGMPreviousYearUSDVAR { get; set; }
    public long actualIBPreviousYearUSDVAR { get; set; }
    public long actualTPSPreviousYearUSDVAR { get; set; }
    
    
    public long totalCountryCurrentYearZAR { 
        get { 
            double var5 = Math.roundToLong(actualOtherCureentYearZARVAR + actualGMCureentYearZARVAR + actualIBCureentYearZARVAR + actualTPSCureentYearZARVAR); 
            return Math.roundToLong(var5/1000); }
        set;}
       public long totalCountryCurrentYearUSD { 
        get { 
               double var6 = Math.roundToLong((actualOtherCurrentYearUSDVAR + actualGMCurrentYearUSDVAR + actualIBCurrentYearUSDVAR + actualTPSCurrentYearUSDVAR));
               return Math.roundToLong(var6/1000); }
        set;}
       public long totalCountryPreviousYearZAR { get { 
            double var7 = Math.roundToLong(actualOtherPreviousYearZARVAR + actualGMPreviousYearZARVAR + actualIBPreviousYearZARVAR + actualTPSPreviousYearZARVAR); 
            return Math.roundToLong(var7/1000); }
        set;} 
       public long totalCountryPreviousYearUSD { get { 
            double var8 = Math.roundToLong(actualOtherPreviousYearUSDVAR + actualGMPreviousYearUSDVAR + actualIBPreviousYearUSDVAR + actualTPSPreviousYearUSDVAR);
            return Math.roundToLong(var8/1000); }
        set;} 
        
    
    public long totalBudgetZAR {get; set;}
    public long totalBudgetUSD {get; set;}
    
    //Map to store data being worked on in the globalClientRevenue Map
    private Map<String,globalClientRevenueCountry> countryRevenue = new Map<String,globalClientRevenueCountry>();
    //Map to store the sorted Global Client Revenue
    private Map<String,globalClientRevenueCountry> countryRevenueSorted = new Map<String,globalClientRevenueCountry>();
    
    
    public date snapshotDate {
        get {
            try {
                if(overviewClientId != null || overviewClientId != ''){
                    AggregateResult[] theSnapshotDate = ([SELECT 
                                             Max(Snapshot_Date__c) SnapshotDate 
                                          FROM 
                                             Global_Client_Revenue__c 
                                          WHERE 
                                             Client__c =: overviewClientId
                                             AND RecordType.Name = 'Current & Previous Year']);
                   return (Date)theSnapshotDate[0].get('SnapshotDate');
                }                             
            }catch (Exception e){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()+' thrown in: '+e.getStackTraceString()));
            }
            return Date.today();
        }
        private set; 
   }{ snapshotDate = Date.today(); }                            
    
    //Map used to populate the Component
    public Map<String,globalClientRevenueCountry> globalClientRevenue { 
        get { 
            try {
                if(overviewClientId != null || overviewClientId != ''){
                    AggregateResult[] globalClientRevenueForClient = [SELECT 
                                                                        Grouping(Reporting_Country__c) divisionTotalled, 
                                                                        Grouping(Trading_Division__c) countryTotalled, 
                                                                        Reporting_Country__c, 
                                                                        Trading_Division__c, 
                                                                        SUM(Budget_ZAR_Next_Year__c) budgetZAR, 
                                                                        SUM(Client_Value_ZAR_Current_Year__c) totalCurrYearZAR, 
                                                                        SUM(Client_Value_ZAR_Previous_Year__c) totalPrevYearZAR,
                                                                        SUM(Budget_USD_Next_Year__c) budgetUSD, 
                                                                        SUM(Client_Value_USD_Current_Year__c) totalCurrYearUSD, 
                                                                        SUM(Client_Value_USD_Previous_Year__c) totalPrevYearUSD 
                                                                      FROM 
                                                                        Global_Client_Revenue__c 
                                                                      WHERE 
                                                                        Client__c =: overviewClientId
                                                                        AND RecordType.Name = 'Current & Previous Year'
                                                                      GROUP BY CUBE
                                                                        (Reporting_Country__c, 
                                                                         Trading_Division__c) 
                                                                      
                                                                      ORDER BY SUM(Client_Value_ZAR_Current_Year__c) DESC NULLS LAST];
                                                                         
                     if(globalClientRevenueForClient.size()>0) {
                         for(AggregateResult gCRFCR : globalClientRevenueForClient ){
                            String country = (String)gCRFCR.get('Reporting_Country__c');
                            String division = (String)gCRFCR.get('Trading_Division__c');
                            if (country <> null) {
                                globalClientRevenueCountry workItem = new globalClientRevenueCountry();
                                if (countryRevenue.containsKey(country)) {
                                    workItem = countryRevenue.get(country);
                                } else {
                                    workItem.totalTPSCurrentYearUSD  = 0;
                                    workItem.totalTPSCurrentYearZAR  = 0;
                                    workItem.totalTPSPreviousYearUSD = 0;
                                    workItem.totalTPSPreviousYearZAR = 0;
                                    workItem.totalIBCurrentYearUSD  = 0;
                                    workItem.totalIBCurrentYearZAR  = 0;
                                    workItem.totalIBPreviousYearUSD = 0;
                                    workItem.totalIBPreviousYearZAR = 0;
                                    workItem.totalOtherCurrentYearUSD = 0;
                                    workItem.totalOtherCurrentYearZAR = 0;
                                    workItem.totalOtherPreviousYearUSD = 0;
                                    workItem.totalOtherPreviousYearZAR = 0;
                                    workItem.totalGMCurrentYearUSD  = 0;
                                    workItem.totalGMCurrentYearZAR  = 0;
                                    workItem.totalGMPreviousYearUSD = 0;
                                    workItem.totalGMPreviousYearZAR = 0;
                                    workItem.totalBudgetZAR  = 0;
                                    workItem.totalBudgetUSD  = 0;
                                    workItem.reportingCountryName = country;
                                   //NK
                                    workItem.actualOtherCureentYearZARVAR = 0 ;
                                    workItem.actualGMCureentYearZARVAR = 0 ;
                                    workItem.actualIBCureentYearZARVAR = 0 ;
                                    workItem.actualTPSCureentYearZARVAR = 0 ;
                                    
                                    workItem.actualOtherCurrentYearUSDVAR = 0 ;
                                    workItem.actualGMCurrentYearUSDVAR = 0 ;
                                    workItem.actualIBCurrentYearUSDVAR = 0 ;
                                    workItem.actualTPSCurrentYearUSDVAR = 0 ;
                                    
                                    workItem.actualOtherPreviousYearZARVAR = 0 ;
                                    workItem.actualGMPreviousYearZARVAR = 0 ;
                                    workItem.actualIBPreviousYearZARVAR = 0 ;
                                    workItem.actualTPSPreviousYearZARVAR = 0 ;
                                    
                                    workItem.actualOtherPreviousYearUSDVAR = 0 ;
                                    workItem.actualGMPreviousYearUSDVAR = 0 ;
                                    workItem.actualIBPreviousYearUSDVAR = 0 ;
                                    workItem.actualTPSPreviousYearUSDVAR = 0 ;

                                }
                                if ((double)gCRFCR.get('countryTotalled')==1){
                                    workItem.totalBudgetZAR  =  (double)gCRFCR.get('budgetZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('budgetZAR')/1000);
                                    workItem.totalBudgetUSD  =  (double)gCRFCR.get('budgetUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('budgetUSD')/1000);
                                }
                                if (division == 'TRANSACTION BANKING') {
                                    workItem.totalTPSCurrentYearUSD  = (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearUSD')/1000);
                                    workItem.totalTPSCurrentYearZAR  = (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearZAR')/1000);
                                    workItem.totalTPSPreviousYearUSD = (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearUSD')/1000);
                                    workItem.totalTPSPreviousYearZAR = (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearZAR')/1000);
                                   
                                    workItem.actualTPSCureentYearZARVAR =   (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearZAR');
                                    workItem.actualTPSCurrentYearUSDVAR =   (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearUSD');
                                    workItem.actualTPSPreviousYearZARVAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearZAR');
                                    workItem.actualTPSPreviousYearUSDVAR =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearUSD');
                                   
                                   } else if (division == 'IB') {
                                    workItem.totalIBCurrentYearUSD  = (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearUSD')/1000);
                                    workItem.totalIBCurrentYearZAR  = (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearZAR')/1000);
                                    workItem.totalIBPreviousYearUSD = (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearUSD')/1000);
                                    workItem.totalIBPreviousYearZAR = (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearZAR')/1000);
                                    
                                    workItem.actualIBCureentYearZARVAR =   (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearZAR');
                                    workItem.actualIBCurrentYearUSDVAR =   (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearUSD');
                                    workItem.actualIBPreviousYearZARVAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearZAR');
                                    workItem.actualIBPreviousYearUSDVAR =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearUSD');
                                
                                } else if (division == 'GM') {
                                    workItem.totalGMCurrentYearUSD  = (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearUSD')/1000);
                                    workItem.totalGMCurrentYearZAR  = (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearZAR')/1000);
                                    workItem.totalGMPreviousYearUSD = (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearUSD')/1000);
                                    workItem.totalGMPreviousYearZAR = (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearZAR')/1000);                                    
                                  
                                    workItem.actualGMCureentYearZARVAR =   (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearZAR');
                                    workItem.actualGMCurrentYearUSDVAR =   (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearUSD');
                                    workItem.actualGMPreviousYearZARVAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearZAR');
                                    workItem.actualGMPreviousYearUSDVAR =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearUSD');
                               
                                } else if (division == null) {
                                    //skip this record
                                } else if (division == 'OTHER'){
                                    workItem.totalOtherCurrentYearUSD  =  (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearUSD')/1000);
                                    workItem.totalOtherCurrentYearZAR  =  (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearZAR')/1000);
                                    workItem.totalOtherPreviousYearUSD =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearUSD')/1000);
                                    workItem.totalOtherPreviousYearZAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearZAR')/1000);
                                    
                                    workItem.actualOtherCureentYearZARVAR =  (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearZAR');
                                    workItem.actualOtherCurrentYearUSDVAR =  (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearUSD');
                                    workItem.actualOtherPreviousYearZARVAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearZAR');
                                    workItem.actualOtherPreviousYearUSDVAR =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearUSD');
                                }
                               
                                countryRevenue.put(country,workItem);
                                
                             } else if (country == null) {
                                 if ((double)gCRFCR.get('divisionTotalled')==1) {
                                     if ((double)gCRFCR.get('countryTotalled')==1) {
                                        totalBudgetZAR  =  (double)gCRFCR.get('budgetZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('budgetZAR')/1000);
                                        totalBudgetUSD  =  (double)gCRFCR.get('budgetUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('budgetUSD')/1000);
                                     }
                                    if (division == 'TRANSACTION BANKING') {
                                        totalTPSCurrentYearUSD  = (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearUSD')/1000);
                                        totalTPSCurrentYearZAR  = (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearZAR')/1000);
                                        totalTPSPreviousYearUSD = (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearUSD')/1000);
                                        totalTPSPreviousYearZAR = (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearZAR')/1000);
                                        
                                        actualTPSCureentYearZARVAR =   (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearZAR');
                                        actualTPSCurrentYearUSDVAR =   (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearUSD');
                                        actualTPSPreviousYearZARVAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearZAR');
                                        actualTPSPreviousYearUSDVAR =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearUSD');
                                     
                                    } else if (division == 'IB') {
                                        totalIBCurrentYearUSD  = (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearUSD')/1000);
                                        totalIBCurrentYearZAR  = (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearZAR')/1000);
                                        totalIBPreviousYearUSD = (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearUSD')/1000);
                                        totalIBPreviousYearZAR = (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearZAR')/1000);
                                       
                                       actualIBCureentYearZARVAR =   (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearZAR');
                                       actualIBCurrentYearUSDVAR =   (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearUSD');
                                       actualIBPreviousYearZARVAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearZAR');
                                       actualIBPreviousYearUSDVAR =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearUSD');
                                
                                    } else if (division == 'GM') {
                                        totalGMCurrentYearUSD  = (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearUSD')/1000);
                                        totalGMCurrentYearZAR  = (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearZAR')/1000);
                                        totalGMPreviousYearUSD = (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearUSD')/1000);
                                        totalGMPreviousYearZAR = (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearZAR')/1000);                                    
                                        
                                        actualGMCureentYearZARVAR =   (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearZAR');
                                        actualGMCurrentYearUSDVAR =   (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearUSD');
                                        actualGMPreviousYearZARVAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearZAR');
                                        actualGMPreviousYearUSDVAR =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearUSD');
                                    
                                    } else if (division == null) {
                                        // skip this record
                                    } else if (division == 'OTHER') {
                                        totalOtherCurrentYearUSD  =  (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearUSD')/1000);
                                        totalOtherCurrentYearZAR  =  (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalCurrYearZAR')/1000);
                                        totalOtherPreviousYearUSD =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearUSD')/1000);
                                        totalOtherPreviousYearZAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : Math.roundToLong((double)gCRFCR.get('totalPrevYearZAR')/1000);
                                        
                                       actualOtherCureentYearZARVAR =  (double)gCRFCR.get('totalCurrYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearZAR');
                                       actualOtherCurrentYearUSDVAR =  (double)gCRFCR.get('totalCurrYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalCurrYearUSD');
                                       actualOtherPreviousYearZARVAR =  (double)gCRFCR.get('totalPrevYearZAR') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearZAR');
                                       actualOtherPreviousYearUSDVAR =  (double)gCRFCR.get('totalPrevYearUSD') == null ? 0 : (long)(double)gCRFCR.get('totalPrevYearUSD');
                                    }
                                    
                                 }
                             }
                          }
                        }
                    }
            }catch (Exception e){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()+' thrown in: '+e.getStackTraceString()));
            }
            //Client Revenue Sorting
            List <globalClientRevenueCountry > sortRevenue = new List <globalClientRevenueCountry >();
            
            sortRevenue.addAll(countryRevenue.values());
            
            sortRevenue.sort();
            countryRevenueSorted = new Map<String,globalClientRevenueCountry>();
            integer i = 00;
            string prefix = '';
                for (globalClientRevenueCountry theCountry : sortRevenue) {
                    prefix = (i < 10 ? '0' : '');
    
                    countryRevenueSorted.put(prefix+i+theCountry.reportingCountryName,theCountry );
                    i++;
            }
                      
            return countryRevenueSorted;
         }
          public set; 
   }{ globalClientRevenue = new Map<String,globalClientRevenueCountry>(); }

    /**
     * @description inner class
     */
    global class globalClientRevenueCountry implements Comparable { 
        public string reportingCountryName {get; set; } 
        public string tradingDivisionName { get; set; } 
        
        public long totalTPSPreviousYearZAR { get; set; } 
        public long totalTPSPreviousYearUSD { get; set; }
        public long totalTPSCurrentYearZAR { get; set; } 
        public long totalTPSCurrentYearUSD { get; set; } 
                          
        public long totalIBCurrentYearZAR { get; set; }
        public long totalIBCurrentYearUSD { get; set; }
        public long totalIBPreviousYearZAR { get; set; }
        public long totalIBPreviousYearUSD { get; set; }
        
        public long totalGMCurrentYearZAR { get; set; }
        public long totalGMCurrentYearUSD { get; set; }
        public long totalGMPreviousYearZAR { get; set; }
        public long totalGMPreviousYearUSD { get; set; }
        
        public long totalOtherCurrentYearZAR { get; set; }
        public long totalOtherCurrentYearUSD { get; set; }
        public long totalOtherPreviousYearZAR { get; set; }
        public long totalOtherPreviousYearUSD { get; set; }
        
        //NK
        public long actualOtherCureentYearZARVAR { get; set; } 
        public long actualGMCureentYearZARVAR { get; set; } 
        public long actualIBCureentYearZARVAR { get; set; } 
        public long actualTPSCureentYearZARVAR { get; set; } 
        
        public long actualOtherCurrentYearUSDVAR { get; set; }
        public long actualGMCurrentYearUSDVAR { get; set; }
        public long actualIBCurrentYearUSDVAR { get; set; }
        public long actualTPSCurrentYearUSDVAR { get; set; }
        
        public long actualOtherPreviousYearZARVAR { get; set; }
        public long actualGMPreviousYearZARVAR { get; set; }
        public long actualIBPreviousYearZARVAR { get; set; }
        public long actualTPSPreviousYearZARVAR { get; set; }
        
        public long actualOtherPreviousYearUSDVAR { get; set; }
        public long actualGMPreviousYearUSDVAR { get; set; }
        public long actualIBPreviousYearUSDVAR { get; set; }
        public long actualTPSPreviousYearUSDVAR { get; set; }
        
        public long totalCountryCurrentYearZAR { 
        get { 
            double var = Math.roundToLong(actualOtherCureentYearZARVAR + actualGMCureentYearZARVAR + actualIBCureentYearZARVAR + actualTPSCureentYearZARVAR); 
            return Math.roundToLong(var/1000); }
        set;}
       public long totalCountryCurrentYearUSD { 
        get { 
               double var2 = Math.roundToLong((actualOtherCurrentYearUSDVAR + actualGMCurrentYearUSDVAR + actualIBCurrentYearUSDVAR + actualTPSCurrentYearUSDVAR));
               return Math.roundToLong(var2/1000); }
        set;}
       public long totalCountryPreviousYearZAR { get { 
            double var3 = Math.roundToLong(actualOtherPreviousYearZARVAR + actualGMPreviousYearZARVAR + actualIBPreviousYearZARVAR + actualTPSPreviousYearZARVAR); 
            return Math.roundToLong(var3/1000); }
        set;} 
       public long totalCountryPreviousYearUSD { get { 
            double var4 = Math.roundToLong(actualOtherPreviousYearUSDVAR + actualGMPreviousYearUSDVAR + actualIBPreviousYearUSDVAR + actualTPSPreviousYearUSDVAR);
            return Math.roundToLong(var4/1000); }
        set;} 
        
        public long totalBudgetZAR {get; set;}
        public long totalBudgetUSD {get; set;}

        /**
         * @description constructor
         */
        public void globalClientRevenueCountry(){
            this.totalTPSCurrentYearUSD  = 0;
            this.totalTPSCurrentYearZAR  = 0;
            this.totalTPSPreviousYearUSD = 0;
            this.totalTPSPreviousYearZAR = 0;
            
            this.totalIBCurrentYearZAR = 0;
            this.totalIBCurrentYearUSD  = 0;
            this.totalIBPreviousYearUSD = 0;
            this.totalIBPreviousYearZAR =0;
            
            this.totalOtherCurrentYearUSD = 0;
            this.totalOtherCurrentYearZAR = 0;
            this.totalOtherPreviousYearUSD = 0;
            this.totalOtherPreviousYearZAR = 0;
            
            this.totalGMCurrentYearZAR = 0;
            this.totalGMCurrentYearUSD  = 0;
            this.totalGMPreviousYearUSD = 0;
            this.totalGMPreviousYearZAR =0;
            
            //NK
            this.actualOtherCureentYearZARVAR = 0 ;
            this.actualGMCureentYearZARVAR = 0 ;
            this.actualIBCureentYearZARVAR = 0 ;
            this.actualTPSCureentYearZARVAR = 0 ;
            
            this.actualOtherCurrentYearUSDVAR = 0 ;
            this.actualGMCurrentYearUSDVAR = 0 ;
            this.actualIBCurrentYearUSDVAR = 0 ;
            this.actualTPSCurrentYearUSDVAR = 0 ;
            
            this.actualOtherPreviousYearZARVAR = 0 ;
            this.actualGMPreviousYearZARVAR = 0 ;
            this.actualIBPreviousYearZARVAR = 0 ;
            this.actualTPSPreviousYearZARVAR = 0 ;
            
            this.actualOtherPreviousYearUSDVAR = 0 ;
            this.actualGMPreviousYearUSDVAR = 0 ;
            this.actualIBPreviousYearUSDVAR = 0 ;
            this.actualTPSPreviousYearUSDVAR = 0 ;

        }

        /**
         * @param compareTo Object
         * @description custom compare logic
         * @return Integer
         */
        public Integer compareTo(Object compareTo) {

            globalClientRevenueCountry compareToCountry = (globalClientRevenueCountry)compareTo;
            if (totalCountryCurrentYearZAR == null) return 1;
            if (compareToCountry.totalCountryCurrentYearZAR == null) return -1;
            if (totalCountryCurrentYearZAR == compareToCountry.totalCountryCurrentYearZAR)return 0;
            if (totalCountryCurrentYearZAR > compareToCountry.totalCountryCurrentYearZAR) return -1;
            return 1;
        }
    }

}