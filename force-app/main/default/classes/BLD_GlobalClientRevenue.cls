/**
 * Builder class for Global Client Revenue
 *
 * @author Unknown
 * @date Unknown
 */
@IsTest
public class BLD_GlobalClientRevenue extends ABS_ObjectBuilderBase {

    public BLD_GlobalClientRevenue() {
		this(getNewUnitOfWork());
	}

    public BLD_GlobalClientRevenue(fflib_SObjectUnitOfWork workUnit) {
        super(Global_Client_Revenue__c.SObjectType, workUnit);
    }

    private BLD_GlobalClientRevenue(Account sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    protected override void setDefaultData(){
    }

	public BLD_GlobalClientRevenue clientValueZarCurrentYear(Decimal value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Client_Value_ZAR_Current_Year__c, value);
	}

	public BLD_GlobalClientRevenue clientValueZarPreviousYear(Decimal value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Client_Value_ZAR_Previous_Year__c, value);
	}

	public BLD_GlobalClientRevenue clientValueUSDCurrentYear(Decimal value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Client_Value_USD_Current_Year__c, value);
	}

	public BLD_GlobalClientRevenue clientValueUSDPreviousYear(Decimal value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Client_Value_USD_Previous_Year__c, value);
	}

	public BLD_GlobalClientRevenue clientValueUSDCurrentMonth(Decimal value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Client_Value_USD_Current_Month__c, value);
	}

	public BLD_GlobalClientRevenue clientValueZARCurrentMonth(Decimal value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Client_Value_ZAR_Current_Month__c, value);
	}

	public BLD_GlobalClientRevenue budgetUSDNextYear(Decimal value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Budget_USD_Next_Year__c, value);
	}

	public BLD_GlobalClientRevenue budgetZARNextYear(Decimal value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Budget_ZAR_Next_Year__c, value);
	}

	public BLD_GlobalClientRevenue tradingDivision(String value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Trading_Division__c, value);
	}

	public BLD_GlobalClientRevenue clientCIFNumber(String cifValue){
	return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Client_CIF_Number__c, cifValue);
	}

	public BLD_GlobalClientRevenue client(ABS_ObjectBuilderBase accountBld){
		return (BLD_GlobalClientRevenue)clientCIFNumber(((Account)accountBld.getRecord()).CIF__c).setRelation(Global_Client_Revenue__c.Client__c, accountBld);
	}

	public BLD_GlobalClientRevenue currentAndPreviousYear(){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.RecordTypeId, UTL_RecordType.getRecordTypeId(DMN_GlobalClientRevenue.OBJ_NAME,DMN_GlobalClientRevenue.RTD_CURRENT_PREVIOUS_YEAR));
	}

	public BLD_GlobalClientRevenue useHistoricalRevenue(){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.RecordTypeId, UTL_RecordType.getRecordTypeId(DMN_GlobalClientRevenue.OBJ_NAME,DMN_GlobalClientRevenue.RTD_HISTORICAL_REVENUE));
	}

    public BLD_GlobalClientRevenue reportingCountry(String reportingCountry){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Reporting_Country__c, reportingCountry);
	}

    public BLD_GlobalClientRevenue snapshotDate(Date snapshotDate){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Snapshot_Date__c, snapshotDate);
	}

	public BLD_GlobalClientRevenue divisionProductSubsets(String divisionProductSubsets){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.Division_Product_Subsets__c, divisionProductSubsets);
	}

	public BLD_GlobalClientRevenue crtDepartment(String value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.CRT_Department__c, value);
	}

	public BLD_GlobalClientRevenue crtBookingCountry(String value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.CRT_BookingCountry__c, value);
	}

	public BLD_GlobalClientRevenue recordTypeId(Id value){
		return (BLD_GlobalClientRevenue) setField(Global_Client_Revenue__c.RecordTypeId, value);
	}
}