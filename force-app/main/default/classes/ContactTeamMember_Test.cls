/*************************************************************************\
    @ Author        :     Jorel Naidoo
    @ Date          :     23/01/2013
    @ Description   :     Test Class for Contact Team Members Class and Trigger
    
    @ Last Modified By: Nitish Kumar
    @ Last Modified Date: 06/03/2013
    @ Description:  Implemented TestDataUtilityClass for generating Test Data
                    Changed the API Version to 27
                    
    @ Last Modified By  :   Nitish Kumar    
    @ Last Modified On  :   August,2013
    @ Description         :  Added Custom Setting Data
                                  Changed the API version to 28
**************************************************************************/
@IsTest
private class ContactTeamMember_Test {

    @IsTest
    static void testContactTeams() {

        //get Custom Setting Record
        insert TEST_DataFactory.getCcSettings();

        //create  users
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testAdminUser = (User) new BLD_USER(uow).useSysAdmin()
                .getRecord();

        User testStdUser = (User) new BLD_USER(uow).useCib()
                .getRecord();

        User testStdUser2 = (User) new BLD_USER(uow).useCib()
                .getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        //create client
        BLD_Account accBld = new BLD_Account(uow)
                .clientCoordinator(testAdminUser);

        BLD_Contact contactBld = new BLD_Contact(uow)
                .account(accBld)
                .ownerId(testAdminUser.Id)
                .addTeamMember(new BLD_ContactTeamMember(uow)
                        .user(testStdUser.Id)
                        .primaryContactPerson(true))
                .addTeamMember(new BLD_ContactTeamMember(uow)
                        .user(testStdUser2.Id)
                        .primaryContactPerson(false));

        ContactTriggerFuctions.isAutomatedUpdate = false ;

        try{
            uow.commitWork();
        }
        catch(Exception ex){}

        Contact testContactCreated = [SELECT Id, OwnerId FROM Contact WHERE Id =:contactBld.getRecordId() LIMIT 1];

        SA_Contact_Team_Member__c createdTeamMember = [SELECT Id, SA_User__c FROM SA_Contact_Team_Member__c WHERE SA_Contact__c =  :contactBld.getRecordId() AND Primary_Contact_Person__c = TRUE LIMIT 1];

        System.assertEquals(testContactCreated.OwnerId,createdTeamMember.SA_User__c);

        ContactTriggerFuctions.isAutomatedUpdate = false ;

        try{
            createdTeamMember.Primary_Contact_Person__c = false;
            update createdTeamMember;

            ContactTriggerFuctions.isAutomatedUpdate = false ;

            createdTeamMember.Primary_Contact_Person__c = true;
            update createdTeamMember;

            ContactTriggerFuctions.isAutomatedUpdate = false ;
        }
        catch(Exception ex){}

        try{
            delete createdTeamMember;
        }catch (DmlException e) {

            System.assert(e.getMessage().contains('You cannot Delete a Primary Contact Person, Please specify a new Primary Contact Person and try again'));

        }

    }

}