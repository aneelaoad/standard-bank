/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 * @description Builder class
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
@IsTest
public without sharing class BLD_Application_Document extends ABS_ObjectBuilderBase{

    public BLD_Application_Document() {
        this(getNewUnitOfWork());
    }
    
    public BLD_Application_Document(fflib_SObjectUnitOfWork workUnit) {
        super(Application_Document__c.SObjectType, workUnit);
    }
    
    public BLD_Application_Document(Application_Document__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }
    
    protected override void setDefaultData() {
        setField(Application_Document__c.Document_Status__c,  DMN_ApplicationDocuments.STATUS_PENDING)
            .setField(Application_Document__c.FileNet_Id__c,  DMN_ApplicationDocuments.DEFAULT_FILE_NET_ID);
    }
    
    public BLD_Application_Document authorisedPerson(ABS_ObjectBuilderBase contactBld) {
        return(BLD_Application_Document) setRelation(Application_Document__c.Authorised_Person__c, contactBld);
    }
    
    public BLD_Application_Document onboardingApplication(ABS_ObjectBuilderBase onboardingApplicationld) {
        return(BLD_Application_Document) setRelation(Application_Document__c.Onboarding_Application__c, onboardingApplicationld);
    }

}