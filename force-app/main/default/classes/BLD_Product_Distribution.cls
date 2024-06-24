/**
 * Builder class for Product Distribution object.
 * <br/>SGPRT-624
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date March 2021
 */
@IsTest
public with sharing class BLD_Product_Distribution extends ABS_ObjectBuilderBase{
    public BLD_Product_Distribution() {
        this(getNewUnitOfWork());
    }

    public BLD_Product_Distribution(fflib_SObjectUnitOfWork workUnit) {
        super(Product_Distribution__c.SObjectType, workUnit);
    }

    public BLD_Product_Distribution(Product_Distribution__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    public BLD_Product_Distribution name(String name) {
        return(BLD_Product_Distribution) setField(Product_Distribution__c.Name, name);
    }

    public BLD_Product_Distribution product(BLD_Product prodBld) {
        return (BLD_Product_Distribution )setRelation(Product_Distribution__c.Product__c, prodBld);
    }

    public BLD_Product_Distribution addInvestorParticipation(BLD_Investor_Participation bldInvPart) {
        return (BLD_Product_Distribution) addChild(Investor_Participation__c.Distribution__c, bldInvPart);
    }

}