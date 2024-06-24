/*************************************************************************************************************************************************************************
    @ Author        : Nitish Kumar
    @ Date          : Sept 2014
    @ Test File     : 
    @ Description   : Controller class for Opportunity Management functionality.
                      Case Description  C-00001133 : Objective is to provide a global dashboard for executives on mobile.
                      It looks at typical Sales Metrics such as pipeline, top opportunities and top clients.
                      These KPIs are defined per Franco, Sector and teams The dashboard be accessible from the SF1 app.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @ Last Modified By  :   Prabhanshu Agrawal
    @ Last Modified On  :   Feb 2015
    @ Last Modified Reason  : Removed Unknown Franco and Unknown Sector filter (En-579)

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
   
    @ Last Modified By  :   Manoj Gupta       
    @ Last Modified On  :   Dec 2015
    @ Last Modified Reason  : EN:0838 - Replacing Corporate Banking references to Client Coverage
*************************************************************************************************************************************************************************/

public with sharing class OMDashboardController {
    
    public Map < String, Double > RateMap = new Map < String, Double > (); // Map for storing Currency code as key and rate of conversion as value
    public List < CurrencyType > CurrTable = new List < CurrencyType > (); //List of object used in Currency conversion

    // List for storing All the closed Opp per franco,sector and user division
    public list < OMDashboardUtilityClass.omOpportunityClosedFranco > AllOpportunityClosedDrillDown { get; set; }
    // List for storing All the pipeline Opp per franco,sector and user division
    public list < OMDashboardUtilityClass.omOpportunityPipelineFranco > AllOpportunityPipelineDrillDown { get; set; }
    
    // List to store Different table data for different views
    public list < OMDashboardUtilityClass.omOpportunityTop > omOpportunityTop = new list < OMDashboardUtilityClass.omOpportunityTop > ();
    public list < OMDashboardUtilityClass.omOpportunitySecTop > omOpportunitySecTop = new list < OMDashboardUtilityClass.omOpportunitySecTop > ();
    public list < OMDashboardUtilityClass.omOppClosedFrancoView > omOppClosedFrancoViewpipe = new list < OMDashboardUtilityClass.omOppClosedFrancoView > ();
    public list < OMDashboardUtilityClass.omOpportunitySecTop > omOpportunitySecToppipe = new list < OMDashboardUtilityClass.omOpportunitySecTop > ();
    public list < OMDashboardUtilityClass.omOppClosedFrancoView > omOppClosedFrancoViewcw = new list < OMDashboardUtilityClass.omOppClosedFrancoView > ();
    public list < OMDashboardUtilityClass.omOppClosedFrancoView > omOppClosedFrancoViewcl = new list < OMDashboardUtilityClass.omOppClosedFrancoView > ();
    public list < OMDashboardUtilityClass.omOpportunitySecTop > omOpportunitySecTopcw = new list < OMDashboardUtilityClass.omOpportunitySecTop > ();
    public list < OMDashboardUtilityClass.omOpportunitySecTop > omOpportunitySecTopcl = new list < OMDashboardUtilityClass.omOpportunitySecTop > ();

    //Method that pulls the latest currency conversion rates.
    public void snapCurrencyTable() {

        this.CurrTable = [Select cur.IsoCode, cur.ConversionRate From CurrencyType cur LIMIT 300];

        for (CurrencyType c: CurrTable) {
            RateMap.put(c.IsoCode, c.ConversionRate);
        }
    }
    
    //CURRENCY CONVERSION CLASS
    public class currencyConverter {

        public currencyConverter() {}

        public Decimal convert(Decimal val, String oldCurr, Map < String, Double > RateMap, String newCurr) {
            //NOTE ON CALCULATION:
            //(current curr / current rate) = USD(1:1) 
            //(USD * new rate) = new curr value

            // No point in trying to convert a null.
            if (val == null) return 0;
            Decimal displayVal;

            if ((oldCurr != newCurr) || (val != 0)) {

                Double oldrate = RateMap.get(oldCurr);
                Decimal usdval = (val / oldrate);
                Double newrate = RateMap.get(newCurr);

                displayVal = (usdval * newrate);

            } else {
                displayVal = val;
            }
            return displayVal;
        }
    }

    public OMDashboardController(){
    
        //Get the currency conversion rates
        snapCurrencyTable();
     
        AllOpportunityClosedDrillDown = getAllOpportunityClosedFrancolstRec();
        AllOpportunityPipelineDrillDown = getAllOpportunityPipelineFrancolstRec();
        AllOpportunityforTable();
    }

    // Closed Opportunity Drill Down View
    public list < OMDashboardUtilityClass.omOpportunityClosedFranco > getAllOpportunityClosedFrancolstRec() {
       
        list < OMDashboardUtilityClass.omOpportunityClosedFranco > oMOppClosedlist = new list < OMDashboardUtilityClass.omOpportunityClosedFranco > ();
       
        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();

        // Aggregate Query to get the sum of revenue of all pipeline opportunities          
        AggregateResult[] allClosedOpportunityCY = [Select
            Grouping(Account.Client_Franco__c) francoTotalled,
            Grouping(Account.Client_Sector__c) sectorTotalled,
            Grouping(StageName) divisionStage,
            StageName,
            Account.Client_Franco__c,
            Account.Client_Sector__c,
            SUM(Current_Year_Revenue_Currency__c) revSum,
            SUM(Amount) totalAmount,
            COUNT(Id) oPPCount
            from Opportunity
            where((Actual_Close_Date__c = THIS_YEAR and StageName IN('3 - Closed Won', '4 - Closed Lost')))
            AND(Account.RecordTypeId NOT IN('012200000009iov', '01220000000cZr1'))
            GROUP BY
            CUBE(StageName,Account.Client_Franco__c, Account.Client_Sector__c) ORDER BY Account.Client_Franco__c ASC
            limit 50000
        ];
        
        //Using map to make solution dynamic
        map<String,decimal> closedWonrevMapCY = new map<String,decimal>();
        map<String,decimal> closedLostrevMapCY = new map<String,decimal>();
        map<String,Integer> closedoPPCountMap = new map<String,Integer>();
        map<String,decimal> closedWontotrevMapCY = new map<String,decimal>();
        map<String,decimal> closedLosttotrevMapCY = new map<String,decimal>();
        
        Set<String> francoSet = new Set<String>() ;
        Set<String> SectorSet = new Set<String>() ;
        
        for (AggregateResult allOpp: allClosedOpportunityCY) {

            String oppStage = (String) allOpp.get('StageName');
            String clientFranco = (String) allOpp.get('Client_Franco__c');
            String sector = (String) allOpp.get('Client_Sector__c');
            
            if (clientFranco <> null && sector <> null && oppStage <> null && (Integer) allOpp.get('oPPCount') != null) {
               
                francoSet.add(clientFranco) ;
                SectorSet.add(sector);
              
                String uniquestrKey =  clientFranco + '#'  + sector ; 
              
                if (!closedoPPCountMap.containsKey(uniquestrKey)){
                    closedoPPCountMap.put(uniquestrKey , (Integer) allOpp.get('oPPCount'));
                }
                else{
                    closedoPPCountMap.put(uniquestrKey , closedoPPCountMap.get(uniquestrKey) + (Integer) allOpp.get('oPPCount'));
                }
            }
                 
            if (clientFranco <> null && sector <> null && oppStage <> null && (double) allOpp.get('totalAmount') != null) {
               
                francoSet.add(clientFranco) ;
                SectorSet.add(sector);
              
                String uniquestrKey =  clientFranco + '#'  + sector ; 
              
                if (oppStage == '3 - Closed Won') {
              
                    if (!closedWontotrevMapCY.containsKey(uniquestrKey)){
                        closedWontotrevMapCY.put(uniquestrKey , converter.convert(Double.valueOf(allOpp.get('totalAmount')), 'USD', RateMap, 'ZAR'));
                    }
                    else{
                        closedWontotrevMapCY.put(uniquestrKey , closedWontotrevMapCY.get(uniquestrKey) + converter.convert(Double.valueOf(allOpp.get('totalAmount')), 'USD', RateMap, 'ZAR'));
                    }
                }
              
                if (oppStage == '4 - Closed Lost') {
                
                    if (!closedLosttotrevMapCY.containsKey(uniquestrKey)){
                        closedLosttotrevMapCY.put(uniquestrKey , converter.convert(Double.valueOf(allOpp.get('totalAmount')), 'USD', RateMap, 'ZAR'));
                    }
                    else{
                        closedLosttotrevMapCY.put(uniquestrKey , closedLosttotrevMapCY.get(uniquestrKey) + converter.convert(Double.valueOf(allOpp.get('totalAmount')), 'USD', RateMap, 'ZAR'));
                    }
                }
            }
         
            if (clientFranco <> null && sector <> null && oppStage <> null && (double) allOpp.get('revSum') != null) {
              
                francoSet.add(clientFranco) ;
                SectorSet.add(sector);
              
                String uniquestrKey =  clientFranco + '#'  + sector ; 
               
                if (oppStage == '3 - Closed Won') {
                
                    if (!closedWonrevMapCY.containsKey(uniquestrKey)){
                        closedWonrevMapCY.put(uniquestrKey , converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                    }
                    else{
                        closedWonrevMapCY.put(uniquestrKey , closedWonrevMapCY.get(uniquestrKey) + converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                    }
                }
              
                if (oppStage == '4 - Closed Lost') {
                
                  if (!closedLostrevMapCY.containsKey(uniquestrKey)){
                    closedLostrevMapCY.put(uniquestrKey , converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                  }
                  else{
                    closedLostrevMapCY.put(uniquestrKey , closedLostrevMapCY.get(uniquestrKey) + converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                  }
                }
            }
        } 
          
        // Aggregate Query to get the sum of revenue of all Closed opportunities last year          
        AggregateResult[] allClosedOpportunityPY = [Select
            Grouping(Account.Client_Franco__c) francoTotalled,
            Grouping(Account.Client_Sector__c) sectorTotalled,
            Grouping(StageName) divisionStage,
            StageName,
            Account.Client_Franco__c,
            Account.Client_Sector__c,
            SUM(Current_Year_Revenue_Currency__c) revSum,
            SUM(Amount) totalAmount
            from Opportunity
            where((Actual_Close_Date__c = LAST_YEAR and StageName IN('3 - Closed Won', '4 - Closed Lost')))
            AND(Account.RecordTypeId NOT IN('012200000009iov', '01220000000cZr1'))
            GROUP BY
            CUBE(StageName,Account.Client_Franco__c, Account.Client_Sector__c) ORDER BY Account.Client_Franco__c ASC
            limit 50000
        ];
        
        map<String,decimal> closedWonrevMapPY = new map<String,decimal>();
        map<String,decimal> closedLostrevMapPY = new map<String,decimal>();
        
        for (AggregateResult allOpp: allClosedOpportunityPY) {

            String oppStage = (String) allOpp.get('StageName');
            String clientFranco = (String) allOpp.get('Client_Franco__c');
            String sector = (String) allOpp.get('Client_Sector__c');

            if (clientFranco <> null && sector <> null && oppStage <> null && (double) allOpp.get('revSum') != null) {
              
                francoSet.add(clientFranco) ;
                SectorSet.add(sector);
              
                String uniquestrKey =  clientFranco + '#'  + sector ; 
              
                if (oppStage == '3 - Closed Won') {
                
                    if (!closedWonrevMapPY.containsKey(uniquestrKey)){
                        closedWonrevMapPY.put(uniquestrKey , converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                    }
                    else{
                        closedWonrevMapPY.put(uniquestrKey , closedWonrevMapPY.get(uniquestrKey) + converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                    }
                }
              
                if (oppStage == '4 - Closed Lost') {
                
                    if (!closedLostrevMapPY.containsKey(uniquestrKey)){
                        closedLostrevMapPY.put(uniquestrKey , converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                    }
                    else{
                        closedLostrevMapPY.put(uniquestrKey , closedLostrevMapPY.get(uniquestrKey) + converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                    }
                }
            }
        } 
          
        list<string> francolst = new list<string>() ;
        list<string> sectorlst = new list<string>() ;
        
        francolst.addAll(francoSet);
        sectorlst.addAll(SectorSet) ;
        
        francolst.sort();
        sectorlst.sort();
            
        for (String franco : francolst){
            for (String sector : SectorSet){
                String uniqueKey =  franco + '#' + sector ; 
                 
                OMDashboardUtilityClass.omOpportunityClosedFranco omClosedDrillDown = new OMDashboardUtilityClass.omOpportunityClosedFranco() ; 
                
                omClosedDrillDown.oppFranco = franco;
                omClosedDrillDown.oppSector = sector;
                omClosedDrillDown.WonPY = closedWonrevMapPY.get(uniqueKey)== null ? 0 : closedWonrevMapPY.get(uniqueKey);
                omClosedDrillDown.WonCY = closedWonrevMapCY.get(uniqueKey)== null ? 0 : closedWonrevMapCY.get(uniqueKey);
                omClosedDrillDown.LostPY = closedLostrevMapPY.get(uniqueKey)== null ? 0 : closedLostrevMapPY.get(uniqueKey);
                omClosedDrillDown.LostCY = closedLostrevMapCY.get(uniqueKey)== null ? 0 : closedLostrevMapCY.get(uniqueKey);
                omClosedDrillDown.totWonCY = closedWontotrevMapCY.get(uniqueKey)== null ? 0 : closedWontotrevMapCY.get(uniqueKey);
                omClosedDrillDown.totLostCY = closedLosttotrevMapCY.get(uniqueKey)== null ? 0 : closedLosttotrevMapCY.get(uniqueKey);
                omClosedDrillDown.oPPCount = closedoPPCountMap.get(uniqueKey)== null ? 0 : closedoPPCountMap.get(uniqueKey);
             
                if (omClosedDrillDown.WonPY > 0 || omClosedDrillDown.WonCY >0 ||  omClosedDrillDown.LostPY >0 || omClosedDrillDown.LostCY >0 || omClosedDrillDown.totWonCY > 0 || omClosedDrillDown.totLostCY > 0 || omClosedDrillDown.oPPCount > 0)          
                    oMOppClosedlist.add(omClosedDrillDown) ;
              
            }
        }

        return oMOppClosedlist ;
    }

    // Pipeline Drill Down View
    public list < OMDashboardUtilityClass.omOpportunityPipelineFranco > getAllOpportunityPipelineFrancolstRec() {

        list < OMDashboardUtilityClass.omOpportunityPipelineFranco > oMOppPipelist = new list < OMDashboardUtilityClass.omOpportunityPipelineFranco > ();
        String oMOppPipeJson;

        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();
     
        // Aggregate Query to get the sum of revenue of all pipeline opportunities          
        AggregateResult[] allpipelineOpportunity = [Select
            Grouping(Account.Client_Franco__c) francoTotalled,
            Grouping(Account.Client_Sector__c) sectorTotalled,
            Grouping(Owner.User_Division__c) divTotalled,
            Account.Client_Franco__c,
            Account.Client_Sector__c,
            Owner.User_Division__c,
            SUM(Current_Year_Revenue_Currency__c) revSum,
            SUM(Amount) totalAmount,
            COUNT(Id) oPPCount
            from Opportunity
            where StageName IN('1 - Lead', '2 - Develop')
            AND(Account.RecordTypeId NOT IN('012200000009iov', '01220000000cZr1'))
            GROUP BY
            CUBE(Account.Client_Franco__c, Account.Client_Sector__c,Owner.User_Division__c) ORDER BY Account.Client_Franco__c ASC
            limit 50000
        ];
        
        //Using map to make solution dynamic
        map<String,decimal> pipelineBErevMap = new map<String,decimal>();
        map<String,decimal> pipelineCBrevMap = new map<String,decimal>();
        map<String,decimal> pipelineGMrevMap = new map<String,decimal>();
        map<String,decimal> pipelineGlMrevMap = new map<String,decimal>();
        map<String,decimal> pipelineIBrevMap = new map<String,decimal>();
        map<String,decimal> pipelineRErevMap = new map<String,decimal>();
        map<String,decimal> pipelineTPSrevMap = new map<String,decimal>();
        map<String,decimal> pipelinetotRevMap = new map<String,decimal>();
        map<String,decimal> pipelinetotRevCYMap = new map<String,decimal>();
        map<String,Integer> pipelineoPPCountMap = new map<String,Integer>();
        
        Set<String> francoSet = new Set<String>() ;
        Set<String> SectorSet = new Set<String>() ;

        for (AggregateResult allOpp: allpipelineOpportunity) {

            String clientFranco = (String) allOpp.get('Client_Franco__c');
            String sector = (String) allOpp.get('Client_Sector__c');
            String userdivision = (String) allOpp.get('User_Division__c');

            if (clientFranco <> null && sector <> null && userdivision <> null) {
              
                francoSet.add(clientFranco) ;
                SectorSet.add(sector);
              
                String uniquestrKey =  clientFranco + '#'  + sector ; 
              
                if (Integer.valueOf(allOpp.get('oPPCount')) != null){
                
                    if (!pipelineoPPCountMap.containsKey(uniquestrKey)){
                        pipelineoPPCountMap.put(uniquestrKey , Integer.valueOf(allOpp.get('oPPCount')));
                    }
                    else{
                        pipelineoPPCountMap.put(uniquestrKey , pipelineoPPCountMap.get(uniquestrKey) + Integer.valueOf(allOpp.get('oPPCount')));
                    }
                }
              
                if (Double.valueOf(allOpp.get('totalAmount')) != null) {
                
                    decimal  revTot =  converter.convert(Double.valueOf(allOpp.get('totalAmount')), 'USD', RateMap, 'ZAR');
                 
                    if (!pipelinetotRevMap.containsKey(uniquestrKey)){
                        pipelinetotRevMap.put(uniquestrKey , revTot);
                    }
                    else{
                        pipelinetotRevMap.put(uniquestrKey , pipelinetotRevMap.get(uniquestrKey) + revTot);
                    }
                }
              
                if (Double.valueOf(allOpp.get('revSum')) != null) {
                     
                    decimal  revCY =  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR');
                 
                    if (!pipelinetotRevCYMap.containsKey(uniquestrKey)){
                        pipelinetotRevCYMap.put(uniquestrKey , revCY);
                    }
                    else{
                        pipelinetotRevCYMap.put(uniquestrKey , pipelinetotRevCYMap.get(uniquestrKey) + revCY);
                    }
                 
                    if (userdivision == 'Business Enablers'){
                        
                        decimal  revBE =  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR');
                        
                        if (!pipelineBErevMap.containsKey(uniquestrKey)){
                            pipelineBErevMap.put(uniquestrKey , revBE);
                        }
                        else{
                            pipelineBErevMap.put(uniquestrKey , pipelineBErevMap.get(uniquestrKey) + revBE);
                        }
                    }
                    if (userdivision == 'Client Coverage'){
                        decimal  revCB =  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR');
                          
                        if (!pipelineCBrevMap.containsKey(uniquestrKey)){
                            pipelineCBrevMap.put(uniquestrKey , revCB);
                        }
                        else{
                            pipelineCBrevMap.put(uniquestrKey , pipelineCBrevMap.get(uniquestrKey) + revCB);
                        }                          
                    }
                    if (userdivision == 'General Management'){
                        
                        decimal   revGenM =  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR');
                          
                        if (!pipelineGMrevMap.containsKey(uniquestrKey)){
                            pipelineGMrevMap.put(uniquestrKey , revGenM);
                        }
                        else{
                            pipelineGMrevMap.put(uniquestrKey , pipelineGMrevMap.get(uniquestrKey) + revGenM);
                        }                          
                    }
                    if (userdivision == 'Global Markets'){
                        
                        decimal  revGlM =  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR');
                          
                        if (!pipelineGlMrevMap.containsKey(uniquestrKey)){
                            pipelineGlMrevMap.put(uniquestrKey , revGlM);
                        }
                        else{
                            pipelineGlMrevMap.put(uniquestrKey , pipelineGlMrevMap.get(uniquestrKey) + revGlM);
                        }                         
                    }
                    if (userdivision == 'Investment Banking'){
                        
                        decimal  revIB =  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR');
                          
                        if (!pipelineIBrevMap.containsKey(uniquestrKey)){
                            pipelineIBrevMap.put(uniquestrKey , revIB);
                        }
                        else{
                            pipelineIBrevMap.put(uniquestrKey , pipelineIBrevMap.get(uniquestrKey) + revIB);
                        }                        
                    }
                    if (userdivision == 'Real Estate'){
                        
                        decimal  revRE =  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR');
                          
                        if (!pipelineRErevMap.containsKey(uniquestrKey)){
                            pipelineRErevMap.put(uniquestrKey , revRE);
                        }
                        else{
                            pipelineIBrevMap.put(uniquestrKey , pipelineRErevMap.get(uniquestrKey) + revRE);
                        }                         
                    }
                    if (userdivision == 'Transactional Products and Services'){
                        
                        decimal  revTPS =  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR');
                          
                        if (!pipelineTPSrevMap.containsKey(uniquestrKey)){
                            pipelineTPSrevMap.put(uniquestrKey , revTPS);
                        }
                        else{
                            pipelineTPSrevMap.put(uniquestrKey , pipelineTPSrevMap.get(uniquestrKey) + revTPS);
                        }
                    }
                }
            }
        }
            
        list<string> francolst = new list<string>() ;
        list<string> sectorlst = new list<string>() ;

        francolst.addAll(francoSet);
        sectorlst.addAll(SectorSet) ;

        francolst.sort();
        sectorlst.sort();
            
        for (String franco : francolst){
            for (String sector : SectorSet){
                String uniqueKey =  franco + '#' + sector ;
                 
                OMDashboardUtilityClass.omOpportunityPipelineFranco omPipelineDrillDown = new OMDashboardUtilityClass.omOpportunityPipelineFranco() ; 
                
                omPipelineDrillDown.oppFranco = franco;
                omPipelineDrillDown.oppSector = sector;
                omPipelineDrillDown.beRev = pipelineBErevMap.get(uniqueKey)== null ? 0 : pipelineBErevMap.get(uniqueKey);
                omPipelineDrillDown.cCovRev = pipelineCBrevMap.get(uniqueKey)== null ? 0 : pipelineCBrevMap.get(uniqueKey);
                omPipelineDrillDown.glmRev = pipelineGlMrevMap.get(uniqueKey)== null ? 0 : pipelineGlMrevMap.get(uniqueKey);
                omPipelineDrillDown.gmRev = pipelineGMrevMap.get(uniqueKey)== null ? 0 : pipelineGMrevMap.get(uniqueKey);
                omPipelineDrillDown.ibRev = pipelineIBrevMap.get(uniqueKey)== null ? 0 : pipelineIBrevMap.get(uniqueKey);
                omPipelineDrillDown.reRev = pipelineRErevMap.get(uniqueKey)== null ? 0 : pipelineRErevMap.get(uniqueKey);
                omPipelineDrillDown.tpsRev = pipelineTPSrevMap.get(uniqueKey)== null ? 0 : pipelineTPSrevMap.get(uniqueKey);
                omPipelineDrillDown.totalRev = pipelinetotRevMap.get(uniqueKey)== null ? 0 : pipelinetotRevMap.get(uniqueKey);
                omPipelineDrillDown.currYearRev = pipelinetotRevCYMap.get(uniqueKey)== null ? 0 : pipelinetotRevCYMap.get(uniqueKey);
                omPipelineDrillDown.oppPipelineCount = pipelineoPPCountMap.get(uniqueKey)== null ? 0 : pipelineoPPCountMap.get(uniqueKey);
             
                if (omPipelineDrillDown.beRev > 0 || omPipelineDrillDown.cCovRev >0 ||  omPipelineDrillDown.glmRev >0 || omPipelineDrillDown.gmRev >0 || omPipelineDrillDown.ibRev > 0 || omPipelineDrillDown.reRev >0 || omPipelineDrillDown.tpsRev >0 || omPipelineDrillDown.totalRev >0 || omPipelineDrillDown.currYearRev >0 ||  omPipelineDrillDown.currYearRev > 0 || omPipelineDrillDown.oppPipelineCount > 0)          
                    oMOppPipelist.add(omPipelineDrillDown) ;
              
            }
        }
         
        oMOppPipeJson = JSON.serializePretty(oMOppPipelist);
        
        return oMOppPipelist ;             
    }

    public String getomJSON(){
        return JSON.serializePretty(getAllOpportunitylstRec());
    }
  
    //Franco Home Page
    public list < OMDashboardUtilityClass.omOpportunity > getAllOpportunitylstRec() {
         
        list < OMDashboardUtilityClass.omOpportunity > oMlist = new list < OMDashboardUtilityClass.omOpportunity > ();
       
        Map<String,Decimal> wonOppLastMonthMap = new map<String,Decimal>();
        Map<String,Decimal> lostOppLastMonthMap = new map<String,Decimal>();
        
        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();
     
        // Aggregate Query to get the sum of revenue of all opportunities which have been closed till previous month and in Current Year.
        AggregateResult[] wonLostOppLastMonth = [Select
            Grouping(StageName) divisionStage,
            Grouping(Account.Client_Franco__c) francoTotalled,
            StageName,
            Account.Client_Franco__c,
            SUM(Current_Year_Revenue_Currency__c) revSum
            from Opportunity
            where((Actual_Close_Date__c = THIS_YEAR 
            and Actual_Close_Date__c < THIS_MONTH 
            and StageName IN('3 - Closed Won', '4 - Closed Lost')))
            AND(Account.RecordTypeId NOT IN('012200000009iov', '01220000000cZr1'))
            GROUP BY CUBE(StageName, Account.Client_Franco__c) ORDER BY Account.Client_Franco__c ASC
            limit 50000
        ];

        // Populating all the variables                                                                              
        for (AggregateResult allOpp: wonLostOppLastMonth) {

            String wonLostoppStage = (String) allOpp.get('StageName');
            String cFranco = (String) allOpp.get('Client_Franco__c');

            if (wonLostoppStage <> null && cFranco <> null && (double) allOpp.get('revSum') != null) {
              
                if (wonLostoppStage == '3 - Closed Won') {
                    wonOppLastMonthMap.put(cFranco,  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                }
                if (wonLostoppStage == '4 - Closed Lost') {
                    lostOppLastMonthMap.put(cFranco,  converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                }     
            }
        }
        
        Map<String,Decimal> francoPipelineRevMap = new map<String,Decimal>();
        Map<String,Decimal> francoPipelineTotRevMap = new map<String,Decimal>();
        Map<String,Integer> francoPipelineOppCountMap = new map<String,Integer>();
        
        Set<String> francoSet = new Set<String>() ;
        
        for (OMDashboardUtilityClass.omOpportunityPipelineFranco francoPipeline :  AllOpportunityPipelineDrillDown){
              
            francoSet.add(francoPipeline.oppFranco) ;
              
            if (!francoPipelineRevMap.containsKey(francoPipeline.oppFranco)) 
                francoPipelineRevMap.put(francoPipeline.oppFranco, francoPipeline.currYearRev);
            else
                francoPipelineRevMap.put(francoPipeline.oppFranco, francoPipelineRevMap.get(francoPipeline.oppFranco) + francoPipeline.currYearRev) ;
          
            if (!francoPipelineTotRevMap.containsKey(francoPipeline.oppFranco)) 
                francoPipelineTotRevMap.put(francoPipeline.oppFranco, francoPipeline.totalRev);
            else
                francoPipelineTotRevMap.put(francoPipeline.oppFranco, francoPipelineTotRevMap.get(francoPipeline.oppFranco) + francoPipeline.totalRev) ;
                 
            if (!francoPipelineOppCountMap.containsKey(francoPipeline.oppFranco)) 
                francoPipelineOppCountMap.put(francoPipeline.oppFranco, francoPipeline.oppPipelineCount);
            else
                francoPipelineOppCountMap.put(francoPipeline.oppFranco, francoPipelineOppCountMap.get(francoPipeline.oppFranco) + francoPipeline.oppPipelineCount) ;
        }
           
        Map<String,Decimal> francoclosedWonRevMap = new map<String,Decimal>();
        Map<String,Decimal> francoclosedLostRevMap = new map<String,Decimal>();
        Map<String,Decimal> francoclosedtotRevMap = new map<String,Decimal>();
        Map<String,Integer> francoClosedOppCountMap = new map<String,Integer>();
             
        for (OMDashboardUtilityClass.omOpportunityClosedFranco closedOpp :  AllOpportunityClosedDrillDown){
            francoSet.add(closedOpp.oppFranco);
               
            if (!francoclosedWonRevMap.containsKey(closedOpp.oppFranco)) 
                francoclosedWonRevMap.put(closedOpp.oppFranco, closedOpp.WonCY);
            else
                francoclosedWonRevMap.put(closedOpp.oppFranco, francoclosedWonRevMap.get(closedOpp.oppFranco) + closedOpp.WonCY) ;
                  
            if (!francoclosedLostRevMap.containsKey(closedOpp.oppFranco)) 
                francoclosedLostRevMap.put(closedOpp.oppFranco, closedOpp.LostCY);
            else
                francoclosedLostRevMap.put(closedOpp.oppFranco, francoclosedLostRevMap.get(closedOpp.oppFranco) + closedOpp.LostCY) ;
                  
            if (!francoclosedtotRevMap.containsKey(closedOpp.oppFranco)) 
                francoclosedtotRevMap.put(closedOpp.oppFranco, closedOpp.totWonCY +  closedOpp.totLostCY );
            else
                francoclosedtotRevMap.put(closedOpp.oppFranco, francoclosedtotRevMap.get(closedOpp.oppFranco) + closedOpp.totWonCY +  closedOpp.totLostCY) ;
                  
            if (!francoClosedOppCountMap.containsKey(closedOpp.oppFranco))
                francoClosedOppCountMap.put(closedOpp.oppFranco, closedOpp.oPPCount  );
            else
                francoClosedOppCountMap.put(closedOpp.oppFranco, francoClosedOppCountMap.get(closedOpp.oppFranco) + closedOpp.oPPCount ) ;
        }
               
        list<string> francolst = new list<string>() ;
        francolst.addAll(francoSet);
        francolst.sort();        
        for (String franco : francolst){
                    
            OMDashboardUtilityClass.omOpportunity omOpp = new OMDashboardUtilityClass.omOpportunity() ;

            omOpp.oppFranco =  franco ;
            omOpp.pipeLineRev = francoPipelineRevMap.get(franco)== null ? 0 : francoPipelineRevMap.get(franco)  ;
            omOpp.ClosedWonRev = francoclosedWonRevMap.get(franco)== null ? 0 : francoclosedWonRevMap.get(franco);
            omOpp.ClosedLostRev = francoclosedLostRevMap.get(franco)== null ? 0 : francoclosedLostRevMap.get(franco);
            omOpp.ClosedWonRevLM = wonOppLastMonthMap.get(franco)== null ? 0 : wonOppLastMonthMap.get(franco);
            omOpp.ClosedLostRevLM = lostOppLastMonthMap.get(franco)== null ? 0 : lostOppLastMonthMap.get(franco);
            Integer francoClosedOppCount = francoClosedOppCountMap.get(franco)== null ? 0 : francoClosedOppCountMap.get(franco) ;
            Integer francoPipelineOppCount = francoPipelineOppCountMap.get(franco)== null ? 0 : francoPipelineOppCountMap.get(franco) ;
            omOpp.oppCount = francoClosedOppCount + francoPipelineOppCount ;
            
            if ((omOpp.ClosedLostRev + omOpp.ClosedWonRev) > 0) 
                omOpp.convRatio = (omOpp.ClosedWonRev) / (omOpp.ClosedLostRev + omOpp.ClosedWonRev);
            else 
                omOpp.convRatio = 0;
            
            if ((omOpp.ClosedLostRevLM + omOpp.ClosedWonRevLM) > 0) 
                omOpp.convRatioPM = (omOpp.ClosedWonRevLM) / (omOpp.ClosedLostRevLM + omOpp.ClosedWonRevLM);
            else 
                omOpp.convRatioPM = 0;         
            

            omOpp.totalRev = (francoPipelineTotRevMap.get(franco)== null ? 0 : francoPipelineTotRevMap.get(franco)) + (francoclosedtotRevMap.get(franco)== null ? 0 : francoclosedtotRevMap.get(franco)) ;
            
            if (omOpp.pipeLineRev > 0 || omOpp.ClosedWonRev >0 ||  omOpp.ClosedLostRev >0 || omOpp.ClosedWonRevLM >0 ||  omOpp.ClosedLostRevLM > 0 || omOpp.oppCount > 0 ||  omOpp.totalRev > 0 || omOpp.convRatio > 0 || omOpp.convRatioPM > 0)          
                oMlist.add(omOpp) ;
        }
         
        return oMlist ;
    }
      
    public String getAllOpportunitySectorlst() {
        return JSON.serializePretty(getAllOpportunitySectorlstRec());
    }
   
    //Sector Home Page   
    public list < OMDashboardUtilityClass.omOpportunitySector > getAllOpportunitySectorlstRec() {
     
        list < OMDashboardUtilityClass.omOpportunitySector > oMlist = new list < OMDashboardUtilityClass.omOpportunitySector > ();
       
        Map<String,Decimal> sectorrevWonLM = new  Map<String,Decimal>();
        Map<String,Decimal> sectorrevLostLM = new  Map<String,Decimal>();
        
        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();
     
        // Aggregate Query to get the sum of revenue of all opportunities which have been closed till previous month and in Current Year.
        AggregateResult[] wonLostOppLastMonth = [Select
            Grouping(StageName) divisionStage,
            Grouping(Account.Client_Sector__c) sectorTotalled,
            StageName,
            Account.Client_Sector__c,
            SUM(Current_Year_Revenue_Currency__c) revSum
            from Opportunity
            where(StageName IN('3 - Closed Won', '4 - Closed Lost'))
            AND ((Actual_Close_Date__c = THIS_YEAR ))
            AND (Actual_Close_Date__c < THIS_MONTH )
            AND (Account.RecordTypeId NOT IN('012200000009iov', '01220000000cZr1'))
            GROUP BY CUBE(StageName, Account.Client_Sector__c) ORDER BY Account.Client_Sector__c ASC
            limit 50000
        ];

        // Populating all the variables                                                                              
        for (AggregateResult allOpp: wonLostOppLastMonth) {

            String wonLostoppStage = (String) allOpp.get('StageName');
            String cSector = (String) allOpp.get('Client_Sector__c');

            if (wonLostoppStage <> null && cSector <> null && (double) allOpp.get('revSum') != null) {

                if (wonLostoppStage == '3 - Closed Won') {
                    sectorrevWonLM.put(cSector,converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                }
                if (wonLostoppStage == '4 - Closed Lost') {
                    sectorrevLostLM.put(cSector,converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                }
            }
        }

        Map<String,Decimal> sectorPipelineRevMap = new map<String,Decimal>();
        Map<String,Decimal> sectorPipelineTotRevMap = new map<String,Decimal>();
        Map<String,Integer> sectorPipelineOppCountMap = new map<String,Integer>();
        
        Set<String> SectorSet = new Set<String>() ;
        
        for (OMDashboardUtilityClass.omOpportunityPipelineFranco sectorPipeline :  AllOpportunityPipelineDrillDown){
              
            SectorSet.add(sectorPipeline.oppSector) ;
              
            if (!sectorPipelineRevMap.containsKey(sectorPipeline.oppSector)) 
                sectorPipelineRevMap.put(sectorPipeline.oppSector, sectorPipeline.currYearRev);
            else
                sectorPipelineRevMap.put(sectorPipeline.oppSector, sectorPipelineRevMap.get(sectorPipeline.oppSector) + sectorPipeline.currYearRev) ;
          
            if (!sectorPipelineTotRevMap.containsKey(sectorPipeline.oppSector)) 
                sectorPipelineTotRevMap.put(sectorPipeline.oppSector, sectorPipeline.totalRev);
            else
                sectorPipelineTotRevMap.put(sectorPipeline.oppSector, sectorPipelineTotRevMap.get(sectorPipeline.oppSector) + sectorPipeline.totalRev) ;
                 
            if (!sectorPipelineOppCountMap.containsKey(sectorPipeline.oppSector)) 
                sectorPipelineOppCountMap.put(sectorPipeline.oppSector, sectorPipeline.oppPipelineCount);
            else
                sectorPipelineOppCountMap.put(sectorPipeline.oppSector, sectorPipelineOppCountMap.get(sectorPipeline.oppSector) + sectorPipeline.oppPipelineCount) ;
          
        }
           
        Map<String,Decimal> sectorclosedWonRevMap = new map<String,Decimal>();
        Map<String,Decimal> sectorclosedLostRevMap = new map<String,Decimal>();
        Map<String,Decimal> sectorclosedtotRevMap = new map<String,Decimal>();
        Map<String,Integer> sectorClosedOppCountMap = new map<String,Integer>();
            
        for (OMDashboardUtilityClass.omOpportunityClosedFranco closedOpp :  AllOpportunityClosedDrillDown){
              
            SectorSet.add(closedOpp.oppSector) ;
               
            if (!sectorclosedWonRevMap.containsKey(closedOpp.oppSector)) 
                sectorclosedWonRevMap.put(closedOpp.oppSector, closedOpp.WonCY);
            else
                sectorclosedWonRevMap.put(closedOpp.oppSector, sectorclosedWonRevMap.get(closedOpp.oppSector) + closedOpp.WonCY) ;
                  
            if (!sectorclosedLostRevMap.containsKey(closedOpp.oppSector)) 
                sectorclosedLostRevMap.put(closedOpp.oppSector, closedOpp.LostCY);
            else
                sectorclosedLostRevMap.put(closedOpp.oppSector, sectorclosedLostRevMap.get(closedOpp.oppSector) + closedOpp.LostCY) ;
                  
            if (!sectorclosedtotRevMap.containsKey(closedOpp.oppSector)) 
                sectorclosedtotRevMap.put(closedOpp.oppSector, closedOpp.totWonCY +  closedOpp.totLostCY );
            else
                sectorclosedtotRevMap.put(closedOpp.oppSector, sectorclosedtotRevMap.get(closedOpp.oppSector) + closedOpp.totWonCY +  closedOpp.totLostCY) ;
                  
            if (!sectorClosedOppCountMap.containsKey(closedOpp.oppSector)) 
                sectorClosedOppCountMap.put(closedOpp.oppSector, closedOpp.oPPCount  );
            else
                sectorClosedOppCountMap.put(closedOpp.oppSector, sectorClosedOppCountMap.get(closedOpp.oppSector) + closedOpp.oPPCount ) ;
        }
               
        list<string> sectorlst = new list<string>() ;
        sectorlst.addAll(SectorSet);
        sectorlst.sort();      
        for (String sector : sectorlst){
                    
            OMDashboardUtilityClass.omOpportunitySector omOpp = new OMDashboardUtilityClass.omOpportunitySector() ;
                    
            omOpp.oppSector =  sector ;
            omOpp.pipeLineRev = sectorPipelineRevMap.get(sector)== null ? 0 : sectorPipelineRevMap.get(sector)  ;
            omOpp.ClosedWonRev = sectorclosedWonRevMap.get(sector)== null ? 0 : sectorclosedWonRevMap.get(sector);
            omOpp.ClosedLostRev = sectorclosedLostRevMap.get(sector)== null ? 0 : sectorclosedLostRevMap.get(sector);
            omOpp.ClosedWonRevLM = sectorrevWonLM.get(sector)== null ? 0 : sectorrevWonLM.get(sector);
            omOpp.ClosedLostRevLM = sectorrevLostLM.get(sector)== null ? 0 : sectorrevLostLM.get(sector);
            Integer sectorClosedOppCount = sectorClosedOppCountMap.get(sector)== null ? 0 : sectorClosedOppCountMap.get(sector) ;
            Integer sectorPipelineOppCount = sectorPipelineOppCountMap.get(sector)== null ? 0 : sectorPipelineOppCountMap.get(sector) ;
            omOpp.oppCount = sectorClosedOppCount + sectorPipelineOppCount ;

            if ((omOpp.ClosedLostRev + omOpp.ClosedWonRev) > 0) 
                omOpp.convRatio = (omOpp.ClosedWonRev) / (omOpp.ClosedLostRev + omOpp.ClosedWonRev);
            else 
                omOpp.convRatio = 0;
            
            if ((omOpp.ClosedLostRevLM + omOpp.ClosedWonRevLM) > 0) 
                omOpp.convRatioPM = (omOpp.ClosedWonRevLM) / (omOpp.ClosedLostRevLM + omOpp.ClosedWonRevLM);
            else 
                omOpp.convRatioPM = 0;         

            decimal pipeLineTotRev = sectorPipelineTotRevMap.get(sector)== null ? 0 : sectorPipelineTotRevMap.get(sector);
            decimal closedTotRev = sectorclosedtotRevMap.get(sector)== null ? 0 : sectorclosedtotRevMap.get(sector) ;
            omOpp.totalRev = pipeLineTotRev +  closedTotRev;

            if (omOpp.pipeLineRev > 0 || omOpp.ClosedWonRev >0 ||  omOpp.ClosedLostRev >0 || omOpp.ClosedWonRevLM >0 ||  omOpp.ClosedLostRevLM > 0 || omOpp.oppCount > 0 ||  omOpp.totalRev > 0 || omOpp.convRatio > 0 || omOpp.convRatioPM > 0)          
                oMlist.add(omOpp) ;
                
        }
        
        return oMlist ;
    }
   
    public String getAllOpportunityPipelineDivlst() {
        return JSON.serializePretty(getAllOpportunityPipelineDivlstRec());
    }
   
   //Franco Pipeline Home Page
    public list < OMDashboardUtilityClass.omOpportunityDiv > getAllOpportunityPipelineDivlstRec() {

        map<String, OMDashboardUtilityClass.omOpportunityDiv> francoPipelineDivMap = new map<String, OMDashboardUtilityClass.omOpportunityDiv>() ;
        
        for (OMDashboardUtilityClass.omOpportunityPipelineFranco francoPipeline :  AllOpportunityPipelineDrillDown){
          
            if (!francoPipelineDivMap.containsKey(francoPipeline.oppFranco)){
                francoPipelineDivMap.put(francoPipeline.oppFranco, new OMDashboardUtilityClass.omOpportunityDiv(francoPipeline.oppFranco, francoPipeline.cCovRev, francoPipeline.gmRev, francoPipeline.ibRev, francoPipeline.tpsRev, francoPipeline.reRev, francoPipeline.beRev, francoPipeline.glmRev, francoPipeline.totalRev, francoPipeline.currYearRev, francoPipeline.oppPipelineCount));
            }else{
                OMDashboardUtilityClass.omOpportunityDiv  varExist = francoPipelineDivMap.get(francoPipeline.oppFranco);
                varExist.beRev = varExist.beRev + francoPipeline.beRev ;
                varExist.cCovRev = varExist.cCovRev + francoPipeline.cCovRev ;
                varExist.gmRev = varExist.gmRev + francoPipeline.gmRev ;
                varExist.ibRev = varExist.ibRev + francoPipeline.ibRev ;
                varExist.tpsRev = varExist.tpsRev + francoPipeline.tpsRev ;
                varExist.reRev = varExist.reRev + francoPipeline.reRev ;
                varExist.glmRev = varExist.glmRev + francoPipeline.glmRev ;
                varExist.totalRev = varExist.totalRev + francoPipeline.totalRev ;
                varExist.currYearRev = varExist.currYearRev + francoPipeline.currYearRev ;
                varExist.oppPipelineCount = varExist.oppPipelineCount + francoPipeline.oppPipelineCount ;
                  
                if (varExist.beRev > 0 || varExist.cCovRev > 0 || varExist.gmRev >0 ||  varExist.ibRev >0 || varExist.tpsRev >0 ||  varExist.reRev > 0 || varExist.glmRev > 0 ||  varExist.totalRev > 0 || varExist.currYearRev > 0 || varExist.oppPipelineCount > 0)   
                    francoPipelineDivMap.put(francoPipeline.oppFranco,varExist) ;
             }
        }

        list < OMDashboardUtilityClass.omOpportunityDiv > olist = new list < OMDashboardUtilityClass.omOpportunityDiv >();
        set <String> keyss = francoPipelineDivMap.keySet();
        list <String> keys  = new list <String>();

        keys.addAll(keyss);
        keys.sort();

        for(String key : keys)
            olist.add(francoPipelineDivMap.get(key));
                        
        return olist;
    } 
    
    public String getAllOpportunityPipelineSectorDivlst() {
        return JSON.serializePretty(getAllOpportunityPipelineSectorDivlstRec());
    }
    
    //Sector Pipeline Home Page
    public  list < OMDashboardUtilityClass.omOpportunitySecDiv> getAllOpportunityPipelineSectorDivlstRec() {

        map<String, OMDashboardUtilityClass.omOpportunitySecDiv> sectorPipelineDivMap = new map<String, OMDashboardUtilityClass.omOpportunitySecDiv>() ;
        
        for (OMDashboardUtilityClass.omOpportunityPipelineFranco sectorPipeline :  AllOpportunityPipelineDrillDown){
                 
            if (!sectorPipelineDivMap.containsKey(sectorPipeline.oppSector)){
                sectorPipelineDivMap.put(sectorPipeline.oppSector ,new OMDashboardUtilityClass.omOpportunitySecDiv(sectorPipeline.oppSector, sectorPipeline.cCovRev, sectorPipeline.gmRev, sectorPipeline.ibRev, sectorPipeline.tpsRev, sectorPipeline.reRev, sectorPipeline.beRev, sectorPipeline.glmRev, sectorPipeline.totalRev, sectorPipeline.currYearRev, sectorPipeline.oppPipelineCount));
            }
            else{            
                OMDashboardUtilityClass.omOpportunitySecDiv  varExist = sectorPipelineDivMap.get(sectorPipeline.oppSector);
                varExist.beRev = varExist.beRev + sectorPipeline.beRev ;
                varExist.cCovRev = varExist.cCovRev + sectorPipeline.cCovRev ;
                varExist.gmRev = varExist.gmRev + sectorPipeline.gmRev ;
                varExist.ibRev = varExist.ibRev + sectorPipeline.ibRev ;
                varExist.tpsRev = varExist.tpsRev + sectorPipeline.tpsRev ;
                varExist.reRev = varExist.reRev + sectorPipeline.reRev ;
                varExist.glmRev = varExist.glmRev + sectorPipeline.glmRev ;
                varExist.totalRev = varExist.totalRev + sectorPipeline.totalRev ;
                varExist.currYearRev = varExist.currYearRev + sectorPipeline.currYearRev ;
                varExist.oppPipelineCount = varExist.oppPipelineCount + sectorPipeline.oppPipelineCount ;
                  
                if (varExist.beRev > 0 || varExist.cCovRev > 0 || varExist.gmRev >0 ||  varExist.ibRev >0 || varExist.tpsRev >0 ||  varExist.reRev > 0 || varExist.glmRev > 0 ||  varExist.totalRev > 0 || varExist.currYearRev > 0 || varExist.oppPipelineCount > 0)   
                    sectorPipelineDivMap.put(sectorPipeline.oppSector,varExist) ;
            }
        }

        list < OMDashboardUtilityClass.omOpportunitySecDiv > olist = new list < OMDashboardUtilityClass.omOpportunitySecDiv >();
        set <String> keyss = sectorPipelineDivMap.keySet();
        list <String> keys  = new list <String>();

        keys.addAll(keyss);
        keys.sort();

        for(String key : keys)
            olist.add(sectorPipelineDivMap.get(key));
                        
        return olist;     
    } 

    public String getAllClosedOpportunitylst() {
        return JSON.serializePretty(getAllClosedOpportunitylstRec());
    }
    
    //Franco Closed Opp home page    
    public list < OMDashboardUtilityClass.omOpportunityClosed >  getAllClosedOpportunitylstRec() {

        list < OMDashboardUtilityClass.omOpportunityClosed > oMClosedlist = new list < OMDashboardUtilityClass.omOpportunityClosed > ();

        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();
        
        map<String,Decimal> francorevWonLM = new map<String,Decimal>();
        map<String,Decimal> francorevLostLM = new map<String,Decimal>();

        // Aggregate Query to get the sum of revenue of all opportunities which have been closed till previous month and in Current Year.
        AggregateResult[] wonLostOppLastMonth = [Select
            Grouping(StageName) divisionStage,
            Grouping(Account.Client_Franco__c) francoTotalled,
            StageName,
            Account.Client_Franco__c,
            SUM(Current_Year_Revenue_Currency__c) revSum
            from Opportunity
            where((Actual_Close_Date__c = THIS_YEAR and Actual_Close_Date__c < THIS_MONTH and StageName IN('3 - Closed Won', '4 - Closed Lost')))
            AND(Account.RecordTypeId NOT IN('012200000009iov', '01220000000cZr1'))
            GROUP BY CUBE(StageName,
                Account.Client_Franco__c) ORDER BY Account.Client_Franco__c ASC
            limit 50000
        ];
        
          // Populating all the variables                                                                              
        for (AggregateResult allOpp: wonLostOppLastMonth) {

            String wonLostoppStage = (String) allOpp.get('StageName');
            String cFranco = (String) allOpp.get('Client_Franco__c');

            if (wonLostoppStage <> null && cFranco <> null && (double) allOpp.get('revSum') != null) {

                if (wonLostoppStage == '3 - Closed Won') {
                    francorevWonLM.put(cFranco,converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                }
                if (wonLostoppStage == '4 - Closed Lost') {
                    francorevLostLM.put(cFranco,converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                }
            }
        }
        
        map<String, Decimal> francoClosedWonCY = new map<String, Decimal>();
        map<String, Decimal> francoClosedLostCY = new map<String, Decimal>();
        map<String, Decimal> francoClosedWonPY = new map<String, Decimal>();
        map<String, Decimal> francoClosedLostPY = new map<String, Decimal>();
        
        Set<String> francoSet = new Set<String>();
        
        for (OMDashboardUtilityClass.omOpportunityClosedFranco closedOpp :  AllOpportunityClosedDrillDown){
              
            francoSet.add(closedOpp.oppFranco) ;
               
            if (!francoClosedWonCY.containsKey(closedOpp.oppFranco)) 
                francoClosedWonCY.put(closedOpp.oppFranco, closedOpp.WonCY);
            else
                francoClosedWonCY.put(closedOpp.oppFranco, francoClosedWonCY.get(closedOpp.oppFranco) + closedOpp.WonCY) ;
                  
            if (!francoClosedLostCY.containsKey(closedOpp.oppFranco)) 
                francoClosedLostCY.put(closedOpp.oppFranco, closedOpp.LostCY);
            else
                francoClosedLostCY.put(closedOpp.oppFranco, francoClosedLostCY.get(closedOpp.oppFranco) + closedOpp.LostCY) ;
                  
            if (!francoClosedWonPY.containsKey(closedOpp.oppFranco)) 
                francoClosedWonPY.put(closedOpp.oppFranco, closedOpp.WonPY);
            else
                francoClosedWonPY.put(closedOpp.oppFranco, francoClosedWonPY.get(closedOpp.oppFranco) + closedOpp.WonPY) ;
                  
            if (!francoClosedLostPY.containsKey(closedOpp.oppFranco)) 
                francoClosedLostPY.put(closedOpp.oppFranco, closedOpp.LostPY);
            else
                francoClosedLostPY.put(closedOpp.oppFranco, francoClosedLostPY.get(closedOpp.oppFranco) + closedOpp.LostPY) ;
               
        }
          
        list<string> francolst = new list<string>() ;
        francolst.addAll(francoSet);
        francolst.sort();
        for (String franco : francolst){
             
            OMDashboardUtilityClass.omOpportunityClosed closedOpp = new OMDashboardUtilityClass.omOpportunityClosed() ;
            
            closedOpp.oppFranco = franco;
            closedOpp.ClosedWonCYRev = francoClosedWonCY.get(franco)== null ? 0 : francoClosedWonCY.get(franco);
            closedOpp.ClosedWonPYRev =francoClosedWonPY.get(franco)== null ? 0 : francoClosedWonPY.get(franco);
            closedOpp.ClosedLostCYRev = francoClosedLostCY.get(franco)== null ? 0 : francoClosedLostCY.get(franco);
            closedOpp.ClosedLostPYRev = francoClosedLostPY.get(franco)== null ? 0 : francoClosedLostPY.get(franco);
            closedOpp.ClosedWonLM = francorevWonLM.get(franco)== null ? 0 : francorevWonLM.get(franco);
            closedOpp.ClosedLostLM = francorevLostLM.get(franco)== null ? 0 : francorevLostLM.get(franco);
            
            if ((closedOpp.ClosedLostCYRev + closedOpp.ClosedWonCYRev) > 0) 
                closedOpp.convRatio = (closedOpp.ClosedWonCYRev) / (closedOpp.ClosedLostCYRev + closedOpp.ClosedWonCYRev);
            else 
                closedOpp.convRatio = 0;
            
            if ((closedOpp.ClosedWonLM + closedOpp.ClosedLostLM) > 0) 
                closedOpp.convRatioLM = (closedOpp.ClosedWonLM) / (closedOpp.ClosedLostLM + closedOpp.ClosedWonLM);
            else 
                closedOpp.convRatioLM = 0;         
            
            if (closedOpp.ClosedWonCYRev > 0 || closedOpp.ClosedWonPYRev >0 ||  closedOpp.ClosedLostCYRev >0 || closedOpp.ClosedLostPYRev >0 ||  closedOpp.ClosedWonLM > 0 || closedOpp.ClosedLostLM > 0 || closedOpp.convRatio > 0 || closedOpp.convRatioLM > 0) 
                oMClosedlist.add(closedOpp);  
            }
      
        return oMClosedlist ;
    }
    
    public String getAllClosedOpportunitySeclst() {
        return JSON.serializePretty(getAllClosedOpportunitySeclstRec());
    }
    
    //Sector Closed Opp Home Page
    public list < OMDashboardUtilityClass.omOpportunitySecClosed >  getAllClosedOpportunitySeclstRec() {

        list < OMDashboardUtilityClass.omOpportunitySecClosed > oMClosedlist = new list < OMDashboardUtilityClass.omOpportunitySecClosed > ();
      
        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();
        
        Map<String,Decimal> sectorrevWonLM = new  Map<String,Decimal>();
        Map<String,Decimal> sectorrevLostLM = new  Map<String,Decimal>();
        
        // Aggregate Query to get the sum of revenue of all opportunities which have been closed till previous month and in Current Year.
        AggregateResult[] wonLostOppLastMonth = [Select
            Grouping(StageName) divisionStage,
            Grouping(Account.Client_Sector__c) sectorTotalled,
            StageName,
            Account.Client_Sector__c,
            SUM(Current_Year_Revenue_Currency__c) revSum
            from Opportunity
            where((Actual_Close_Date__c = THIS_YEAR and Actual_Close_Date__c < THIS_MONTH and StageName IN('3 - Closed Won', '4 - Closed Lost')))
            AND(Account.RecordTypeId NOT IN('012200000009iov', '01220000000cZr1'))
            GROUP BY CUBE(StageName, Account.Client_Sector__c) ORDER BY Account.Client_Sector__c ASC
            limit 50000
        ];

        // Populating all the variables                                                                              
        for (AggregateResult allOpp: wonLostOppLastMonth) {

            String wonLostoppStage = (String) allOpp.get('StageName');
            String cSector = (String) allOpp.get('Client_Sector__c');

            if (wonLostoppStage <> null && cSector <> null && (double) allOpp.get('revSum') != null) {

                if (wonLostoppStage == '3 - Closed Won') {
                    sectorrevWonLM.put(cSector,converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                }
                if (wonLostoppStage == '4 - Closed Lost') {
                    sectorrevLostLM.put(cSector,converter.convert(Double.valueOf(allOpp.get('revSum')), 'USD', RateMap, 'ZAR'));
                }
            }
        }
                    
        map<String, Decimal> sectorClosedWonCY = new map<String, Decimal>();
        map<String, Decimal> sectorClosedLostCY = new map<String, Decimal>();
        map<String, Decimal> sectorClosedWonPY = new map<String, Decimal>();
        map<String, Decimal> sectorClosedLostPY = new map<String, Decimal>();
        
        Set<String> sectorSet = new Set<String>();
        
        for (OMDashboardUtilityClass.omOpportunityClosedFranco closedOpp :  AllOpportunityClosedDrillDown){
              
            sectorSet.add(closedOpp.oppSector) ;              
            if (!sectorClosedWonCY.containsKey(closedOpp.oppSector)) 
                sectorClosedWonCY.put(closedOpp.oppSector, closedOpp.WonCY);
            else
                sectorClosedWonCY.put(closedOpp.oppSector, sectorClosedWonCY.get(closedOpp.oppSector) + closedOpp.WonCY) ;
                  
            if (!sectorClosedLostCY.containsKey(closedOpp.oppSector)) 
                sectorClosedLostCY.put(closedOpp.oppSector, closedOpp.LostCY);
            else
                sectorClosedLostCY.put(closedOpp.oppSector, sectorClosedLostCY.get(closedOpp.oppSector) + closedOpp.LostCY) ;
                  
            if (!sectorClosedWonPY.containsKey(closedOpp.oppSector)) 
                sectorClosedWonPY.put(closedOpp.oppSector, closedOpp.WonPY);
            else
                sectorClosedWonPY.put(closedOpp.oppSector, sectorClosedWonPY.get(closedOpp.oppSector) + closedOpp.WonPY) ;
                  
            if (!sectorClosedLostPY.containsKey(closedOpp.oppSector)) 
                sectorClosedLostPY.put(closedOpp.oppSector, closedOpp.LostPY);
            else
                sectorClosedLostPY.put(closedOpp.oppSector, sectorClosedLostPY.get(closedOpp.oppSector) + closedOpp.LostPY) ;
               
        }
          
        list<string> sectorlst = new list<string>() ;
        sectorlst.addAll(sectorSet);
        sectorlst.sort();
        for (String sector : sectorlst){
             
            OMDashboardUtilityClass.omOpportunitySecClosed closedOpp = new OMDashboardUtilityClass.omOpportunitySecClosed() ;
            
            closedOpp.oppSector = sector;
            closedOpp.ClosedWonCYRev = sectorClosedWonCY.get(sector)== null ? 0 : sectorClosedWonCY.get(sector);
            closedOpp.ClosedWonPYRev =sectorClosedWonPY.get(sector)== null ? 0 : sectorClosedWonPY.get(sector);
            closedOpp.ClosedLostCYRev = sectorClosedLostCY.get(sector)== null ? 0 : sectorClosedLostCY.get(sector);
            closedOpp.ClosedLostPYRev = sectorClosedLostPY.get(sector)== null ? 0 : sectorClosedLostPY.get(sector);
            closedOpp.ClosedWonLM = sectorrevWonLM.get(sector)== null ? 0 : sectorrevWonLM.get(sector);
            closedOpp.ClosedLostLM = sectorrevLostLM.get(sector)== null ? 0 : sectorrevLostLM.get(sector);

            if ((closedOpp.ClosedLostCYRev + closedOpp.ClosedWonCYRev) > 0) 
                closedOpp.convRatio = (closedOpp.ClosedWonCYRev) / (closedOpp.ClosedLostCYRev + closedOpp.ClosedWonCYRev);
            else 
                closedOpp.convRatio = 0;
            
            if ((closedOpp.ClosedWonLM + closedOpp.ClosedLostLM) > 0) 
                closedOpp.convRatioLM = (closedOpp.ClosedWonLM) / (closedOpp.ClosedLostLM + closedOpp.ClosedWonLM);
            else 
                closedOpp.convRatioLM = 0;         
            
            if (closedOpp.ClosedWonCYRev > 0 || closedOpp.ClosedWonPYRev >0 ||  closedOpp.ClosedLostCYRev >0 || closedOpp.ClosedLostPYRev >0 ||  closedOpp.ClosedWonLM > 0 || closedOpp.ClosedLostLM > 0 || closedOpp.convRatio > 0 || closedOpp.convRatioLM > 0) 
                oMClosedlist.add(closedOpp);  
            }
      
        return oMClosedlist ;
    }
    
    public String getAllOpportunityPipelineFrancolst() {
        return JSON.serializePretty(AllOpportunityPipelineDrillDown);
    }        
    
    public String getAllOpportunityClosedFrancolst() {
        return JSON.serializePretty(AllOpportunityClosedDrillDown);
    }
    
    /**Table**/

    public void AllOpportunityforTable() {
       
        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();

        // Query to get all opportunities for table
        list < Opportunity > topOpp = [select Id, 
            Name, 
            StageName, 
            Current_Year_Revenue_Currency__c, 
            Amount, CurrencyIsoCode, 
            Account.Name, 
            Account.Id, 
            Account.Client_Franco__c,
            Account.Client_Sector__c,
            Actual_Close_Date__c
            from Opportunity
            where (Account.RecordTypeId NOT IN('012200000009iov', '01220000000cZr1'))
            And IsPrivate = false
            Order by Current_Year_Revenue_Currency__c desc NULLS LAST limit 25000
        ];
        
        // Local variables
        Decimal cYear = 0;
        Decimal tYear = 0;
        // Integer to count the opp for table
        Integer countopp = 0;
        // Map to keep track of number of top opp per franco and sector of pipeline and closed opp
        map< String,Integer > mapcountopppipedrill = new map< String,Integer >(); 
        map< String,Integer > mapcountoppclosedwon = new map< String,Integer >();
        map< String,Integer > mapcountoppclosedlost = new map< String,Integer >();
        
        // Processing the records once and populating all the list to be used later
        for (Opportunity opp: topOpp) {                     

            cYear = converter.convert(Double.valueOf(opp.Current_Year_Revenue_Currency__c), String.valueOf(opp.CurrencyIsoCode), RateMap, 'ZAR');   
            tYear = converter.convert(Double.valueOf(opp.Amount), String.valueOf(opp.CurrencyIsoCode), RateMap, 'ZAR');
            
            // Populating the list of top opp for Pipeline View 
            if((opp.StageName == '1 - Lead' || opp.StageName == '2 - Develop') && countopp < Integer.valueof(Label.No_of_Top_Opp)){

                if (cYear != 0 || tYear != 0) {
                    omOpportunityTop.add(new OMDashboardUtilityClass.omOpportunityTop(opp.Account.Client_Franco__c, opp.Name, opp.Id, opp.Account.Name, opp.Account.Id, cYear, tYear));
                    omOpportunitySecTop.add(new OMDashboardUtilityClass.omOpportunitySecTop(opp.Account.Client_Sector__c, opp.Name, opp.Id, opp.Account.Name, opp.Account.Id, cYear, tYear));
                    countopp++;
                }
            }
            
            // Populating the list of top opp for Pipeline Drilldown View   
            if(opp.StageName == '1 - Lead' || opp.StageName == '2 - Develop'){

                if (!mapcountopppipedrill.containsKey(opp.Account.Client_Franco__c)){
                    mapcountopppipedrill.put(opp.Account.Client_Franco__c, 0);
                }
                if (!mapcountopppipedrill.containsKey(opp.Account.Client_Sector__c)){
                    mapcountopppipedrill.put(opp.Account.Client_Sector__c, 0);
                }

                if ((cYear != 0 || tYear != 0) && mapcountopppipedrill.get(opp.Account.Client_Franco__c) < Integer.valueof(Label.No_of_Top_Opp)) {              
                    omOppClosedFrancoViewpipe.add(new OMDashboardUtilityClass.omOppClosedFrancoView(opp.Account.Client_Franco__c, opp.Name, opp.Id, opp.Account.Name, opp.Account.Id, cYear, tYear));
                    mapcountopppipedrill.put(opp.Account.Client_Franco__c, (mapcountopppipedrill.get(opp.Account.Client_Franco__c) + 1));
                }
                if ((cYear != 0 || tYear != 0) && mapcountopppipedrill.get(opp.Account.Client_Sector__c) < Integer.valueof(Label.No_of_Top_Opp)) {              
                    omOpportunitySecToppipe.add(new OMDashboardUtilityClass.omOpportunitySecTop(opp.Account.Client_Sector__c, opp.Name, opp.Id, opp.Account.Name, opp.Account.Id, cYear, tYear));
                    mapcountopppipedrill.put(opp.Account.Client_Sector__c, (mapcountopppipedrill.get(opp.Account.Client_Sector__c) + 1));
                }               
            }
            
            // Populating the list of top opp for Closed Won Drilldown View 
            if(opp.StageName == '3 - Closed Won' && opp.Actual_Close_Date__c.year() == system.today().year()){          

                if (!mapcountoppclosedwon.containsKey(opp.Account.Client_Franco__c)){
                    mapcountoppclosedwon.put(opp.Account.Client_Franco__c, 0);
                }
                if (!mapcountoppclosedwon.containsKey(opp.Account.Client_Sector__c)){
                    mapcountoppclosedwon.put(opp.Account.Client_Sector__c, 0);
                }

                if ((cYear != 0 || tYear != 0) && mapcountoppclosedwon.get(opp.Account.Client_Franco__c) < Integer.valueof(Label.No_of_Top_CLosed_Won_Opp)) {
                    omOppClosedFrancoViewcw.add(new OMDashboardUtilityClass.omOppClosedFrancoView(opp.Account.Client_Franco__c, opp.Name, opp.Id, opp.Account.Name, opp.Account.Id, cYear, tYear));
                    mapcountoppclosedwon.put(opp.Account.Client_Franco__c, (mapcountoppclosedwon.get(opp.Account.Client_Franco__c) + 1));
                }
                if ((cYear != 0 || tYear != 0) && mapcountoppclosedwon.get(opp.Account.Client_Sector__c) < Integer.valueof(Label.No_of_Top_CLosed_Won_Opp)) {          
                    omOpportunitySecTopcw.add(new OMDashboardUtilityClass.omOpportunitySecTop(opp.Account.Client_Sector__c, opp.Name, opp.Id, opp.Account.Name, opp.Account.Id, cYear, tYear));
                    mapcountoppclosedwon.put(opp.Account.Client_Sector__c, (mapcountoppclosedwon.get(opp.Account.Client_Sector__c) + 1));
                }
            }
            
            // Populating the list of top opp for Closed Lost Drilldown View    
            if(opp.StageName == '4 - Closed Lost' && opp.Actual_Close_Date__c.year() == system.today().year()){  
                
                if (!mapcountoppclosedlost.containsKey(opp.Account.Client_Franco__c)){
                    mapcountoppclosedlost.put(opp.Account.Client_Franco__c, 0);
                }  
                if (!mapcountoppclosedlost.containsKey(opp.Account.Client_Sector__c)){
                    mapcountoppclosedlost.put(opp.Account.Client_Sector__c, 0);
                }                
       
                if ((cYear != 0 || tYear != 0) && mapcountoppclosedlost.get(opp.Account.Client_Franco__c) < Integer.valueof(Label.No_of_Top_CLosed_Lost_Opp)) {              
                    omOppClosedFrancoViewcl.add(new OMDashboardUtilityClass.omOppClosedFrancoView(opp.Account.Client_Franco__c, opp.Name, opp.Id, opp.Account.Name, opp.Account.Id, cYear, tYear));
                    mapcountoppclosedlost.put(opp.Account.Client_Franco__c, (mapcountoppclosedlost.get(opp.Account.Client_Franco__c) + 1));
                }
                if ((cYear != 0 || tYear != 0) && mapcountoppclosedlost.get(opp.Account.Client_Sector__c) < Integer.valueof(Label.No_of_Top_CLosed_Lost_Opp)) {                           
                    omOpportunitySecTopcl.add(new OMDashboardUtilityClass.omOpportunitySecTop(opp.Account.Client_Sector__c, opp.Name, opp.Id, opp.Account.Name, opp.Account.Id, cYear, tYear));
                    mapcountoppclosedlost.put(opp.Account.Client_Sector__c, (mapcountoppclosedlost.get(opp.Account.Client_Sector__c) + 1));
                }
            }
                                    
        }        
    }
        
    // To get the top opp for table Pipeline Franco View
    public String getTopOpp() { 
        omOpportunityTop.sort();    
        return JSON.serializePretty(omOpportunityTop);
    }

    // To get the top opp for table Pipeline Sector View
    public String getSectorTopOpp() {
        omOpportunitySecTop.sort();     
        return JSON.serializePretty(omOpportunitySecTop);
    }

    // To get the top opp for table Pipeline Drilldown Franco View
     public String getTopOppPipelineDrillDownFranco() {
        omOppClosedFrancoViewpipe.sort();       
        return JSON.serializePretty(omOppClosedFrancoViewpipe);
    }

    // To get the top opp for table Pipeline Drilldown Sector View
    public String getTopOppPipelineDrillDownSector() {
        omOpportunitySecToppipe.sort();
        return JSON.serializePretty(omOpportunitySecToppipe);
    }

    // To get the top opp for table Closed Won Franco View
    public String getTopOppClosedWonDrillDownFranco(){
        omOppClosedFrancoViewcw.sort();     
        return JSON.serializePretty(omOppClosedFrancoViewcw);
    }

    // To get the top opp for table Closed Lost Franco View
    public String getTopOppClosedLostDrillDownFranco() {
        omOppClosedFrancoViewcl.sort();     
        return JSON.serializePretty(omOppClosedFrancoViewcl);
    }

    // To get the top opp for table Closed Won Sector View
    public String getTopOppClosedWonPipelineDrillDownSector() {
        omOpportunitySecTopcw.sort();       
        return JSON.serializePretty(omOpportunitySecTopcw);
    }

    // To get the top opp for table Closed Lost Sector View
    public String getTopOppClosedLostPipelineDrillDownSector() {
        omOpportunitySecTopcl.sort();       
        return JSON.serializePretty(omOpportunitySecTopcl);
    } 
    
}