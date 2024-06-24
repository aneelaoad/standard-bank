@IsTest
public with sharing class BLD_ClientSatisfactionIndex extends ABS_ObjectBuilderBase {
	
	public BLD_ClientSatisfactionIndex() { 
        this(getNewUnitOfWork());        
    }

    public BLD_ClientSatisfactionIndex(fflib_SObjectUnitOfWork workUnit) { 
        super(Client_Satisfaction_Index__c.SObjectType, workUnit);
    }

    public BLD_ClientSatisfactionIndex(Client_Satisfaction_Index__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit); 
    }

    protected override void setDefaultData(){
    	//setfield(Client_Satisfaction_Index__c.CSI_Project_Country__c,  );
    } 

    public BLD_ClientSatisfactionIndex client(Id accId){
    	setField(Client_Satisfaction_Index__c.Client__c, accId);
    	return this;
    }

    public BLD_ClientSatisfactionIndex client(BLD_Account accountBld){
    	setRelation(Client_Satisfaction_Index__c.Client__c, accountBld);
    	return this;
    }

    public BLD_ClientSatisfactionIndex contact(BLD_Contact contactBld){
    	setRelation(Client_Satisfaction_Index__c.CSI_Survey_Contact__c, contactBld);
    	return this;
    }

    public BLD_ClientSatisfactionIndex projectCountry(String projectCountry){
    	setField(Client_Satisfaction_Index__c.CSI_Project_Country__c, projectCountry);
    	return this;
    }

    public BLD_ClientSatisfactionIndex rating(Decimal rate){
    	setField(Client_Satisfaction_Index__c.Overall_CIB_CSI_Rating_Number__c, rate);
    	return this;
    }

    public BLD_ClientSatisfactionIndex year(Integer year){
    	setField(Client_Satisfaction_Index__c.Survey_Year__c, String.valueOf(year));
    	return this;
    } 
}