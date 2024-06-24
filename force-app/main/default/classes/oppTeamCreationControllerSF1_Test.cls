/*************************************************************************************************
Class Name          : oppTeamCreationControllerSF1_Test
Version             : 1.0
Date Created        : Jan 15
Function            : This class is the test class for oppTeamCreationController    
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer                Date                    Description
* ---------------        -----------             ----------------------------------------------
 Prabhanshu Agrawal       Jan 15               Initial version of the class.
**************************************************************************************************/
@SuppressWarnings('PMD.ClassNamingConventions')
@IsTest
private class oppTeamCreationControllerSF1_Test {

    @IsTest
    static void testController() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }
    
        BLD_Opportunity oppBld = new BLD_Opportunity(uow)
            .client(
                new BLD_Account(uow).useChild()
            );
        OpportunityTeamMember otmRec = (OpportunityTeamMember) new BLD_OpportunityTeamMember(uow)
            .opportunity(oppBld)
            .userId(testUser.Id)
            .role('Product Specialist')
            .getRecord();

        uow.commitWork();

        try {
            ApexPages.StandardController controller = new ApexPages.StandardController((Opportunity) oppBld.getRecord());
            oppTeamCreationControllerSF1 opt = new oppTeamCreationControllerSF1(controller);

            oppTeamCreationControllerSF1.TeamMember tm = new oppTeamCreationControllerSF1.TeamMember();
            tm.oppId = oppBld.getRecordId();

            String oppAccess = 'Read';
            oppTeamCreationControllerSF1.oppShare(oppAccess, otmRec);

            oppAccess = 'Edit';
            oppTeamCreationControllerSF1.oppShare(oppAccess, otmRec);

            oppTeamCreationControllerSF1.save(tm);
            oppTeamCreationControllerSF1.getUserList(testUser.Name);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
}