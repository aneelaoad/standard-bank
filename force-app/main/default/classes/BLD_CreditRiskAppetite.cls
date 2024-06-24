@IsTest
public without sharing class BLD_CreditRiskAppetite extends ABS_ObjectBuilderBase{

	public BLD_CreditRiskAppetite() {  
        this(getNewUnitOfWork());        
    }

    public BLD_CreditRiskAppetite(fflib_SObjectUnitOfWork workUnit) { 
        super(Credit_Risk_Appetite__c.sObjectType, workUnit);
    }

    private BLD_CreditRiskAppetite(Credit_Risk_Appetite__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

}