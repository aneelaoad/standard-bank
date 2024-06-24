/**
 * Builder class for Client_Financial_Analysis__c object
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_ClientFinancialAnalysis extends ABS_ObjectBuilderBase {

    private static final Date DEF_STATEMENT_DATE = Date.today();

    public BLD_ClientFinancialAnalysis() {
        this(getNewUnitOfWork());
    }

    public BLD_ClientFinancialAnalysis(fflib_SObjectUnitOfWork uow) {
        super(Client_Financial_Analysis__c.SObjectType, uow);
    }

    protected override void setDefaultData() {
        setField(Client_Financial_Analysis__c.Statement_Date__c, DEF_STATEMENT_DATE);
    }

    public BLD_ClientFinancialAnalysis useManual() {
        return (BLD_ClientFinancialAnalysis) setField(Client_Financial_Analysis__c.RecordTypeId,
            UTL_RecordType.getRecordTypeId(DMN_ClientFinancialAnalysis.OBJ_NAME, DMN_ClientFinancialAnalysis.RT_MANUAL));
    }

    public BLD_ClientFinancialAnalysis useSpread() {
        return (BLD_ClientFinancialAnalysis) setField(Client_Financial_Analysis__c.RecordTypeId,
                UTL_RecordType.getRecordTypeId(DMN_ClientFinancialAnalysis.OBJ_NAME, DMN_ClientFinancialAnalysis.RT_SPREAD))
            .setField(Client_Financial_Analysis__c.Spreadpac__c, true);
    }

    public BLD_ClientFinancialAnalysis client(BLD_Account accBld) {
        return (BLD_ClientFinancialAnalysis) setRelation(Client_Financial_Analysis__c.Client_Name__c, accBld);
    }

}