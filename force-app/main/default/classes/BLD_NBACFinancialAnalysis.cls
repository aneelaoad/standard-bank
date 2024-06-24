@IsTest
public class BLD_NBACFinancialAnalysis extends ABS_ObjectBuilderBase {
	public BLD_NBACFinancialAnalysis() {
		this(getNewUnitOfWork());
	}

	public BLD_NBACFinancialAnalysis(fflib_SObjectUnitOfWork workUnit) {
		super(NBAC_Financial_Analysis__c.SObjectType, workUnit);
	}

	private BLD_NBACFinancialAnalysis(NBAC_Financial_Analysis__c sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}

	protected override void setDefaultData() {

	}

	public BLD_NBACFinancialAnalysis businessAssessment(BLD_BusinessAssessment bAssessment) {
		return(BLD_NBACFinancialAnalysis) setRelation(NBAC_Financial_Analysis__c.Business_Assessment__c, bAssessment);
	}

	public BLD_NBACFinancialAnalysis businessAssessment(Business_Assessment__c busienessbAssessment) {
		return(BLD_NBACFinancialAnalysis) setField(NBAC_Financial_Analysis__c.Business_Assessment__c, busienessbAssessment.Id);
	}

	public BLD_NBACFinancialAnalysis metric() {
		return(BLD_NBACFinancialAnalysis) setField(NBAC_Financial_Analysis__c.RecordTypeId, UTL_RecordType.getRecordTypeId(NBAC_Financial_Analysis__c.getSobjectType().getDescribe().getName(), DMN_NBACFinancialAnalysis.RT_METRIC));
	}

	public BLD_NBACFinancialAnalysis indicatior() {
		return(BLD_NBACFinancialAnalysis) setField(NBAC_Financial_Analysis__c.RecordTypeId, UTL_RecordType.getRecordTypeId(NBAC_Financial_Analysis__c.getSobjectType().getDescribe().getName(), DMN_NBACFinancialAnalysis.RT_INDICATOR));
	}

	public BLD_NBACFinancialAnalysis metricYear1(String value) {
		return(BLD_NBACFinancialAnalysis) setField(NBAC_Financial_Analysis__c.Metric_Year_1__c, value);
	}

	public BLD_NBACFinancialAnalysis metricYear2(String value) {
		return(BLD_NBACFinancialAnalysis) setField(NBAC_Financial_Analysis__c.Metric_Year_2__c, value);
	}

	public BLD_NBACFinancialAnalysis metricYear3(String value) {
		return(BLD_NBACFinancialAnalysis) setField(NBAC_Financial_Analysis__c.Metric_Year_3__c, value);
	}

	public BLD_NBACFinancialAnalysis metricYear4(String value) {
		return(BLD_NBACFinancialAnalysis) setField(NBAC_Financial_Analysis__c.Metric_Year_4__c, value);
	}

}