/**
 * @description A builder class for creating RealEstateFinance records.
 * 
 * @author Stane Murhula (stane.murhula@standardbank.co.za)
 * @date March 2024
 */
@isTest
public without sharing class BLD_NbacRealEstateFinance extends ABS_ObjectBuilderBase {
    private static final String METRIC = 'Metric 1';
    private static final Integer LAND_COST = 1;

    public BLD_NbacRealEstateFinance() {
        this(getNewUnitOfWork());
    }

    public BLD_NbacRealEstateFinance(fflib_SObjectUnitOfWork uow) {
        super(NBAC_Real_Estate_Finance__c.SObjectType, uow);
    }

    public BLD_NbacRealEstateFinance(NBAC_Real_Estate_Finance__c sObj, fflib_SObjectUnitOfWork uow) {
        super(sObj, uow);
    }

    /**
     * @description sets the default fields
     */
    protected override void setDefaultData() {
        //Account ac = (Account)new BLD_Account().commitWork().getRecord();
        Business_Assessment__c ba = (Business_Assessment__c)new BLD_BusinessAssessment()
            .commitWork()
            .getRecord();

            setField(NBAC_Real_Estate_Finance__c.Metric__c, METRIC)
            .setField(NBAC_Real_Estate_Finance__c.Land_Cost__c, LAND_COST)
            .setField(NBAC_Real_Estate_Finance__c.Business_Assessment__c, ba.Id);
    }

    /**
     * @description Sets the metric of the NBAC_Real_Estate_Finance__c sObject.
     * @param metric String metric.
     * @return BLD_NbacRealEstateFinance
     */
    public BLD_NbacRealEstateFinance setMetric(String metric) {
        return (BLD_NbacRealEstateFinance)setField(NBAC_Real_Estate_Finance__c.Metric__c, metric);
    }

     /**
     * @description Sets the landcst of the NBAC_Real_Estate_Finance__c sObject.
     * @param landCost String metric.
     * @return BLD_NbacRealEstateFinance
     */
    public BLD_NbacRealEstateFinance setLandCost(Integer landCost) {
        return (BLD_NbacRealEstateFinance)setField(NBAC_Real_Estate_Finance__c.Land_Cost__c, landCost);
    }

    /**
     * @description Sets the baId  of the NBAC_Real_Estate_Finance__c sObject.
     * @param baId String baId.
     * @return BLD_NbacRealEstateFinance
     */
    public BLD_NbacRealEstateFinance setBaId(String baId) {
        return (BLD_NbacRealEstateFinance)setField(NBAC_Real_Estate_Finance__c.Business_Assessment__c, baId);
    }
}