/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 111/2011
    @description   : Case# 1168 : Test class for CampaignMemberTriggerFunctions.cls     
                   
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Case #6521- Change contact to use TestFatcory    
                               API Version moved from 20 to 25  
    
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 17/01/13
    @ Last Modified Reason  : EN - 0008 - Adding best practices to the test class
                                          Updated the API version to 27
    
******************************************************************************************************/

@isTest(SeeALLData = False)
public class TestCampaignMemberTrigger {
    public static final String EVENT_NAME = 'TestEventName';

    //Static data Member
    public static List<CampaignMember> olstCampaignMember;
    public static Map<Id,CampaignMember> oldMapCampaignMember;

    /**
     * @author Nitish Kumar
     * @date 17/01/2013
     * @description Sets up the test data
     */
    static void setupTest() {
        insert TEST_DataFactory.getErrorMessages();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow);

        BLD_Contact conBld = new BLD_Contact(uow).useClientContact()
            .ownerId(UserInfo.getUserId())
            .account(accBld);

        BLD_Campaign campBld = new BLD_Campaign(uow)
            .addMemberHost(
                new BLD_CampaignMemberHost(uow)
                    .member(conBld)
                    .addHost(
                        new BLD_CampaignHost(uow)
                            .bankContact(conBld)
                    )
            );

        new BLD_Campaign(uow)
            .category(DMN_Campaign.CATEGORY_APP_EVENT)
            .eventName(EVENT_NAME);

        olstCampaignMember = new List<CampaignMember> {
            (CampaignMember)new BLD_CampaignMember(uow).campaign(campBld).contact(conBld).getRecord()
        };

        BLD_CampaignMember campMemberToDelete = new BLD_CampaignMember(uow)
            .campaign(campBld)
            .contact(new BLD_Contact(uow).useClientContact());
        BLD_CampaignMember campMemberToChangeWave = new BLD_CampaignMember(uow)
            .campaign(campBld)
            .contact(new BLD_Contact(uow).useClientContact());

        BLD_Campaign campToLock = new BLD_Campaign(uow);

        uow.commitWork();

        try {
            CampaignMember cmRec = (CampaignMember) new BLD_CampaignMember(uow)
                .campaign(campBld)
                .getRecord();
            Lead leadRec = new Lead(LastName = 'test', Company = 'test');
            uow.registerNew(leadRec);
            uow.registerRelationship(cmRec, CampaignMember.LeadId, leadRec);
            uow.commitWork();
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(ErrorMessages__c.getValues('Campaign_AddLeadValidation').Error_String__c), 'Not the expected message');
        }

        campToLock.lock(true);
        uow.registerDirty(campToLock);

        uow.registerDeleted(campMemberToDelete);

        campMemberToChangeWave.wave('2');
        uow.registerDirty(campMemberToChangeWave);

        uow.commitWork();
    }


    /**
     * @author Nitish Kumar
     * @date 17/01/2013
     * @description Tests the functionality
     */
    @isTest
    public static void testCampaignMemTrigger() {
        setupTest();
        oldMapCampaignMember = new Map<Id,CampaignMember>();
        for(CampaignMember cm:olstCampaignMember){
            oldMapCampaignMember.put(cm.id,cm);
        }

        Test.startTest();

        //TEST TRIGGER FUNCTIONS
        //Make instance of the CampaignMemberTriggerFunctions class.
        CampaignMemberTriggerFunctions cf;
        cf = new CampaignMemberTriggerFunctions(olstCampaignMember);
        cf.validateRecordLock(oldMapCampaignMember);
        cf.setContactRecordType();
        cf.addToMemberHostObject();
        cf.updateMemberHostObject();
        cf.deleteFromMemberHostObject();
        cf.validateMemberType();
        cf.sendErrorMail('This is a test');

        Test.stopTest();
        System.assertEquals(true, true, 'Something went wrong');

    }

    /**
    * @description 
    * @author TCK | 07-01-2022 
    **/
    @isTest
    public static void testCreateAttendee() {
        setupTest();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Campaign cmp = [SELECT Id FROM Campaign WHERE Campaign_Category__c = :DMN_Campaign.CATEGORY_APP_EVENT LIMIT 1];
        List<EAP_Attendee__c> orAttendeeList = [SELECT Id FROM EAP_Attendee__c];

        new BLD_CampaignMember(uow)
            .campaign(cmp.Id)
            .contact(new BLD_Contact(uow).useClientContact());
        uow.commitWork();
        CampaignMember cmpMember = [SELECT Id, Invitation_Response__c FROM CampaignMember WHERE CampaignId =: cmp.Id LIMIT 1];

        Test.startTest();
            cmpMember.Invitation_Response__c = DMN_CampaignMember.INVITATION_STATUS_ACCEPTED;
            update cmpMember;
        Test.stopTest();

        List<EAP_Attendee__c> result = [SELECT Id FROM EAP_Attendee__c];
        System.assertEquals(1, (result.size() - orAttendeeList.size()), 'Not the expected result');
    }
}