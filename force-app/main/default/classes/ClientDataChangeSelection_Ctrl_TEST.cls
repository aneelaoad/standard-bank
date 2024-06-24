/**
 * Test class for ClientDataChangeSelection_Controller class
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
 */
@IsTest
public class ClientDataChangeSelection_Ctrl_TEST {

    static User testUser;
    static BLD_Account bldAccount;

    @IsTest
    static void isNoArchivedClients() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            List<String> fullName = Label.Archived_Clients.split(' ');
            testUser = (User) new BLD_USER(uow)
                    .firstName(fullName[0])
                    .lastName(fullName[1])
                    .userName('clientDataChangeUser@test.com')
                    .useCib()
                    .division('Transactional Products and Services')
                    .syncContact()
                    .getRecord();
            uow.commitWork();
        }

        Test.startTest();
        System.runAs(testUser) {
            bldAccount = new BLD_Account(uow)
                    .name('clientDataChange Account')
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .user(testUser.Id)
                            .role(DMN_ClientTeam.ROLE_ANALYST)
                            .coordinator(true));
            uow.commitWork();
        }
        Test.stopTest();

        System.assert(!ClientDataChangeSelection_Controller.checkArchivedOrPBBClients(bldAccount.getRecordId()));

    }
}