/**
 * Functional Area: Consent Management
 * Usage: Contact flow to handle consent management events
 * @author Atul Sharma
 * @date 2023-8-20
 */
@isTest
public class ConsentMgmtContactHandlerTest {
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
        c3.LastName = 'l3';
        c3.FirstName = 'F3';
        c3.Email = 'a3@test.com';
        c2.HasOptedOutOfEmail = false;             
        
        uow.registerNew(ac1);
        uow.registerNew(ac2);
		uow.registerNew(c1, Contact.AccountId, ac1);
        uow.registerNew(c2, Contact.AccountId, ac1);
        uow.registerNew(c3, Contact.AccountId, ac2);
               
        uow.commitWork();
        
        Individual i1 = new Individual();
        i1.FirstName  = c2.FirstName;
        i1.LastName   = c2.LastName;
        
        Individual i2 = new Individual();
        i2.FirstName  = c3.FirstName;
        i2.LastName   = c3.LastName;        
        
        uow.registerNew(i1);
        uow.registerNew(i2); 
        
        uow.commitWork();
        
        c2.IndividualId = i1.Id;
        c3.IndividualId = i2.Id;
            
        uow.registerDirty(c2);
        uow.registerDirty(c3);               
        
        ContactPointTypeConsent cpt1 = new ContactPointTypeConsent();
        cpt1.Name 					 = 'Email - Direct Marketing';
        cpt1.PrivacyConsentStatus	 = 'OptIn';
        cpt1.EffectiveFrom 			 = date.today();
        cpt1.CaptureDate   			 = date.today();
        cpt1.DataUsePurposeId 		 = dup.Id;
        cpt1.PartyId				 = i2.Id;
        cpt1.CaptureContactPointType = 'Web';
        cpt1.ContactPointType		 = 'Email';
        cpt1.AccountId__c 			 = c3.AccountId;
        cpt1.CaptureSource 			 = 'Salesforce UI';
        
        uow.registerNew(cpt1);        
        uow.commitWork();        
    }
    
    @isTest
    static void enforceConsentTest() {        
        contact[] cons =  [select id,HasOptedOutOfEmail from contact limit 10];        
        Test.startTest();        
        ConsentMgmtContactHandler.manageConsent(cons);
        Test.stopTest();        
    }
}