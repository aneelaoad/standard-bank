/**
* Test class for the trigger on knowledgeExceptions
*
* @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
* @date January 2020
*
**/
@isTest
private class TRH_KnowledgeExceptions_Test {
	private static final String TEST_COMMUNITY_STATUS = 'Approved';
    private static final String TEST_COMMUNITY_ROLE = 'Authorised Person';
    
    @isTest
    static void beforeInsertTest(){
        Boolean expectedExceptionThrown;
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();

        Contact managerContact = (Contact) new BLD_Contact()
            .commitWork()
            .getRecord();
        
        Contact teamContact = (Contact) new BLD_Contact()
            .setOSBDefaultData(TEST_COMMUNITY_ROLE,TEST_COMMUNITY_STATUS)
            .communityAccessManager(managerContact.Id) 
            .commitWork()
            .getRecord();
        
        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
                .setOSBData()
                .isComingSoon(false)
                .useApiProduct()
                .commitWork()
            	.getRecord();
        
        Test.startTest();
        
        Knowledge_Entitlement_Exception__c knowledgeExcep = (Knowledge_Entitlement_Exception__c) new BLD_Knowledge_Entitlement()
            .knowledgeArticle(article.Id)
            .contact(teamContact.Id)
            .commitWork()
            .getRecord();
        
        try{
            Knowledge_Entitlement_Exception__c knowledgeExcepError = (Knowledge_Entitlement_Exception__c) new BLD_Knowledge_Entitlement()
                .knowledgeArticle(article.Id)
                .contact(teamContact.Id)
                .commitWork()
                .getRecord(); 
        }catch(Exception ex){
            expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
        }
        System.assertEquals(expectedExceptionThrown, true);
        Test.stopTest();
    }
}