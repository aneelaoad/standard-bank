/**
 * Builder class for Distribution_Client__c SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_DistributionClient extends ABS_ObjectBuilderBase {

    private static final Decimal DEF_AMOUNT = 10000;
    private static final Decimal DEF_MARGIN_POINTS = 50;

    public BLD_DistributionClient() {
        this(getNewUnitOfWork());
    }

    public BLD_DistributionClient(fflib_SObjectUnitOfWork uow) {
        super(Distribution_Client__c.SObjectType, uow);
    }

    protected override void setDefaultData() {
        setField(Distribution_Client__c.Amount__c, DEF_AMOUNT);
        setField(Distribution_Client__c.Margin_Points__c, DEF_MARGIN_POINTS);
    }

    public BLD_DistributionClient distributionClient(BLD_Account accBld) {
        return (BLD_DistributionClient) setRelation(Distribution_Client__c.Distribution_Client__c, accBld);
    }

    public BLD_DistributionClient product(BLD_Product prodBld) {
        return (BLD_DistributionClient) setRelation(Distribution_Client__c.Product__c, prodBld);
    }

}