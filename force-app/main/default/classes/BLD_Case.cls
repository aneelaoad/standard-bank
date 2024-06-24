/**
 * Builder class for Case SObject
 * <br/>US-4178
 *
 * @author		Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date		March 2020
 */
@IsTest
public without sharing class BLD_Case extends ABS_ObjectBuilderBase {
	public static final String SUPPLIED_NAME = 'Test user';
    public static final String SUPPLIED_PHONE = '+27-0842454812';
    public static final String EMAIL = 'test@test.com';
    public static final String USER_INDUSTRY = 'IT';
    public static final String DEF_JOB_TITLE = 'Developer';
    public static final String DEF_USER_COMPANY = 'Test Company';

    private static final String DEF_DESCRIPTION = 'random description';
    private static final String DEF_NEXT_STEPS = 'steps to be taken';
    private static final String DEF_RESOLUTION_COMMENTS = 'comments';
    private static final String DEF_SUBJECT = 'subject';

    public BLD_Case() {
        this(getNewUnitOfWork());
    }

    public BLD_Case(fflib_SObjectUnitOfWork workUnit) {
        super(Case.SObjectType, workUnit);
    }

    public BLD_Case(Case caseRecord, fflib_SObjectUnitOfWork uow) {
        super(caseRecord, uow);
    }

    public BLD_Case setOSBData() {
        return (BLD_Case) setField(Case.SuppliedName, SUPPLIED_NAME)
                .setField(Case.SuppliedPhone, SUPPLIED_PHONE)
                .setField(Case.User_Industry__c, USER_INDUSTRY)
                .setField(Case.User_Job_Title__c,  DEF_JOB_TITLE)
                .setField(Case.User_Company_Name__c,  DEF_USER_COMPANY);
    }
    
    /**
     * Builds a Case
     * User Story : SFP-5296
     *
     * @return BLD_Case
    */
    public BLD_Case setPPData() {
        return (BLD_Case) setField(Case.SuppliedName, SUPPLIED_NAME)
                .setField(Case.SuppliedPhone, SUPPLIED_PHONE)
                .setField(Case.Description, DEF_DESCRIPTION)
                .setField(Case.Subject,  DEF_SUBJECT)
            	.setField(Case.SuppliedEmail,  EMAIL)
            	.setField(Case.Status,  DMN_CASE.STATUS_NEW);
    }

    public BLD_Case useCrossBorder() {
        return (BLD_Case) setField(Case.RecordTypeId,
            UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CROSS_BORDER));
    }
        
    public BLD_Case useRtHandOff() {
        return (BLD_Case) setField(Case.RecordTypeId,
            UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_HAND_OFF));
    }

    public BLD_Case useChangeRequest() {
        return (BLD_Case) setField(Case.RecordTypeId,
            UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CHANGE_REQUEST))
            .setField(Case.Subject, DEF_SUBJECT)
            .setField(Case.Description, DEF_DESCRIPTION);
    }

    public BLD_Case useClientCase() {
        return (BLD_Case) setField(Case.RecordTypeId,
            UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CIB_CLIENT_CASE));
    }

    public BLD_Case useUserCase() {
        return (BLD_Case) setField(Case.RecordTypeId,
            UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_USER_CASE));
    }

    public BLD_Case close() {
        return (BLD_Case) setField(Case.Status, DMN_Case.STATUS_CLOSED)
            .setField(Case.Next_Steps__c, DEF_NEXT_STEPS)
            .setField(Case.Resolution_Comment__c, DEF_RESOLUTION_COMMENTS);
    }

    public BLD_Case contact(BLD_Contact contactBuilder) {
        return (BLD_Case) setRelation(Case.ContactId, contactBuilder);
    }

    public BLD_Case suppliedEmail(String suppliedEmail) {
        return (BLD_Case) setField(Case.SuppliedEmail, suppliedEmail);
    }

    public BLD_Case subject(String subject) {
        return (BLD_Case) setField(Case.Subject, subject);
    }
    
    public BLD_Case account(BLD_Account accountBuilder) {
        return (BLD_Case) setRelation(Case.AccountId, accountBuilder);
    }

    public BLD_Case accountId(Id accountId) {
        return (BLD_Case) setField(Case.AccountId, accountId);
    }

    public BLD_Case serviceTypeId(Id serviceTypeId) {
        return (BLD_Case) setField(Case.Service_Type_Name__c, serviceTypeId);
    }
    	    public BLD_Case serviceType(BLD_ServiceType serviceType) {
        return (BLD_Case) setRelation(Case.Service_Type_Name__c, serviceType);
    }
    
    public BLD_Case parent(BLD_Case parentCase) {
        return (BLD_Case) setRelation(Case.ParentId, parentCase);
    }
    
    public BLD_Case status(String status) {
        return (BLD_Case) setField(Case.status, status);
    }
    
    public BLD_Case cibServiceTier(String ServiceTier) {
        return (BLD_Case) setField(Case.CIB_Service_Tier__c, ServiceTier);
    }
}