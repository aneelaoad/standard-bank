/**
* @description  : Test Class for Partner Portal Tracker Controller
* User Story : SFP-4873
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date Aug 2021
*/
@IsTest(IsParallel=true)
public class PP_TrackerMenu_CTRL_TEST {

    @IsTest
    static void getOnboardingTasksTest(){
            fflib_ApexMocks mocks = new fflib_ApexMocks();
            SEL_Contacts contactMock = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
            Contact con = (Contact) new BLD_Contact().mock(); 
       
            SEL_PartnerApplication partnerMock = (SEL_PartnerApplication) mocks.mock(SEL_PartnerApplication.class);
            PP_PartnerApplication__c partner = (PP_PartnerApplication__c) new BLD_PartnerApplication()
                .setPartnerData()
                .setPrimaryContact(con.Id)
                .mock();
       	   
           SEL_Tasks taskMock = (SEL_Tasks) mocks.mock(SEL_Tasks.class);
           Task task = (Task) new BLD_Task()
                .subject('Test')
                .recordTypeId(UTL_RecordType.getRecordTypeId('Task', 'PP_OnboardingStep'))
                .phase('Registration')
                .step('Submit Application')
                .whatId(partner.Id)
 				.mock();
        
            mocks.startStubbing();
            mocks.when(contactMock.sObjectType()).thenReturn(Contact.SObjectType);
        	mocks.when(contactMock.selectByUserId((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact> {con});
            mocks.when(partnerMock.sObjectType()).thenReturn(PP_PartnerApplication__c.SObjectType);
            mocks.when(partnerMock.selectByPrimaryContactId((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<PP_PartnerApplication__c> {partner});
        
           mocks.when(taskMock).thenReturn(Task);
           mocks.when(taskMock.selectByWhatIdsAndRecordTypeIdWithoutSharing((Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyString()))
                .thenReturn(new List<Task> {task});
        
           mocks.stopStubbing();
           
           ORG_Application.selector.setMock(contactMock);
           ORG_Application.selector.setMock(partnerMock);
           ORG_Application.selector.setMock(taskMock);
        
			Test.startTest();
            Map<String, Task> result = PP_TrackerMenu_CTRL.getOnboardingTasks(con.Id);
            PP_TrackerMenu_CTRL.getRelatedFiles(partner.Id);
            System.AssertNotEquals(result,null);
            Test.stopTest();
        
    }
}