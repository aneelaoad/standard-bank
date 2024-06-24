/***
@ Func Area     	:  PBB Lifestyle
@ Author        	:  Mykhailo Reznyk
@ Date          	:  04.11.2019
@ User Story    	:  US-4424
@ Description 	    :  APEX Controller class for PBB_Lifestyle_PMT_Overview_Client_Page component.
***/
/* @ModifiedBy Emmanuel Mulea(Nocks)
* @date July 2022
* @Description : adding pmt method getPMTData
*/
public without sharing class PBB_Lifestyle_PMT_Overview_Controller {
    private static final SRV_Logger LOGGER_SERVICE = (SRV_Logger) SRV_Logger.newInstance();
    private static final PBB_SRV_GatewayAPI_GetTransactions.IService TRANSATION_INFO_SERVICE = PBB_SRV_GatewayAPI_GetTransactions.newInstance();
    
    /***
@ param  	    :  Id 	                              clientId 	   Current Client Id
@ return   	    :  Revenue_and_Profitability__c 	  recordData   Latest Revenue_and_Profitability__c object
@ Description 	:  Retrieves the latest related to current Client(Account) Revenue_and_Profitability__c object. Returns null if no related Revenue_and_Profitability__c objects with such Client Id were found.
***/
    @AuraEnabled
    public static Revenue_and_Profitability__c fetchData(Id clientId){
        
        Revenue_and_Profitability__c[] recordsData = [SELECT Id, Net_Interest_Income__c, Non_Interest_Revenue__c, Avarage_Credit_Balance__c, Avarage_Debit_Balance__c, Impairments__c, PMT_extract_date__c, Operating_Income__c,
                                                      YTD_Avarage_Credit_Balance__c, YTD_Avarage_Debit_Balance__c, YTD_Impairments__c, YTD_Net_Interest_Income__c, YTD_Non_Interest_Revenue__c, YTD_Operating_Income__c
                                                      FROM Revenue_and_Profitability__c
                                                      WHERE Client_Name__c =: clientId
                                                      ORDER BY PMT_extract_date__c DESC NULLS LAST, CreatedDate DESC  LIMIT 1 ];
        if(recordsData.size() == 0){    
            return null;
        } 
        return recordsData[0];
        
    }
    /**
     * @description fetches pmt data and displays it on aura cmp
     * @param clientId id
     * @return PMTFinacials
     */  
    @AuraEnabled
    public static PMTFinacials getPMTData(Id clientId){
        try {
            Account account = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{
                clientId
                    }).get(0);
            
            if (!PBB_RiskAndFacilitiesController.isPermited(account)) {
                throw new PBB_RiskAndFacilitiesController.ControllerException('unauthorized');
            }
            
            List<PBB_SRV_GatewayAPI_GetTransactions.PMTFinacials> pmtFinanceData = TRANSATION_INFO_SERVICE.getPMTFinacials(clientId);
            List<PMTFinacials> listOfPMTFinacials = new List<PMTFinacials>();
            PMTFinacials finData = calcAverage(pmtFinanceData);
            return finData;
        } 
        catch (Exception e) {
            LOGGER_SERVICE.log(e, PBB_Lifestyle_PMT_Overview_Controller.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            throw e;
        }
    }
    /**
     * @description runs calculations on pmt data returned from API by summing up figures
     * @param pmtFinanceData PMTFinacials
     * @return PMTFinacials
     */     
    public static PMTFinacials calcAverage(List<PBB_SRV_GatewayAPI_GetTransactions.PMTFinacials> pmtFinanceData){
        PMTFinacials tempPMTFin = new PMTFinacials();
        for(PBB_SRV_GatewayAPI_GetTransactions.PMTFinacials pmtFin:pmtFinanceData){
            
            tempPMTFin.AE_Number = pmtFin.AE_Number;
            tempPMTFin.Customer_Num = pmtFin.Customer_Num;
            tempPMTFin.Business_name = pmtFin.Business_name;
            tempPMTFin.OI += pmtFin.OI;
            tempPMTFin.NII += pmtFin.NII;
            tempPMTFin.NIR += pmtFin.NIR;
            tempPMTFin.Year_Month = getLatestYTD(tempPMTFin.trackYrMonth,pmtFin.Year_Month) ;
            tempPMTFin.trackYrMonth = pmtFin.Year_Month;
            tempPMTFin.YTD_Average_Credit_Balance += pmtFin.YTD_Average_Credit_Balance;
            tempPMTFin.YTD_Average_Debit_Balance += pmtFin.YTD_Average_Debit_Balance;
            tempPMTFin.Impairments += pmtFin.Impairments;
            tempPMTFin.Performing_Average_Credit_Balance += pmtFin.Performing_Average_Credit_Balance;
            tempPMTFin.Performing_Average_Debit_Balance += pmtFin.Performing_Average_Debit_Balance;
            tempPMTFin.YTD_Impairments += pmtFin.YTD_Impairments;
            tempPMTFin.YTD_OI += pmtFin.YTD_OI;
            tempPMTFin.YTD_NII += pmtFin.YTD_NII;
            tempPMTFin.YTD_NIR += pmtFin.YTD_NIR;
        }
        return tempPMTFin;
    }
    /**
     * @description gets the latest year_month 
     * @param yearMonthOld Integer
     * @param yearMonthNew Integer
     * @return Date
     */     
    public static Date getLatestYTD(Integer yearMonthOld, Integer yearMonthNew){
        String yrMonth;
        if(yearMonthOld>yearMonthNew){
            yrMonth = String.ValueOf(yearMonthOld);
        }
        else{
            yrMonth =  String.ValueOf(yearMonthNew);
        }
        String yr = yrMonth.substring(0,4);
        String mt = yrMonth.substring(4,6);
        Date yrMt = Date.newInstance(Integer.ValueOf(yr),Integer.ValueOf(mt),1);
        return yrMt;
    }
    public class PMTFinacials {
        
        @AuraEnabled
        public String AE_Number;
        @AuraEnabled
        public Integer Customer_Num;
        @AuraEnabled
        public String Business_name;
        @AuraEnabled
        public Double OI;
        @AuraEnabled
        public Double NII;
        @AuraEnabled
        public Double NIR;
        @AuraEnabled
        public Date Year_Month;
        @AuraEnabled
        public Double YTD_Average_Credit_Balance;
        @AuraEnabled
        public Double YTD_Average_Debit_Balance;
        @AuraEnabled
        public Double Impairments;
        @AuraEnabled
        public Double Performing_Average_Credit_Balance;
        @AuraEnabled
        public Double Performing_Average_Debit_Balance;
        @AuraEnabled
        public Double YTD_Impairments;
        @AuraEnabled
        public Double YTD_OI;
        @AuraEnabled
        public Double YTD_NII;
        @AuraEnabled
        public Double YTD_NIR;
        @AuraEnabled
        public Integer trackYrMonth;
        public PMTFinacials(){
            this.OI = 0;
            this.NII = 0;
            this.NIR = 0;
            this.trackYrMonth = 0;
            this.YTD_Average_Credit_Balance = 0;
            this.YTD_Average_Debit_Balance = 0;
            this.Impairments = 0;
            this.Performing_Average_Credit_Balance = 0;
            this.Performing_Average_Debit_Balance=0;
            this.YTD_Impairments = 0;
            this.YTD_OI = 0;
            this.YTD_NII = 0;
            this.YTD_NIR = 0;
            
        }
    }
}