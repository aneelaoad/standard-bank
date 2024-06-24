/**
 * Test class for OSB_SRV_EmailSender
 *
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date May 2020
 *
 **/
@IsTest(IsParallel=true)
public class OSB_SendEmailPage_CTRL_Test {

    @TestSetup
    static void setup() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
    }
	
    @IsTest
    static void shouldSendEmailApEmailInvite(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        OSB_SRV_EmailSender emailSenderMock = (OSB_SRV_EmailSender) mocks.mock(OSB_SRV_EmailSender.class);

        Contact accessManager = (Contact) new BLD_Contact()
            .setOSBDefaultData(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED)
            .mock();
        
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectById(new Set<Id> {accessManager.Id})).thenReturn(new List<Contact> {accessManager});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);
        ORG_Application.service.setMock(OSB_SRV_EmailSender.IService.class, emailSenderMock);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(accessManager);
        OSB_SendEmailPage_CTRL osbSendEmailPageCtrl = new OSB_SendEmailPage_CTRL(controller);
        
        Test.startTest();
        PageReference result = osbSendEmailPageCtrl.sendApEmailInvite();
        Test.stopTest();
        
		System.assertNotEquals(result,null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
        ((OSB_SRV_EmailSender) mocks.verify(emailSenderMock, 1)).sendApInviteEmail(new List<Contact>{accessManager}, uowMock);
    }
}