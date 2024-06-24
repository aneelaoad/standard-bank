/**
 * Functional Area: Consent Management
 * Usage: Contact flow to handle consent management events
 * @author Atul Sharma
 * @date 2023-8-20
 */
@isTest
private class ConsentMgmtCampaignMemberHandlerTest {
    @TestSetup
    private static void createTestData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        DataUsePurpose dup= new DataUsePurpose();
        dup.Name = 'Direct Marketing';
        dup.IsActive =false;
        insert dup;
        
        BusinessBrand b = new BusinessBrand(Name='CIB');
        insert b;	
        
        Account ac1 = new Account();
        ac1.Name ='First Account';
        Account ac2 = new Account();
        ac2.Name ='Second Account';
        
		Contact c1 = new Contact();
        c1.LastName = 'l1';
        c1.FirstName = 'F1';
        c1.Email = 'a1@test.com';  
        c1.HasOptedOutOfEmail = false;
        
        Contact c2 = new Contact();
        c2.LastName = 'l1';
        c2.FirstName = 'F2';
        c2.Email = 'a2@test.com';
        c2.HasOptedOutOfEmail = false;      
        
        Contact c3 = new Contact();
        c3.LastName = 'Out';
        c3.FirstName = 'Opted';
        c3.Email = 'a3@test.com';
        c3.HasOptedOutOfEmail = true;
        
        uow.registerNew(ac1);
        uow.registerNew(ac2);
		uow.registerNew(c1, Contact.AccountId, ac1);
        uow.registerNew(c2, Contact.AccountId, ac1);
        uow.registerNew(c3, Contact.AccountId, ac2);
               
        uow.commitWork();
        
        Contact[] cons = [select Id from Contact WHERE Id=:c3.Id and IndividualId=null ];
        
        if(cons.size()>0){
            Individual i1 = new Individual();
            i1.FirstName  = c3.FirstName;
            i1.LastName   = c3.LastName;                  
            
            uow.registerNew(i1);        
            uow.commitWork();
            
            c3.IndividualId = i1.Id;            
            uow.registerDirty(c3);               
            
            ContactPointTypeConsent cpt1 = new ContactPointTypeConsent();
            cpt1.Name 					 = 'Email - Direct Marketing';
            cpt1.PrivacyConsentStatus	 = 'OptIn';
            cpt1.EffectiveFrom 			 = date.today();
            cpt1.CaptureDate   			 = date.today();
            cpt1.DataUsePurposeId 		 = dup.Id;
            cpt1.PartyId				 = i1.Id;
            cpt1.CaptureContactPointType = 'Web';
            cpt1.ContactPointType		 = 'Email';
            cpt1.AccountId__c 			 = c3.AccountId;
            cpt1.CaptureSource 			 = 'Salesforce UI';
            
            uow.registerNew(cpt1);        
            uow.commitWork();
        }
        
        Campaign campaing = new Campaign();
        campaing.Name = 'Test cmp';
        campaing.isActive = true;
        campaing.Campaign_Category__c = DMN_Campaign.CATEGORY_GROUP_EVENT;
        campaing.Type = 'Direct Marketing';
        uow.registerNew(campaing);        
        uow.commitWork();		//insert all
        
        new BLD_CampaignMember(UOW)
            .campaign(String.valueOf(campaing.Id))
            .contact(String.valueOf(c1.Id))
            .invitationResponseAccepted();
        
        new BLD_CampaignMember(UOW)
            .campaign(String.valueOf(campaing.Id))
            .contact(String.valueOf(c2.Id))
            .invitationResponseAccepted();
        
        uow.commitWork();
    }
    
    @isTest
    static void enforceConsentTest() {
        List<CampaignMember> members = [SELECT Id FROM CampaignMember];
        Integer intialMembersAmount = members.size();
        Test.startTest();
        ConsentMgmtCampaignMemberHandler.enforceConsent(members);
        Test.stopTest();        
    }
}