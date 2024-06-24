/**
* Builder class for Knowledge__kav SObject
*
* @author      Wayde Fagan (wayde.fagan@tetrad.co.za)
* @date        October 2020
*/
@IsTest
public with sharing class BLD_Knowledge_Entitlement extends ABS_ObjectBuilderBase {
    
    public static final String DEF_TITLE = 'Test article';
    public static final String DEF_INTRODUCTION = 'Test introduction';
    public static final String DEF_URL = 'Test url';
    public static final String DEF_URL_NAME = 'Testname';
    public static final String DEF_OPERATING_COUNTRY = 'Angola;South Africa';
    public static final String DEF_PERSONA = 'Staff;Client';
    
    public BLD_Knowledge_Entitlement() {
        this(getNewUnitOfWorkWithKnowledge());
    }
    
    public BLD_Knowledge_Entitlement(fflib_SObjectUnitOfWork uow) {
        super(Knowledge_Entitlement_Exception__c.SObjectType, uow);
    }
    
    public BLD_Knowledge_Entitlement(Knowledge__kav knowledge, fflib_SObjectUnitOfWork uow) {
        super(knowledge, uow);
    }
    
    public BLD_Knowledge_Entitlement knowledgeArticle(Id knowledgeArticle) {
        return (BLD_Knowledge_Entitlement) setField(Knowledge_Entitlement_Exception__c.OSB_Knowledge_Article__c, knowledgeArticle);
    }
    
    public BLD_Knowledge_Entitlement contact(Id contact) {
        return (BLD_Knowledge_Entitlement) setField(Knowledge_Entitlement_Exception__c.OSB_Contact_Exception__c , contact);
    }
}