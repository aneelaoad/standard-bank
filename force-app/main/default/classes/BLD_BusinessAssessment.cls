@IsTest
public class BLD_BusinessAssessment extends ABS_ObjectBuilderBase {
	public BLD_BusinessAssessment() {
		this(getNewUnitOfWork());
	}

	public BLD_BusinessAssessment(fflib_SObjectUnitOfWork workUnit) {
		super(Business_Assessment__c.SObjectType, workUnit);
	}

	private BLD_BusinessAssessment(Business_Assessment__c sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}	

	protected override void setDefaultData() {
		//setField(Account.Name, DEF_NAME);
	}

	public BLD_BusinessAssessment client(Id accId) {
		setField(Business_Assessment__c.Account__c , accId);
		return this;
	}

	public BLD_BusinessAssessment client(BLD_Account clientBld) {
		setRelation(Business_Assessment__c.Account__c, clientBld);
		return this; 
	}

	public BLD_BusinessAssessment client(){
		setRelation(Business_Assessment__c.Account__c, new BLD_Account(workUnit));
		return this;
	}

	public BLD_BusinessAssessment guarantorName(BLD_Account guarantorNameBld) {
		setRelation(Business_Assessment__c.Guarantor_Name__c, guarantorNameBld);
		return this;
	}

	public BLD_BusinessAssessment approvalMilestoneDate(Date dte) {
		setField(Business_Assessment__c.Approval_Milestone_Date__c , dte);
		return this;
	}

	public BLD_BusinessAssessment mnpi(Boolean mnpi) {
		setField(Business_Assessment__c.MNPI__c , mnpi);
		return this;
	}
}