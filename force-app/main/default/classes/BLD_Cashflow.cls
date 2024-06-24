/**
 * Builder class for Cashflow__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_Cashflow extends ABS_ObjectBuilderBase {

    private static final Decimal DEF_CASHFLOW = 10000;
    private static final Date DEF_DATE = System.today();

    public BLD_Cashflow() {
        this(getNewUnitOfWork());
    }

    public BLD_Cashflow(fflib_SObjectUnitOfWork uow) {
        super(Cashflow__c.SObjectType, uow);
    }

    protected override void setDefaultData() {
        setField(Cashflow__c.Cashflow__c, DEF_CASHFLOW);
        setField(Cashflow__c.Date__c, DEF_DATE);
    }

    public BLD_Cashflow product(BLD_Product prodBuilder) {
        return (BLD_Cashflow) setRelation(Cashflow__c.Product__c, prodBuilder);
    }

}