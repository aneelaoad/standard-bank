@IsTest
public without sharing class BLD_ClientTeam extends ABS_ObjectBuilderBase {

    public BLD_ClientTeam() { 
        this(getNewUnitOfWork());
    }

    public BLD_ClientTeam(fflib_SObjectUnitOfWork workUnit) { 
        super(Custom_Client_Team__c.SObjectType, workUnit);
    }

    private BLD_ClientTeam(Custom_Client_Team__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    protected override void setDefaultData(){
       setField(Custom_Client_Team__c.Client_Access__c, DMN_ClientTeam.ACCESS_READ)
       .setField(Custom_Client_Team__c.Opportunity_Access__c, DMN_ClientTeam.ACCESS_READ)
       .setField(Custom_Client_Team__c.Contact_Access__c, DMN_ClientTeam.ACCESS_READ)
       .setField(Custom_Client_Team__c.Case_Access__c, DMN_ClientTeam.ACCESS_READ); 
    }

    public BLD_ClientTeam account(String accountId){
    	setField(Custom_Client_Team__c.Account__c, accountId);
    	return this;
    } 

    public BLD_ClientTeam coordinator(Boolean isCoordinator){
        setField(Custom_Client_Team__c.Client_Coordinator__c, isCoordinator);
        return this; 
    }

    public BLD_ClientTeam clientAccess(String clientAccess){
        setField(Custom_Client_Team__c.Client_Access__c, clientAccess);
        return this;
    }

	public BLD_ClientTeam ccbm(){
		setField(Custom_Client_Team__c.Client_Coordinator_BM__c, true);
		return this;
	}

    public BLD_ClientTeam ccbm(Boolean isCcBm){
        setField(Custom_Client_Team__c.Client_Coordinator_BM__c, isCcBm);
        return this;
    }

    public BLD_ClientTeam account(ABS_ObjectBuilderBase accBld){
        return (BLD_ClientTeam) setRelation(Custom_Client_Team__c.Account__c, accBld); 
    }
		
    public BLD_ClientTeam role(String role){
    	setField(Custom_Client_Team__c.Client_Role__c, role);
    	return this;
    }

    public BLD_ClientTeam GTB(Boolean gtb){
    	setField(Custom_Client_Team__c.GTB__c, gtb);
    	return this;
    }

    public BLD_ClientTeam user(String userId){
    	setField(Custom_Client_Team__c.Team_Member__c, userId);
    	return this;
    }

    public BLD_ClientTeam sourceFlag(Integer flag){
        setField(Custom_Client_Team__c.SourceFlag__c, flag);
        return this;
    }

    public BLD_ClientTeam id(Id id){
        setField(Custom_Client_Team__c.Id, id);
        return this;
    }

    public BLD_ClientTeam visibleToClient(Boolean flag){
        setField(Custom_Client_Team__c.Visible_to_Client__c, flag);
        return this;
    }
}