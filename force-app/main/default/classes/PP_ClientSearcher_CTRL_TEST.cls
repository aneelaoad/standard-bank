/**
* @description  : Client Search Contiller Test Class
* User Story : SFP-11652
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date April 2022
*/
@IsTest
public class PP_ClientSearcher_CTRL_TEST {

    @IsTest
    static void searchClient(){
        
        Account account  = (Account) new BLD_Account().useCommB().getRecord();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        uow.registerNew(account);
        uow.commitWork();
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = account.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        List<Account> accList = PP_ClientSearcher_CTRL.getMatchingClients('test','123');
        
        PP_PartnerApplication__c partnerApplication = (PP_PartnerApplication__c) new BLD_PartnerApplication().setPartnerData().getRecord();
        uow.registerNew(partnerApplication);
        uow.commitWork();
        
        Test.startTest();
        PP_ClientSearcher_CTRL.linkClient(partnerApplication.Id,accList[0].Id);
        Test.stopTest();
        
        PP_PartnerApplication__c application = [SELECT ID,PP_Account__c FROM PP_PartnerApplication__c LIMIT 1];
        System.assertNotEquals(null, application.PP_Account__c);
    }
}