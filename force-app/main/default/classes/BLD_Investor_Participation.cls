/**
 * Builder class for Investor Participation object.
 * <br/>SGPRT-624
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date March 2021
 */
@IsTest
public with sharing class BLD_Investor_Participation extends ABS_ObjectBuilderBase{
    public BLD_Investor_Participation() {
        this(getNewUnitOfWork());
    }

    public BLD_Investor_Participation(fflib_SObjectUnitOfWork workUnit) {
        super(Investor_Participation__c.SObjectType, workUnit);
    }

    public BLD_Investor_Participation(Investor_Participation__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    public BLD_Investor_Participation name(String name) {
        return(BLD_Investor_Participation) setField(Investor_Participation__c.Name, name);
    }

    public BLD_Investor_Participation partyStatus(String partyStatus) {
        return(BLD_Investor_Participation) setField(Investor_Participation__c.Distribution_Party_Status__c, partyStatus);
    }

    public BLD_Investor_Participation partyBidPrice(Integer partyBidPrice) {
        return(BLD_Investor_Participation) setField(Investor_Participation__c.Distribution_Party_Bid_Price__c, partyBidPrice);
    }

    public BLD_Investor_Participation distribution(BLD_Product_Distribution distributionBld) {
        return (BLD_Investor_Participation) setRelation(Investor_Participation__c.Distribution__c, distributionBld);
    }

    public BLD_Investor_Participation account(BLD_Account acc) {
        return (BLD_Investor_Participation)  setRelation(Investor_Participation__c.Distribution_Party__c, acc);
    }

}