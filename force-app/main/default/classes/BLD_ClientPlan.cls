@IsTest
public without sharing class BLD_ClientPlan  extends ABS_ObjectBuilderBase {
	
	public BLD_ClientPlan() { 
		this(getNewUnitOfWork());        
	}

    public BLD_ClientPlan(Client_Plan__c plan){
        this(plan, getNewUnitOfWork()); 
    }

    public BLD_ClientPlan(fflib_SObjectUnitOfWork workUnit) { 
        super(Client_Plan__c.SObjectType, workUnit);
    }

    private BLD_ClientPlan(Client_Plan__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    protected override void setDefaultData(){
       setField(Client_Plan__c.Client_Plan_Status__c, DMN_ClientPlan.SUBMITTED);
    }

    public BLD_ClientPlan currencyIsoCode(String code){
       return (BLD_ClientPlan) setField(Client_Plan__c.CurrencyIsoCode, code);
    }

    public BLD_ClientPlan status(String status){
        return (BLD_ClientPlan) setField(Client_Plan__c.Client_Plan_Status__c, status);
    }

    public BLD_ClientPlan canBeSubmitted(Boolean submitted){
        return (BLD_ClientPlan) setField(Client_Plan__c.Can_be_Submitted__c, submitted);
    }

    public BLD_ClientPlan currentCcLineManager(Id managerUserId){
        return (BLD_ClientPlan) setField(Client_Plan__c.Current_CC_Line_Manager__c, managerUserId);
    }
    
    public BLD_ClientPlan account(ABS_ObjectBuilderBase accountBld){
        return (BLD_ClientPlan) setRelation(Client_Plan__c.Client_Name__c, accountBld); 
    }

    public BLD_ClientPlan approve(){
    	return (BLD_ClientPlan)setField(Client_Plan__c.Client_Plan_Status__c, DMN_ClientPlan.APPROVED)
    	.setField(Client_Plan__c.Can_be_Submitted__c, false)
    	.setField(Client_Plan__c.Approved_By__c, UserInfo.getUserId());
    }
}