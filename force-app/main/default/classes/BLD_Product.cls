/**
 * Builder class for SB_Product SObject
*/
@IsTest
@SuppressWarnings('PMD.ExcessivePublicCount')
public without sharing class BLD_Product extends ABS_ObjectBuilderBase {

	public static final Decimal DEF_TOTAL = 100;

	public BLD_Product() { 
		this(getNewUnitOfWork());        
	}

    public BLD_Product(fflib_SObjectUnitOfWork workUnit) { 
        super(SB_Product__c.SObjectType, workUnit);
    }

    private BLD_Product(SB_Product__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

	protected override void setDefaultData(){
		setField(SB_Product__c.Total_Margin__c, DEF_TOTAL)
		.setField(SB_Product__c.Current_Year_Margin__c, DEF_TOTAL)
		.setField(SB_Product__c.Total_Fees__c, DEF_TOTAL)
		.setField(SB_Product__c.Current_Year_Fees__c, DEF_TOTAL);
	}

	public BLD_Product useAdvisory() {
		return (BLD_Product) setField(SB_Product__c.RecordTypeId,
			UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_ADVISORY));
	}

	public BLD_Product useCapitalMarkets() {
		return (BLD_Product) setField(SB_Product__c.RecordTypeId,
				UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_CAPITAL_MARKETS));
	}

	public BLD_Product linkToOpp(String oppId){
		return (BLD_Product)setField(SB_Product__c.Opportunity__c, oppId);
	}

	public BLD_Product linkToOpp(BLD_Opportunity bOpp){
		return (BLD_Product)setRelation(SB_Product__c.Opportunity__c, bOpp);
	}

	public BLD_Product notionalValue(Decimal value){
		return (BLD_Product)setField(SB_Product__c.Facility_Size__c, value);
	}

	public BLD_Product sbHold(Decimal value){
		return (BLD_Product)setField(SB_Product__c.SB_Hold__c, value);
	}

	public BLD_Product sbSellDown(Decimal value){
		return (BLD_Product)setField(SB_Product__c.SB_Sell_Down__c, value);
	}

	public BLD_Product balanceSheetOfBooking(String bsob){
		return (BLD_Product) setField(SB_Product__c.Balance_Sheet_of_Booking__c, bsob);
	}

	public BLD_Product transactionType(String transactionType){
		return (BLD_Product) setField(SB_Product__c.Transaction_Type__c, transactionType);
	}

	public BLD_Product currentYearFees(Decimal currentYearFees){
	  return (BLD_Product) setField(SB_Product__c.Current_Year_Fees__c, currentYearFees);
	}

	public BLD_Product currentYearMargin(Decimal currentYearMargin){
	  return (BLD_Product) setField(SB_Product__c.Current_Year_Margin__c, currentYearMargin);
	}

	public BLD_Product notionalValueCurrency(Decimal value){
		return (BLD_Product)setField(SB_Product__c.SB_Gross_Participation__c, value);
	}

	public BLD_Product currency(String isoCode){
		return (BLD_Product)setField(SB_Product__c.CurrencyIsoCode, isoCode);
	}

	public BLD_Product grandParentProduct(String gpp){
		return (BLD_Product) setField(SB_Product__c.Grand_Parent_Product__c, gpp);
	}

	public BLD_Product riskWeightedValue(Decimal riskWeightedValue){
		return (BLD_Product) setField(SB_Product__c.Risk_Weighted_Value__c, riskWeightedValue);
	}

	public BLD_Product totalFees(Decimal totalFees){
		return (BLD_Product) setField(SB_Product__c.Total_Fees__c, totalFees);
	}

	public BLD_Product feeFrequency(String feeFreq){
		return (BLD_Product) setField(SB_Product__c.Fee_Frequency__c, feeFreq);
	}

	public BLD_Product feeAmount(Decimal feeAmount){
		return (BLD_Product) setField(SB_Product__c.Fee_Amount__c, feeAmount);
	}

	public BLD_Product billingStartDate(Date billingStart){
		return (BLD_Product) setField(SB_Product__c.Billing_Start_Date__c, billingStart);
	}

	public BLD_Product billingEndDate(Date billingEnd){
		return (BLD_Product) setField(SB_Product__c.Billing_End_Date__c, billingEnd);
	}

	public BLD_Product termTenor(Integer term){
		return (BLD_Product) setField(SB_Product__c.Term_Tenor__c, term);
	}

	public BLD_Product estRevSchUpdated(Boolean estUpdated){
		return (BLD_Product) setField(SB_Product__c.EstRevSch_Updated__c, estUpdated);
	}
	public BLD_Product bankRole(String bankRole){
		return (BLD_Product) setField(SB_Product__c.Bank_Role__c, bankRole);
	}

	public BLD_Product addDrawDownProfile(BLD_DrawDownProfile ddpBld) {
		return (BLD_Product) addChild(Draw_Down_Profile__c.Product__c, ddpBld);
	}

	public BLD_Product addEstimatedRevenueSchedule(BLD_EstimatedRevenueSchedule bldErs) {
		return (BLD_Product) addChild(Estimated_Revenue_Schedule__c.Product__c, bldErs);
	}
	public BLD_Product addProductDistribution(BLD_Product_Distribution bldPd) {
		return (BLD_Product) addChild(Product_Distribution__c.Product__c, bldPd);
	}

}