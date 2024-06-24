@IsTest
public without sharing class BLD_RevenueAndProfitability extends ABS_ObjectBuilderBase {
    public static final String DEF_NAME = 'testRevenue';

	public BLD_RevenueAndProfitability() { 
		super(Revenue_and_Profitability__c.SObjectType);
		init();
	}

    public BLD_RevenueAndProfitability(fflib_SObjectUnitOfWork workUnit) {
        super(Revenue_and_Profitability__c.sObjectType, workUnit);
        setDefaultData();
    }

    protected override void setDefaultData() {
        setField(Revenue_and_Profitability__c.Name, DEF_NAME);
    }

    public BLD_RevenueAndProfitability(Revenue_and_Profitability__c rap) { 
        super(rap);
    }

    private void init(){
    	setField(Revenue_and_Profitability__c.PMT_extract_date__c, System.today());
    }

    public BLD_RevenueAndProfitability averageCreditBalance(Integer value){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Avarage_Credit_Balance__c , value);
    }

    public BLD_RevenueAndProfitability averageDebitBalance(Integer value){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Avarage_Debit_Balance__c , value);
    }

    public BLD_RevenueAndProfitability impairments(Integer value){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Impairments__c , value);
    }

    public BLD_RevenueAndProfitability name(String name){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Name , name);
    }

    public BLD_RevenueAndProfitability netInterestIncome(Decimal value){
    	return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Net_Interest_Income__c , value);
    }

    public BLD_RevenueAndProfitability nonInterestRevenue(Decimal value){
    	return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Non_Interest_Revenue__c , value);
    }

    public BLD_RevenueAndProfitability operatingIncome(Decimal value){
    	return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Operating_Income__c , value);
    }

    public BLD_RevenueAndProfitability headlineErnings(Decimal value){
    	return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Headline_Earnings__c , value);
    }

    public BLD_RevenueAndProfitability roe(Decimal value){
    	return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.ROE__c , value);
    }

    public BLD_RevenueAndProfitability accountId(Id accId){
    	return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Client_Name__c , accId);
    }

    public BLD_RevenueAndProfitability groupNumber(String groupNumber){
    	return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.Relationship_Group_Number__c , groupNumber);
    }

    public BLD_RevenueAndProfitability pmtExtractDate(Date pmtDate){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.PMT_extract_date__c , pmtDate);
    }

    public BLD_RevenueAndProfitability ytdAverageCreditBalance(Integer value){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.YTD_Avarage_Credit_Balance__c , value);
    }

    public BLD_RevenueAndProfitability ytdAverageDebitBalance(Integer value){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.YTD_Avarage_Debit_Balance__c , value);
    }

    public BLD_RevenueAndProfitability ytdImpairments(Integer value){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.YTD_Impairments__c , value);
    }

    public BLD_RevenueAndProfitability ytdNetInterestIncome(Integer value){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.YTD_Net_Interest_Income__c , value);
    }

    public BLD_RevenueAndProfitability ytdNonInterestRevenue(Integer value){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.YTD_Non_Interest_Revenue__c , value);
    }

    public BLD_RevenueAndProfitability ytdOperatingIncome(Integer value){
        return (BLD_RevenueAndProfitability)setField(Revenue_and_Profitability__c.YTD_Operating_Income__c , value);
    }
}