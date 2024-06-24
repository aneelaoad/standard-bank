/**
* @description  : Test Class for Partner Portal Support Controller
* User Story : SFP-5296
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
@IsTest(IsParallel=true)
public class PP_Support_CTRL_TEST {

    @IsTest
    static void createCase() {
        Account acct = new Account(Name='Test1');
		insert Acct;
        Entitlement defaultEntRec = new Entitlement(
            name = 'FR240mins : Mon - Fri (8h00 - 17h00)',
            AccountId = Acct.Id
        );

        insert defaultEntRec;
        Case c = (Case) new BLD_Case().setPPData().getRecord();

        Test.startTest();
        PP_Support_CTRL.createCase(c);
        Test.stopTest();
        Case createdCase = [SELECT Id,SuppliedEmail FROM Case LIMIT 1];
        System.assertEquals(BLD_Case.EMAIL, createdCase.SuppliedEmail);
    }
    
    @IsTest
    static void getPartnerOwnerTest() {
            fflib_ApexMocks mocks = new fflib_ApexMocks();
            SEL_Contacts contactMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
            Contact con = (Contact) new BLD_Contact().mock(); 
       
            SEL_PartnerApplication partnerMock = (SEL_PartnerApplication) mocks.mock(SEL_PartnerApplication.class);
            PP_PartnerApplication__c partner = (PP_PartnerApplication__c) new BLD_PartnerApplication()
                .setPartnerData()
                .setPrimaryContact(con.Id)
                .mock();
        
            mocks.startStubbing();
            mocks.when(contactMock.sObjectType()).thenReturn(Contact.SObjectType);
        	mocks.when(contactMock.selectByUserId((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact> {con});
            mocks.when(partnerMock.sObjectType()).thenReturn(PP_PartnerApplication__c.SObjectType);
            mocks.when(partnerMock.selectByPrimaryContactId((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<PP_PartnerApplication__c> {partner});
            mocks.stopStubbing();
           
           ORG_Application.selector.setMock(contactMock);
           ORG_Application.selector.setMock(partnerMock);
        
			Test.startTest();
           User result = PP_Support_CTRL.getParnerRecordOnwer(con.Id);
            Test.stopTest();
           System.AssertNotEquals(result,null);
    }
    
}