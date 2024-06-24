/*****************************************************************************************************\
 @Class Name   : Test_UserAnsContactRoleUpdateBatch
 @description  : Test class for the UserAnsContactRoleUpdateBatch class
 @Created By   : Vishnu Teja V
  @Created On   : 27 March 2015
  @Modification Log:
  --------------------------------------------------------------------------------------------------
  @Developer                Date                   Description
  --------------------------------------------------------------------------------------------------
  @Vishnu Teja V         27 March 2015               Created
  ---------------------------------------------------------------------------------------------------

    @ Last Modified By      :   Prabhanshu Agrawal        
    @ Last Modified On      :   Apr 2015
    @ Last Modified Reason  :   EN-662, Added Meeting audience and Meeting type in the test data for validation rule 
    
    @ Last Modified By      :   Abhishek V        
    @ Last Modified On      :   Nov 2016
    @ Last Modified Reason  :   101 SOQL error fix by adjusting starttest() and stoptest()      

****************************************************************************/
@IsTest
public class Test_UserAnsContactRoleUpdateBatch {

    @TestSetup
    static void generateData() {

        List<SObject> settings = new List<SObject> {TEST_DataFactory.getEnvironmentVariable()};
        settings.addAll((List<SObject>) TEST_DataFactory.getUserProfileIds());
        settings.addAll((List<SObject>) TEST_DataFactory.getErrorMessages());
        settings.addAll((List<SObject>) TEST_DataFactory.getCcSettings());
        settings.addAll((List<SObject>) TEST_DataFactory.getCstTeamRankings());
        insert settings;
    }

    @IsTest
    static void testBatch() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUser2 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUser3 = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        BLD_Account accBld1 = new BLD_Account(uow).useChild()
            .proposedClientCoordinator(testUser2)
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(testUser3.Id)
                    .role(DMN_ClientTeam.ROLE_CLIENT_ANALYST)
            );
        BLD_Account accBld2 = new BLD_Account(uow).useChild()
            .proposedClientCoordinator(testUser2);

        Custom_Client_Team__c cctRec = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(accBld1)
            .user(testUser2.Id)
            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
            .getRecord();

        BLD_Contact conBld = new BLD_Contact(uow).useClientContact()
            .account(accBld1);
        Contact conRec = (Contact) conBld.getRecord();

        BLD_CallReport crBld = new BLD_CallReport(uow)
            .internal()
            .meetingPurpose(DMN_CallReport.DAY_TO_DAY_MEETING)
            .endDate(System.now().addDays(1))
            .linkWithParent(accBld1)
            .assign(testUser3.Id);
        Call_Report__c crRec = (Call_Report__c) crBld.getRecord();

        new BLD_CallReport(uow)
            .internal()
            .meetingPurpose(DMN_CallReport.DAY_TO_DAY_MEETING)
            .endDate(System.now().addDays(1))
            .linkWithParent(accBld1)
            .assign(testUser3.Id);

        uow.commitWork();

        system.Test.startTest();
        try {
            new BLD_CallReportAttendee(uow)
                    .callReport(crBld)
                    .contact(conBld)
                    .status(DMN_CallReportAttendee.STATUS_INVITED)
                    .commitWork();

            conRec.Contact_Category__c = DMN_Contact.CATEGORY_MANAGER;
            update conRec;

            crRec.Relate_to_Client__c = accBld2.getRecordId();
            update crRec;
            cctRec.Team_Member__c = testUser.Id;
            cctRec.Client_Role__c = DMN_ClientTeam.ROLE_ANALYST;
            update cctRec;

            UserAndContactRoleUpdateBatch b = new UserAndContactRoleUpdateBatch();
            Database.executeBatch(b);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }
}