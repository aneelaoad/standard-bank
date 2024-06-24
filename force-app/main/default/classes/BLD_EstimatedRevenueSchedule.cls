@IsTest
public without sharing class BLD_EstimatedRevenueSchedule extends ABS_ObjectBuilderBase {

    public static final Decimal DEF_TOTAL = 100;

    public BLD_EstimatedRevenueSchedule() {
        this(getNewUnitOfWork());
    }

    public BLD_EstimatedRevenueSchedule(fflib_SObjectUnitOfWork workUnit) {
        super(Estimated_Revenue_Schedule__c.sObjectType, workUnit);
        setDefaultData();
    }

    private BLD_EstimatedRevenueSchedule(Estimated_Revenue_Schedule__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    protected override void setDefaultData() {
        setField(Estimated_Revenue_Schedule__c.Fee_Amount__c, DEF_TOTAL);
        setField(Estimated_Revenue_Schedule__c.Estimated_Revenue_Date__c, System.today());
    }

    public BLD_EstimatedRevenueSchedule useAdvisory() {
        return  (BLD_EstimatedRevenueSchedule) setField(Estimated_Revenue_Schedule__c.RecordTypeId,
            UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME, DMN_EstimatedRevenueSchedule.RT_ESR_ADVISORY));
    }

    public BLD_EstimatedRevenueSchedule useNiiAndNir() {
        return  (BLD_EstimatedRevenueSchedule) setField(Estimated_Revenue_Schedule__c.RecordTypeId,
            UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME, DMN_EstimatedRevenueSchedule.RT_ESR_NII_NIR));
    }

    public BLD_EstimatedRevenueSchedule useNir() {
        return (BLD_EstimatedRevenueSchedule)
                setField(Estimated_Revenue_Schedule__c.RecordTypeId,
                    UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME, DMN_EstimatedRevenueSchedule.RT_ESR_NIR));
    }

    public BLD_EstimatedRevenueSchedule linkToProduct(String productId){
        return (BLD_EstimatedRevenueSchedule)
                setField(Estimated_Revenue_Schedule__c.Product__c, productId);
    }

    public BLD_EstimatedRevenueSchedule linkToProduct(BLD_Product bldProduct){
        return (BLD_EstimatedRevenueSchedule)
                setRelation(Estimated_Revenue_Schedule__c.Product__c, bldProduct);
    }

    public BLD_EstimatedRevenueSchedule feeAmount(Decimal amount){
        return (BLD_EstimatedRevenueSchedule)
                setField(Estimated_Revenue_Schedule__c.Fee_Amount__c, amount);
    }

    public BLD_EstimatedRevenueSchedule estimatedRevenueDate(Date estimatedDate){
        return (BLD_EstimatedRevenueSchedule)
                setField(Estimated_Revenue_Schedule__c.Estimated_Revenue_Date__c, estimatedDate);
    }

}