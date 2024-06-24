@IsTest
public without sharing class BLD_CreditLine extends ABS_ObjectBuilderBase {

    public BLD_CreditLine() { 
        this(getNewUnitOfWork());        
    }

    public BLD_CreditLine(fflib_SObjectUnitOfWork workUnit) { 
        super(Credit_Line__c.SObjectType, workUnit);
    }

    private BLD_CreditLine(Credit_Line__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    protected override void setDefaultData(){
        setField(Credit_Line__c.Credit_Limit__c, 0)
        .setField(Credit_Line__c.Total_utilisation__c, 0);
    }

    public BLD_CreditLine account(String accountId){
    	setField(Credit_Line__c.Client_Name__c, accountId);
    	return this;
    }

    public BLD_CreditLine account(BLD_Account accountBld) {
        return(BLD_CreditLine) setRelation(Credit_Line__c.Client_Name__c, accountBld);
    }  

    public BLD_CreditLine product(String product){
    	setField(Credit_Line__c.Product__c, product);
    	return this;
    }   

    public BLD_CreditLine totalUtilisation(Decimal value){
    	setField(Credit_Line__c.Total_utilisation__c, value);
    	return this;
    }

     public BLD_CreditLine creditLimit(Decimal value){
    	setField(Credit_Line__c.Credit_Limit__c, value);
    	return this;
    }

     public BLD_CreditLine creditLimitReferenceNumber(String value){
    	setField(Credit_Line__c.Limit_Reference_Number__c, value);
    	return this;
    }
}