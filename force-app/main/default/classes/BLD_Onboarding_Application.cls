/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 * @description Builder class
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
@IsTest
public without sharing class BLD_Onboarding_Application extends ABS_ObjectBuilderBase{
    public BLD_Onboarding_Application() {
        this(getNewUnitOfWork());
    }
    
    public BLD_Onboarding_Application(fflib_SObjectUnitOfWork workUnit) {
        super(Onboarding_Application__c.SObjectType, workUnit);
    }
    
    public BLD_Onboarding_Application(Onboarding_Application__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }
    
    protected override void setdefaultData() {
        setField(Onboarding_Application__c.Status__c,  DMN_OnboardingApplications.STATUS_PENDING);
    }
    
    public BLD_Onboarding_Application requestType(String requestType) {
        return(BLD_Onboarding_Application) setField(Onboarding_Application__c.Request_Type__c, requestType);
    }
    
    public BLD_Onboarding_Application client(BLD_Account clientBld) {
        return(BLD_Onboarding_Application) setRelation(Onboarding_Application__c.Client__c, clientBld);
    }
    
    public BLD_Onboarding_Application requestedBy(String requestedBy) {
        return(BLD_Onboarding_Application) setField(Onboarding_Application__c.Requested_By__c, requestedBy);
    }

    public BLD_Onboarding_Application status(String status) {
        return(BLD_Onboarding_Application) setField(Onboarding_Application__c.Status__c, status);
    }
    
    public BLD_Onboarding_Application useRequestConsentRT(String commBRecTypeConsent) {
        string recordTypeId = UTL_RecordType.getRecordTypeId(DMN_OnboardingApplications.OBJECT_NAME, commBRecTypeConsent);
        return(BLD_Onboarding_Application) setField(Onboarding_Application__c.RecordTypeId, recordTypeId);
    }
    
}