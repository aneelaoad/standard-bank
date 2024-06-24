/**
 * Test class for OSB_GenericError_CTRL
 * 
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date July 2020
 * 
 */
@IsTest
public class OSB_GenericError_CTRL_Test {
    
	@IsTest
    static void shouldGetApDpName() {
    	fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts selectorMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        
        Contact contactRecord = (Contact) new BLD_Contact()
                .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
                .mock();
                
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectByIdWoSharing((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Contact> {contactRecord});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(selectorMock);
        
        Test.startTest();
        String contactName = OSB_GenericError_CTRL.getApDpName(contactRecord.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, contactName);
    }

    @isTest(SeeAllData=true)
    static void shouldGetLogoutUrl() {
        String logoutUrl = OSB_GenericError_CTRL.getLogoutUrl();
        System.assertNotEquals(null, logoutUrl);
    }
}