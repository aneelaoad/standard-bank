/*****************************************************************************************************
    @ Func Area     : Client Plan
    @ Author        : Aneske Meiring
    @ Date          : 09/2013
    @ Test File     : FinancialAnalysisController_TestCP.cls
    @ Description   : This controller is used for creating the Financial Analysis VF componnet which is used in the client wallet section of the client plan.

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Dec 11, 2015
    @ Modification Description : EN-928 - fetching client's Sub Sector
******************************************************************************************************/

public with sharing class PublicFinancialAnalysisController {
 
   public WRP_Account accountObj {get;set;}
   public String thisFinAnalysisDataId{get; set;}
   public String thisKeyIndCreditLineId{get; set;}
   public String RIskRating {get ; set;}
   public String sharePriceLastYears {get ; set;}
   public Decimal marketCapitalisation {get ; set;}
   public Integer Employees {get ; set;}
   public string globalSector {get;set;}
   public String globalSubSector {get;set;}
   public decimal CROCZAR {get;set;}
   public decimal capUtilization {get;set;}
   public String clientId{get;set;}
   
   
   // Variables to hold the vlaues for total Credit Limit and total Utilisation
   public decimal sumTotalCreditLimit {get;set;}
   public decimal sumTotalUtilitsation {get;set;}
   
   public Client_Plan__c[] cPlan = new Client_Plan__c[1]; 
   
   //Create CreditLine List
    //List<Credit_Line__c> cl;
  

  //Create Financial Analysis List
  List<Client_Financial_Analysis__c > FAList = new List<Client_Financial_Analysis__c>();
    List<Client_Financial_Analysis__c > CFAList = new List<Client_Financial_Analysis__c>();

    public String CurrencyIsoCode = '';
  
   public cPlanFinAnalysis cplanFinResult {get;set;}
   public list<cPlanCreditLines> cCreditLineResult {get;set;}
   
   public  PublicFinancialAnalysisController() {
      init();
    /*    RIskRating = '';
        globalSector = '';
        globalSubSector = '';
    clientId = ApexPages.currentPage().getParameters().get('id');
    this.cPlan = [Select Id
                        , LastModifiedDate
                        , CurrencyIsoCode
                        , Name
                        , Client_Name__c 
                  FROM Client_Plan__c 
                  WHERE Client_Name__c =: ApexPages.currentPage().getParameters().get('id')
                  ORDER BY LastModifiedDate 
                  DESC LIMIT 1];
    
    ClientPlanClass cp = new ClientPlanClass(); 
    cp.snapCurrencyTable(); 
   
    ClientPlanClass.currencyConverter converter = new ClientPlanClass.currencyConverter();              
    list<Account> acc = [Select Id 
                              , Internal_Credit_Rating__c
                              , NumberOfEmployees
                              , Market_Capitalisation__c
                              , Share_price_over_last_3_years__c
                              , Client_Sector__c
                              , Client_Sub_Sector__c 
                              , Economic_Group_Parent__c
                        FROM Account WHERE Id =: ApexPages.currentPage().getParameters().get('id')  
                        limit 1];
    if(acc.isEmpty())
      return;
    account = new WRP_Account(acc[0]);
    RIskRating = acc[0].Internal_Credit_Rating__c ;
    Employees  = acc[0].NumberOfEmployees ;
    globalSector = acc[0].Client_Sector__c ;
    globalSubSector = acc[0].Client_Sub_Sector__c;
    if(acc[0].Market_Capitalisation__c != NULL){
        marketCapitalisation = converter.convert(Double.valueOf(acc[0].Market_Capitalisation__c),String.valueOf(acc[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode)/1000;
    }else
        marketCapitalisation = null;
    sharePriceLastYears = acc[0].Share_price_over_last_3_years__c ;
    
     list<Client_Capital_and_Revenue__c> clientCapRevenuelst = [select Id ,Capital_Utilisation_ZAR__c,Capital_Utilisation_USD__c, CROC_ZAR__c from Client_Capital_and_Revenue__c where  Client__c =: ApexPages.currentPage().getParameters().get('id') limit 1];
     
     if(clientCapRevenuelst.size() >0){
         if (!cPlan.isEmpty()){
                 if(cPlan[0].CurrencyIsoCode == 'ZAR'){
                     capUtilization =  clientCapRevenuelst[0].Capital_Utilisation_ZAR__c ;
                     CROCZAR = clientCapRevenuelst[0].CROC_ZAR__c ;
                  }
                     if(cPlan[0].CurrencyIsoCode == 'USD'){
                         capUtilization =  clientCapRevenuelst[0].Capital_Utilisation_USD__c ;
                         CROCZAR = clientCapRevenuelst[0].CROC_ZAR__c ;
                     }
                 }
         else{
         capUtilization =  clientCapRevenuelst[0].Capital_Utilisation_ZAR__c ;
             CROCZAR = clientCapRevenuelst[0].CROC_ZAR__c ;
         }
     }*/
   } 
   
   public  PublicFinancialAnalysisController(ApexPages.StandardController controller) {
    init();
    /*RIskRating = '';
    globalSector = '';
    globalSubSector = '';

    clientId = ApexPages.currentPage().getParameters().get('id');
    this.cPlan = [Select Id
                        , LastModifiedDate
                        , CurrencyIsoCode
                        , Name
                        , Client_Name__c 
                  FROM Client_Plan__c 
                  WHERE Client_Name__c =: clientId
                  ORDER BY LastModifiedDate 
                  DESC LIMIT 1];
                  
    ClientPlanClass cp = new ClientPlanClass(); 
    cp.snapCurrencyTable(); 
   
    ClientPlanClass.currencyConverter converter = new ClientPlanClass.currencyConverter();
    list<Account> acc = [Select Id 
                              , Internal_Credit_Rating__c
                              , NumberOfEmployees
                              , Market_Capitalisation__c
                              , Share_price_over_last_3_years__c
                              , Client_Sector__c
                              , Client_Sub_Sector__c
                              , Economic_Group_Parent__c 
                        FROM Account WHERE Id =: ApexPages.currentPage().getParameters().get('id') 
                        LIMIT 1];
    if(acc.isEmpty())
      return;
    account = new WRP_Account(acc[0]);
    RIskRating = acc[0].Internal_Credit_Rating__c ;
    Employees  = acc[0].NumberOfEmployees ;
    globalSector = acc[0].Client_Sector__c ;
    globalSubSector = acc[0].Client_Sub_Sector__c;
    if(acc[0].Market_Capitalisation__c != NULL){
        marketCapitalisation = converter.convert(Double.valueOf(acc[0].Market_Capitalisation__c),String.valueOf(acc[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode)/1000;
    }else
        marketCapitalisation = null;
    sharePriceLastYears = acc[0].Share_price_over_last_3_years__c ;
    
    list<Client_Capital_and_Revenue__c> clientCapRevenuelst = [select Id ,Capital_Utilisation_ZAR__c,Capital_Utilisation_USD__c, CROC_ZAR__c from Client_Capital_and_Revenue__c where  Client__c =: ApexPages.currentPage().getParameters().get('id') limit 1];
    
      if(clientCapRevenuelst.size() >0){
         if (!cPlan.isEmpty()){
                 if(cPlan[0].CurrencyIsoCode == 'ZAR'){
                     capUtilization =  clientCapRevenuelst[0].Capital_Utilisation_ZAR__c ;
                     CROCZAR = clientCapRevenuelst[0].CROC_ZAR__c ;
                  }
                     if(cPlan[0].CurrencyIsoCode == 'USD'){
                         capUtilization =  clientCapRevenuelst[0].Capital_Utilisation_USD__c ;
                         CROCZAR = clientCapRevenuelst[0].CROC_ZAR__c ;
                     }
                 }
         else{
         capUtilization =  clientCapRevenuelst[0].Capital_Utilisation_ZAR__c ;
             CROCZAR = clientCapRevenuelst[0].CROC_ZAR__c ;
         }
     }*/
     
   } 

   private void init(){
      RIskRating = '';
    globalSector = '';
    globalSubSector = '';

    clientId = ApexPages.currentPage().getParameters().get('id');
    this.cPlan = [Select Id
                        , LastModifiedDate
                        , CurrencyIsoCode
                        , Name
                        , Client_Name__c 
                  FROM Client_Plan__c 
                  WHERE Client_Name__c =: clientId
                  ORDER BY LastModifiedDate 
                  DESC LIMIT 1];
                  
    ClientPlanClass cp = new ClientPlanClass(); 
    cp.snapCurrencyTable(); 
   
    ClientPlanClass.currencyConverter converter = new ClientPlanClass.currencyConverter();
    list<Account> acc = [Select Id
                              , Name 
                              , Internal_Credit_Rating__c
                              , NumberOfEmployees
                              , Market_Capitalisation__c
                              , Share_price_over_last_3_years__c
                              , Client_Sector__c
                              , Client_Sub_Sector__c
                              , Economic_Group_Parent_Client_Name__c 
                        FROM Account WHERE Id =: ApexPages.currentPage().getParameters().get('id') 
                        LIMIT 1];
    if(acc.isEmpty())
      return;
    accountObj = new WRP_Account(acc[0]);
    RIskRating = acc[0].Internal_Credit_Rating__c ;
    Employees  = acc[0].NumberOfEmployees ;
    globalSector = acc[0].Client_Sector__c ;
    globalSubSector = acc[0].Client_Sub_Sector__c;
    if(acc[0].Market_Capitalisation__c != NULL){
        marketCapitalisation = converter.convert(Double.valueOf(acc[0].Market_Capitalisation__c),String.valueOf(acc[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode)/1000;
    }else
        marketCapitalisation = null;
    sharePriceLastYears = acc[0].Share_price_over_last_3_years__c ;
    
    list<Client_Capital_and_Revenue__c> clientCapRevenuelst = [select Id ,Capital_Utilisation_ZAR__c,Capital_Utilisation_USD__c, CROC_ZAR__c from Client_Capital_and_Revenue__c where  Client__c =: ApexPages.currentPage().getParameters().get('id') limit 1];
    
      if(clientCapRevenuelst.size() >0){
         if (!cPlan.isEmpty()){
                 if(cPlan[0].CurrencyIsoCode == 'ZAR'){
                     capUtilization =  clientCapRevenuelst[0].Capital_Utilisation_ZAR__c ;
                     CROCZAR = clientCapRevenuelst[0].CROC_ZAR__c ;
                  }
                     if(cPlan[0].CurrencyIsoCode == 'USD'){
                         capUtilization =  clientCapRevenuelst[0].Capital_Utilisation_USD__c ;
                         CROCZAR = clientCapRevenuelst[0].CROC_ZAR__c ;
                     }
                 }
         else{
         capUtilization =  clientCapRevenuelst[0].Capital_Utilisation_ZAR__c ;
             CROCZAR = clientCapRevenuelst[0].CROC_ZAR__c ;
         }
     }
   }



       public date creditLineSnapshotDate {
       
      
        get {
            try {
                String SOQL = 'SELECT ' +
                       + 'Max(Snapshot_Date__c) SnapshotDate '+
                       + 'FROM Credit_Line__c ' +
                       + 'WHERE Client_Name__c = :clientId' +
                       + (accountObj.getIsEconomicGroupParent()? ' OR Client_Name__r.Economic_Group_Parent__c = :clientId': '');

                if(clientId != null || clientId != ''){
                    AggregateResult[] theSnapshotDate = Database.query(SOQL);
                                             
                   return (Date)theSnapshotDate[0].get('SnapshotDate');
                }                             
            }catch (Exception e){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()+' thrown in: '+e.getStackTraceString()));
            }
            return Date.today();
        }
        private set; 
   }{ creditLineSnapshotDate = Date.today(); } 
   public cPlanFinAnalysis getFin(){ 
    
    Set<Id> PFAids = new Set<ID>();
    Set<ID> manPFAids = new Set<ID>();
    ClientPlanClass cp = new ClientPlanClass(); 
    cp.snapCurrencyTable(); 
   
    ClientPlanClass.currencyConverter converter = new ClientPlanClass.currencyConverter();
    
    Decimal trevEBITDA = 0.0;
       Decimal ttotalRev = 0.0;
    
    Decimal tNetProfitForThePeriod = 0.0; // jan 26,2016 
    Decimal tTotalAssets = 0.0;
    Decimal tTotalLiabilities = 0.0;
    Decimal tOperatingCashflow = 0.0;
    Decimal tTangibleNetWorth = 0.0;
      
    Map<ID,RecordType> rt_Map = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Client_Financial_Analysis__c']);
    FAList = [Select ID, 
               Client_Name__c, 
               EBITDA__c, 
               Debt_Ratio__c, 
               Statement_Date__c,
               Client_Name__r.Internal_Credit_Rating__c,
               Client_Name__r.NumberOfEmployees,
               CurrencyIsoCode,
               recordtypeId,
               LastModifiedDate,
               Net_profit_for_the_period__c,  // jan 26,2016 - Added fields
               Total_assets__c,
               Total_liabilities__c,
               Operating_cashflow__c,
               Tangible_Net_Worth__c,
               Total_Revenue__c
               FROM Client_Financial_Analysis__c 
               WHERE Client_Name__c = :ApexPages.currentPage().getParameters().get('id')];   
               
       //Check if the Financial Analysis list is empty or not
        if(!FAList.isEmpty())
        {
            for(Client_Financial_Analysis__c loopPFA: FAList)
            {
                if(rt_map.get(loopPFA.recordTypeID).name.containsIgnoreCase('Spreadpac Feed'))
                {
                    PFAids.add(loopPFA.id);
                }
                else
                {
                    manPFAids.add(loopPFA.id);
                }
            }  
            if(PFAids.size()>0)
            {
                CFAList= [Select ID, 
                       Client_Name__c, 
                       EBITDA__c, 
                       Debt_Ratio__c, 
                       Statement_Date__c,
                       Client_Name__r.Internal_Credit_Rating__c,
                       Client_Name__r.NumberOfEmployees,
                       CurrencyIsoCode,
                       recordtypeId,
                       LastModifiedDate,
                       Net_profit_for_the_period__c, // jan 26,2016 - Added fields
                   Total_assets__c,
                   Total_liabilities__c,
                   Operating_cashflow__c,
                   Tangible_Net_Worth__c,
                   Total_Revenue__c
                       FROM Client_Financial_Analysis__c 
                       WHERE id in:PFAids
                       ORDER BY Statement_Date__c Desc LIMIT 1];
                cplanFinResult = new cPlanFinAnalysis(CFAList[0]);
           
                trevEBITDA = converter.convert(Double.valueOf(CFAList[0].EBITDA__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.revEBITDA = trevEBITDA/1000;
                //trevMarCapita = converter.convert(Double.valueOf(FAList[0].Market_Capitalisation__c),String.valueOf(FAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                //cplanFinResult.revMarCapita = trevMarCapita ;
                ttotalRev = converter.convert(Double.valueOf(CFAList[0].Total_Revenue__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.totalRev = ttotalRev/1000 ;
                
                // jan 26,2016 added new fields and converion is necessary
                tNetProfitForThePeriod = converter.convert(Double.valueOf(CFAList[0].Net_profit_for_the_period__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.netProfitForThePeriod = tNetProfitForThePeriod/1000 ;
                
                tTotalAssets = converter.convert(Double.valueOf(CFAList[0].Total_assets__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.totalAssets = tTotalAssets/1000 ;
                
                tTotalLiabilities = converter.convert(Double.valueOf(CFAList[0].Total_liabilities__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.totalLiabilities = tTotalLiabilities/1000 ;
                
                tOperatingCashflow = converter.convert(Double.valueOf(CFAList[0].Operating_cashflow__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.operatingCashflow = tOperatingCashflow/1000 ;
                
                tTangibleNetWorth = converter.convert(Double.valueOf(CFAList[0].Tangible_Net_Worth__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.tangibleNetWorth = tTangibleNetWorth/1000 ; 
                
              } 
              else
              {
                CFAList= [Select ID, 
                       Client_Name__c, 
                       EBITDA__c, 
                       Debt_Ratio__c, 
                       Statement_Date__c,
                       Client_Name__r.Internal_Credit_Rating__c,
                       Client_Name__r.NumberOfEmployees,
                       CurrencyIsoCode,
                       recordtypeId,
                       LastModifiedDate,
                       Net_profit_for_the_period__c,  // jan 26,2016 - Added fields
                   Total_assets__c,
                   Total_liabilities__c,
                   Operating_cashflow__c,
                   Tangible_Net_Worth__c,
                   Total_Revenue__c
                       FROM Client_Financial_Analysis__c 
                       WHERE id in:manPFAids
                       ORDER BY Statement_Date__c Desc LIMIT 1];
                cplanFinResult = new cPlanFinAnalysis(CFAList[0]);
           
                trevEBITDA = converter.convert(Double.valueOf(CFAList[0].EBITDA__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.revEBITDA = trevEBITDA/1000;
                //trevMarCapita = converter.convert(Double.valueOf(FAList[0].Market_Capitalisation__c),String.valueOf(FAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                //cplanFinResult.revMarCapita = trevMarCapita ;
                ttotalRev = converter.convert(Double.valueOf(CFAList[0].Total_Revenue__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.totalRev = ttotalRev/1000 ; 
                
                // jan 26,2016 added new fields and converion is necessary
                tNetProfitForThePeriod = converter.convert(Double.valueOf(CFAList[0].Net_profit_for_the_period__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.netProfitForThePeriod = tNetProfitForThePeriod/1000 ;
                
                tTotalAssets = converter.convert(Double.valueOf(CFAList[0].Total_assets__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.totalAssets = tTotalAssets/1000 ;
                
                tTotalLiabilities = converter.convert(Double.valueOf(CFAList[0].Total_liabilities__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.totalLiabilities = tTotalLiabilities/1000 ;
                
                tOperatingCashflow = converter.convert(Double.valueOf(CFAList[0].Operating_cashflow__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.operatingCashflow = tOperatingCashflow/1000 ;
                
                tTangibleNetWorth = converter.convert(Double.valueOf(CFAList[0].Tangible_Net_Worth__c),String.valueOf(CFAList[0].CurrencyIsoCode),cp.RateMap,cPlan[0].CurrencyIsoCode);
                cplanFinResult.tangibleNetWorth = tTangibleNetWorth/1000 ; 
              }
      }
      else{
         cplanFinResult = new cPlanFinAnalysis(new Client_Financial_Analysis__c());
      }
       
       return cplanFinResult; 
     } 
    
      public String getCurrencyIsoCode(){
        this.CurrencyIsoCode = cPlan[0].CurrencyIsoCode;
        return this.CurrencyIsoCode;
    }  
     
     
     //Wrapper Object for Public Financial Analysis
     public class cPlanFinAnalysis {
        public Client_Financial_Analysis__c pubFinAnalysis {get;set;}
        public Decimal revEBITDA{get; set; }
        public Decimal revMarCapita{get; set; }
        public Decimal totalRev{get; set; }
        
        // jan 26,2016
        public Decimal netProfitForThePeriod{get; set; }
        public Decimal totalAssets{get; set; }
        public Decimal totalLiabilities{get; set; }
        public Decimal operatingCashflow{get; set; }
        public Decimal tangibleNetWorth{get; set; }
        
      
       public cPlanFinAnalysis(){
            pubFinAnalysis = new Client_Financial_Analysis__c();
        }
     
        public cPlanFinAnalysis(Client_Financial_Analysis__c pfa){
            pubFinAnalysis = pfa;
        }
     }
     
       public list<cPlanCreditLines> getcl(){ 
        
        /*ClientPlanClass cp = new ClientPlanClass(); 
        cp.snapCurrencyTable(); */
        
        if (cCreditLineResult != null)
          return cCreditLineResult;
        
        cCreditLineResult = new List<cPlanCreditLines>();
        CurrencyConverter converter = new CurrencyConverter();

        Decimal tcreditLimit = 0.0;
        Decimal ttotalUtilisation = 0.0;
            //set the sum values to zero
        sumTotalCreditLimit = 0.0;
        sumTotalUtilitsation = 0.0;
        
        String SOQL = 'SELECT' +
                     + ' Product__c' +
                     + ', SUM(Credit_Limit__c) creditLimit'+
                     + ', SUM(Total_utilisation__c) totalUtilisation' +
                     + ' FROM Credit_Line__c' +
                     + ' WHERE '+
                     + ' Client_Name__c=:clientId'
                     + (accountObj.getIsEconomicGroupParent()? ' OR Client_Name__r.Economic_Group_Parent__c=:clientId': '') +
                     + ' GROUP BY Product__c';
        System.debug('>>> SOQL: '+SOQL);
        AggregateResult[] crecitLinesByProduct = Database.query(SOQL);
        
               /*cl  = [Select Id, 
                               Credit_Limit__c,
                               Client_Name__c,
                               Product__c,
                               CurrencyIsoCode, 
                               Total_utilisation__c 
                               FROM Credit_Line__c
                               WHERE Client_Name__c = :ApexPages.currentPage().getParameters().get('id') 
                               ORDER by Product__c
                               ];*/
            
            for (AggregateResult productCreditLine : crecitLinesByProduct){
                
                cPlanCreditLines cLine = new cPlanCreditLines((String)productCreditLine.get('Product__c'));

                tcreditLimit = converter.convertCorporateCurrency((Double)productCreditLine.get('creditLimit'),cPlan[0].CurrencyIsoCode);
                cLine.creditLimit = tcreditLimit.divide(1000, 2);
                ttotalUtilisation = converter.convertCorporateCurrency((Double)productCreditLine.get('totalUtilisation'),cPlan[0].CurrencyIsoCode);
                cLine.totalUtilisation = ttotalUtilisation.divide(1000, 2);
                
                // get the Sum of Credit Limit and Total Utilisation
                sumTotalCreditLimit = sumTotalCreditLimit + cLine.creditLimit;
                sumTotalUtilitsation = sumTotalUtilitsation + cLine.totalUtilisation;
                
                cCreditLineResult.add(cLine);
            }
           
           return cCreditLineResult;                       
       } 
   
   //Wrapper Object for Credit Lines
    public class cPlanCreditLines {
        public String productName {get;set;}
        public Decimal creditLimit {get; set;}
        public Decimal totalUtilisation {get ; set;}
        
        public cPlanCreditLines(){
            //cCreditLines= new Credit_Line__c();
        }
        
        public cPlanCreditLines(String productName){
            this.productName= productName;
        }
        
    } 
 
     
  }