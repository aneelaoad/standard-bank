@IsTest
public without sharing class BLD_KYC_Status extends ABS_ObjectBuilderBase {
	public BLD_KYC_Status() {
		this(getNewUnitOfWork());
	}

	public BLD_KYC_Status(fflib_SObjectUnitOfWork workUnit) {
		super(KYC_Status__c.SObjectType, workUnit);
	}

	private BLD_KYC_Status(KYC_Status__c sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}

	protected override void setDefaultData() {

	}

	public BLD_KYC_Status KYC_Status_Requested() {
		return(BLD_KYC_Status) setField(KYC_Status__c.Status__c,DMN_KYC_Status.KYCSTATUS_2_STATUS.get(DMN_KYC_Status.KYC_STATUS_REQUESTED));
	}

    public BLD_KYC_Status entityCode(String code) {
		return(BLD_KYC_Status) setField(KYC_Status__c.Entity_Code__c, code);
	}

	public BLD_KYC_Status client(BLD_Account bAccount) {
		return(BLD_KYC_Status) setRelation(KYC_Status__c.Client__c, bAccount);

	}
}