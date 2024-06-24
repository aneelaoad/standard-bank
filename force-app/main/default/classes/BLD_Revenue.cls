/**
* @description  : Builder class Revenue
* User Story : SFP-7503
*
* @author Michal Pesko (mpesko@deloittece.com)
* @date October 2021
*/
@IsTest
public with sharing class BLD_Revenue extends ABS_ObjectBuilderBase{
    public BLD_Revenue() {
        this(getNewUnitOfWork());
    }

    public BLD_Revenue(fflib_SObjectUnitOfWork workUnit) {
        super(FinServ__Revenue__c.SObjectType, workUnit);
    }

    protected override void setDefaultData(){

    }

    public BLD_Revenue globalClient(Id value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.CRT_ClientRevenue__c, value);
    }

    public BLD_Revenue client(Id value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.FinServ__Account__c, value);
    }

    public BLD_Revenue reportingYear(String value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.CRT_ReportingYear__c, value);
    }

    public BLD_Revenue reportingMonth (Double value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.CRT_ReportingMonth__c, value);
    }

    public BLD_Revenue date (Date value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.FinServ__Date__c, value);
    }

    public BLD_Revenue productDrCrIndicator(String value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.CRT_ProductDRCRIndicator__c, value);
    }

    public BLD_Revenue actualRevenueLcy(Double value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.CRT_ActualRevenueLCY__c, value);
    }
    
    public BLD_Revenue avgBalanceZar(Double value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.CRT_AverageBalanceZAR__c, value);
    }

    public BLD_Revenue avgBalanceLcy(Double value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.CRT_AverageBalanceLCY__c, value);
    }

    public BLD_Revenue crtLocalCurrLcy(String value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.CRT_LocalCurrencyLCY__c, value);
    }

    public BLD_Revenue actualRevenueZar(Double value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.CRT_ActualRevenueZAR__c, value);
    }

    public BLD_Revenue amount(Double value){
        return (BLD_Revenue) setField(FinServ__Revenue__c.FinServ__Amount__c, value);
    }

}